CREATE TABLE admin_users (
    id CHAR(36) NOT NULL DEFAULT (UUID()),

    username      VARCHAR(50)   NOT NULL UNIQUE,
    email         VARCHAR(100)  NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    full_name     VARCHAR(100)  NOT NULL,

    role ENUM(
        'SUPER_ADMIN',
        'CONTENT_MANAGER',
        'REVIEWER'
    ) NOT NULL DEFAULT 'CONTENT_MANAGER',

    is_active     TINYINT(1) NOT NULL DEFAULT 1,
    last_login_at DATETIME,

    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                  ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    INDEX idx_admin_username (username),
    INDEX idx_admin_email (email),
    INDEX idx_admin_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;