-- =====================================================
-- AI Agent 自动接项目系统 - v1.4 新增表 DDL（§10.1）
-- 版本：v1.4
-- 日期：2026-06-11
-- 说明：v1.4 迭代新增的 5 张业务表
-- 执行顺序：00 → 01 → 02 → 03 → 04 → 05
-- =====================================================

-- ============================================================
-- 1. 交付物版本历史表 t_deliverable_version
-- 记录每个交付物每次 AI 生成/修改的版本快照，支持版本回溯与 Diff 对比
-- ============================================================
CREATE TABLE t_deliverable_version (
    id                VARCHAR(36) PRIMARY KEY,
    deliverable_id    VARCHAR(36) NOT NULL,
    project_id        VARCHAR(36) NOT NULL,
    version           VARCHAR(20) NOT NULL,                 -- v1.0, v1.1, v2.0
    content_text      TEXT,
    content_json      JSONB,
    file_path         VARCHAR(500),
    file_size         BIGINT,
    content_hash      VARCHAR(64),
    change_summary    TEXT,
    trigger_type      VARCHAR(30) NOT NULL DEFAULT 'AI_GENERATE',  -- AI_GENERATE / USER_FEEDBACK / MANUAL_EDIT / ROLLBACK
    parent_version    VARCHAR(20),
    created_by        VARCHAR(36),
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dv_deliverable ON t_deliverable_version(deliverable_id);
CREATE INDEX idx_dv_project     ON t_deliverable_version(project_id);
CREATE INDEX idx_dv_version     ON t_deliverable_version(deliverable_id, version);

-- ============================================================
-- 2. 交付物修改反馈表 t_deliverable_feedback
-- 记录用户对交付物的每次修改意见，用于 AI 增量更新的上下文追踪
-- ============================================================
CREATE TABLE t_deliverable_feedback (
    id                VARCHAR(36) PRIMARY KEY,
    project_id        VARCHAR(36) NOT NULL,
    deliverable_id    VARCHAR(36) NOT NULL,
    deliverable_type  VARCHAR(50) NOT NULL,                 -- PRD / PROTOTYPE / UI_DESIGN
    feedback_type     VARCHAR(30) NOT NULL DEFAULT 'TEXT',  -- TEXT / CHAPTER_EDIT / COMPONENT_EDIT / TOKEN_EDIT / LAYOUT_ADJUST
    target_section    VARCHAR(200),
    feedback_content  TEXT NOT NULL,
    before_snapshot   TEXT,
    after_snapshot    TEXT,
    status            VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- PENDING / PROCESSING / COMPLETED / REJECTED
    from_version      VARCHAR(20),
    to_version        VARCHAR(20),
    ai_response       TEXT,
    created_by        VARCHAR(36) NOT NULL,
    processed_at      TIMESTAMP,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_df_project    ON t_deliverable_feedback(project_id);
CREATE INDEX idx_df_deliverable ON t_deliverable_feedback(deliverable_id);
CREATE INDEX idx_df_status     ON t_deliverable_feedback(status);

-- ============================================================
-- 3. 工作流子任务表 t_workflow_subtask
-- 记录工作流每个阶段内部的子任务执行情况
-- ============================================================
CREATE TABLE t_workflow_subtask (
    id                VARCHAR(36) PRIMARY KEY,
    project_id        VARCHAR(36) NOT NULL,
    stage_id          VARCHAR(36) NOT NULL,
    stage_name        VARCHAR(50) NOT NULL,
    task_name         VARCHAR(200) NOT NULL,
    task_order        INTEGER NOT NULL DEFAULT 0,
    status            VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- PENDING / RUNNING / COMPLETED / FAILED / SKIPPED
    output_files      JSONB,
    error_message     TEXT,
    started_at        TIMESTAMP,
    completed_at      TIMESTAMP,
    duration_ms       BIGINT,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ws_project ON t_workflow_subtask(project_id);
CREATE INDEX idx_ws_stage   ON t_workflow_subtask(stage_id);
CREATE INDEX idx_ws_status  ON t_workflow_subtask(project_id, status);

-- ============================================================
-- 4. 交付物变更记录表 t_deliverable_change_log
-- 记录每次预览界面的具体变更条目
-- ============================================================
CREATE TABLE t_deliverable_change_log (
    id                VARCHAR(36) PRIMARY KEY,
    project_id        VARCHAR(36) NOT NULL,
    deliverable_id    VARCHAR(36) NOT NULL,
    version_id        VARCHAR(36) NOT NULL,
    change_position   VARCHAR(300) NOT NULL,
    change_type       VARCHAR(10) NOT NULL DEFAULT 'ADD',   -- ADD / MODIFY / DELETE
    change_content    TEXT NOT NULL,
    change_detail     JSONB,
    sort_order        INTEGER DEFAULT 0,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_dcl_deliverable ON t_deliverable_change_log(deliverable_id);
CREATE INDEX idx_dcl_version     ON t_deliverable_change_log(version_id);
CREATE INDEX idx_dcl_project     ON t_deliverable_change_log(project_id);

-- ============================================================
-- 5. 工作流预览状态表 t_workflow_preview_state
-- 记录用户在各阶段预览界面的操作状态（确认/撤回/跳过）
-- ============================================================
CREATE TABLE t_workflow_preview_state (
    id                VARCHAR(36) PRIMARY KEY,
    project_id        VARCHAR(36) NOT NULL,
    stage_name        VARCHAR(50) NOT NULL,                 -- DOC_GENERATING / PROTOTYPE_GENERATING / UI_DESIGNING
    current_version   VARCHAR(20),
    preview_status    VARCHAR(30) NOT NULL DEFAULT 'GENERATING',  -- GENERATING / PREVIEWING / UPDATING / CONFIRMED / REVERTED
    confirmed_at      TIMESTAMP,
    confirmed_by      VARCHAR(36),
    revert_count      INTEGER DEFAULT 0,
    last_action       VARCHAR(30),                           -- CONFIRM / REVERT / SKIP / UPDATE
    last_action_at    TIMESTAMP,
    created_at        TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_wps_project ON t_workflow_preview_state(project_id);
CREATE INDEX idx_wps_stage   ON t_workflow_preview_state(project_id, stage_name);
