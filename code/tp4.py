import numpy as np
import matplotlib.pyplot as plt
import argparse
from skimage import io, color, util
from scipy.fftpack import dctn, idctn
import skimage
import cv2
from skimage.transform import rescale


def read_image(name: str) -> np.ndarray:
    img = io.imread(name)
    # Case RGB images
    if len(img.shape) == 3:
        img = color.rgb2gray(img)
    # Convert image to float, but in range 0, 255
    img = util.img_as_ubyte(img).astype(np.float64)
    return img


def normalize(img: np.ndarray, target: float = 1.0) -> np.ndarray:
    return (img - img.min()) * target / (img.max() - img.min())


def crop_img(img: np.ndarray, tlx: int, tly: int, brx: int, bry: int) -> np.ndarray:
    assert len(img.shape) == 2, "Image must be 2 dimensions !"
    return img[tly:bry, tlx:brx]


def insert_img(img: np.ndarray, img2: np.ndarray, tlx: int, tly: int) -> np.ndarray:
    result = img.copy()
    result[tly : tly + img2.shape[0], tlx : tlx + img2.shape[1]] = img2
    result[result == 0] = img[result == 0]
    return result.astype(int)


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


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Double JPEG compression")
    parser.add_argument(
        "-i", "--image", required=True, help="Image to make double compression"
    )
    args = parser.parse_args()

    img = read_image(args.image)
    cropped_img = crop_img(img, 197, 894, 345, 1000)
    rescale_1_5 = skimage.transform.rescale(cropped_img, scale=1.5)
    rescale_0_5 = skimage.transform.rescale(cropped_img, scale=0.5, anti_aliasing=True)
    rotate_90 = skimage.transform.rotate(
        cropped_img, angle=90, resize=False, preserve_range=True
    )
    rotate_45 = skimage.transform.rotate(
        cropped_img, angle=45, resize=False, preserve_range=True
    )
    noise_0_5 = add_noise(cropped_img, std=0.5)
    noise_1 = add_noise(cropped_img, std=1)
    compression_50_30 = jpeg_compress(jpeg_compress(cropped_img, 50), 30)
    compression_50_90 = jpeg_compress(jpeg_compress(cropped_img, 50), 90)
    print_image(img)
    print_image(cropped_img)
    print_image(insert_img(img, rescale_1_5, 440, 840))
    io.imsave(
        "no_modification.png", util.img_as_ubyte(insert_img(img, cropped_img, 578, 894))
    )
    io.imsave(
        "rescale_1_5.png",
        util.img_as_ubyte(insert_img(img, rescale_1_5, 440, 840)),
    )
    io.imsave(
        "rescale_0_5.png",
        util.img_as_ubyte(insert_img(img, rescale_0_5, 480, 930)),
    )
    io.imsave(
        "rotate_90.png",
        util.img_as_ubyte(insert_img(img, rotate_90, 578, 894)),
    )
    io.imsave(
        "rotate_45.png",
        util.img_as_ubyte(insert_img(img, rotate_45, 400, 894)),
    )
    io.imsave(
        "noise_0_5.png",
        util.img_as_ubyte(insert_img(img, noise_0_5, 578, 894)),
    )
    io.imsave(
        "noise_1.png",
        util.img_as_ubyte(insert_img(img, noise_1, 578, 894)),
    )
    io.imsave(
        "compression_50_90.png",
        util.img_as_ubyte(insert_img(img, compression_50_90, 578, 894)),
    )
    io.imsave(
        "compression_50_30.png",
        util.img_as_ubyte(insert_img(img, compression_50_30, 578, 894)),
    )
