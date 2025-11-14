import numpy as np
import cv2
import matplotlib.pyplot as plt
import argparse
import skimage as ski
from typing import Union


def read_image(name: str, gray: bool = False) -> np.ndarray:
    img = ski.io.imread(name)
    # Case RGB images
    if len(img.shape) == 3 and gray:
        img = ski.color.rgb2gray(img)
    # Convert image to int array in range 0, 255
    img = ski.util.img_as_ubyte(img)
    return img


def binary_image(name: str) -> np.ndarray:
    img = read_image(name, gray=True)
    img[img < 128] = 0
    img[img >= 128] = 1
    return img


def lsb_extraction(img: np.ndarray, level: int = 0) -> np.ndarray:
    assert level <= 7 and level >= 0, (
        f"level must be between 0 and 7 ! current: {level}"
    )
    # Extract the specific bit at given level (0 = LSB, 7 = MSB)
    return (img >> level) & 1


def extract_channel(img: np.ndarray, channel: int = 2) -> np.ndarray:
    if len(img.shape) == 3:
        return img[:, :, channel].copy()
    else:
        return img.copy()


def insert_channel(
    img: np.ndarray, insertion: np.ndarray, channel: int = 2
) -> np.ndarray:
    result = img.copy()
    if len(img.shape) == 3:
        result[:, :, channel] = insertion
        return result
    else:
        return insertion


def hide_message(
    img: np.ndarray,
    msg: Union[str, np.ndarray],
    key: int = 21,
    level: int = 0,
    channel: int = 2,
) -> np.ndarray:
    # Create random number generator with given key
    rng = np.random.default_rng(seed=key)
    img_channel = extract_channel(img, channel)
    rows, cols = img_channel.shape
    layer = lsb_extraction(img_channel, level)
    result = img_channel - (layer << level)  # Remove the bit we're going to replace
    layer_flat = layer.ravel()

    if isinstance(msg, np.ndarray):
        msg_bits = (msg.ravel() > 0).astype(int)
    else:
        msg_bits = np.array(
            list("".join(format(b, "08b") for b in msg.encode("utf-8")))
        ).astype(int)

    positions = rng.choice(
        np.arange(layer_flat.shape[0]), size=msg_bits.shape[0], replace=False
    )
    layer_flat[positions] = msg_bits
    result += layer_flat.reshape(rows, cols) << level

    return insert_channel(img, result, channel)


def hide_image(
    img: np.ndarray, msg: np.ndarray, key: int = 21, quantization: int = 4
) -> np.ndarray:
    assert len(img.shape) == 3, "Must work with rgb image !"
    assert quantization <= 8 and quantization >= 1, (
        "Quantization represent number of MSB kept. It must be between 1 and 8 !"
    )
    key_incrementer = 3984
    M, N, _ = img.shape
    m, n = msg.shape
    nb_insert = (M * N) // (m * n)
    nb_insert = max(1, nb_insert // 3)
    current_key = key
    msg_bit_index = 0  # Track which bit plane of message we're using
    result = img.copy()

    print(f"Hiding image with quantization={quantization}")
    print(f"Message shape: {msg.shape}")
    print(f"Number of insertions per bit plane: {nb_insert}")

    # Go through cover image bit planes (LSB to MSB) and embed message MSB to LSB
    for img_level in range(8):
        for img_channel in range(3):  # RGB channels
            if msg_bit_index >= quantization:
                print(f"Image hidden using {msg_bit_index} MSB planes of message!")
                return result

            # Extract the current MSB bit plane from message (7 = MSB, 6 = next MSB, etc.)
            msg_bit_plane = np.array([])

            # For each insertion, use the same bit plane (this might be the issue)
            for _ in range(nb_insert):
                if msg_bit_index >= quantization:
                    break
                # Extract the (7 - msg_bit_index) bit plane from message
                bit_plane = lsb_extraction(msg, 7 - msg_bit_index)
                msg_bit_plane = np.concatenate([msg_bit_plane, bit_plane.ravel()])
                print(
                    f"  Embedding message bit plane {7 - msg_bit_index} into cover bit plane {img_level}, channel {img_channel}"
                )
                msg_bit_index += 1

            # Hide this bit plane in the cover image
            result = hide_message(
                result,
                msg_bit_plane,
                level=img_level,
                channel=img_channel,
                key=current_key,
            )

            current_key += key_incrementer

    return result


def get_image(
    img: np.ndarray, size: np.ndarray, key: int = 21, quantization: int = 4
) -> np.ndarray:
    assert len(img.shape) == 3, "Must work with rgb image !"
    assert quantization <= 8 and quantization >= 1, (
        "Quantization represent number of MSB kept. It must be between 1 and 8 !"
    )
    M, N, _ = img.shape
    m, n = size
    nb_insert = (M * N) // (m * n)
    nb_insert = max(1, nb_insert // 3)
    key_incrementer = 3984
    current_key = key
    msg_bit_index = 0

    # Initialize result with zeros
    result = np.zeros((m, n), dtype=np.uint8)

    print(f"Extracting image with quantization={quantization}")
    print(f"Expected size: {size}")

    # Reconstruct the image by extracting bits in the same order
    for img_level in range(8):  # 0-7 (LSB to MSB of cover image)
        for img_channel in range(3):  # RGB channels
            if msg_bit_index >= quantization:
                return result

            # Extract the bit plane
            extracted_bits = get_message(
                img,
                size=np.array(
                    [1, n * m * min(nb_insert, quantization - msg_bit_index)]
                ),
                level=img_level,
                channel=img_channel,
                key=current_key,
            )[0]

            # Reconstruct message bits in the correct order
            for k in range(nb_insert):
                if msg_bit_index >= quantization:
                    break
                bit_weight = (
                    7 - msg_bit_index
                )
                start_idx = k * m * n
                end_idx = (k + 1) * m * n
                msg_segment = (extracted_bits[start_idx:end_idx] > 0).astype(np.uint8)
                result = result + (msg_segment.reshape(m, n) << bit_weight)
                print(
                    f"  Extracted cover bit plane {img_level}, channel {img_channel} -> message bit plane {7 - msg_bit_index}"
                )

                msg_bit_index += 1
            current_key += key_incrementer

    return result


def get_message(
    img: np.ndarray,
    key: int = 21,
    size: Union[np.ndarray, int] = 100,
    level: int = 0,
    channel: int = 2,
) -> np.ndarray:
    if isinstance(size, int):
        length = size * 8
    else:
        length = size[0] * size[1]

    # Use the same seed as used in hiding, else no message can be retrieved
    rng = np.random.default_rng(seed=key)
    img_channel = extract_channel(img, channel)
    layer = lsb_extraction(img_channel, level).ravel()
    positions = rng.choice(np.arange(layer.shape[0]), size=length, replace=False)
    msg_bits = layer[positions]

    if isinstance(size, np.ndarray):
        # Return as image
        msg_bits = msg_bits.reshape(size[0], size[1])
        return msg_bits
    return msg_bits


def bits2str(msg: np.ndarray) -> str:
    msg_bits = "".join(str(i) for i in msg)
    return (
        int(msg_bits, 2)
        .to_bytes(len(msg_bits) // 8, "big")
        .decode("utf-8", errors="ignore")
    )


def bit_plane_visualization(img: np.ndarray, title: str = "Bit-planes of the image"):
    plt.figure()
    plt.suptitle(title)
    for i in range(8):
        plt.subplot(2, 4, i + 1)
        plt.imshow(lsb_extraction(img, i), cmap="gray")
        plt.axis("off")
        plt.title(f"Level {i}")
    plt.show()


def pixel_wise(img1: np.ndarray, img2: np.ndarray, title: str):
    diff = ski.util.img_as_ubyte(ski.util.compare_images(img1, img2, method="diff"))
    plt.figure()
    colorbar = plt.imshow(diff, cmap="gray", vmin=0, vmax=np.max(diff))
    plt.axis("off")
    plt.colorbar(colorbar)
    plt.title(title)
    plt.show()


def add_noise(img: np.ndarray, mean: float = 0.0, std: float = 1.0) -> np.ndarray:
    noise = np.random.normal(loc=mean, scale=std, size=img.shape)
    img_noised = img.astype(np.float32) + noise
    return np.clip(img_noised, a_min=0, a_max=255).astype(np.uint8)


def jpeg_compress(img: np.ndarray, quality: int = 90) -> np.ndarray:
    params = [cv2.IMWRITE_JPEG_QUALITY, quality]
    success, encoded_img = cv2.imencode(".jpg", img, params)

    if not success:
        print("Error when encoding")

    compressed_img = cv2.imdecode(encoded_img, cv2.IMREAD_UNCHANGED)
    return compressed_img


def print_metrics(img_1: np.ndarray, img_2: np.ndarray):
    print("-------------------------------------------------------------")
    print(f"MSE: {ski.metrics.mean_squared_error(img_1, img_2)}")
    print(f"PSNR: {ski.metrics.peak_signal_noise_ratio(img_1, img_2)}")
    if len(img_1.shape) == 3:
        print(f"SSIM: {ski.metrics.structural_similarity(img_1, img_2, channel_axis=2)}")
        print_image(ski.color.deltaE_cie76(img_1, img_2, channel_axis=2), title="Overall color difference")
    else:
        print(f"SSIM: {ski.metrics.structural_similarity(img_1, img_2)}")
    print("-------------------------------------------------------------")


def print_channel(img_1: np.ndarray, img_2: np.ndarray, title: str):
    print_metrics(img_1, img_2)
    hist_1, hist_1_centers = ski.exposure.histogram(img_1)
    cdf_1, cdf_1_centers = ski.exposure.cumulative_distribution(img_1)

    hist_2, hist_2_centers = ski.exposure.histogram(img_2)
    cdf_2, cdf_2_centers = ski.exposure.cumulative_distribution(img_2)

    plt.figure()
    plt.plot(hist_2_centers, hist_2, label="Image with secret")
    plt.plot(hist_1_centers, hist_1, label="Original image")
    plt.legend()
    plt.title(title)
    plt.show()


def print_quality(img_1: np.ndarray, img_2: np.ndarray):
    print("-------------------------------------------------------------")
    print("Image comparison between original image and image with secret")
    print("-------------------------------------------------------------")
    if len(img_1.shape) != 3:
        print_channel(img_1, img_2, title="Histogram comparison for grayscale image")
        pixel_wise(img_1, img_2, title="Pixel-wise difference for grayscale image")
    else:
        channel = ["R", "G", "B"]
        print("-------------------- OVERALL COMPARISON ---------------------")
        print_metrics(img_1, img_2)
        for i in range(img_1.shape[2]):
            print(
                f"------------------------ CHANNEL {channel[i]} --------------------------"
            )
            print_channel(
                img_1[:, :, i],
                img_2[:, :, i],
                title=f"Histogram comparison for {channel[i]} channel",
            )
            pixel_wise(
                img_1[:, :, i],
                img_2[:, :, i],
                title=f"Pixel-wise difference for {channel[i]} channel",
            )


def robustness(
    img: np.ndarray,
    size: Union[np.ndarray, int],
    key: int = 21,
    top: int = 0,
    bottom: int = 1000,
    left: int = 0,
    right: int = 1000,
):
    if len(img.shape) == 3:
        crop = ski.util.crop(img, ((top, bottom), (left, right), (0, 0)))
        noised = img.copy()
        for i in range(img.shape[2]):
            noised[:, :, i] = ski.util.img_as_ubyte(
                ski.util.random_noise(noised[:, :, i], mode="gaussian", clip=True)
            )
    else:
        crop = ski.util.crop(img, ((top, bottom), (left, right)))
        noised = ski.util.img_as_ubyte(
            ski.util.random_noise(img, mode="gaussian", clip=True)
        )
    compress = jpeg_compress(img, quality=98)
    crop_secret = get_message(crop, size=size, key=key)
    compress_secret = get_message(compress, size=size, key=key)
    noised_secret = get_message(noised, size=size, key=key)
    print_image(crop_secret, title="Hidden image retrieved from cropped image")
    print_image(compress_secret, title="Hidden image retrieved from compressed image")
    print_image(noised_secret, title="Hidden image retrieved from noised image")


def print_range(img: np.ndarray):
    print(f"dtype:  {img.dtype}")
    print(f"shape:  {img.shape}")
    print(f"min:    {img.min()}")
    print(f"max:    {img.max()}")
    print(f"range:  {img.max() - img.min()}")


def print_image(img: np.ndarray, title: str = "Image"):
    plt.figure()
    plt.title(title)
    plt.imshow(img, cmap="gray")
    plt.axis("off")
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Steganography")
    parser.add_argument("-i", "--image", help="Path to base image")
    parser.add_argument(
        "-b",
        "--bit_plane",
        action="store_true",
        help="Display each bit-plane of the image",
    )
    parser.add_argument("-m", "--message", help="Message to hide")
    parser.add_argument("-mi", "--message_image", help="Image to hide")
    parser.add_argument(
        "-msb",
        "--msb_number",
        help="Store the x MSB of grayscale image into LSB of the RGB base image",
    )
    parser.add_argument("-g", "--grayscale", action="store_true", help="Convert base image to grayscale")
    parser.add_argument("-k", "--key", default="16", help="Key used to hide message in pseudo-random positions")
    args = parser.parse_args()

    if args.bit_plane:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        img = read_image(args.image, gray=True)
        bit_plane_visualization(img)
    if args.message:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        key = int(args.key)
        if args.grayscale:
            img = read_image(args.image, gray=True)
        else:
            img = read_image(args.image)
        img_msg = hide_message(img, msg=args.message, level=7, key=key)
        print_image(img, title="Original image")
        print_image(img_msg, title="Image with hidden message")
        msg = get_message(img_msg, size=len(args.message), key=key, level=7)
        print(f"Recovered message: {bits2str(msg)}")
        print_quality(img, img_msg)
    if args.message_image:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        key = int(args.key)
        if args.grayscale:
            img = read_image(args.image, gray=True)
        else:
            img = read_image(args.image)
        if args.msb_number:
            secret_img = read_image(args.message_image, gray=True)

            # Hide the image
            img_msg = hide_image(img, secret_img, key=key, quantization=int(args.msb_number))

            # Extract the image
            secret = get_image(
                img_msg, np.array(secret_img.shape), key=key, quantization=int(args.msb_number)
            )
        else:
            secret_img = binary_image(args.message_image)
            img_msg = hide_message(img, msg=secret_img, key=key)
            secret = get_message(img_msg, size=np.array(secret_img.shape), key=key)
        print_image(img, title="Original image")
        print_image(img_msg, title="Image with hidden message")
        print_image(secret, title="Hidden image")
        print_quality(img, img_msg)
        robustness(img_msg, np.array(secret_img.shape), key=key)
