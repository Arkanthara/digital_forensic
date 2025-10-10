import numpy as np
import matplotlib.pyplot as plt
import argparse
import os
from skimage import io, color, util, restoration
from typing import Callable


def read_image(name: str) -> np.ndarray:
    """
    Function that read an image from disk and store it into a numpy array.
    The image is loaded in grayscale, in double precision.

    Parameters
    ----------
    name : str
        Path to the image

    Returns
    -------
    np.ndarray
        Image converted in numpy array

    """
    img = io.imread(name)
    # Case RGB images
    if len(img.shape) == 3:
        img = color.rgb2gray(img)
    # Convert image to float
    img = util.img_as_float(img)
    return img


def read_directory(path: str, no_check: bool = False) -> list[np.ndarray]:
    """
    Function that open a directory and store all images from the directory in a list.
    No check is made on the nature of the files present in the directory.
    Option no_check allow to check or not if the image has a correct mean and variance for fingerprint computation.
    So be careful to have only images in directory !

    Parameters
    ----------
    path : str
        Path to the directory

    no_check : bool
        Function that avoid check of mean and variance of images

    Returns
    -------
    list[np.ndarray]
        List of readed images

    """
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


def is_good(img: np.ndarray, max_mean: float = 0.85, max_var: float = 0.1) -> bool:
    """
    Function that check variance and mean of an image to say if this image is good for fingerprint computation.

    Parameters
    ----------
    img : np.ndarray
        Given image

    max_mean : float
        Maximum mean tolerated

    max_var : float
        Maximum variance tolerated

    Returns
    -------
    bool
        return False if image doesn't correspond to criteria

    """
    if not np.mean(img) < max_mean and np.var(img) < max_var:
        print(
            "Image has a too big variance or mean value ! The detection couldn't properly work !"
        )
        print(f"Current mean:       {np.mean(img)}")
        print(f"Current variance:   {np.var(img)}")
        return False
    return True


def normalize(img: np.ndarray, target: float = 1.0) -> np.ndarray:
    """
    Function that normalize an image and scale it to range [0, target]

    Parameters
    ----------
    img : np.ndarray
        Image

    target : float
        Target range

    Returns
    -------
    np.ndarray
        Image normalized in the target range, so min_image = 0 and max_image = target.

    """
    return (img - img.min()) * target / (img.max() - img.min())


def contribution(x: np.ndarray, filter: Callable[..., np.ndarray]) -> np.ndarray:
    """
    Function that compute PRNU of a given image with a given filter

    Parameters
    ----------
    x : np.ndarray
        Image

    filter : Callable[..., np.ndarray]
        Denoising filter

    Returns
    -------
    np.ndarray
        PRNU of the image

    """
    # Used to normalize the division and avoid zero division.
    epsilon = 1e-8
    return ((x - filter(x)) * x) / (x**2 + epsilon)


def fingerprint_computation(
    images: list[np.ndarray],
    filter: Callable[..., np.ndarray],
    savedir: str = ".",
    model: str = "model",
):
    """
    Function that create the fingerprint of a camera according to a set of images given

    Parameters
    ----------
    images : list[np.ndarray]
        Set of images

    filter : Callable[..., np.ndarray]
        Denoising filter

    savedir : str
        Directory where the fingerprint image is saved

    model : str
        Name of the camera that will appear in name of fingerprint image saved.

    """
    assert len(images) >= 15, (
        f"You must provide more images ! Actually good images: {len(images)}"
    )
    contributions = [contribution(img, filter) for img in images]
    # fingerprint = normalize(np.sum(contributions, axis=0))
    fingerprint = normalize(np.mean(contributions, axis=0))
    io.imsave(
        os.path.join(savedir, model + "_fingerprint.png"),
        util.img_as_ubyte(fingerprint),
    )


def p(img_1: np.ndarray, img_2: np.ndarray) -> float:
    """
    Function that compute correlation between 2 images

    Parameters
    ----------
    img_1 : np.ndarray
        Image 1
    img_2 : np.ndarray
        Image 2

    Returns
    -------
    float
        Correlation value

    """
    assert img_1.shape == img_2.shape, "Shape of images must be the same !"
    X = img_1.ravel() - np.mean(img_1)
    Y = img_2.ravel() - np.mean(img_2)
    return (np.dot(X, Y)) / np.sqrt(np.sum(X**2) * np.sum(Y**2))


def img_identification(
    img: np.ndarray, fingerprint: np.ndarray, filter: Callable[..., np.ndarray]
) -> float:
    """
    Function that perform the image identification by comparing the PRNU of the image to the given fingerprint

    Parameters
    ----------
    img : np.ndarray
        Image

    fingerprint : np.ndarray
        Fingerprint

    filter : Callable[..., np.ndarray]
        Denoising filter

    Returns
    -------
    float
        Correlation between PRNU of the image and fingerprint

    """
    # Crop images to have same size
    cropped_shape = (
        np.min([img.shape[0], fingerprint.shape[0]]),
        np.min([img.shape[1], fingerprint.shape[1]]),
    )
    cropped_img = normalize(img[: cropped_shape[0], : cropped_shape[1]])
    cropped_fingerprint = normalize(fingerprint[: cropped_shape[0], : cropped_shape[1]])

    # Compute fingerprint from given image
    fingerprint_img = contribution(cropped_img, filter)

    # Compute correlation between two images
    return p(cropped_fingerprint, fingerprint_img)


def print_range(img: np.ndarray):
    """
    Function to print informations about an image, like type of data, minimum, maximum...

    Parameters
    ----------
    img : np.ndarray
        Image

    """
    print(f"dtype:  {img.dtype}")
    print(f"shape:  {img.shape}")
    print(f"min:    {img.min()}")
    print(f"max:    {img.max()}")
    print(f"range:  {img.max() - img.min()}")


def print_image(img: np.ndarray, title: str = "Image"):
    """
    Function used to print an image

    Parameters
    ----------
    img : np.ndarray
        Image
    title : str
        Title for the figure

    """
    plt.figure()
    plt.title(title)
    plt.imshow(img, cmap="gray")
    plt.axis("off")
    plt.show()


if __name__ == "__main__":
    # Create argument parser
    parser = argparse.ArgumentParser(description="Find PRNU of camera")

    # Add arguments
    parser.add_argument(
        "-d",
        "--directories",
        nargs="+",
        help="directories where are stored images took by specific camera",
    )
    parser.add_argument("-f", "--fingerprint", help="Fingerprint of the camera")
    parser.add_argument(
        "-l",
        "--labels",
        nargs="+",
        help="Labels for graph output. You must provide a label by directory given. Default is the name of directories.",
    )
    parser.add_argument(
        "-m", "--model", default="model", help="Model of the camera. Default is 'model'"
    )
    parser.add_argument(
        "-s",
        "--saving_path",
        default=".",
        help="Path where fingerprint will be stored. Default is '.'",
    )

    # Parse arguments
    args = parser.parse_args()

    # Encapsulate wiener filter to depend only of the given image
    def wiener_filter(img: np.ndarray) -> np.ndarray:
        result = np.array(restoration.wiener(img, psf=np.ones((5, 5)), balance=0.1))
        return result

    # Case computation of fingerprint
    if args.directories and not args.fingerprint:
        images = []
        for dir in args.directories:
            images += read_directory(dir)
        fingerprint = fingerprint_computation(
            images, wiener_filter, model=args.model, savedir=args.saving_path
        )

    # Case image identification
    elif args.fingerprint:
        fingerprint = read_image(args.fingerprint)
        if args.directories:
            # Look after labels defautl value
            labels = []
            if not args.labels or len(args.labels) != len(args.directories):
                labels = [os.path.basename(dir) for dir in args.directories]
            else:
                labels = args.labels

            # Create list of images
            images = []
            for dir in args.directories:
                images.append(read_directory(dir, no_check=True))
            results = []

            # Compute correlation between image prnu and fingerprint for all images
            for imgs in images:
                tmp = []
                for img in imgs:
                    tmp.append(img_identification(img, fingerprint, wiener_filter))
                results.append(tmp)

            # Print the result
            plt.figure()
            for i in range(len(results)):
                plt.plot(
                    np.arange(1, len(results[i]) + 1), results[i], "o", label=labels[i]
                )
            plt.title(
                f"Correlation between given images and fingerprint of {args.model}"
            )
            plt.xlabel("Images")
            plt.ylabel("Correlation")
            plt.legend()
            plt.show()

        # If arguments were not properly given, print an error message
        else:
            print("You must provide an image with the fingerprint to compute PCE !")
            parser.print_help()
            exit(0)

    # If arguments were not properly given, print an error message
    else:
        print("You must provide an argument !")
        parser.print_help()
        exit(0)
