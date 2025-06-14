CREATE TABLE VIDEOS (
    id_video INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    categoria VARCHAR(100),
    fps INT
);

CREATE TABLE EVC_ENCODER (
    id_resultat INT AUTO_INCREMENT PRIMARY KEY,
    id_video INT,
    platform VARCHAR(50), 
    memory_used_mb FLOAT,
    io_read_mb FLOAT,
    temps_total_sec FLOAT,
    mida_sortida_mb FLOAT,
    FOREIGN KEY (id_video) REFERENCES VIDEOS(id_video)
);

CREATE TABLE VVC_ENCODER (
    id_resultat INT AUTO_INCREMENT PRIMARY KEY,
    id_video INT,
	platform VARCHAR(50), 
    memory_used_mb FLOAT,
    io_read_mb FLOAT,
    temps_total_sec FLOAT,
    mida_sortida_mb FLOAT,
    FOREIGN KEY (id_video) REFERENCES VIDEOS(id_video)
);



# ======= CARREGAR LES DADES D'ANDROID DE EVC A LA BASE DE DADES ========
CREATE TABLE IF NOT EXISTS TEMP_EVC (	# TAULA TEMPORAL DADES ANDROID EVC
    nom_video VARCHAR(255),
    categoria VARCHAR(100),
    fps INT,
    platform VARCHAR(50),
    memory_used_mb FLOAT,
    io_read_mb FLOAT,
    temps_total_sec FLOAT,
    mida_sortida_mb FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/evc_results.csv'
INTO TABLE TEMP_EVC
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO VIDEOS (nom, categoria, fps)
SELECT DISTINCT nom_video, categoria, fps
FROM TEMP_EVC
WHERE nom_video NOT IN (
    SELECT nom FROM VIDEOS
);

INSERT INTO EVC_ENCODER (id_video, platform, memory_used_mb, io_read_mb, temps_total_sec, mida_sortida_mb)
SELECT v.id_video, t.platform, t.memory_used_mb, t.io_read_mb, t.temps_total_sec, t.mida_sortida_mb
FROM TEMP_EVC t
JOIN VIDEOS v ON t.nom_video = v.nom;
# =======================================================================

# ======= CARREGAR LES DADES D'ANDROID DE VVC A LA BASE DE DADES ========

CREATE TABLE IF NOT EXISTS TEMP_VVC (	# TAULA TEMPORAL DADES ANDROID VVC
    nom_video VARCHAR(255),
    categoria VARCHAR(100),
    fps INT,
    platform VARCHAR(50),
    memory_used_mb FLOAT,
    io_read_mb FLOAT,
    temps_total_sec FLOAT,
    mida_sortida_mb FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vvc_results.csv'
INTO TABLE TEMP_VVC
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO VIDEOS (nom, categoria, fps)
SELECT DISTINCT nom_video, categoria, fps
FROM TEMP_VVC
WHERE nom_video NOT IN (
    SELECT nom FROM VIDEOS
);

INSERT INTO VVC_ENCODER (id_video, platform, memory_used_mb, io_read_mb, temps_total_sec, mida_sortida_mb)
SELECT v.id_video, t.platform, t.memory_used_mb, t.io_read_mb, t.temps_total_sec, t.mida_sortida_mb
FROM TEMP_VVC t
JOIN VIDEOS v ON t.nom_video = v.nom;
# ======================================================================


# ======================= VISUALITZAR DADES EVC =========================
SELECT * FROM EVC_ENCODER encoder
JOIN VIDEOS videos ON encoder.id_video = videos.id_video
WHERE videos.categoria = 'videogame';
# =======================================================================


# ======================= VISUALITZAR DADES VVC =========================
SELECT * FROM VVC_ENCODER encoder
JOIN VIDEOS videos ON encoder.id_video = videos.id_video
WHERE videos.categoria = 'videogame';
# =======================================================================


# ====================== OBTENIR MITJANES DADES =========================
SELECT 
    E.platform,
    'VVC' AS codec,
    AVG(E.io_read_mb) AS mitjana_io_read_mb,
    AVG(E.temps_total_sec) AS mitjana_temps_total_sec,
    AVG(E.mida_sortida_mb) AS mitjana_mida_sortida_mb
FROM 
    VVC_ENCODER E
GROUP BY 
    E.platform;
# =======================================================================


# ===================== EXTRACCIÓ DELS PARÀMETRES =======================
SELECT 
    'EVC' AS codificador,
    platform,
    AVG(io_read_mb) AS io_read_mitjana,
    MIN(io_read_mb) AS io_read_minima,
    MAX(io_read_mb) AS io_read_maxima
FROM 
    EVC_ENCODER
GROUP BY 
    platform

UNION ALL

SELECT 
    'VVC' AS codificador,
    platform,
    AVG(io_read_mb) AS io_read_mitjana,
    MIN(io_read_mb) AS io_read_minima,
    MAX(io_read_mb) AS io_read_maxima
FROM 
    VVC_ENCODER
GROUP BY 
    platform;
# =======================================================================


# ============ EXTRACCIÓ DELS PARÀMETRES PER CATEGORIA ==================
SELECT 
    V.categoria,
    'EVC' AS codificador,
    E.platform,
    AVG(E.io_read_mb) AS io_read_mitjana
FROM EVC_ENCODER E
JOIN VIDEOS V ON E.id_video = V.id_video
GROUP BY V.categoria, E.platform

UNION ALL

SELECT 
    V.categoria,
    'VVC' AS codificador,
    VVC.platform,
    AVG(VVC.io_read_mb) AS io_read_mitjana
FROM VVC_ENCODER VVC
JOIN VIDEOS V ON VVC.id_video = V.id_video
GROUP BY V.categoria, VVC.platform;
# =======================================================================


# ==================== VISUALITZAR TOTES LES DADES ======================
SELECT 
    V.categoria,
    V.nom AS nom_video,
    'EVC' AS codificador,
    E.platform,
    E.mida_sortida_mb,
    E.temps_total_sec,
    E.io_read_mb
FROM 
    EVC_ENCODER E
JOIN 
    VIDEOS V ON E.id_video = V.id_video

UNION ALL

SELECT 
    V.categoria,
    V.nom AS nom_video,
    'VVC' AS codificador,
    VVC.platform,
    VVC.mida_sortida_mb,
    VVC.temps_total_sec,
    VVC.io_read_mb
FROM 
    VVC_ENCODER VVC
JOIN 
    VIDEOS V ON VVC.id_video = V.id_video;
# =======================================================================
