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

def hide_message(img: np.ndarray, msg: str = "Hellloooowww !!!", key: int = 21, level: int = 0) -> np.ndarray:
    # Create random number generator with given key
    rng = np.random.default_rng(seed=key)
    rows, cols = img.shape
    layer = lsb_extraction(img, level)
    result = img.copy() - layer
    layer = layer.ravel()
    msg_bits = 2**level * np.array(list(''.join(format(b, '08b') for b in msg.encode('utf-8')))).astype(int)
    positions = rng.choice(np.arange(layer.shape[0]), size=msg_bits.shape[0])
    layer[positions] = msg_bits
    result += layer.reshape(rows, cols)
    return result

def get_message(img: np.ndarray, key: int = 21, length: int = 100, level: int = 0) -> str:
    rng = np.random.default_rng(seed=key)
    layer = lsb_extraction(img, level).ravel()
    positions = rng.choice(np.arange(layer.shape[0]), size=length*8)
    msg_bits = layer[positions]
    msg_bits = (msg_bits > 0).astype(int)
    msg_bits = ''.join(str(i) for i in msg_bits)
    # We ignore here the decoding errors to retrieve a message even if we don't know the size of the message
    return int(msg_bits, 2).to_bytes(len(msg_bits) // 8, 'big').decode('utf-8', errors='ignore')

def bit_plane_visualization(img: np.ndarray, title: str = "Bit-planes of the image"):
    plt.figure()
    plt.suptitle(title)
    for i in range(8):
        plt.subplot(2, 4, i + 1)
        plt.imshow(lsb_extraction(img, i), cmap='gray')
        plt.axis('off')
        plt.title(f'Level {i}')
    plt.show()


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
    parser = argparse.ArgumentParser(description="Steganography")
    parser.add_argument(
        "-i", "--image", help="Image"
    )
    parser.add_argument(
        "-b", "--bit_plane", action="store_true", help="Display each bit-plane of the image"
    )
    parser.add_argument("-m", "--message", help="Message to hide !")
    parser.add_argument("-p", )
    args = parser.parse_args()

    if args.bit_plane:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        img = read_image(args.image)
        bit_plane_visualization(img)
    if args.message:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        img = read_image(args.image)
        img_msg = hide_message(img, msg=args.message, level=7)
        print_image(img, title='Original image')
        print_image(img_msg, title='Image with hidden message')
        print(f"Recovered message: {get_message(img_msg)}")
