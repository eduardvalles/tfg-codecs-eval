#!/data/data/com.termux/files/usr/bin/bash

# === CONFIGURACIÓ ===
CATEGORIA="cartoon"  									# Categoria dels vídeos
XEVE_APP="$HOME/xeve_app"        						# Ruta cap al binari EVC
INPUT_DIR="/sdcard/Download/TFG/videos/$CATEGORIA"  	# Carpeta d'entrada amb vídeos .yuv
OUTPUT_DIR="/sdcard/Download/TFG/encoded/evc"       	# Carpeta de sortida
RESULTS_DIR="/sdcard/Download/TFG/results"          	# Carpeta per guardar resultats
CSV_FILE="/sdcard/Download/TFG/results/evc_results.csv" # Fitxer CSV de resultats

WIDTH=1920                                          # Amplada del vídeo
HEIGHT=1080                                         # Alçada del vídeo
FPS=25                                              # FPS del vídeo
QP=32  												# Quantization Parameter                                              		

# === CREAR CARPETA DE SORTIDA SI NO EXISTEIX ===
mkdir -p "$OUTPUT_DIR"

# === CREAR CAPÇALERA DEL CSV SI NO EXISTEIX ===
if [ ! -f "$CSV_FILE" ]; then
    echo "nom_video,categoria,fps,platform,memory_used_mb,io_read_mb,temps_total_sec,mida_sortida_mb" > "$CSV_FILE"
fi

# === CODIFICAR CADA .yuv DE LA CATEGORIA ===
for yuv_file in "$INPUT_DIR"/*.yuv; do
    base_name=$(basename "$yuv_file" .yuv)
    output_file="$OUTPUT_DIR/${base_name}_evc.evc"

    echo "Codificant: $base_name.yuv → $output_file"
	
	# Mesurar temps inici    
	start_time=$(date +%s.%N)
	
    # Mesurar ús de memòria abans
    mem_before=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    
	# Codificació
    "$XEVE_APP" -i "$yuv_file" -w $WIDTH -h $HEIGHT -z $FPS -q $QP -o "$output_file"
	
	# Temps final i càlcul    
	end_time=$(date +%s.%N)
    temps_total_sec=$(echo "$end_time - $start_time" | bc)
	
    # Mesura memòria després    
	mem_after=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    memory_used_kb=$((mem_before - mem_after))    
	memory_used_mb=$(echo "scale=2; $memory_used_kb / 1024" | bc)
	
    # IO read (MB)
    read_bytes=$(cat /proc/$$/io | grep read_bytes | awk '{print $2}')    
	io_read_mb=$(echo "scale=2; $read_bytes / 1024 / 1024" | bc)
	
    # Mida sortida
    if [ -f "$output_file" ]; then        
		file_size=$(stat -c %s "$output_file")
        mida_sortida_mb=$(echo "scale=2; $file_size / 1024 / 1024" | bc)    
	else
        mida_sortida_mb=0    
	fi
	
	# Escriure resultats al CSV
    echo "${base_name}.yuv,$CATEGORIA,$FPS,android,$memory_used_mb,$io_read_mb,$temps_total_sec,$mida_sortida_mb" >> "$CSV_FILE"
    
    echo "✔️ Fet: $output_file"
    echo "--------------------------"
done
