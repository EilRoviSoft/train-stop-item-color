from PIL import Image
import os
import sys
import time

def get_rgb_avg_with_alpha(filename):
    img = Image.open(filename)
    pixels = img.load()
    w, h = img.size
    total_r = total_g = total_b = pixel_count = 0

    for x in range(w):
        for y in range(h):
            pixel = pixels[x, y]
            if type(pixel) == int:
                r, g, b, a = (pixel >> 24) % 8, (pixel >> 16) % 8, (pixel >> 8) % 8, pixel % 8
                if a > 0:
                    total_r += r
                    total_g += g
                    total_b += b
                    pixel_count += 1
            elif len(pixel) >= 4:
                r, g, b, a = pixel
                if a > 0:
                    total_r += r
                    total_g += g
                    total_b += b
                    pixel_count += 1
            elif len(pixel) == 3:
                r, g, b = pixel
                total_r += r
                total_g += g
                total_b += b
                pixel_count += 1

    if pixel_count > 0:
        return (round(total_r / pixel_count), round(total_g / pixel_count), round(total_b / pixel_count))
    else:
        return (0, 0, 0)

def get_clean_filename(filename):
    # Remove .png extension
    return os.path.splitext(filename)[0]

def main(folder_path, output_file):
    files = [f for f in os.listdir(folder_path) if f.lower().endswith(".png")]
    total_files = len(files)
    current_file = 0

    with open(output_file, "w") as out:
        for filename in files:
            current_file += 1
            filepath = os.path.join(folder_path, filename)

            # Progress
            progress = (current_file / total_files) * 100
            sys.stdout.write(f"\rProgress: {get_clean_filename(filename)} ({progress:.1f}%)")
            sys.stdout.flush()

            r, g, b = get_rgb_avg_with_alpha(filepath)
            out.write(f'["{get_clean_filename(filename)}"] = {{ r = {r}/255, g = {g}/255, b = {b}/255 }},\n')
            time.sleep(0.01)

    print("\rDone! Output saved to", output_file)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <folder_path> <output_file>")
        print("Use current folder:", sys.argv[0], "output.txt")
        sys.exit(1)

    folder_path = sys.argv[1] if sys.argv[1] != "." else os.getcwd()
    output_file = sys.argv[2]

    if not os.path.isdir(folder_path):
        print(f"Error: Folder '{folder_path}' doesn't exist!")
        sys.exit(1)

    main(folder_path, output_file)
