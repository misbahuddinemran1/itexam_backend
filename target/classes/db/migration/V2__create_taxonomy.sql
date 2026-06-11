-- V1__create_taxonomy.sql

CREATE TABLE subjects (
    id            CHAR(36)        NOT NULL DEFAULT (UUID()),
    name          VARCHAR(100)    NOT NULL,
    name_bn       VARCHAR(100),
    code          VARCHAR(20)     NOT NULL UNIQUE,
    is_active     TINYINT(1)      NOT NULL DEFAULT 1,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_subjects_code (code),
    INDEX idx_subjects_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE chapters (
    id            CHAR(36)        NOT NULL DEFAULT (UUID()),
    subject_id    CHAR(36)        NOT NULL,
    name          VARCHAR(200)    NOT NULL,
    name_bn       VARCHAR(200),
    order_index   INT             NOT NULL DEFAULT 0,
    is_active     TINYINT(1)      NOT NULL DEFAULT 1,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_chapters_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(id),
    INDEX idx_chapters_subject (subject_id),
    INDEX idx_chapters_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE topics (
    id            CHAR(36)        NOT NULL DEFAULT (UUID()),
    chapter_id    CHAR(36)        NOT NULL,
    name          VARCHAR(200)    NOT NULL,
    name_bn       VARCHAR(200),
    description   TEXT,
    order_index   INT             NOT NULL DEFAULT 0,
    is_active     TINYINT(1)      NOT NULL DEFAULT 1,
    created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                  ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_topics_chapter
        FOREIGN KEY (chapter_id) REFERENCES chapters(id),
    INDEX idx_topics_chapter (chapter_id),
    INDEX idx_topics_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;