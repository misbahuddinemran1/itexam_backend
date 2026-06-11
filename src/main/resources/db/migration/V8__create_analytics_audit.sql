-- Per-question analytics (AI training data)
CREATE TABLE question_analytics (
    id                      VARCHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id             VARCHAR(36)     NOT NULL UNIQUE,

    total_attempts         BIGINT          NOT NULL DEFAULT 0,
    correct_attempts       BIGINT          NOT NULL DEFAULT 0,
    skip_count             BIGINT          NOT NULL DEFAULT 0,

    avg_time_spent_sec     DECIMAL(8,2)    NOT NULL DEFAULT 0,
    accuracy_rate          DECIMAL(5,2)    NOT NULL DEFAULT 0
                            COMMENT 'Auto: correct/total * 100',

    difficulty_score_actual DECIMAL(3,2)
                            COMMENT 'AI computed vs admin assigned',

    discrimination_index    DECIMAL(3,2)
                            COMMENT 'IRT: top27% - bottom27%',

    last_computed_at       DATETIME,
    updated_at             DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CONSTRAINT fk_qa_question
        FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Audit log (write-only, high volume)
CREATE TABLE audit_logs (
    id              BIGINT          NOT NULL AUTO_INCREMENT,

    actor_id        VARCHAR(36)     NOT NULL,
    actor_type      ENUM('ADMIN','SYSTEM','AI') NOT NULL DEFAULT 'ADMIN',

    action          VARCHAR(100)    NOT NULL
                    COMMENT 'QUESTION_CREATED, QUESTION_APPROVED etc',

    resource_type   VARCHAR(50)     NOT NULL
                    COMMENT 'QUESTION, CONCEPT, TAG etc',

    resource_id     VARCHAR(36)     NOT NULL,

    old_value       JSON,
    new_value       JSON,

    ip_address      VARCHAR(45),

    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    INDEX idx_audit_actor       (actor_id),
    INDEX idx_audit_resource    (resource_type, resource_id),
    INDEX idx_audit_action      (action),
    INDEX idx_audit_created     (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Bulk upload tracking
CREATE TABLE bulk_upload_jobs (
    id              VARCHAR(36)     NOT NULL DEFAULT (UUID()),
    uploaded_by     VARCHAR(36)     NOT NULL,

    file_name       VARCHAR(255)    NOT NULL,
    file_size_kb    INT             NOT NULL,

    total_rows      INT             NOT NULL DEFAULT 0,
    valid_rows      INT             NOT NULL DEFAULT 0,
    failed_rows     INT             NOT NULL DEFAULT 0,
    imported_rows   INT             NOT NULL DEFAULT 0,

    status          ENUM(
                        'UPLOADED',
                        'VALIDATING',
                        'VALIDATION_DONE',
                        'IMPORTING',
                        'COMPLETED',
                        'FAILED'
                    ) NOT NULL DEFAULT 'UPLOADED',

    error_report    JSON,
    started_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at    DATETIME,

    PRIMARY KEY (id),

    INDEX idx_bulk_uploader (uploaded_by),
    INDEX idx_bulk_status   (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;