CREATE TABLE study_streaks (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id                 CHAR(36)        NOT NULL UNIQUE,
    current_streak_days     INT             NOT NULL DEFAULT 0,
    longest_streak_days     INT             NOT NULL DEFAULT 0,
    last_activity_date      DATE,
    streak_freeze_count     INT             NOT NULL DEFAULT 2,
    total_study_days        INT             NOT NULL DEFAULT 0,
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_streak_user
        FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_badges (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    badge_type      ENUM('STREAK_7','STREAK_30','STREAK_100',
                         'FIRST_EXAM','PERFECT_SCORE','TOP_10',
                         'TOP_1','BATTLE_WINNER','FAST_LEARNER',
                         'CONSISTENT') NOT NULL,
    earned_at       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_badge_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uq_user_badge (user_id, badge_type),
    INDEX idx_badge_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_notifications (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    type            ENUM('EXAM_REMINDER','WEAK_TOPIC_ALERT',
                         'NEW_EXAM_AVAILABLE','STREAK_BROKEN',
                         'STREAK_MILESTONE','RANK_CHANGED',
                         'EXAM_RESULT','SUBSCRIPTION_EXPIRING',
                         'SUBSCRIPTION_EXPIRED','PAYMENT_SUCCESS',
                         'BATTLE_INVITE','BATTLE_RESULT',
                         'BADGE_EARNED','SYSTEM') NOT NULL,
    title           VARCHAR(200)    NOT NULL,
    body            TEXT            NOT NULL,
    metadata        JSON,
    is_read         TINYINT(1)      NOT NULL DEFAULT 0,
    delivery_channel ENUM('IN_APP','EMAIL','SMS','PUSH')
                    NOT NULL DEFAULT 'IN_APP',
    sent_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at         DATETIME,
    PRIMARY KEY (id),
    CONSTRAINT fk_notif_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_notif_user (user_id),
    INDEX idx_notif_read (user_id, is_read),
    INDEX idx_notif_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE study_plans (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    exam_type_id        CHAR(36)        NOT NULL,
    title               VARCHAR(200)    NOT NULL,
    target_exam_date    DATE            NOT NULL,
    daily_study_minutes INT             NOT NULL DEFAULT 30,
    status              ENUM('ACTIVE','COMPLETED','PAUSED','ABANDONED')
                        NOT NULL DEFAULT 'ACTIVE',
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_plan_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_plan_examtype
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id),
    INDEX idx_plan_user   (user_id),
    INDEX idx_plan_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE study_plan_topics (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    plan_id                 CHAR(36)        NOT NULL,
    topic_id                CHAR(36)        NOT NULL,
    target_questions_count  INT             NOT NULL DEFAULT 20,
    completed_count         INT             NOT NULL DEFAULT 0,
    scheduled_date          DATE,
    completion_status       ENUM('PENDING','IN_PROGRESS','DONE','SKIPPED')
                            NOT NULL DEFAULT 'PENDING',
    priority_score          DECIMAL(5,2)    NOT NULL DEFAULT 0.5,
    PRIMARY KEY (id),
    CONSTRAINT fk_spt_plan
        FOREIGN KEY (plan_id) REFERENCES study_plans(id),
    INDEX idx_spt_plan   (plan_id),
    INDEX idx_spt_status (completion_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;