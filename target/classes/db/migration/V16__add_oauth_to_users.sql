-- email nullable (phone-only registration এর জন্য)
ALTER TABLE users
    MODIFY COLUMN email VARCHAR(100) NULL;

-- password nullable (Google/Facebook login এর জন্য)
ALTER TABLE users
    MODIFY COLUMN password_hash VARCHAR(255) NULL;

-- OAuth columns add
ALTER TABLE users
    ADD COLUMN auth_provider ENUM('LOCAL', 'GOOGLE', 'FACEBOOK')
        NOT NULL DEFAULT 'LOCAL'
        AFTER password_hash,
    ADD COLUMN provider_id VARCHAR(255) NULL
        AFTER auth_provider;

-- Index
ALTER TABLE users
    ADD INDEX idx_users_auth_provider (auth_provider),
    ADD INDEX idx_users_provider_id (provider_id);