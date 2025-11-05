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
    # Convert image to int array in range 0, 255
    img = util.img_as_ubyte(img)
    return img


def lsb_extraction(img: np.ndarray, level: int = 0) -> np.ndarray:
    assert level <= 7 and level >= 0, (
        f"level must be between 0 and 7 ! current: {level}"
    )
    mask = np.zeros_like(img).astype(int) + 2**level
    result = img.copy().astype(int) & mask
    # return ((result & mask) > 0).astype(int)
    return result & mask


def crop_img(img: np.ndarray, tlx: int, tly: int, brx: int, bry: int) -> np.ndarray:
    assert len(img.shape) == 2, "Image must be 2 dimensions !"
    return img[tly:bry, tlx:brx]


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
    parser = argparse.ArgumentParser(description="Double JPEG compression")
    # parser.add_argument(
    #     "-i", "--image", required=True, help="Image to make double compression"
    # )
    args = parser.parse_args()

    a = np.ones((5, 5))
    print(lsb_extraction(a))
    print(lsb_extraction(a, 1))
    print(lsb_extraction(a * 2, 1))
