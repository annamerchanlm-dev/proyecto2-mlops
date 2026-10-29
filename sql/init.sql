-- =========================================================
-- Proyecto 2 MLOps - Esquema de datos (base: mlops_data)
-- Re-ejecutable: no borra datos existentes
-- =========================================================

-- RAW: datos tal como llegan del archivo fuente
CREATE TABLE IF NOT EXISTS raw_data (
    id           BIGSERIAL    PRIMARY KEY,
    batch_id     INTEGER      NOT NULL,                    -- lote de carga
    load_ts      TIMESTAMPTZ  NOT NULL DEFAULT now(),      -- fecha y hora de carga
    source_file  TEXT         NOT NULL,                    -- origen del dato
    row_hash     CHAR(64)     NOT NULL UNIQUE,             -- id único / anti-duplicados
    status       TEXT         NOT NULL DEFAULT 'loaded',   -- loaded | processed | error
    payload      JSONB        NOT NULL                     -- fila original completa
);
CREATE INDEX IF NOT EXISTS idx_raw_batch  ON raw_data (batch_id);
CREATE INDEX IF NOT EXISTS idx_raw_status ON raw_data (status);

-- CLEAN: datos listos para entrenamiento
-- PENDIENTE: B define las columnas de features tras la EDA
CREATE TABLE IF NOT EXISTS clean_data (
    id           BIGSERIAL    PRIMARY KEY,
    raw_id       BIGINT       NOT NULL UNIQUE REFERENCES raw_data(id),
    batch_id     INTEGER      NOT NULL,
    processed_ts TIMESTAMPTZ  NOT NULL DEFAULT now()
    -- , <features de B> ...
    -- , target  SMALLINT NOT NULL
);

-- INFERENCE LOGS: una fila por cada llamada a /predict
CREATE TABLE IF NOT EXISTS inference_logs (
    id               BIGSERIAL    PRIMARY KEY,
    request_id       UUID         NOT NULL UNIQUE,         -- identificador de la solicitud
    inference_ts     TIMESTAMPTZ  NOT NULL DEFAULT now(),  -- fecha y hora
    input_data       JSONB        NOT NULL,                -- datos de entrada
    prediction       TEXT         NOT NULL,                -- predicción
    score            DOUBLE PRECISION,                     -- probabilidad (si aplica)
    model_name       TEXT         NOT NULL,                -- nombre del modelo
    model_version    TEXT         NOT NULL,                -- versión o alias (champion)
    latency_ms       DOUBLE PRECISION NOT NULL             -- tiempo de respuesta
);
CREATE INDEX IF NOT EXISTS idx_inf_ts ON inference_logs (inference_ts);