import numpy as np
import matplotlib.pyplot as plt
import argparse
import os
from scipy.linalg import norm
from skimage import io, color, util, restoration
from scipy import signal
from typing import Callable, clear_overloads


def read_image(name: str, path: str = "../images") -> np.ndarray:
    img = io.imread(path + "/" + name)
    img = color.rgb2gray(img)
    img = util.img_as_float(img)
    print_range(img)
    return img


def read_directory(path: str) -> list[np.ndarray]:
    images = [
        read_image(img, path)
        for img in os.listdir(path)
        if os.path.isfile(os.path.join(path, img))
    ]
    image_shapes = np.array([img.shape for img in images])
    min_shape = (np.min(image_shapes[:, 0]), np.min(image_shapes[:, 1]))
    return [img[: min_shape[0], : min_shape[1]] for img in images if is_good(img)]


def is_good(img: np.ndarray, max_mean: float = 0.8, max_var: float = 0.2) -> bool:
    return bool(np.mean(img) < max_mean and np.var(img) < max_var)


def normalize(img: np.ndarray, target: float = 1.0) -> np.ndarray:
    return (img - img.min()) * target / (img.max() - img.min())


def contribution(x: np.ndarray, filter: Callable[..., np.ndarray]) -> np.ndarray:
    # Used to normalize the division
    epsilon = 1e-8
    return ((x - filter(x)) * x) / (x**2 + epsilon)


def PRNU(
    path: str,
    filter: Callable[..., np.ndarray],
    savedir: str = ".",
    model: str = "model",
) -> np.ndarray:
    images = read_directory(path)
    assert len(images) >= 15, (
        f"You must provide more images ! Actually good images: {len(images)}"
    )
    contributions = [contribution(img, filter) for img in images]
    fingerprint = normalize(np.sum(contributions, axis=0))
    print_range(fingerprint)
    io.imsave(
        os.path.join(savedir, model + "_fingerprint.png"),
        util.img_as_ubyte(fingerprint),
    )
    return fingerprint


def PCE(
    img: np.ndarray,
    prnu: np.ndarray,
    filter: Callable[..., np.ndarray],
    windows_size: int = 10,
) -> float:
    # Crop images to have same size
    cropped_shape = (
        np.min([img.shape[0], prnu.shape[0]]),
        np.min([img.shape[1], prnu.shape[1]]),
    )
    cropped_img = normalize(img[: cropped_shape[0], : cropped_shape[1]])
    cropped_prnu = normalize(prnu[: cropped_shape[0], : cropped_shape[1]])

    # Compute prnu from given image
    prnu_img = contribution(cropped_img, filter)

    print("Before correlation")
    # Compare to the given prnu
    correlation = signal.correlate2d(cropped_prnu, prnu_img)
    print("After correlation")

    # Take coordinates of peak, and value of peak
    peak = np.unravel_index(np.argmax(np.abs(correlation)), correlation.shape)
    peak_value = correlation[peak[0], peak[1]]

    # Compute small windows around peak
    half = windows_size // 2
    x_min = max(0, peak[0] - half)
    x_max = min(correlation.shape[0], peak[0] + half + 1)
    y_min = max(0, peak[1] - half)
    y_max = min(correlation.shape[1], peak[1] + half + 1)
    mask = np.ones_like(correlation)
    mask[x_min:x_max, y_min:y_max] = 0

    # Compute peak to correlation energy
    # Note: the mask is useful to suppress the window around the peak
    pce = peak_value**2 / np.mean(correlation[mask] ** 2)
    return pce


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


def MSE(img_1: np.ndarray, img_2: np.ndarray) -> float:
    return float(np.mean((img_1 - img_2) ** 2))


def double_precision(img: np.ndarray) -> np.ndarray:
    return img.astype(np.float64) / 255.0


def add_noise(img: np.ndarray, mean: float = 0.0, std: float = 1.0) -> np.ndarray:
    noise = np.random.normal(loc=mean, scale=std, size=img.shape)
    img_noised = img.astype(np.float32) + noise
    return np.clip(img_noised, a_min=0, a_max=255).astype(np.uint8)


def PSNR(img_1: np.ndarray, img_2: np.ndarray, max_value=255) -> float:
    mse = MSE(img_1, img_2)
    if mse == 0:
        return 100
    return 10 * np.log10(max_value**2 / mse)


def print_quality(img_1: np.ndarray, img_2: np.ndarray):
    print(f"MSE: {MSE(img_1, img_2)}")
    print(f"PSNR: {PSNR(img_1, img_2)}")
    # print(f"SSIM: {ssim(img_1, img_2)}")


# def image_processing(img: np.ndarray):
#     noise_1 = add_noise(img, std = 1)
#     noise_2 = add_noise(img, std = 5)
#     jpeg_1 = jpeg_compress(img)
#     jpeg_2 = jpeg_compress(img, quality = 50)
#     images = [noise_1, noise_2, jpeg_1, jpeg_2]
#     titles = ["Gaussian noise with sigma = 1", "Gaussian noise with sigma = 5", "Jpeg compression 90", "Jpeg compression 50"]
#     print_image(img, "Original image")
#     for i in range(len(images)):
#         print("\n==============================================")
#         print(f"{titles[i]}")
#         print_quality(img, images[i])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find PRNU of camera")
    parser.add_argument(
        "-d",
        "--directory",
        help="Directory where are stored images took by specific camera",
    )
    parser.add_argument("-m", "--model", help="Model of the camera")
    parser.add_argument("-f", "--fingerprint", help="Fingerprint of the camera")
    parser.add_argument(
        "-i", "--image", help="Image to compute PCE with given fingerprint"
    )
    args = parser.parse_args()

    def wiener_filter(img: np.ndarray) -> np.ndarray:
        result = np.array(restoration.wiener(img, psf=np.ones((5, 5)), balance=0.1))
        return result

    if args.directory:
        fingerprint = PRNU(args.directory, wiener_filter)

    elif args.fingerprint:
        fingerprint = io.imread(args.fingerprint)
        fingerprint = util.img_as_float(fingerprint)
        img = io.imread(args.image)
        img = color.rgb2gray(img)
        img = util.img_as_float(img)
        if not args.image:
            print("You must provide an image with the fingerprint to compute PCE !")
            parser.print_help()
            exit(0)
        pce = PCE(img, fingerprint, wiener_filter)

    else:
        print("You must provide an argument !")
        parser.print_help()
        exit(0)
