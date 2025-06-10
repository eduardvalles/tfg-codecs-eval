import os
import subprocess

# Carpeta vídeos
BASE_DIR = "videos"

# Sortida
OUTPUT_DIR = "E:/TFG/yuv_videos"

def mp4_to_yuv(input_path, output_path):
    cmd = [
        "ffmpeg", "-y", "-i", input_path,
        "-vf", "scale=1920:1080,fps=25",          # resolució + fps
        "-pix_fmt", "yuv420p",                    # format de píxel
        "-f", "rawvideo",                         # format de sortida explícit
        output_path
    ]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)



def convert_category(categoria):
    input_folder = os.path.join(BASE_DIR, categoria)
    output_folder = os.path.join(OUTPUT_DIR, categoria)

    if not os.path.isdir(input_folder):
        print("Categoria no trobada.")
        return

    os.makedirs(output_folder, exist_ok=True)

    for arxiu in os.listdir(input_folder):
        if arxiu.endswith(".mp4"):
            input_path = os.path.join(input_folder, arxiu)
            output_path = os.path.join(output_folder, arxiu.replace(".mp4", ".yuv"))
            print(f"Convertint {arxiu} → {output_path}")
            mp4_to_yuv(input_path, output_path)


def main():
    while True:
        print("\n--- MENÚ TFG CONVERSOR MP4 A YUV ---")
        print("1. Convertir videos")
        print("2. Sortir")
        opcio = input("Escull una opció: ")

        if opcio == "1":
            categoria = input("Introdueix la categoria (ex. sport, film...): ").strip()
            convert_category(categoria)
        elif opcio == "2":
            print("Sortint...")
            break
        else:
            print("Opció no vàlida.")
            continue

        categoria = input("Introdueix la categoria (ex. sport, film...): ").strip()
        carpeta = os.path.join(BASE_DIR, categoria)

if __name__ == "__main__":
    main()
