CREATE TABLE options (
    id              VARCHAR(36)     NOT NULL DEFAULT (UUID()),
    question_id     VARCHAR(36)     NOT NULL,

    option_key      CHAR(1)         NOT NULL COMMENT 'A B C D',
    option_text     TEXT            NOT NULL,
    option_text_bn  TEXT,

    is_correct      TINYINT(1)      NOT NULL DEFAULT 0,

    explanation     TEXT,
    explanation_bn  TEXT,

    order_index     TINYINT         NOT NULL DEFAULT 0,

    selection_count BIGINT          NOT NULL DEFAULT 0
                    COMMENT 'How many users selected this option',

    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CONSTRAINT fk_options_question
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_option_key (question_id, option_key),
    INDEX idx_options_question (question_id),
    INDEX idx_options_correct (question_id, is_correct)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;