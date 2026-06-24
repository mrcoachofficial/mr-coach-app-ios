import os
from PIL import Image

def main():
    brain_dir = r"C:\Users\abikamal123\.gemini\antigravity\brain\ba1f8ab3-9f7f-4e02-82ca-48cb31fa6e62"
    dest_dir = r"d:\mrc\playstore_assets"
    os.makedirs(dest_dir, exist_ok=True)

    files = [
        "flutter_app_mobile_1780588858128.png",
        "login_screen_1780986661164.png",
        "otp_screen_1780986715507.png",
        "service_list_verified_1779545485976.png"
    ]

    for i, filename in enumerate(files, 1):
        src_path = os.path.join(brain_dir, filename)
        dest_path = os.path.join(dest_dir, f"screenshot_{i}.png")
        
        if not os.path.exists(src_path):
            print(f"Skipping {filename}: not found")
            continue

        print(f"Processing: {filename} -> screenshot_{i}.png")
        img = Image.open(src_path)
        
        # Calculate aspect ratio
        target_w, target_h = 1080, 1920
        img_w, img_h = img.size
        
        # Scale image to fit within target dimensions
        ratio = min(target_w / img_w, target_h / img_h)
        new_w = int(img_w * ratio)
        new_h = int(img_h * ratio)
        
        img_resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        
        # Create black canvas
        canvas = Image.new("RGB", (target_w, target_h), (0, 0, 0))
        # Center the resized image on canvas
        x = (target_w - new_w) // 2
        y = (target_h - new_h) // 2
        canvas.paste(img_resized, (x, y))
        
        canvas.save(dest_path, "PNG")
        print(f"Saved: {dest_path}")

if __name__ == "__main__":
    main()
