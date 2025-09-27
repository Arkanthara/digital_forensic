import cv2
import numpy as np
import matplotlib.pyplot as plt
from skimage.metrics import structural_similarity as ssim

def read_image(name: str, path: str = '../images') -> np.ndarray:
    img = cv2.imread(path + '/' + name, cv2.IMREAD_GRAYSCALE)
    return img

def print_range(img: np.ndarray):
    print(f"dtype:  {img.dtype}")
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

def normalize(img: np.ndarray, target: int = 255) -> np.ndarray:
    return (img - img.min()) * target / (img.max() - img.min())

def add_noise(img: np.ndarray, mean: float = 0.0, std: float = 1.0) -> np.ndarray:
    noise = np.random.normal(loc = mean, scale = std, size = img.shape)
    img_noised = img.astype(np.float32) + noise
    return np.clip(img_noised, a_min = 0, a_max = 255).astype(np.uint8)

def filterFT(img: np.ndarray, h: np.ndarray) -> np.ndarray:
    F_img = np.fft.fft2(img)
    h = np.fft.fftshift(h)
    #print_image(np.log(np.abs(F_img * h) + 1))
    return np.abs(np.fft.ifft2(F_img * h))

def jpeg_compress(img: np.ndarray, quality: int = 90) -> np.ndarray:
    params = [cv2.IMWRITE_JPEG_QUALITY, quality]
    success, encoded_img = cv2.imencode('.jpg', img, params)

    if not success:
        print("Error when encoding")

    compressed_img = cv2.imdecode(encoded_img, cv2.IMREAD_UNCHANGED)
    return compressed_img

def PSNR(img_1: np.ndarray, img_2: np.ndarray, max_value=255) -> np.ndarray:
    mse = MSE(img_1, img_2)
    if mse == 0:
        return 100
    return 20 * np.log10(max_value/np.sqrt(mse)) # Multiple definitions possibles ??

def print_quality(img_1: np.ndarray, img_2: np.ndarray):
    print(f"MSE: {MSE(img_1, img_2)}")
    print(f"PSNR: {PSNR(img_1, img_2)}")
    print(f"SSIM: {ssim(img_1, img_2)}")
    print("LPIPS")

def image_processing(img: np.ndarray):
    noise_1 = add_noise(img, std = 0.01)
    noise_2 = add_noise(img, std = 0.5)
    jpeg_1 = jpeg_compress(img)
    jpeg_2 = jpeg_compress(img, quality = 50)
    images = [noise_1, noise_2, jpeg_1, jpeg_2]
    titles = ["Gaussian noise with sigma = 0.01", "Gaussian noise with sigma = 0.5", "Jpeg compression 90", "Jpeg compression 50"]
    for i in range(len(images)):
        print("\n==============================================")
        print(f"{titles[i]}")
        print_range(images[i])
        print_quality(img, images[i])
    


img_1 = read_image("256.png")
img_2 = read_image("512.png")
img_3 = read_image("1000.jpeg")
img_4 = read_image("2000.jpg")

image_processing(img_1)
