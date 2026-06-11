CREATE TABLE certificates (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    session_id          CHAR(36)        NOT NULL,
    exam_type_id        CHAR(36),
    special_exam_id     CHAR(36),
    certificate_number  VARCHAR(50)     NOT NULL UNIQUE,
    title               VARCHAR(200)    NOT NULL,
    score               DECIMAL(8,2)    NOT NULL,
    percentage          DECIMAL(5,2)    NOT NULL,
    grade               VARCHAR(10),
    issued_at           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at          DATETIME,
    pdf_url             VARCHAR(500),
    is_valid            TINYINT(1)      NOT NULL DEFAULT 1,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_cert_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_cert_session
        FOREIGN KEY (session_id) REFERENCES user_exam_sessions(id),
    INDEX idx_cert_user   (user_id),
    INDEX idx_cert_number (certificate_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE referrals (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    referrer_user_id        CHAR(36)        NOT NULL,
    referred_user_id        CHAR(36)        NOT NULL,
    referral_code           VARCHAR(20)     NOT NULL,
    status                  ENUM('PENDING','COMPLETED','REWARD_GIVEN')
                            NOT NULL DEFAULT 'PENDING',
    referrer_reward_value   DECIMAL(10,2)   NOT NULL DEFAULT 7,
    referred_reward_value   DECIMAL(10,2)   NOT NULL DEFAULT 7,
    completed_at            DATETIME,
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_ref_referrer
        FOREIGN KEY (referrer_user_id) REFERENCES users(id),
    CONSTRAINT fk_ref_referred
        FOREIGN KEY (referred_user_id) REFERENCES users(id),
    UNIQUE KEY uq_referred  (referred_user_id),
    INDEX idx_ref_referrer  (referrer_user_id),
    INDEX idx_ref_code      (referral_code),
    INDEX idx_ref_status    (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_referral_codes (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id                 CHAR(36)        NOT NULL UNIQUE,
    code                    VARCHAR(20)     NOT NULL UNIQUE,
    total_referrals         INT             NOT NULL DEFAULT 0,
    successful_referrals    INT             NOT NULL DEFAULT 0,
    total_rewards           DECIMAL(10,2)   NOT NULL DEFAULT 0,
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_refcode_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_refcode_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE question_bookmarks (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    question_id     CHAR(36)        NOT NULL,
    note            TEXT,
    folder          VARCHAR(100)    NOT NULL DEFAULT 'Default',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_bookmark_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_bookmark_question
        FOREIGN KEY (question_id) REFERENCES questions(id),
    UNIQUE KEY uq_user_question (user_id, question_id),
    INDEX idx_bookmark_user   (user_id),
    INDEX idx_bookmark_folder (user_id, folder)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE bookmark_folders (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    name            VARCHAR(100)    NOT NULL,
    color_code      VARCHAR(7)      DEFAULT '#6366f1',
    question_count  INT             NOT NULL DEFAULT 0,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_folder_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY uq_user_folder (user_id, name),
    INDEX idx_folder_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_question_reports (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    question_id     CHAR(36)        NOT NULL,
    report_type     ENUM('WRONG_ANSWER','TYPO','OUTDATED',
                         'AMBIGUOUS','DUPLICATE','INAPPROPRIATE') NOT NULL,
    description     TEXT,
    status          ENUM('OPEN','UNDER_REVIEW','RESOLVED','DISMISSED')
                    NOT NULL DEFAULT 'OPEN',
    resolved_by     CHAR(36),
    resolution_note TEXT,
    notified_user   TINYINT(1)      NOT NULL DEFAULT 0,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_report_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_report_question
        FOREIGN KEY (question_id) REFERENCES questions(id),
    INDEX idx_report_user     (user_id),
    INDEX idx_report_question (question_id),
    INDEX idx_report_status   (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_friends (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    friend_id       CHAR(36)        NOT NULL,
    status          ENUM('PENDING','ACCEPTED','BLOCKED')
                    NOT NULL DEFAULT 'PENDING',
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_friend_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_friend_friend
        FOREIGN KEY (friend_id) REFERENCES users(id),
    UNIQUE KEY uq_friendship (user_id, friend_id),
    INDEX idx_friend_user   (user_id),
    INDEX idx_friend_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;