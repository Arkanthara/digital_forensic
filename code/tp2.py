import numpy as np
import matplotlib.pyplot as plt
import argparse
import os
from skimage import io, color, util, restoration
from scipy import signal
from typing import Callable


def read_image(name: str) -> np.ndarray:
    img = io.imread(name)
    # Case RGB images
    if len(img.shape) == 3:
        img = color.rgb2gray(img)
    # Convert image to float
    img = util.img_as_float(img)
    return img


def read_directory(path: str, no_check: bool = False) -> list[np.ndarray]:
    images = [
        read_image(os.path.join(path, img))
        for img in os.listdir(path)
        if os.path.isfile(os.path.join(path, img))
    ]
    image_shapes = np.array([img.shape for img in images])
    min_shape = (np.min(image_shapes[:, 0]), np.min(image_shapes[:, 1]))
    return [
        img[: min_shape[0], : min_shape[1]]
        for img in images
        if is_good(img) or no_check
    ]


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


def p(img_1: np.ndarray, img_2: np.ndarray) -> float:
    assert img_1.shape == img_2.shape, "Shape of images must be the same !"
    X = img_1.ravel() - np.mean(img_1)
    Y = img_2.ravel() - np.mean(img_2)
    return (np.dot(X, Y)) / np.sqrt(np.sum(X**2) * np.sum(Y**2))


def correlation(
    img: np.ndarray, prnu: np.ndarray, filter: Callable[..., np.ndarray]
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

    # Compute correlation between two images
    return p(cropped_prnu, prnu_img)


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
    parser = argparse.ArgumentParser(description="Find PRNU of camera")
    parser.add_argument(
        "-d",
        "--directory",
        nargs="+",
        help="Directory where are stored images took by specific camera",
    )
    parser.add_argument("-m", "--model", default="Default", help="Model of the camera")
    parser.add_argument("-f", "--fingerprint", help="Fingerprint of the camera")
    parser.add_argument(
        "-i", "--image", help="Image to compute PCE with given fingerprint"
    )
    args = parser.parse_args()

    def wiener_filter(img: np.ndarray) -> np.ndarray:
        result = np.array(restoration.wiener(img, psf=np.ones((5, 5)), balance=0.1))
        return result

    if args.directory and not args.fingerprint:
        fingerprint = PRNU(args.directory[0], wiener_filter)

    elif args.fingerprint:
        fingerprint = read_image(args.fingerprint)
        if args.image:
            img = read_image(args.image)
            print(f"Correlation: {correlation(img, fingerprint, wiener_filter)}")
        elif args.directory:
            images = read_directory(args.directory, no_check=True)
            results = []
            for img in images:
                results.append(correlation(img, fingerprint, wiener_filter))
            plt.figure()
            plt.plot(np.arange(1, len(results) + 1), results, "o")
            plt.title(f"Correlation between images and PRNU of model {args.model}")
            plt.xlabel("Images")
            plt.ylabel("Correlation")
            plt.show()
        else:
            print("You must provide an image with the fingerprint to compute PCE !")
            parser.print_help()
            exit(0)
    else:
        print("You must provide an argument !")
        parser.print_help()
        exit(0)
