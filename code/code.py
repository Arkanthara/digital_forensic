import cv2
import numpy as np
import matplotlib.pyplot as plt

def read_image(name: str, path: str = '../images') -> np.ndarray:
    img = cv2.imread(path + '/' + name, cv2.IMREAD_GRAYSCALE)
    return img

def print_range(img: np.ndarray):
    print(f"dtype:  {img.dtype}")
    print(f"min:    {img.min()}")
    print(f"max:    {img.max()}")
    print(f"range:  {img.max() - img.min()}")

def print_image(img: np.ndarray, title: str = "Image", cmap: str = 'gray'):
    plt.figure()
    plt.title(title)
    plt.imshow(img, cmap=cmap)
    plt.axis('off')
    plt.show()

def MSE(img_1: np.ndarray, img_2: np.ndarray) -> float:
    return np.mean((img_1 - img_2)**2)

def normalize(img: np.ndarray, target: int = 255) -> np.ndarray:
    return (img - img.min()) * target / (img.max() - img.min())

def add_noise(img: np.ndarray, mean: float = 0.0, std: float = 1.0) -> np.ndarray:
    noise = np.random.normal(loc = mean, scale = std, size = img.shape)
    img_noised = img + noise
    return np.clip(img_noised, a_min = 0, a_max = 255)

def filterFT(img: np.ndarray, h: np.ndarray) -> np.ndarray:
    F_img = np.fft.fft2(img)
    h = np.fft.fftshift(h)
    #print_image(np.log(np.abs(F_img * h) + 1))
    return np.abs(np.fft.ifft2(F_img * h))

def jpeg_compress(img: np.ndarray, quality: int = 90) -> np.ndarray:
    params = [cv2.IMWRITE_JPEG_QUALITY, quality]
    success, encoded_img = cv2.imencode('jpeg', img, params)

    if not success:
        print("Error when encoding")

    compressed_img = cv2.imdecode(encoded_img, cv2.IMREAD_UNCHANGED)
    return compressed_img
