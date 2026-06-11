CREATE TABLE users (
    id                      CHAR(36)        NOT NULL DEFAULT (UUID()),
    full_name               VARCHAR(100)    NOT NULL,
    full_name_bn            VARCHAR(100),
    email                   VARCHAR(100)    NOT NULL UNIQUE,
    phone                   VARCHAR(15)     UNIQUE,
    password_hash           VARCHAR(255)    NOT NULL,
    avatar_url              VARCHAR(500),
    date_of_birth           DATE,
    gender                  ENUM('MALE','FEMALE','OTHER'),
    district                VARCHAR(100),
    education_level         ENUM(
                                'SSC','HSC','HONORS',
                                'MASTERS','OTHER'
                            ),
    target_exam             VARCHAR(100)
                            COMMENT 'Primary exam preparing for',
    is_active               TINYINT(1)      NOT NULL DEFAULT 1,
    is_email_verified       TINYINT(1)      NOT NULL DEFAULT 0,
    is_phone_verified       TINYINT(1)      NOT NULL DEFAULT 0,
    email_verify_token      VARCHAR(100),
    password_reset_token    VARCHAR(100),
    password_reset_expires  DATETIME,
    last_login_at           DATETIME,
    login_count             INT             NOT NULL DEFAULT 0,
    referred_by             CHAR(36)        COMMENT 'Referral system',
    created_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                            ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_users_email       (email),
    INDEX idx_users_phone       (phone),
    INDEX idx_users_active      (is_active),
    INDEX idx_users_district    (district),
    INDEX idx_users_target_exam (target_exam)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_devices (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    device_token    VARCHAR(500)    NOT NULL,
    device_type     ENUM('ANDROID','IOS','WEB')
                    NOT NULL DEFAULT 'ANDROID',
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    last_used_at    DATETIME,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_device_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_device_user   (user_id),
    INDEX idx_device_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;