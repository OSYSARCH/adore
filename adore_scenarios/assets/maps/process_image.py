import cv2
import numpy as np


def denoise_image(img):
    """Apply strong denoising to remove thin diagonal lines and noise."""
    # denoised = cv2.fastNlMeansDenoisingColored(img, None, 10, 10, 3, 9)
    blur = cv2.GaussianBlur(img, (9, 9), 0)

    blur = cv2.GaussianBlur(blur, (3, 3), 0)


    # Define a sharpening kernel
    sharpening_kernel = np.array([[-1, -1, -1],
                                [-1,  9, -1],
                                [-1, -1, -1]])
    sharpened = cv2.filter2D(blur, -1, sharpening_kernel)
    # sharpened = cv2.filter2D(sharpened, -1, sharpening_kernel)

    denoise_image = cv2.fastNlMeansDenoisingColored(sharpened, None, 10, 10, 7, 21)
    sharpened = cv2.filter2D(denoise_image, -1, sharpening_kernel)

    return quantize_hue_based( white_balance_opencv(denoise_image))

def white_balance_opencv(img):
    wb = cv2.xphoto.createSimpleWB()
    return wb.balanceWhite(img)

def quantize_hue_based(img, k=20):
    """Cluster colors based on hue similarity and reduce total colors while preserving brightness."""
    # Convert image to HSV
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    h, s, v = cv2.split(hsv)

    # Stack H, S, and V into a 2D array for clustering, prioritizing Hue
    data = np.stack([h.flatten(), s.flatten(), v.flatten()], axis=1).astype(np.float32)

    # Apply K-means clustering to group similar hues
    criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 100, 0.2)
    _, labels, centers = cv2.kmeans(data, k, None, criteria, 10, cv2.KMEANS_RANDOM_CENTERS)

    # Convert centers to uint8 and reshape to image shape
    centers = np.uint8(centers)
    clustered = centers[labels.flatten()].reshape(hsv.shape)

    # Convert back to BGR for display
    clustered_bgr = cv2.cvtColor(clustered, cv2.COLOR_HSV2BGR)

    return clustered_bgr


def remove_lines_fft(img):
    """Remove periodic diagonal lines by detecting peaks in frequency domain and applying axis-specific filtering."""
    # Split channels to process separately
    channels = cv2.split(img)
    processed_channels = []
    
    for channel in channels:
        # Perform FFT
        f = np.fft.fft2(channel)
        fshift = np.fft.fftshift(f)
        magnitude_spectrum = np.log(np.abs(fshift) + 1)
        
        # Find the dominant frequency peaks
        peak_threshold = np.percentile(magnitude_spectrum, 99.999)  # Top 0.5% frequencies
        peak_indices = np.argwhere(magnitude_spectrum > peak_threshold)
        
        # Create a mask to remove only the detected peaks
        mask = np.ones_like(fshift, dtype=np.uint8)
        for peak in peak_indices:
            r, c = peak
            mask[r:r+1, c:c+1] = 0  # Suppress small regions around peaks
        
        # Apply mask to remove peaks
        fshift = fshift * mask
        f_ishift = np.fft.ifftshift(fshift)
        img_back = np.fft.ifft2(f_ishift)
        img_back = np.abs(img_back)
        
        # Normalize and convert to uint8
        img_back = cv2.normalize(img_back, None, 0, 255, cv2.NORM_MINMAX)
        img_back = np.uint8(img_back)
        
        processed_channels.append(img_back)
    
    # Merge the processed channels back into a color image
    return cv2.merge(processed_channels)

# Load and process the image
image_path = "6048:57971.jpg"
output_path = "processed_image_" + image_path

original_image = cv2.imread(image_path)

denosed_image = denoise_image(original_image)

# Save results
cv2.imwrite(output_path, denosed_image)

print(f"Processed image saved at: {output_path}")
