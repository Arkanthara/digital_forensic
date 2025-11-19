import argparse
import matplotlib.pyplot as plt
import skimage as ski
import numpy as np


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Mini project")
    parser.add_argument("-i", "--image", help="Image to print YCbCr")
    parser.add_argument("-f1", "--frame_1", help="Frame 1 of a video")
    parser.add_argument("-f2", "--frame_2", help="Frame 2 of a video")
    args = parser.parse_args()
    if args.frame_1:
        img1 = ski.io.imread(args.frame_1, as_gray=False)
        img2 = ski.io.imread(args.frame_2, as_gray=False)

        ski.io.imsave("frame.jpg", ski.util.img_as_ubyte(img1))
        ski.io.imsave(
            "diff_frame.jpg",
            ski.util.img_as_ubyte(ski.util.compare_images(img1, img2, method="diff")),
        )
    if args.image:
        img = ski.color.rgb2ycbcr(ski.io.imread(args.image))
        img = img.astype(np.uint8)
        ski.io.imsave("y.jpg", ski.util.img_as_ubyte(img[:, :, 0]))
        ski.io.imsave("cb.jpg", ski.util.img_as_ubyte(img[:, :, 1]))
        ski.io.imsave("cr.jpg", ski.util.img_as_ubyte(img[:, :, 2]))

    # plt.figure()
    # plt.suptitle("Changes between 2 consecutives frame in a video")
    # plt.subplot(1, 2, 1)
    # plt.axis("off")
    # plt.imshow(img1, cmap='gray')
    # plt.title("Frame 1")
    # plt.subplot(1, 2, 2)
    # plt.axis('off')
    # plt.imshow(ski.util.compare_images(img1, img2, method='diff'), cmap='gray')
    # plt.title("Change with two consecutives frames")
    # plt.show()
