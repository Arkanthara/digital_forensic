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


def zigzag(img: np.ndarray) -> np.ndarray:
    assert len(img.shape) == 2, f"Image must be 2D array and not {len(img.shape)}"
    index = 0
    output = np.zeros(img.shape[0] * img.shape[1])
    for i in range(img.shape[0] + img.shape[1] - 1):
        for j in range(i + 1):
            if (i % 2) == 0:
                if j < img.shape[0] and i - j < img.shape[1]:
                    output[index] = img[j, i - j]
                    index += 1
            elif i - j < img.shape[0] and j < img.shape[1]:
                output[index] = img[i - j, j]
                index += 1
            else:
                continue
    return output


a = np.array([[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]])
print(a)
print(zigzag(a))


def quality_matrix(QF: int = 90) -> np.ndarray:
    QM1 = np.array([])
    Q50 = np.array(
        [
            [16, 11, 10, 16, 24, 40, 51, 61],
            [12, 12, 14, 19, 26, 58, 60, 55],
            [14, 13, 16, 24, 40, 57, 69, 56],
            [14, 17, 22, 29, 51, 87, 80, 62],
            [18, 22, 37, 56, 68, 109, 103, 77],
            [24, 35, 55, 64, 81, 104, 113, 92],
            [49, 64, 78, 87, 103, 121, 120, 101],
            [72, 92, 95, 98, 112, 100, 103, 99],
        ]
    )
    if QF > 50:
        QM1 = np.round(Q50 * (np.ones(8) * ((100 - QF) / 50))).astype(np.uint8)
    elif QF < 50:
        QM1 = np.round(Q50 * (np.ones(8) * (50 / QF))).astype(np.uint8)
    elif QF == 50:
        QM1 = Q50
    return QM1.astype(np.float64)


def JPEG_Tools(img: np.ndarray, QF: int = 90, encode: bool = True) -> list[np.ndarray]:
    # Quality Matrix for QF
    QM1 = quality_matrix(QF)

    # Define values
    dct_domain = np.zeros_like(img)
    dct_quantized = np.zeros_like(img)
    dct_dequantized = np.zeros_like(img)
    dct_quantized_coeff = np.zeros((64, (img.shape[0] // 8) * (img.shape[1] // 8)))
    dct_restored = np.zeros_like(img)
    # Encoding
    if encode:
        print_range(img)
        new_img = img - 128
        k = 0
        for i in range(0, new_img.shape[0], 8):
            for j in range(0, new_img.shape[1], 8):
                zBLOCK = new_img[i : i + 8, j : j + 8]
                # Forward discret cosine transform
                win1 = dctn(zBLOCK)
                dct_domain[i : i + 8, j : j + 8] = win1
                # Quantization of the DCT coefficients
                win2 = np.round(win1 / QM1)
                dct_quantized[i : i + 8, j : j + 8] = win2
                dct_quantized_coeff[:, k] = zigzag(win2)
                k += 1
        return [dct_quantized, dct_quantized_coeff]

    # Decoding
    else:
        for i in range(0, img.shape[0], 8):
            for j in range(0, img.shape[1], 8):
                win2 = img[i : i + 8, j : j + 8]
                # Dequantization of DCT Coefficients
                win3 = win2 * QM1
                dct_dequantized[i : i + 8, j : j + 8] = win3
                # Inverse discrete cosine transform
                win4 = idctn(win3)
                dct_restored[i : i + 8, j : j + 8] = win4
        return [dct_restored]


def double_JPEG_compression(
    img: np.ndarray, QF1: int = 50, QF2: int = 75, graphs: bool = True
) -> np.ndarray:
    dct_quantized = JPEG_Tools(img, QF1, encode=True)[0]
    decoded = JPEG_Tools(dct_quantized, QF1, encode=False)[0]
    print("Decoded")
    print_range(decoded)
    dct_quantized2 = JPEG_Tools(decoded, QF2, encode=True)[0]
    decoded2 = JPEG_Tools(dct_quantized2, QF2, encode=False)[0]

    if graphs:
        plt.figure()
        plt.subplot(1, 2, 1)
        plt.imshow(dct_quantized, cmap="gray")
        plt.title("DCT 1st quantization")
        plt.subplot(1, 2, 2)
        plt.imshow(dct_quantized2, cmap="gray")
        plt.title("DCT 2nd quantization")
        plt.show()

        # min_dct = min(min(dct_quantized), min(dct_quantized2))
        # max_dct = max(max(dct_quantized), max(dct_quantized2))
        # x_bin = np.arange(min_dct, max_dct)
        hist = skimage.exposure.histogram(util.img_as_ubyte(decoded))
        hist2 = skimage.exposure.histogram(util.img_as_ubyte(decoded2))
        plt.figure()
        plt.subplot(1, 2, 1)
        plt.bar(hist[1], hist[0])
        plt.title("DCT 1st quantization")
        plt.subplot(1, 2, 2)
        plt.bar(hist2[1], hist2[0])
        plt.title("DCT 2nd quantization")
        plt.show()
    return decoded2


def normalize(img: np.ndarray, target: float = 1.0) -> np.ndarray:
    return (img - img.min()) * target / (img.max() - img.min())


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
    parser.add_argument(
        "--QF1", default=50, help="Quality Factor for first compression"
    )
    parser.add_argument(
        "--QF2", default=75, help="Quality Factor for second compression"
    )
    args = parser.parse_args()

    img = read_image(args.image)

    double_JPEG_compression(img, args.QF1, args.QF2, graphs=True)
