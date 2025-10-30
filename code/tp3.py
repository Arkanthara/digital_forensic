import numpy as np
import matplotlib.pyplot as plt
import argparse
from skimage import io, color, util
from scipy.fftpack import dctn, idctn


def read_image(name: str) -> np.ndarray:
    img = io.imread(name)
    # Case RGB images
    if len(img.shape) == 3:
        img = color.rgb2gray(img)
    # Convert image to float, but in range 0, 255
    img = util.img_as_ubyte(img).astype(np.float64)
    return img


def zigzag(img: np.ndarray) -> np.ndarray:
    # Perform zigzag scan on a matrix.
    # The implementation doesn't follow the matlab implementation.
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


def JPEG_Tools(
    img: np.ndarray, QF: int = 90, encode: bool = True, dct: bool = False
) -> list[np.ndarray]:
    # Quality Matrix for QF
    QM1 = quality_matrix(QF)

    # Define values
    dct_domain = np.zeros_like(img)
    dct_quantized = np.zeros_like(img)
    dct_dequantized = np.zeros_like(img)
    dct_quantized_coeff = np.zeros((64, (img.shape[0] // 8) * (img.shape[1] // 8)))
    dct_domain_coeff = np.zeros((64, (img.shape[0] // 8) * (img.shape[1] // 8)))
    dct_restored = np.zeros_like(img)
    # Encoding
    if encode:
        new_img = img - 128
        k = 0
        for i in range(0, new_img.shape[0], 8):
            for j in range(0, new_img.shape[1], 8):
                zBLOCK = new_img[i : i + 8, j : j + 8]
                # Forward discret cosine transform
                win1 = dctn(zBLOCK, norm="ortho")
                dct_domain[i : i + 8, j : j + 8] = win1
                dct_domain_coeff[:, k] = zigzag(win1)
                # Quantization of the DCT coefficients
                win2 = np.round(win1 / QM1)
                dct_quantized[i : i + 8, j : j + 8] = win2
                dct_quantized_coeff[:, k] = zigzag(win2)
                k += 1
        return [dct_quantized, dct_quantized_coeff]

    elif dct:
        new_img = img - 128
        k = 0
        for i in range(0, new_img.shape[0], 8):
            for j in range(0, new_img.shape[1], 8):
                zBLOCK = new_img[i : i + 8, j : j + 8]
                # Forward discret cosine transform
                win1 = dctn(zBLOCK, norm="ortho")
                dct_domain[i : i + 8, j : j + 8] = win1
                dct_domain_coeff[:, k] = zigzag(win1)
                k += 1
        return [dct_domain, dct_domain_coeff]
    # Decoding
    else:
        for i in range(0, img.shape[0], 8):
            for j in range(0, img.shape[1], 8):
                win2 = img[i : i + 8, j : j + 8]
                # Dequantization of DCT Coefficients
                win3 = win2 * QM1
                dct_dequantized[i : i + 8, j : j + 8] = win3
                # Inverse discrete cosine transform
                win4 = idctn(win3, norm="ortho")
                dct_restored[i : i + 8, j : j + 8] = win4
        dct_restored += 128
        return [np.clip(dct_restored, 0, 255)]


def manimage1(img: np.ndarray, QF1: int, QF2: int) -> np.ndarray:
    # Generate manipulated image 1 by working in DCT domain.
    # Note that the result is encoded with QF1, even if QF1 is lower than QF2 !
    result = np.zeros_like(img)
    half = result.shape[1] // 2
    dct_quantized, dct_quantized_coeff = JPEG_Tools(img, QF1, encode=True)
    decoded = JPEG_Tools(dct_quantized, QF1, encode=False)[0]
    dct_quantized2, dct_quantized2_coeff = JPEG_Tools(decoded, QF2, encode=True)
    result[:, :half] = dct_quantized[:, :half]
    result[:, half:] = dct_quantized2[:, half:]
    # Other way to generate the manimage1...
    # return JPEG_Tools(result, max([QF1, QF2]), encode=False)[0]
    return JPEG_Tools(result, QF1, encode=False)[0]


def manimage2(img: np.ndarray, QF1: int, QF2: int) -> np.ndarray:
    # Genrate manipulated image 2 by working in spacial domain.
    result = np.zeros_like(img)
    half = result.shape[1] // 2
    dct_quantized, dct_quantized_coeff = JPEG_Tools(img, QF1, encode=True)
    decoded = JPEG_Tools(dct_quantized, QF1, encode=False)[0]
    dct_quantized2, dct_quantized2_coeff = JPEG_Tools(decoded, QF2, encode=True)
    decoded2 = JPEG_Tools(dct_quantized2, QF2, encode=False)[0]
    result[:, :half] = decoded[:, :half]
    result[:, half:] = decoded2[:, half:]
    return result


def plot_graph(
    # Plot graphs of given image, it DCT coefficients and it histogram of DCT coefficients
    img: np.ndarray,
    title: list[str] = ["Original image", "DCT", "Histogram"],
    QF: int = 75,
):
    plt.figure()
    plt.imshow(img, cmap="gray")
    plt.title(title[0])
    plt.axis("off")
    plt.show()
    # Here I use encode=True and not dct=True else histograms printed for manipulated images are with a lot of holes
    # since there is a lot of coefficients from the original image that are deleted.
    dct_quantized, dct_quantized_coeff = JPEG_Tools(img, QF=QF, encode=True)
    plt.figure()
    plt.imshow(dct_quantized, cmap="gray")
    plt.title(title[1])
    plt.axis("off")
    plt.show()
    y = dct_quantized_coeff.ravel()
    x_bin = np.arange(np.min(y), np.max(y) + 1)
    plt.figure()
    plt.hist(y, bins=x_bin)
    plt.title(title[2])
    plt.yscale("log")
    plt.show()


def plot_graphs(
    dct_quantized: np.ndarray,
    dct_quantized2: np.ndarray,
    dct_quantized_coeff: np.ndarray,
    dct_quantized2_coeff: np.ndarray,
    QF1: int,
    QF2: int,
):
    # Plot comparison graphs of given image for double JPEG compression, with DCT coefficients, histograms
    # and pairwise analysis.
    plt.figure()
    plt.subplot(1, 2, 1)
    block = 35
    plt.imshow(
        dct_quantized[block * 8 : block * 8 + 8, block * 8 : block * 8 + 8],
        cmap="gray",
    )
    plt.title(f"DCT 1st quantization with QF={QF1}")
    plt.subplot(1, 2, 2)
    plt.imshow(
        dct_quantized2[block * 8 : block * 8 + 8, block * 8 : block * 8 + 8],
        cmap="gray",
    )
    plt.title(f"DCT 2nd quantization with QF={QF2}")
    plt.tight_layout()
    plt.show()

    y1 = dct_quantized_coeff.ravel()
    y2 = dct_quantized2_coeff.ravel()
    min_dct = min(min(y1), min(y2))
    max_dct = max(max(y1), np.max(y2))
    x_bin = np.arange(min_dct, max_dct + 1)
    plt.figure()
    plt.subplot(2, 1, 1)
    plt.hist(y1, bins=x_bin)
    plt.title(f"One time compressed with QF={QF1}")
    plt.yscale("log")
    plt.subplot(2, 1, 2)
    plt.hist(y2, bins=x_bin)
    plt.title(f"Two times compressed with QF={QF2}")
    plt.yscale("log")
    plt.tight_layout()

    plt.figure()
    for i in range(8):
        coeff = i * 8
        p1 = dct_quantized_coeff[coeff, :]
        p2 = dct_quantized2_coeff[coeff, :]
        x_min = np.min([p1, p2])
        x_max = np.max([p1, p2])
        plt.subplot(2, 4, i + 1)
        plt.scatter(p1, p2, alpha=0.5, s=1)
        plt.title(f"Coefficient {coeff}")
        plt.xlabel("compression 1")
        plt.ylabel("compression 2")
        # Avoid case where x_min and x_max are 0
        if x_min != x_max:
            plt.xlim(x_min, x_max)
            plt.ylim(x_min, x_max)
    plt.suptitle(
        f"Pairwise analysis of DCT coefficients with QF1={QF1} and QF2={QF2}",
        fontsize=18,
        y=0.98,
    )
    plt.tight_layout()
    plt.show()


def double_JPEG_compression(
    img: np.ndarray, QF1: int = 50, QF2: int = 75, graphs: bool = True
) -> np.ndarray:
    # Perform double JPEG compression and plot comparison graphs.
    dct_quantized, dct_quantized_coeff = JPEG_Tools(img, QF1, encode=True)
    decoded = JPEG_Tools(dct_quantized, QF1, encode=False)[0]
    dct_quantized2, dct_quantized2_coeff = JPEG_Tools(decoded, QF2, encode=True)
    decoded2 = JPEG_Tools(dct_quantized2, QF2, encode=False)[0]

    if graphs:
        plot_graphs(
            dct_quantized,
            dct_quantized2,
            dct_quantized_coeff,
            dct_quantized2_coeff,
            QF1,
            QF2,
        )
    return decoded2


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Double JPEG compression")
    parser.add_argument(
        "-i", "--image", required=True, help="Image to make double compression"
    )
    parser.add_argument(
        "--QF1", default=50, help="Quality Factor for first compression. Default is 50"
    )
    parser.add_argument(
        "--QF2", default=75, help="Quality Factor for second compression. Default is 75"
    )
    parser.add_argument(
        "-m1",
        "--manipulated1",
        action="store_true",
        help="Create image with half QF1 and half QF2 in DCT domain and plot results",
    )
    parser.add_argument(
        "-m2",
        "--manipulated2",
        action="store_true",
        help="Create image with half QF1 and half QF2 in spacial domain and plot results",
    )
    args = parser.parse_args()

    img = read_image(args.image)

    QF1 = int(args.QF1)
    QF2 = int(args.QF2)

    if not args.manipulated1 and not args.manipulated2:
        double_JPEG_compression(img, QF1, QF2, graphs=True)

    if args.manipulated1:
        tmp = manimage1(img, QF1, QF2)
        plot_graph(
            tmp,
            [
                f"ManImage1 with QF1={QF1} and QF2={QF2}",
                f"DCT transform with QF1={QF1} and QF2={QF2}",
                "Histogram of DCT coefficients",
            ],
            np.max([QF1, QF2]),
        )

    if args.manipulated2:
        tmp = manimage2(img, QF1, QF2)
        plot_graph(
            tmp,
            [
                f"ManImage2 with QF1={QF1} and QF2={QF2}",
                f"DCT transform with QF1={QF1} and QF2={QF2}",
                "Histogram of DCT coefficients",
            ],
            np.max([QF1, QF2]),
        )
