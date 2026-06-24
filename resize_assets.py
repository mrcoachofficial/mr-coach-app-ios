import os
import sys

try:
    from PIL import Image
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow"])
    from PIL import Image

def main():
    workspace_dir = r"d:\mrc"
    output_dir = os.path.join(workspace_dir, "playstore_assets")
    os.makedirs(output_dir, exist_ok=True)

    app_data_dir = r"C:\Users\abikamal123\.gemini\antigravity\brain\ba1f8ab3-9f7f-4e02-82ca-48cb31fa6e62"
    
    icon_src = None
    graphic_src = None

    for file in os.listdir(app_data_dir):
        if file.startswith("mr_coach_playstore_icon") and file.endswith(".png"):
            icon_src = os.path.join(app_data_dir, file)
        elif file.startswith("mr_coach_feature_graphic") and file.endswith(".png"):
            graphic_src = os.path.join(app_data_dir, file)

    if not icon_src or not graphic_src:
        print("Source images not found in app data directory.")
        return

    # Resize Icon
    print(f"Resizing Icon: {icon_src}")
    img_icon = Image.open(icon_src)
    img_icon_resized = img_icon.resize((512, 512), Image.Resampling.LANCZOS)
    icon_dest = os.path.join(output_dir, "app_icon_512.png")
    img_icon_resized.save(icon_dest, "PNG")
    print(f"Saved: {icon_dest}")

    # Resize Feature Graphic
    print(f"Resizing Feature Graphic: {graphic_src}")
    img_graphic = Image.open(graphic_src)
    img_graphic_resized = img_graphic.resize((1024, 500), Image.Resampling.LANCZOS)
    graphic_dest = os.path.join(output_dir, "feature_graphic_1024_500.png")
    img_graphic_resized.save(graphic_dest, "PNG")
    print(f"Saved: {graphic_dest}")

    print("Success!")

if __name__ == "__main__":
    main()
