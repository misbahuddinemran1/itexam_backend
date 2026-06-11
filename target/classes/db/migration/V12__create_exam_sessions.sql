CREATE TABLE special_exams (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    title               VARCHAR(200)    NOT NULL,
    title_bn            VARCHAR(200),
    description         TEXT,
    exam_category       ENUM('MOCK_TEST','BATTLE','WRITTEN',
                             'LIVE','CUSTOM','CHALLENGE')
                        NOT NULL DEFAULT 'MOCK_TEST',
    exam_type_id        CHAR(36),
    required_plan       ENUM('FREE','MONTHLY','YEARLY')
                        NOT NULL DEFAULT 'FREE',
    total_questions     INT             NOT NULL DEFAULT 30,
    time_limit_minutes  INT             NOT NULL DEFAULT 30,
    negative_marking    TINYINT(1)      NOT NULL DEFAULT 0,
    negative_value      DECIMAL(4,2)    NOT NULL DEFAULT 0.25,
    pass_percentage     DECIMAL(5,2)    NOT NULL DEFAULT 40,
    max_participants    INT,
    is_scheduled        TINYINT(1)      NOT NULL DEFAULT 0,
    scheduled_at        DATETIME,
    ends_at             DATETIME,
    show_leaderboard    TINYINT(1)      NOT NULL DEFAULT 1,
    show_result_instantly TINYINT(1)    NOT NULL DEFAULT 1,
    is_active           TINYINT(1)      NOT NULL DEFAULT 1,
    created_by          CHAR(36)        NOT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_sexam_examtype
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id),
    INDEX idx_sexam_category  (exam_category),
    INDEX idx_sexam_plan      (required_plan),
    INDEX idx_sexam_active    (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_exam_sessions (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    special_exam_id     CHAR(36),
    exam_type_id        CHAR(36),
    topic_id            CHAR(36),
    session_type        ENUM('MOCK','PRACTICE','TOPIC_WISE',
                             'BATTLE','WRITTEN','LIVE','CUSTOM','CHALLENGE')
                        NOT NULL DEFAULT 'PRACTICE',
    status              ENUM('IN_PROGRESS','COMPLETED','ABANDONED','TIMED_OUT')
                        NOT NULL DEFAULT 'IN_PROGRESS',
    total_questions     INT             NOT NULL DEFAULT 0,
    attempted_count     INT             NOT NULL DEFAULT 0,
    correct_count       INT             NOT NULL DEFAULT 0,
    wrong_count         INT             NOT NULL DEFAULT 0,
    skip_count          INT             NOT NULL DEFAULT 0,
    score               DECIMAL(8,2)    NOT NULL DEFAULT 0,
    percentage          DECIMAL(5,2)    NOT NULL DEFAULT 0,
    time_spent_sec      INT             NOT NULL DEFAULT 0,
    is_passed           TINYINT(1)      NOT NULL DEFAULT 0,
    rank_in_exam        INT,
    percentile          DECIMAL(5,2),
    started_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at        DATETIME,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_usession_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_usession_sexam
        FOREIGN KEY (special_exam_id) REFERENCES special_exams(id),
    CONSTRAINT fk_usession_examtype
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id),
    INDEX idx_usession_user   (user_id),
    INDEX idx_usession_status (status),
    INDEX idx_usession_type   (session_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_question_attempts (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    session_id          CHAR(36)        NOT NULL,
    question_id         CHAR(36)        NOT NULL,
    selected_option_id  CHAR(36),
    is_correct          TINYINT(1)      NOT NULL DEFAULT 0,
    is_skipped          TINYINT(1)      NOT NULL DEFAULT 0,
    time_spent_sec      INT             NOT NULL DEFAULT 0,
    confidence_level    TINYINT,
    answered_at         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_uattempt_session
        FOREIGN KEY (session_id) REFERENCES user_exam_sessions(id),
    CONSTRAINT fk_uattempt_question
        FOREIGN KEY (question_id) REFERENCES questions(id),
    INDEX idx_uattempt_session  (session_id),
    INDEX idx_uattempt_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE battle_rooms (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    special_exam_id     CHAR(36)        NOT NULL,
    user_id_1           CHAR(36)        NOT NULL,
    user_id_2           CHAR(36),
    session_id_1        CHAR(36),
    session_id_2        CHAR(36),
    status              ENUM('WAITING','IN_PROGRESS','COMPLETED',
                             'CANCELLED','EXPIRED')
                        NOT NULL DEFAULT 'WAITING',
    winner_user_id      CHAR(36),
    room_code           VARCHAR(10)     UNIQUE,
    is_private          TINYINT(1)      NOT NULL DEFAULT 0,
    expires_at          DATETIME,
    started_at          DATETIME,
    completed_at        DATETIME,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_battle_sexam
        FOREIGN KEY (special_exam_id) REFERENCES special_exams(id),
    CONSTRAINT fk_battle_user1
        FOREIGN KEY (user_id_1) REFERENCES users(id),
    CONSTRAINT fk_battle_user2
        FOREIGN KEY (user_id_2) REFERENCES users(id),
    INDEX idx_battle_status    (status),
    INDEX idx_battle_room_code (room_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE written_answers (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    session_id          CHAR(36)        NOT NULL,
    question_id         CHAR(36)        NOT NULL,
    answer_text         MEDIUMTEXT      NOT NULL,
    word_count          INT             NOT NULL DEFAULT 0,
    ai_score            DECIMAL(5,2),
    ai_feedback         TEXT,
    ai_verified_at      DATETIME,
    manual_score        DECIMAL(5,2),
    manual_feedback     TEXT,
    reviewed_by         CHAR(36),
    reviewed_at         DATETIME,
    final_score         DECIMAL(5,2),
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_written_session
        FOREIGN KEY (session_id) REFERENCES user_exam_sessions(id),
    INDEX idx_written_session  (session_id),
    INDEX idx_written_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE leaderboard (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    exam_type_id    CHAR(36),
    special_exam_id CHAR(36),
    period_type     ENUM('DAILY','WEEKLY','MONTHLY','ALL_TIME')
                    NOT NULL DEFAULT 'ALL_TIME',
    total_score     DECIMAL(10,2)   NOT NULL DEFAULT 0,
    total_sessions  INT             NOT NULL DEFAULT 0,
    total_attempts  INT             NOT NULL DEFAULT 0,
    accuracy_rate   DECIMAL(5,2)    NOT NULL DEFAULT 0,
    rank_position   INT,
    percentile      DECIMAL(5,2),
    period_start    DATE,
    computed_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_leader_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_leader_examtype
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id),
    CONSTRAINT fk_leader_sexam
        FOREIGN KEY (special_exam_id) REFERENCES special_exams(id),
    INDEX idx_leader_examtype (exam_type_id, period_type),
    INDEX idx_leader_sexam    (special_exam_id, period_type),
    INDEX idx_leader_user     (user_id),
    INDEX idx_leader_rank     (rank_position)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;