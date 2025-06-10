#!/data/data/com.termux/files/usr/bin/bash

# === CONFIGURACIÓ ===
CATEGORIA="cartoon"                                       # Categoria dels vídeos
VVENC_APP="$HOME/vvencapp"                                # Ruta cap al binari VVC (amb permisos d'execució)
INPUT_DIR="/sdcard/Download/TFG/videos/$CATEGORIA"        # Carpeta d'entrada amb vídeos .yuv
OUTPUT_DIR="/sdcard/Download/TFG/encoded/vvc"             # Carpeta de sortida
RESULTS_DIR="/sdcard/Download/TFG/results"                # Carpeta per guardar resultats
CSV_FILE="$RESULTS_DIR/vvc_results.csv"                   # Fitxer CSV de resultats

WIDTH=1920                                                # Amplada del vídeo
HEIGHT=1080                                               # Alçada del vídeo
FPS=25                                                    # FPS del vídeo
QP=32                                                     # Quantization Parameter

# === CREAR CARPETES SI NO EXISTEIXEN ===
mkdir -p "$OUTPUT_DIR"
mkdir -p "$RESULTS_DIR"

# === CREAR CAPÇALERA DEL CSV SI NO EXISTEIX ===
if [ ! -f "$CSV_FILE" ]; then
    echo "nom_video,categoria,fps,platform,memory_used_mb,io_read_mb,temps_total_sec,mida_sortida_mb" > "$CSV_FILE"
fi

# === CODIFICAR CADA .yuv DE LA CATEGORIA ===
for yuv_file in "$INPUT_DIR"/*.yuv; do
    base_name=$(basename "$yuv_file" .yuv)
    output_file="$OUTPUT_DIR/${base_name}_vvc.vvc"

    echo "Codificant: $base_name.yuv → $output_file"

    start_time=$(date +%s.%N)
    mem_before=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

    # Codificació amb vvencapp
    "$VVENC_APP" \
        --input "$yuv_file" \
        --size ${WIDTH}x${HEIGHT} \
        --framerate $FPS \
        --qp $QP \
        --format yuv420 \
        --output "$output_file"

    end_time=$(date +%s.%N)
    temps_total_sec=$(echo "$end_time - $start_time" | bc)

    mem_after=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    memory_used_kb=$((mem_before - mem_after))
    memory_used_mb=$(echo "scale=2; $memory_used_kb / 1024" | bc)

    read_bytes=$(cat /proc/$$/io | grep read_bytes | awk '{print $2}')
    io_read_mb=$(echo "scale=2; $read_bytes / 1024 / 1024" | bc)

    if [ -f "$output_file" ]; then
        file_size=$(stat -c %s "$output_file")
        mida_sortida_mb=$(echo "scale=2; $file_size / 1024 / 1024" | bc)
    else
        mida_sortida_mb=0
    fi

    echo "${base_name}.yuv,$CATEGORIA,$FPS,android,$memory_used_mb,$io_read_mb,$temps_total_sec,$mida_sortida_mb" >> "$CSV_FILE"

    echo "✔️ Fet: $output_file"
    echo "--------------------------"
done
