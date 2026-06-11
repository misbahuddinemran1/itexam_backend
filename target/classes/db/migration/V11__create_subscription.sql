CREATE TABLE subscription_plans (
    id                          CHAR(36)        NOT NULL DEFAULT (UUID()),
    name                        VARCHAR(100)    NOT NULL,
    name_bn                     VARCHAR(100),
    plan_code                   VARCHAR(30)     NOT NULL UNIQUE,
    plan_type                   ENUM('FREE','MONTHLY','YEARLY','CUSTOM') NOT NULL,
    price_bdt                   DECIMAL(10,2)   NOT NULL DEFAULT 0,
    duration_days               INT             NOT NULL DEFAULT 30,
    description                 TEXT,
    max_practice_per_day        INT             NOT NULL DEFAULT 20,
    max_mock_tests_per_month    INT             NOT NULL DEFAULT 3,
    has_detailed_analytics      TINYINT(1)      NOT NULL DEFAULT 0,
    has_weak_topic_detection    TINYINT(1)      NOT NULL DEFAULT 0,
    has_leaderboard             TINYINT(1)      NOT NULL DEFAULT 0,
    has_battle_exam             TINYINT(1)      NOT NULL DEFAULT 0,
    has_written_exam            TINYINT(1)      NOT NULL DEFAULT 0,
    has_ai_recommendation       TINYINT(1)      NOT NULL DEFAULT 0,
    has_certificate             TINYINT(1)      NOT NULL DEFAULT 0,
    has_offline_access          TINYINT(1)      NOT NULL DEFAULT 0,
    has_live_exam               TINYINT(1)      NOT NULL DEFAULT 0,
    is_popular                  TINYINT(1)      NOT NULL DEFAULT 0,
    display_order               INT             NOT NULL DEFAULT 0,
    color_code                  VARCHAR(7)      DEFAULT '#6366f1',
    is_active                   TINYINT(1)      NOT NULL DEFAULT 1,
    created_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                                ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_plan_type     (plan_type),
    INDEX idx_plan_active   (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE user_subscriptions (
    id              CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id         CHAR(36)        NOT NULL,
    plan_id         CHAR(36)        NOT NULL,
    status          ENUM('ACTIVE','EXPIRED','CANCELLED','TRIAL','PENDING')
                    NOT NULL DEFAULT 'ACTIVE',
    payment_method  ENUM('BKASH','NAGAD','ROCKET','CARD','BANK',
                         'ADMIN_GRANTED','PROMO_CODE','REFERRAL')
                    NOT NULL DEFAULT 'ADMIN_GRANTED',
    starts_at       DATETIME        NOT NULL,
    expires_at      DATETIME        NOT NULL,
    auto_renew      TINYINT(1)      NOT NULL DEFAULT 0,
    granted_by      CHAR(36),
    promo_code      VARCHAR(50),
    transaction_id  VARCHAR(200),
    amount_paid     DECIMAL(10,2)   NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10,2)   NOT NULL DEFAULT 0,
    notes           TEXT,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_sub_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_sub_plan
        FOREIGN KEY (plan_id) REFERENCES subscription_plans(id),
    INDEX idx_sub_user    (user_id),
    INDEX idx_sub_status  (status),
    INDEX idx_sub_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE payment_transactions (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    user_id             CHAR(36)        NOT NULL,
    subscription_id     CHAR(36),
    transaction_id      VARCHAR(200)    NOT NULL UNIQUE,
    payment_method      ENUM('BKASH','NAGAD','ROCKET','CARD','BANK') NOT NULL,
    amount              DECIMAL(10,2)   NOT NULL,
    currency            VARCHAR(5)      NOT NULL DEFAULT 'BDT',
    status              ENUM('PENDING','SUCCESS','FAILED','REFUNDED','CANCELLED')
                        NOT NULL DEFAULT 'PENDING',
    gateway_response    JSON,
    phone_number        VARCHAR(15),
    refund_amount       DECIMAL(10,2)   NOT NULL DEFAULT 0,
    refund_reason       TEXT,
    refunded_at         DATETIME,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_payment_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_payment_user   (user_id),
    INDEX idx_payment_status (status),
    INDEX idx_payment_txn    (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE promo_codes (
    id                  CHAR(36)        NOT NULL DEFAULT (UUID()),
    code                VARCHAR(50)     NOT NULL UNIQUE,
    discount_type       ENUM('PERCENTAGE','FIXED') NOT NULL DEFAULT 'PERCENTAGE',
    discount_value      DECIMAL(10,2)   NOT NULL,
    applicable_plan     ENUM('MONTHLY','YEARLY','ALL') NOT NULL DEFAULT 'ALL',
    max_uses            INT             NOT NULL DEFAULT 1,
    used_count          INT             NOT NULL DEFAULT 0,
    valid_from          DATETIME        NOT NULL,
    valid_until         DATETIME        NOT NULL,
    is_active           TINYINT(1)      NOT NULL DEFAULT 1,
    created_by          CHAR(36)        NOT NULL,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_promo_code   (code),
    INDEX idx_promo_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO subscription_plans (
    id, name, name_bn, plan_code, plan_type,
    price_bdt, duration_days,
    max_practice_per_day, max_mock_tests_per_month,
    has_detailed_analytics, has_weak_topic_detection,
    has_leaderboard, has_battle_exam, has_written_exam,
    has_ai_recommendation, has_certificate,
    has_offline_access, has_live_exam,
    is_popular, display_order, color_code
) VALUES
(UUID(),'Free Plan','ফ্রি প্ল্যান','FREE','FREE',
 0,36500,20,3,0,0,0,0,0,0,0,0,0,0,1,'#6b7280'),
(UUID(),'Monthly Plan','মাসিক প্ল্যান','MONTHLY','MONTHLY',
 199,30,-1,-1,1,1,1,0,0,0,0,0,0,0,2,'#3b82f6'),
(UUID(),'Yearly Plan','বার্ষিক প্ল্যান','YEARLY','YEARLY',
 1499,365,-1,-1,1,1,1,1,1,1,1,1,1,1,3,'#8b5cf6');