import os
import time
import mysql.connector
import psutil
from datetime import datetime
import subprocess
from pathlib import Path

# Paràmetres del vídeo
width = 1920
height = 1080
fps = 25


# Configuració connexió base de dades
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="159753",
    database="database_tfg"
)
cursor = conn.cursor()


# Carpeta vídeos
BASE_DIR = "yuv_videos"


# Comandaments FFmpeg per a cada còdec
def ffmpeg_command(input_path, output_path, codec):
    input_opts = f'-f rawvideo -pix_fmt yuv420p -s:v {width}x{height} -r {fps}'
    if codec == "evc":
        return f'ffmpeg -y {input_opts} -i "{input_path}" -c:v libxeve "{output_path}"'
    elif codec == "vvc":
        return f'ffmpeg -y {input_opts} -i "{input_path}" -c:v libvvenc "{output_path}"'

  

# Taxa de bits per segon
def get_video_fps(path):
    try:
        result = subprocess.run(
            ['ffprobe', '-v', 'error', '-select_streams', 'v:0',
             '-show_entries', 'stream=r_frame_rate', '-of', 'default=noprint_wrappers=1:nokey=1', path],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        fps_str = result.stdout.decode().strip()
        if '/' in fps_str:
            num, den = map(int, fps_str.split('/'))
            return round(num / den)
        return int(float(fps_str))
    except Exception as e:
        return 25  # Valor per defecte
    

def process_video(file_path, codec, platform, categoria):
    video_name = os.path.basename(file_path)
    ext = ".evc" if codec == "evc" else ".vvc"
    output_path = file_path.replace(".yuv", ext)

    # Col·loquem el vídeo a la BD si no existeix
    cursor.execute("SELECT id_video FROM VIDEOS WHERE nom = %s", (video_name,))
    result = cursor.fetchone()
    if not result:
        fps = get_video_fps(file_path)
        cursor.execute("INSERT INTO VIDEOS (nom, categoria, fps) VALUES (%s, %s, %s)", (video_name, categoria, fps))
        conn.commit()
        cursor.execute("SELECT LAST_INSERT_ID()")
        id_video = cursor.fetchone()[0]
    else:
        id_video = result[0]

    # Temps d'inici i ús de CPU abans
    start_time = time.time()
    mem_before = psutil.Process().memory_info().rss / (1024 * 1024)  # MB

    # Execució del codificador
    cmd = ffmpeg_command(file_path, output_path, codec)
    os.system(cmd)

    # Temps final i mètriques
    end_time = time.time()  
    mem_after = psutil.Process().memory_info().rss / (1024 * 1024)  # MB

    io_read_mb = psutil.Process().io_counters().read_bytes / (1024 * 1024)
    output_size_mb = os.path.getsize(output_path) / (1024 * 1024)
    
    total_time_sec = round(end_time - start_time, 2)
    mem_used_mb = mem_after - mem_before

    table = "VVC_ENCODER" if codec == "vvc" else "EVC_ENCODER"

    cursor.execute(f"""
        INSERT INTO {table} (id_video, platform, memory_used_mb, io_read_mb, temps_total_sec, mida_sortida_mb)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        id_video, platform, mem_used_mb, io_read_mb, total_time_sec, output_size_mb))
    conn.commit()
    
    print(f"OK!{codec.upper()} codificat: {video_name} ,{round(output_size_mb,2)} MB en {total_time_sec}s")


def main():
    while True:
        print("\n--- MENÚ TFG CODIFICADOR ---")
        print("1. Codificar amb EVC")
        print("2. Codificar amb VVC")
        print("3. Sortir")
        opcio = input("Escull una opció: ")

        if opcio == "1":
            codec = "evc"
        elif opcio == "2":
            codec = "vvc"
        elif opcio == "3":
            print("Sortint...")
            break
        else:
            print("Opció no vàlida.")
            continue

        categoria = input("Introdueix la categoria (ex. sport, film...): ").strip()
        carpeta = os.path.join(BASE_DIR, categoria)

        if not os.path.isdir(carpeta):
            print("Categoria no trobada.")
            continue
        
        for arxiu in os.listdir(carpeta):
            if arxiu.endswith(".yuv"):
                path_video = os.path.join(carpeta, arxiu)
                process_video(path_video, codec, platform="windows", categoria=categoria)

if __name__ == "__main__":
    main()
