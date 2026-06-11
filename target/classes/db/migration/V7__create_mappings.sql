-- Question <-> Concept (Many-to-Many with weight)
CREATE TABLE question_concepts (
    id              VARCHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id     VARCHAR(36)     NOT NULL,
    concept_id      VARCHAR(36)     NOT NULL,

    weight          DECIMAL(3,2)    NOT NULL DEFAULT 1.00
                    COMMENT '0.1 to 1.0 - how central is this concept',

    is_primary      TINYINT(1)      NOT NULL DEFAULT 0
                    COMMENT 'Main concept being tested',

    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CONSTRAINT fk_qc_question
        FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_qc_concept
        FOREIGN KEY (concept_id) REFERENCES concepts(id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_question_concept (question_id, concept_id),
    INDEX idx_qc_question (question_id),
    INDEX idx_qc_concept (concept_id),
    INDEX idx_qc_primary (concept_id, is_primary)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Question <-> Tag (Many-to-Many)
CREATE TABLE question_tags (
    question_id     VARCHAR(36)     NOT NULL,
    tag_id          VARCHAR(36)     NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (question_id, tag_id),

    CONSTRAINT fk_qt_question
        FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_qt_tag
        FOREIGN KEY (tag_id) REFERENCES tags(id)
        ON DELETE CASCADE,

    INDEX idx_qt_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Question <-> ExamType (Many-to-Many)
CREATE TABLE question_exam_types (
    question_id         VARCHAR(36)     NOT NULL,
    exam_type_id        VARCHAR(36)     NOT NULL,

    relevance_score     DECIMAL(3,2)    NOT NULL DEFAULT 1.00,

    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (question_id, exam_type_id),

    CONSTRAINT fk_qet_question
        FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_qet_examtype
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id)
        ON DELETE CASCADE,

    INDEX idx_qet_examtype (exam_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Question Version History
CREATE TABLE question_versions (
    id                  VARCHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id         VARCHAR(36)     NOT NULL,

    version_number      INT             NOT NULL,
    question_text       MEDIUMTEXT      NOT NULL,

    options_snapshot    JSON            NOT NULL
                        COMMENT 'Full options state at this version',

    changed_by          VARCHAR(36)     NOT NULL,
    change_reason       VARCHAR(500),

    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CONSTRAINT fk_qv_question
        FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_version (question_id, version_number),
    INDEX idx_qv_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Question Reports (User-reported errors)
CREATE TABLE question_reports (
    id              VARCHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id     VARCHAR(36)     NOT NULL,
    reported_by     VARCHAR(36)     NOT NULL COMMENT 'user id',

    report_type     ENUM(
                        'WRONG_ANSWER',
                        'TYPO',
                        'OUTDATED',
                        'AMBIGUOUS',
                        'DUPLICATE'
                    ) NOT NULL,

    description     TEXT,

    status          ENUM(
                        'OPEN',
                        'UNDER_REVIEW',
                        'RESOLVED',
                        'DISMISSED'
                    ) NOT NULL DEFAULT 'OPEN',

    resolved_by     VARCHAR(36),
    resolution_note TEXT,

    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CONSTRAINT fk_qr_question
        FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE,

    INDEX idx_qr_question (question_id),
    INDEX idx_qr_status (status),
    INDEX idx_qr_reporter (reported_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;