-- =====================================================
-- AI Agent 自动接项目系统 - 核心表 DDL（§6.2）
-- 版本：v1.4
-- 日期：2026-06-11
-- 说明：系统全部核心业务表建表语句
-- 执行顺序：00 → 01 → 02 → 03 → 04 → 05
-- =====================================================

-- ============================================================
-- 1. 用户表 t_user
-- ============================================================
CREATE TABLE t_user (
    id              VARCHAR(36) PRIMARY KEY,
    username        VARCHAR(50) NOT NULL UNIQUE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    nickname        VARCHAR(100),
    avatar_url      VARCHAR(500),
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',  -- ACTIVE / DISABLED / LOCKED
    monthly_quota   INTEGER NOT NULL DEFAULT 100,
    used_quota      INTEGER NOT NULL DEFAULT 0,
    quota_reset_at  TIMESTAMP,
    last_login_at   TIMESTAMP,
    failed_login_attempts INTEGER DEFAULT 0,
    last_failed_login_at  TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_username ON t_user(username);
CREATE INDEX idx_user_email ON t_user(email);
CREATE INDEX idx_user_status ON t_user(status);

-- ============================================================
-- 2. 项目表 t_project
-- ============================================================
CREATE TABLE t_project (
    id                  VARCHAR(36) PRIMARY KEY,
    user_id             VARCHAR(36) NOT NULL REFERENCES t_user(id),
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    requirement_text    TEXT NOT NULL,
    project_type        VARCHAR(50),                         -- WEB_APP / MINI_PROGRAM / etc.
    status              VARCHAR(50) NOT NULL DEFAULT 'DRAFT',
    current_stage       VARCHAR(50),
    progress            INTEGER DEFAULT 0,
    auto_confirm        BOOLEAN DEFAULT FALSE,
    retry_count         INTEGER DEFAULT 0,
    max_retry           INTEGER DEFAULT 3,
    error_message       TEXT,
    completed_at        TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_project_user ON t_project(user_id);
CREATE INDEX idx_project_status ON t_project(status);
CREATE INDEX idx_project_created ON t_project(created_at DESC);

-- ============================================================
-- 3. 工作流阶段表 t_workflow_stage
-- ============================================================
CREATE TABLE t_workflow_stage (
    id              VARCHAR(36) PRIMARY KEY,
    project_id      VARCHAR(36) NOT NULL REFERENCES t_project(id),
    stage_name      VARCHAR(50) NOT NULL,
    stage_order     INTEGER NOT NULL,
    status          VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- PENDING / RUNNING / COMPLETED / FAILED / SKIPPED
    input_data      JSONB,
    output_data     JSONB,
    output_ref_id   VARCHAR(36),
    retry_count     INTEGER DEFAULT 0,
    error_message   TEXT,
    started_at      TIMESTAMP,
    completed_at    TIMESTAMP,
    duration_ms     BIGINT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stage_project ON t_workflow_stage(project_id);
CREATE INDEX idx_stage_status ON t_workflow_stage(status);

-- ============================================================
-- 4. 交付物元数据表 t_deliverable
-- ============================================================
CREATE TABLE t_deliverable (
    id              VARCHAR(36) PRIMARY KEY,
    project_id      VARCHAR(36) NOT NULL REFERENCES t_project(id),
    deliverable_type VARCHAR(50) NOT NULL,                   -- PRD / PROTOTYPE / UI_DESIGN / TECH_PLAN / EXEC_PLAN / SOURCE_CODE
    title           VARCHAR(255),
    description     TEXT,
    file_path       VARCHAR(500),
    file_size       BIGINT,
    content_hash    VARCHAR(64),
    version         VARCHAR(20) DEFAULT 'v1.0',
    es_doc_id       VARCHAR(36),
    status          VARCHAR(30) DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deliverable_project ON t_deliverable(project_id);
CREATE INDEX idx_deliverable_type ON t_deliverable(deliverable_type);

-- ============================================================
-- 5. RBAC 菜单表 t_menu
-- ============================================================
CREATE TABLE t_menu (
    id              VARCHAR(36) PRIMARY KEY,
    parent_id       VARCHAR(36),
    name            VARCHAR(100) NOT NULL,
    type            VARCHAR(10) NOT NULL DEFAULT 'MENU',     -- DIR / MENU / BTN
    path            VARCHAR(200),
    component       VARCHAR(200),
    icon            VARCHAR(100),
    permission      VARCHAR(200),
    sort_order      INTEGER NOT NULL DEFAULT 0,
    visible         BOOLEAN NOT NULL DEFAULT TRUE,
    keep_alive      BOOLEAN DEFAULT FALSE,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_menu_parent ON t_menu(parent_id);
CREATE INDEX idx_menu_sort ON t_menu(parent_id, sort_order);

-- ============================================================
-- 6. 角色表 t_role
-- ============================================================
CREATE TABLE t_role (
    id              VARCHAR(36) PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    code            VARCHAR(50) NOT NULL UNIQUE,
    description     VARCHAR(500),
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    is_system       BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_role_code ON t_role(code);
CREATE INDEX idx_role_status ON t_role(status);

-- ============================================================
-- 7. 角色-菜单关联表 t_role_menu
-- ============================================================
CREATE TABLE t_role_menu (
    id              VARCHAR(36) PRIMARY KEY,
    role_id         VARCHAR(36) NOT NULL REFERENCES t_role(id),
    menu_id         VARCHAR(36) NOT NULL REFERENCES t_menu(id),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (role_id, menu_id)
);

CREATE INDEX idx_rm_role ON t_role_menu(role_id);
CREATE INDEX idx_rm_menu ON t_role_menu(menu_id);

-- ============================================================
-- 8. 角色-接口权限关联表 t_role_api
-- ============================================================
CREATE TABLE t_role_api (
    id              VARCHAR(36) PRIMARY KEY,
    role_id         VARCHAR(36) NOT NULL REFERENCES t_role(id),
    method          VARCHAR(10) NOT NULL,                    -- GET / POST / PUT / DELETE / PATCH
    path_pattern    VARCHAR(300) NOT NULL,
    description     VARCHAR(200),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (role_id, method, path_pattern)
);

CREATE INDEX idx_ra_role ON t_role_api(role_id);

-- ============================================================
-- 9. 用户-角色关联表 t_user_role
-- ============================================================
CREATE TABLE t_user_role (
    id              VARCHAR(36) PRIMARY KEY,
    user_id         VARCHAR(36) NOT NULL REFERENCES t_user(id),
    role_id         VARCHAR(36) NOT NULL REFERENCES t_role(id),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, role_id)
);

CREATE INDEX idx_ur_user ON t_user_role(user_id);
CREATE INDEX idx_ur_role ON t_user_role(role_id);

-- ============================================================
-- 10. 登录日志表 t_login_log
-- ============================================================
CREATE TABLE t_login_log (
    id              VARCHAR(36) PRIMARY KEY,
    user_id         VARCHAR(36) NOT NULL,
    username        VARCHAR(100) NOT NULL,
    ip_address      VARCHAR(50),
    user_agent      VARCHAR(500),
    login_type      VARCHAR(20) NOT NULL DEFAULT 'PASSWORD', -- PASSWORD / REFRESH_TOKEN
    login_status    VARCHAR(20) NOT NULL,                     -- SUCCESS / FAILED
    fail_reason     VARCHAR(200),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ll_user ON t_login_log(user_id);
CREATE INDEX idx_ll_time ON t_login_log(created_at DESC);

-- ============================================================
-- 11. 模型配置表 t_model_config
-- ============================================================
CREATE TABLE t_model_config (
    id              VARCHAR(36) PRIMARY KEY,
    model_name      VARCHAR(100) NOT NULL,
    provider        VARCHAR(50) NOT NULL,
    api_key_encrypted VARCHAR(500) NOT NULL,
    api_base_url    VARCHAR(500),
    default_temperature DOUBLE PRECISION DEFAULT 0.7,
    max_tokens      INTEGER DEFAULT 4096,
    is_active       BOOLEAN DEFAULT TRUE,
    priority        INTEGER DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 12. 提示词模板表 t_prompt_template
-- ============================================================
CREATE TABLE t_prompt_template (
    id              VARCHAR(36) PRIMARY KEY,
    template_key    VARCHAR(100) NOT NULL UNIQUE,
    template_name   VARCHAR(255) NOT NULL,
    node_type       VARCHAR(50) NOT NULL,
    system_prompt   TEXT NOT NULL,
    user_prompt     TEXT,
    variables       JSONB,
    version         VARCHAR(20) DEFAULT 'v1.0',
    is_default      BOOLEAN DEFAULT FALSE,
    created_by      VARCHAR(36),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prompt_node ON t_prompt_template(node_type);

-- ============================================================
-- 13. 功能模块库表 t_function_module
-- ============================================================
CREATE TABLE t_function_module (
    id              VARCHAR(36) PRIMARY KEY,
    module_name     VARCHAR(100) NOT NULL,
    module_key      VARCHAR(50) NOT NULL UNIQUE,
    description     TEXT,
    domain          VARCHAR(30) NOT NULL,                    -- GENERAL / ECOMMERCE / CMS / MINI_PROGRAM / ADMIN
    icon            VARCHAR(100),
    tags            JSONB,
    is_core         BOOLEAN DEFAULT FALSE,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(36),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_fm_key ON t_function_module(module_key);
CREATE INDEX idx_fm_domain ON t_function_module(domain);
CREATE INDEX idx_fm_active ON t_function_module(is_active);

-- ============================================================
-- 14. 排版规则库表 t_layout_rule
-- ============================================================
CREATE TABLE t_layout_rule (
    id              VARCHAR(36) PRIMARY KEY,
    layout_name     VARCHAR(100) NOT NULL,
    layout_type     VARCHAR(50) NOT NULL,                    -- SidebarLayout / HeaderMainFooter / MixedNav / GridLayout / TabBarLayout / FullScreen
    config_json     JSONB NOT NULL,
    preview_html    TEXT,
    description     TEXT,
    applicable_scenes JSONB,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      VARCHAR(36),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lr_type ON t_layout_rule(layout_type);
CREATE INDEX idx_lr_active ON t_layout_rule(is_active);

-- ============================================================
-- 15. 项目模板表 t_project_template
-- ============================================================
CREATE TABLE t_project_template (
    id              VARCHAR(36) PRIMARY KEY,
    template_name   VARCHAR(255) NOT NULL,
    template_code   VARCHAR(50) NOT NULL UNIQUE,
    category        VARCHAR(50) NOT NULL,                    -- ECOMMERCE / CMS / MINI_PROGRAM / ADMIN_PANEL / API_SERVICE / GENERAL
    description     TEXT,
    thumbnail       VARCHAR(500),
    project_type    VARCHAR(50) NOT NULL,                    -- WEB_APP / MINI_PROGRAM / MOBILE_APP / API_SERVICE
    default_requirement TEXT,
    tech_stack      JSONB,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    is_system       BOOLEAN DEFAULT FALSE,
    usage_count     INTEGER DEFAULT 0,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    created_by      VARCHAR(36),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_pt_code ON t_project_template(template_code);
CREATE INDEX idx_pt_category ON t_project_template(category);
CREATE INDEX idx_pt_active ON t_project_template(is_active);

-- ============================================================
-- 16. 模板-功能模块关联表 t_template_function
-- ============================================================
CREATE TABLE t_template_function (
    id              VARCHAR(36) PRIMARY KEY,
    template_id     VARCHAR(36) NOT NULL REFERENCES t_project_template(id) ON DELETE CASCADE,
    module_id       VARCHAR(36) NOT NULL REFERENCES t_function_module(id),
    is_required     BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order      INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (template_id, module_id)
);

CREATE INDEX idx_tf_template ON t_template_function(template_id);
CREATE INDEX idx_tf_module ON t_template_function(module_id);

-- ============================================================
-- 17. 模板-排版规则关联表 t_template_layout
-- ============================================================
CREATE TABLE t_template_layout (
    id              VARCHAR(36) PRIMARY KEY,
    template_id     VARCHAR(36) NOT NULL REFERENCES t_project_template(id) ON DELETE CASCADE,
    layout_id       VARCHAR(36) NOT NULL REFERENCES t_layout_rule(id),
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (template_id, layout_id)
);

CREATE INDEX idx_tl_template ON t_template_layout(template_id);
CREATE INDEX idx_tl_layout ON t_template_layout(layout_id);

-- ============================================================
-- 18. 功能管理表 t_feature
-- ============================================================
CREATE TABLE t_feature (
    id              VARCHAR(36) PRIMARY KEY,
    parent_id       VARCHAR(36),
    feature_name    VARCHAR(100) NOT NULL,
    feature_key     VARCHAR(50) NOT NULL UNIQUE,
    description     TEXT,
    icon            VARCHAR(100),
    sort_order      INTEGER NOT NULL DEFAULT 0,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_by      VARCHAR(36),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_feature_parent ON t_feature(parent_id);
CREATE INDEX idx_feature_key ON t_feature(feature_key);
CREATE INDEX idx_feature_status ON t_feature(status);
CREATE INDEX idx_feature_sort ON t_feature(parent_id, sort_order);

-- ============================================================
-- 19. 功能-模板关联表 t_feature_template
-- ============================================================
CREATE TABLE t_feature_template (
    id              VARCHAR(36) PRIMARY KEY,
    feature_id      VARCHAR(36) NOT NULL REFERENCES t_feature(id) ON DELETE CASCADE,
    template_id     VARCHAR(36) NOT NULL REFERENCES t_project_template(id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (feature_id, template_id)
);

CREATE INDEX idx_ft_feature ON t_feature_template(feature_id);
CREATE INDEX idx_ft_template ON t_feature_template(template_id);
