CREATE TABLE user_topic_weakness (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    topic_id            CHAR(36)        NOT NULL,
    exam_type_id        CHAR(36),
    total_attempts      INT             NOT NULL DEFAULT 0,
    correct_attempts    INT             NOT NULL DEFAULT 0,
    accuracy_rate       DECIMAL(5,2)    NOT NULL DEFAULT 0,
    weakness_score      DECIMAL(5,2)    NOT NULL DEFAULT 0.5,
    avg_time_spent_sec  DECIMAL(8,2)    NOT NULL DEFAULT 0,
    last_attempted_at   DATETIME,
    last_computed_at    DATETIME,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_weakness_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uq_user_topic_exam (user_id, topic_id, exam_type_id),
    INDEX idx_weakness_user  (user_id),
    INDEX idx_weakness_score (weakness_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_concept_weakness (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    concept_id          CHAR(36)        NOT NULL,
    total_attempts      INT             NOT NULL DEFAULT 0,
    correct_attempts    INT             NOT NULL DEFAULT 0,
    accuracy_rate       DECIMAL(5,2)    NOT NULL DEFAULT 0,
    weakness_score      DECIMAL(5,2)    NOT NULL DEFAULT 0.5,
    last_computed_at    DATETIME,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_cweakness_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uq_user_concept (user_id, concept_id),
    INDEX idx_cweakness_user  (user_id),
    INDEX idx_cweakness_score (weakness_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_performance_summary (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id                 CHAR(36)        NOT NULL UNIQUE,
    total_sessions          INT             NOT NULL DEFAULT 0,
    total_questions_seen    INT             NOT NULL DEFAULT 0,
    total_correct           INT             NOT NULL DEFAULT 0,
    overall_accuracy        DECIMAL(5,2)    NOT NULL DEFAULT 0,
    total_study_time_min    INT             NOT NULL DEFAULT 0,
    avg_score_per_exam      DECIMAL(8,2)    NOT NULL DEFAULT 0,
    best_score              DECIMAL(8,2)    NOT NULL DEFAULT 0,
    best_score_exam         VARCHAR(200),
    strongest_topic_id      CHAR(36),
    weakest_topic_id        CHAR(36),
    battles_played          INT             NOT NULL DEFAULT 0,
    battles_won             INT             NOT NULL DEFAULT 0,
    last_computed_at        DATETIME,
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_perf_user
        FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_misconceptions (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    question_id         CHAR(36)        NOT NULL,
    wrong_option_id     CHAR(36)        NOT NULL,
    select_count        INT             NOT NULL DEFAULT 1,
    concept_id          CHAR(36),
    last_occurred_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_misc_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uq_user_question_option
        (user_id, question_id, wrong_option_id),
    INDEX idx_misc_user    (user_id),
    INDEX idx_misc_concept (concept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_activity_logs (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    user_id         CHAR(36)        NOT NULL,
    activity_type   ENUM('LOGIN','LOGOUT','EXAM_STARTED',
                         'EXAM_COMPLETED','SUBSCRIPTION_PURCHASED',
                         'PASSWORD_CHANGED','PROFILE_UPDATED',
                         'BATTLE_STARTED','BATTLE_COMPLETED') NOT NULL,
    metadata        JSON,
    ip_address      VARCHAR(45),
    device_type     VARCHAR(50),
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_actlog_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_actlog_user (user_id),
    INDEX idx_actlog_type (activity_type),
    INDEX idx_actlog_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;