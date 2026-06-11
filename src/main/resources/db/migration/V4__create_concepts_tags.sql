CREATE TABLE concepts (
    id                  VARCHAR(36) NOT NULL DEFAULT (UUID()),
    topic_id            VARCHAR(36) NOT NULL,
    parent_concept_id   VARCHAR(36),

    name                VARCHAR(300) NOT NULL,
    name_bn             VARCHAR(300),
    description         TEXT,

    concept_type        ENUM(
                            'DEFINITION',
                            'PROCESS',
                            'FORMULA',
                            'PRINCIPLE',
                            'FACT'
                        ) NOT NULL DEFAULT 'DEFINITION',

    difficulty_level    TINYINT NOT NULL DEFAULT 3,

    importance_score    DECIMAL(3,2) NOT NULL DEFAULT 0.50,

    embedding_vector    TEXT,

    is_active           TINYINT(1) NOT NULL DEFAULT 1,
    created_by          VARCHAR(36) NOT NULL,

    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    CONSTRAINT fk_concepts_topic
        FOREIGN KEY (topic_id) REFERENCES topics(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_concepts_parent
        FOREIGN KEY (parent_concept_id) REFERENCES concepts(id)
        ON DELETE SET NULL,

    INDEX idx_concepts_topic (topic_id),
    INDEX idx_concepts_parent (parent_concept_id),
    INDEX idx_concepts_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE tags (
    id            VARCHAR(36) NOT NULL DEFAULT (UUID()),
    name          VARCHAR(100) NOT NULL UNIQUE,

    tag_type      ENUM(
                      'SUBJECT',
                      'EXAM_TYPE',
                      'DIFFICULTY',
                      'TOPIC',
                      'CUSTOM'
                  ) NOT NULL DEFAULT 'CUSTOM',

    color_code    VARCHAR(7) DEFAULT '#6366f1',
    usage_count   INT NOT NULL DEFAULT 0,

    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    INDEX idx_tags_name (name),
    INDEX idx_tags_type (tag_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;