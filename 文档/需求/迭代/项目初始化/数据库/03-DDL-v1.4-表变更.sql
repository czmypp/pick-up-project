-- =====================================================
-- AI Agent 自动接项目系统 - v1.4 表变更（§10.1.6 + §6.2.19）
-- 版本：v1.4
-- 日期：2026-06-11
-- 说明：对现有核心表的字段扩展
-- 执行顺序：00 → 01 → 02 → 03 → 04 → 05
-- =====================================================

-- ============================================================
-- 1. t_project 表扩展：模板/模块关联 + 预览状态跟踪
-- ============================================================
ALTER TABLE t_project ADD COLUMN IF NOT EXISTS template_id       VARCHAR(36);
ALTER TABLE t_project ADD COLUMN IF NOT EXISTS layout_id         VARCHAR(36);
ALTER TABLE t_project ADD COLUMN IF NOT EXISTS selected_modules   JSONB;
ALTER TABLE t_project ADD COLUMN IF NOT EXISTS layout_config_override JSONB;
ALTER TABLE t_project ADD COLUMN IF NOT EXISTS current_preview_version VARCHAR(20);
ALTER TABLE t_project ADD COLUMN IF NOT EXISTS last_preview_stage    VARCHAR(50);

-- ============================================================
-- 2. t_deliverable 表扩展：版本跟踪字段
-- ============================================================
ALTER TABLE t_deliverable ADD COLUMN IF NOT EXISTS current_version  VARCHAR(20) DEFAULT 'v1.0';
ALTER TABLE t_deliverable ADD COLUMN IF NOT EXISTS version_count    INTEGER DEFAULT 1;
ALTER TABLE t_deliverable ADD COLUMN IF NOT EXISTS last_feedback_at TIMESTAMP;
ALTER TABLE t_deliverable ADD COLUMN IF NOT EXISTS confirmed        BOOLEAN DEFAULT FALSE;
ALTER TABLE t_deliverable ADD COLUMN IF NOT EXISTS confirmed_at     TIMESTAMP;
ALTER TABLE t_deliverable ADD COLUMN IF NOT EXISTS confirmed_by     VARCHAR(36);

-- ============================================================
-- 3. t_workflow_stage 表扩展：子任务计数
-- ============================================================
ALTER TABLE t_workflow_stage ADD COLUMN IF NOT EXISTS total_subtasks   INTEGER DEFAULT 0;
ALTER TABLE t_workflow_stage ADD COLUMN IF NOT EXISTS completed_subtasks INTEGER DEFAULT 0;
