CREATE TABLE IF NOT EXISTS steam.Hw_Survey
(
    id   BIGSERIAL PRIMARY KEY,
    date date UNIQUE NOT NULL DEFAULT CURRENT_DATE
);


CREATE TABLE IF NOT EXISTS steam.RamConfiguration
(
    id           BIGSERIAL PRIMARY KEY,
    min_capacity DECIMAL(10, 2) NOT NULL CHECK ( min_capacity >= 0 ),
    max_capacity DECIMAL(10, 2) CHECK ( max_capacity >= 0),

    UNIQUE (min_capacity, max_capacity)
);


CREATE TABLE IF NOT EXISTS steam.Hw_Survey_Ram_Configuration
(
    hw_survey_id         BIGINT         NOT NULL,
    ram_configuration_id BIGINT         NOT NULL,
    percentage           DECIMAL(10, 2) NOT NULL CHECK ( percentage >= 0 ),

    PRIMARY KEY (hw_survey_id, ram_configuration_id, percentage),

    FOREIGN KEY (hw_survey_id)
        REFERENCES steam.Hw_Survey (id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (ram_configuration_id)
        REFERENCES steam.RamConfiguration (id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS steam.GpuManufacturer
(
    id   BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS steam.GpuConfig
(
    id              BIGSERIAL PRIMARY KEY,
    model           VARCHAR(255) NOT NULL,
    sub_brand       VARCHAR(255),
    manufacturer_id BIGINT       NOT NULL,

    UNIQUE (model, manufacturer_id, sub_brand),

    FOREIGN KEY (manufacturer_id)
        REFERENCES steam.GpuManufacturer (id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS steam.Hw_Survey_Gpu_Config
(
    hw_survey_id  BIGINT         NOT NULL,
    gpu_config_id BIGINT         NOT NULL,
    percentage    DECIMAL(10, 2) NOT NULL CHECK ( percentage >= 0 ),

    PRIMARY KEY (hw_survey_id, gpu_config_id, percentage),

    FOREIGN KEY (hw_survey_id)
        REFERENCES steam.Hw_Survey (id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (gpu_config_id)
        REFERENCES steam.GpuConfig (id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS steam.OsVersion
(
    id           BIGSERIAL PRIMARY KEY,
    os           VARCHAR(255) NOT NULL,
    version      VARCHAR(255) NOT NULL,
    architecture VARCHAR(10)  NOT NULL DEFAULT '64',

    UNIQUE (os, version, architecture)
);

CREATE TABLE IF NOT EXISTS steam.Hw_Survey_Os_Version
(
    hw_survey_id  BIGINT         NOT NULL,
    os_version_id BIGINT         NOT NULL,
    percentage    DECIMAL(10, 2) NOT NULL CHECK ( percentage >= 0 ),

    PRIMARY KEY (hw_survey_id, os_version_id, percentage),

    FOREIGN KEY (hw_survey_id)
        REFERENCES steam.Hw_Survey (id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (os_version_id)
        REFERENCES steam.OsVersion (id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS steam.CpuCount
(
    id    BIGSERIAL PRIMARY KEY,
    count INT NOT NULL DEFAULT 4
);

CREATE TABLE IF NOT EXISTS steam.Hw_Survey_Cpu_Count
(
    hw_survey_id BIGINT         NOT NULL,
    cpu_count_id BIGINT         NOT NULL,
    percentage   DECIMAL(10, 2) NOT NULL CHECK ( percentage >= 0 ),

    PRIMARY KEY (hw_survey_id, cpu_count_id, percentage),

    FOREIGN KEY (hw_survey_id)
        REFERENCES steam.Hw_Survey (id)
        ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (cpu_count_id)
        REFERENCES steam.CpuCount (id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
