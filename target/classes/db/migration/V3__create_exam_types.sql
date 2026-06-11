CREATE TABLE exam_types (
    id VARCHAR(36) NOT NULL DEFAULT (UUID()),
    name VARCHAR(100) NOT NULL,
    name_bn VARCHAR(100),
    code VARCHAR(30) NOT NULL UNIQUE,
    description TEXT,
    conducting_body VARCHAR(200),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    KEY idx_exam_types_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Seed data
INSERT INTO exam_types (id, name, name_bn, code, conducting_body) VALUES
(UUID(), 'BCS ICT',         'বিসিএস আইসিটি',       'BCS_ICT',    'BPSC'),
(UUID(), 'NTRCA ICT',       'এনটিআরসিএ আইসিটি',    'NTRCA_ICT',  'NTRCA'),
(UUID(), 'Bank IT Officer', 'ব্যাংক আইটি অফিসার',   'BANK_IT',    'BB'),
(UUID(), 'Govt IT Job',     'সরকারি আইটি চাকরি',    'GOVT_IT',    'PSC');