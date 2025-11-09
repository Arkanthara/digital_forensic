import numpy as np
import matplotlib.pyplot as plt
import argparse
from skimage import io, color, util
from typing import Union

def read_image(name: str, gray: bool = False) -> np.ndarray:
    img = io.imread(name)
    # Case RGB images
    if len(img.shape) == 3 and gray:
        img = color.rgb2gray(img)
    # Convert image to int array in range 0, 255
    img = util.img_as_ubyte(img)
    return img

def binary_image(name: str) -> np.ndarray:
    img = read_image(name, gray=True)
    img[img < 128] = 0
    img[img >= 128] = 1
    return img

def lsb_extraction(img: np.ndarray, level: int = 0) -> np.ndarray:
    assert level <= 7 and level >= 0, (
        f"level must be between 0 and 7 ! current: {level}"
    )
    # Extract the specific bit at given level (0 = LSB, 7 = MSB)
    return (img >> level) & 1

def extract_channel(img: np.ndarray, channel: int = 2) -> np.ndarray:
    if len(img.shape) == 3:
        return img[:, :, channel].copy()
    else:
        return img.copy()

def insert_channel(img: np.ndarray, insertion: np.ndarray, channel: int = 2) -> np.ndarray:
    result = img.copy()
    if len(img.shape) == 3:
        result[:, :, channel] = insertion
        return result
    else:
        return insertion

def hide_message(img: np.ndarray, msg: Union[str, np.ndarray], key: int = 21, level: int = 0, channel: int = 2) -> np.ndarray:
    # Create random number generator with given key
    rng = np.random.default_rng(seed=key)
    img_channel = extract_channel(img, channel)
    rows, cols = img_channel.shape
    layer = lsb_extraction(img_channel, level)
    result = img_channel - (layer << level)  # Remove the bit we're going to replace
    layer_flat = layer.ravel()
    
    if isinstance(msg, np.ndarray):
        msg_bits = (msg.ravel() > 0).astype(int)
    else:
        msg_bits = np.array(list(''.join(format(b, '08b') for b in msg.encode('utf-8')))).astype(int)
    
    positions = rng.choice(np.arange(layer_flat.shape[0]), size=msg_bits.shape[0], replace=False)
    layer_flat[positions] = msg_bits
    result += (layer_flat.reshape(rows, cols) << level)  # Add back the modified bits
    
    return insert_channel(img, result, channel)

def hide_image(img: np.ndarray, msg: np.ndarray, key: int = 21, quantization: int = 4) -> np.ndarray:
    assert len(img.shape) == 3, "Must work with rgb image !" 
    assert quantization <= 8, "Quantization represent number of MSB kept. It must be between 1 and 8 !"
    key_incrementer = 3984
    current_key = key
    level = 0
    result = img.copy()
    
    print(f"Hiding image with quantization={quantization}")
    print(f"Message shape: {msg.shape}")
    
    for img_level in range(8):  # 0-7 (LSB to MSB)
        for img_channel in range(min(3, img.shape[2])):  # RGB channels
            if level >= quantization:  # Fixed termination condition
                return result
            
            # Extract the bit plane from message (MSB first)
            msg_bit_plane = lsb_extraction(msg, 7 - level)  # 7-level = MSB to LSB order
            
            # Hide this bit plane in the cover image
            result = hide_message(
                result, 
                msg_bit_plane, 
                level=img_level,  # Which bit of cover image to use
                channel=img_channel, 
                key=current_key
            )
            
            level += 1
            current_key += key_incrementer
    
    return result

def get_image(img: np.ndarray, size: np.ndarray, key: int = 21, quantization: int = 4) -> np.ndarray:
    assert len(img.shape) == 3, "Must work with rgb image !"
    assert quantization <= 8, "Quantization represent number of MSB kept. It must be between 1 and 8 !"
    key_incrementer = 3984
    current_key = key
    level = 0
    result = np.zeros((size[0], size[1]), dtype=np.uint8)
    
    print(f"Extracting image with quantization={quantization}")
    print(f"Expected size: {size}")
    
    for img_level in range(8):  # 0-7 (LSB to MSB)
        for img_channel in range(min(3, img.shape[2])):  # RGB channels
            if level >= quantization:  # Fixed termination condition
                return result
            
            # Extract the bit plane
            extracted_bits = get_message(
                img, 
                size=size, 
                level=img_level,  # Which bit of cover image to extract from
                channel=img_channel, 
                key=current_key
            )
            
            # Add this bit plane to result with proper weighting
            bit_weight = 7 - level  # MSB first order
            result = result + ((extracted_bits > 0).astype(np.uint8) << bit_weight)
            
            level += 1
            current_key += key_incrementer
    
    return result

def get_message(img: np.ndarray, key: int = 21, size: Union[np.ndarray, int] = 100, level: int = 0, channel: int = 2) -> Union[str, np.ndarray]:
    if isinstance(size, int):
        length = size * 8
    else:
        length = size[0] * size[1]
    
    # Use the SAME seed as used in hiding
    rng = np.random.default_rng(seed=key)
    img_channel = extract_channel(img, channel)
    
    # Extract the specified bit level
    layer = lsb_extraction(img_channel, level).ravel()
    
    # Use the SAME positions as used in hiding
    positions = rng.choice(np.arange(layer.shape[0]), size=length, replace=False)
    msg_bits = layer[positions]
    
    if isinstance(size, np.ndarray):
        # Return as image
        msg_bits = msg_bits.reshape(size[0], size[1])
        return msg_bits
    else:
        # Return as string
        msg_bits = ''.join(str(i) for i in msg_bits)
        return int(msg_bits, 2).to_bytes(len(msg_bits) // 8, 'big').decode('utf-8', errors='ignore')

# Rest of your functions remain the same...
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
    parser.add_argument("-mi", "--message_image", help="Image to hide !")
    parser.add_argument("-msb", "--msb_number", help="Store the x MSB of grayscale image into RGB image LSB")
    args = parser.parse_args()

    if args.bit_plane:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        img = read_image(args.image, gray=True)
        bit_plane_visualization(img)
    if args.message:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        img = read_image(args.image)
        img_msg = hide_message(img, msg=args.message, level=7)
        print_image(img, title='Original image')
        print_image(img_msg, title='Image with hidden message')
        print(f"Recovered message: {get_message(img_msg)}")
    if args.message_image:
        assert args.image, "Image must be given to show each bit-plane of the image !"
        img = read_image(args.image)
        if args.msb_number:
            secret_img = read_image(args.message_image, gray=True)
            
            # Hide the image
            img_msg = hide_image(img, secret_img, quantization=int(args.msb_number))
            
            # Extract the image
            secret = get_image(img_msg, np.array(secret_img.shape), quantization=int(args.msb_number))
        else:
            secret_img = binary_image(args.message_image)
            img_msg = hide_message(img, msg=secret_img)
            secret = get_message(img_msg, size=np.array(secret_img.shape))
        print_image(img, title='Original image')
        print_image(img_msg, title='Image with hidden message')
        print_image(secret, title="Hidden image")
