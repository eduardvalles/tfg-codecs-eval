# Estudi comparatiu dels estàndards emergents de vídeo EVC i VVC en Windows i Android

Aquest projecte forma part del Treball de Fi de Grau en Sistemes Audiovisuals, i té com a objectiu analitzar i comparar el rendiment computacional dels estàndards de codificació de vídeo **EVC (Essential Video Coding)** i **VVC (Versatile Video Coding)** en dos entorns diferents: **Windows** i **Android**.

He decidit crear aquest repositori per oferir una eina de codi obert a qualsevol persona o investigador/a que vulgui analitzar el rendiment i cost computacional del procés de codificació de vídeo amb els estàndards **Essential Video Coding (EVC)**, **Versatile Video Coding (VVC)** i **FFmpeg amb EVC**.

## Scripts 
S'han inclòs els scripts desenvolupats necessaris per codificar amb els estàndards **EVC i **VVC** en l'entorn de **Windows** i en **Android**, així com l'script de conversió de vídeos al format en brut .YUV.

### Windows
En el cas de windows, només cal executar l'script per codificar EVC i VVC a través d'un menú interactiu que facilita l'extracció de dades de codificació.

### Android
Si es vol codificar en Android, s'han d'editar els scripts de EVC i VVC manualment per introduir la categoria a la secció _CONFIGURACIÓ_. Durant el projecte s'ha fet servir l'aplicació Termux per editar i executar el codi en Android

En qualsevol dels casos, un cop executat, el codi s'encarrega de codificar tots els vídeos de la categoria (nom de la carpeta) introduida.

## Vídeos
L'estudi s'ha realitzat amb 90 vídeos (10 vídeos de 9 categories diferent, ex: Dibuixos Animats, Esports, Entrevistes, etc.) descarregats de youtube. En general es poden fer servir qualsevol tipus de vídeos. Els scripts originals estan pensats per transformar vídeos .mp4 a .yuv però es pot modificar alterant el codi mp4_to_yuv_converter.py. En qualsevol cas, la codificació s'haurà de realitzar sempre amb el format brut dels vídeos (.yuv).
