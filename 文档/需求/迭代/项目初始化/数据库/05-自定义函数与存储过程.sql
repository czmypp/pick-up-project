-- =====================================================
-- AI Agent 自动接项目系统 - 自定义函数（§11.3.1）
-- 版本：v1.4
-- 日期：2026-06-11
-- 说明：数据库存储过程与自定义函数
-- 执行顺序：00 → 01 → 02 → 03 → 04 → 05
-- =====================================================

-- ============================================================
-- 1. 版本号递增函数
-- 输入当前版本号 v{major}.{minor}，返回下一个小版本号
-- 示例：v1.0 → v1.1, v2.9 → v2.10
-- ============================================================
CREATE OR REPLACE FUNCTION next_version(p_current_version VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    v_major INT;
    v_minor INT;
BEGIN
    v_major := (regexp_match(p_current_version, 'v(\d+)\.(\d+)'))[1]::INT;
    v_minor := (regexp_match(p_current_version, 'v(\d+)\.(\d+)'))[2]::INT;
    RETURN 'v' || v_major || '.' || (v_minor + 1);
END;
$$ LANGUAGE plpgsql;
