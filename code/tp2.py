import numpy as np
import matplotlib.pyplot as plt
import argparse
import os
from skimage import io, color, img_as_float, restoration
from typing import Callable
from functools import partial

def read_image(name: str, path: str = '../images') -> np.ndarray:
    img = io.imread(path + '/' + name)
    img = color.rgb2gray(img)
    img = img_as_float(img)
    print_range(img)
    return img

def read_directory(path: str) -> list[np.ndarray]:
    images = [read_image(img, path) for img in os.listdir(path) if os.path.isfile(os.path.join(path, img))]
    image_shapes = np.array([img.shape for img in images])
    min_shape = (np.min(image_shapes[:, 0]), np.min(image_shapes[:, 1]))
    return [img[:min_shape[0], :min_shape[1]] for img in images if is_good(img)]


def is_good(img: np.ndarray, max_mean: float = 0.8, max_var: float = 0.2) -> bool:
    return np.mean(img) < max_mean and np.var(img) < max_var


def PRNU(path: str, filter: Callable[..., np.ndarray]) -> np.ndarray:
    images = read_directory(path)
    assert len(images) >= 15, f"You must provide more images ! Actually good images: {len(images)}"
    contrib = lambda x: ((x - filter(x)) * x) / x**2
    contributions = [contrib(img) for img in images]
    fingerprint = np.sum(contributions, axis=0)
    # print_image(fingerprint)
    return fingerprint

def print_range(img: np.ndarray):
    print(f"dtype:  {img.dtype}")
    print(f"shape:  {img.shape}")
    print(f"min:    {img.min()}")
    print(f"max:    {img.max()}")
    print(f"range:  {img.max() - img.min()}")

def print_image(img: np.ndarray, title: str = "Image"):
    plt.figure()
    plt.title(title)
    plt.imshow(img, cmap='gray')
    plt.axis('off')
    plt.show()

def MSE(img_1: np.ndarray, img_2: np.ndarray) -> float:
    return np.mean((img_1 - img_2)**2)

def double_precision(img: np.ndarray) -> np.ndarray:
    return img.astype(np.float64) / 255.0

def add_noise(img: np.ndarray, mean: float = 0.0, std: float = 1.0) -> np.ndarray:
    noise = np.random.normal(loc = mean, scale = std, size = img.shape)
    img_noised = img.astype(np.float32) + noise
    return np.clip(img_noised, a_min = 0, a_max = 255).astype(np.uint8)


def PSNR(img_1: np.ndarray, img_2: np.ndarray, max_value=255) -> np.ndarray:
    mse = MSE(img_1, img_2)
    if mse == 0:
        return 100
    return 10 * np.log10(max_value**2/mse)

def print_quality(img_1: np.ndarray, img_2: np.ndarray):
    print(f"MSE: {MSE(img_1, img_2)}")
    print(f"PSNR: {PSNR(img_1, img_2)}")
    print(f"SSIM: {ssim(img_1, img_2)}")

def image_processing(img: np.ndarray):
    noise_1 = add_noise(img, std = 1)
    noise_2 = add_noise(img, std = 5)
    jpeg_1 = jpeg_compress(img)
    jpeg_2 = jpeg_compress(img, quality = 50)
    images = [noise_1, noise_2, jpeg_1, jpeg_2]
    titles = ["Gaussian noise with sigma = 1", "Gaussian noise with sigma = 5", "Jpeg compression 90", "Jpeg compression 50"]
    print_image(img, "Original image")
    for i in range(len(images)):
        print("\n==============================================")
        print(f"{titles[i]}")
        print_quality(img, images[i])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find PRNU of camera")
    parser.add_argument('-d', '--directory', required=True, help='Directory where are stored images took by specific camera')
    args = parser.parse_args()

    fingerprint = PRNU(args.directory, partial(restoration.wiener, psf=np.ones((5, 5)) / 25, balance=0.1))
