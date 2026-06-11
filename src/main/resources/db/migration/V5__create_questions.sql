CREATE TABLE questions (
    id                      VARCHAR(36) NOT NULL DEFAULT (UUID()),

    -- CONTENT
    question_text           MEDIUMTEXT NOT NULL
                            COMMENT 'HTML supported, Bengali/English',

    question_text_bn        MEDIUMTEXT,

    question_type           ENUM(
                                'MCQ_SINGLE',
                                'MCQ_MULTI',
                                'TRUE_FALSE'
                            ) NOT NULL DEFAULT 'MCQ_SINGLE',

    language                ENUM('EN','BN','BOTH') NOT NULL DEFAULT 'EN',

    -- KNOWLEDGE HIERARCHY
    subject_id              VARCHAR(36) NOT NULL,
    chapter_id              VARCHAR(36) NOT NULL,
    topic_id                VARCHAR(36) NOT NULL,

    -- QUALITY METADATA
    difficulty_level        TINYINT NOT NULL DEFAULT 3,

    cognitive_level         ENUM(
                                'REMEMBER',
                                'UNDERSTAND',
                                'APPLY',
                                'ANALYZE',
                                'EVALUATE'
                            ) NOT NULL DEFAULT 'REMEMBER',

    estimated_time_sec      SMALLINT NOT NULL DEFAULT 60,

    -- EXAM SOURCE INFO
    source_reference        VARCHAR(500),
    year_appeared           YEAR,
    is_reusable             TINYINT(1) NOT NULL DEFAULT 1,

    -- STATUS WORKFLOW
    status                  ENUM(
                                'DRAFT',
                                'UNDER_REVIEW',
                                'APPROVED',
                                'REJECTED',
                                'ARCHIVED'
                            ) NOT NULL DEFAULT 'DRAFT',

    review_notes            TEXT,
    reported_count          SMALLINT NOT NULL DEFAULT 0,

    -- DUPLICATE DETECTION
    content_hash            CHAR(64),
    UNIQUE KEY uk_content_hash (content_hash),

    -- AI READY FIELDS
    ai_generated            TINYINT(1) NOT NULL DEFAULT 0,
    ai_confidence_score     DECIMAL(3,2),
    embedding_vector        TEXT,

    -- VERSIONING
    version                 INT NOT NULL DEFAULT 1,

    -- AUDIT
    created_by              VARCHAR(36) NOT NULL,
    reviewed_by             VARCHAR(36),

    created_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    -- FOREIGN KEYS
    CONSTRAINT fk_questions_subject
        FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_questions_chapter
        FOREIGN KEY (chapter_id) REFERENCES chapters(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_questions_topic
        FOREIGN KEY (topic_id) REFERENCES topics(id)
        ON DELETE CASCADE,

    -- INDEXES
    INDEX idx_q_status              (status),
    INDEX idx_q_subject_status      (subject_id, status),
    INDEX idx_q_topic_difficulty    (topic_id, difficulty_level, status),
    INDEX idx_q_year                (year_appeared),
    INDEX idx_q_type_status         (question_type, status),
    INDEX idx_q_created_by          (created_by),
    INDEX idx_q_ai_generated        (ai_generated)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;