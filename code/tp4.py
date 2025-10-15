import numpy as np
import matplotlib.pyplot as plt
import argparse
from skimage import io, color, util
from scipy.fftpack import dctn, idctn
import skimage


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
    return img[tlx:brx, tly:bry]


def insert_img(img: np.ndarray, img2: np.ndarray, tlx: int, tly: int) -> np.ndarray:
    result = img.copy()
    result[tlx : tlx + img2.shape[0], tly : tly + img2.shape[1]] = img2
    return result


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
    parser.add_argument(
        "-i", "--image", required=True, help="Image to make double compression"
    )
    args = parser.parse_args()

    img = read_image(args.image)
    cropped_img = crop_img(img, 250, 220, 370, 340)
    print_image(img)
    print_image(cropped_img)
    print_image(insert_img(img, cropped_img, 250, 400))
