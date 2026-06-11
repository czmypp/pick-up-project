# 数据库 SQL 脚本

本目录包含 AI-Agent 自动接项目系统的全部数据库 DDL/DML 脚本。

## 执行顺序

```
00-创建数据库与扩展.sql     → 创建数据库 + 安装 uuid-ossp / pgcrypto 扩展
01-DDL-核心表.sql           → 核心业务表建表（19 张表）
02-DDL-v1.4-新增表.sql      → v1.4 新增表建表（5 张表，依赖核心表）
03-DDL-v1.4-表变更.sql      → 现有表字段扩展（ALTER 语句）
04-DML-种子数据.sql         → 全部种子数据（用户/角色/菜单/模板/AI配置）
05-自定义函数与存储过程.sql  → 版本号函数 next_version()
```

## 表清单

| 序号 | 表名 | 说明 | 来源 |
|------|------|------|------|
| 1 | `t_user` | 用户账户与配额 | 01-核心表 |
| 2 | `t_project` | 项目主表 | 01-核心表 |
| 3 | `t_workflow_stage` | 工作流阶段 | 01-核心表 |
| 4 | `t_deliverable` | 交付物元数据 | 01-核心表 |
| 5 | `t_menu` | RBAC 菜单 | 01-核心表 |
| 6 | `t_role` | 角色 | 01-核心表 |
| 7 | `t_role_menu` | 角色-菜单关联 | 01-核心表 |
| 8 | `t_role_api` | 角色-接口权限关联 | 01-核心表 |
| 9 | `t_user_role` | 用户-角色关联 | 01-核心表 |
| 10 | `t_login_log` | 登录日志 | 01-核心表 |
| 11 | `t_model_config` | LLM 模型配置 | 01-核心表 |
| 12 | `t_prompt_template` | 提示词模板 | 01-核心表 |
| 13 | `t_function_module` | 功能模块库 | 01-核心表 |
| 14 | `t_layout_rule` | 排版规则库 | 01-核心表 |
| 15 | `t_project_template` | 项目模板 | 01-核心表 |
| 16 | `t_template_function` | 模板-模块关联 | 01-核心表 |
| 17 | `t_template_layout` | 模板-排版关联 | 01-核心表 |
| 18 | `t_feature` | 功能管理树 | 01-核心表 |
| 19 | `t_feature_template` | 功能-模板关联 | 01-核心表 |
| 20 | `t_deliverable_version` | 交付物版本历史 | 02-新增表 |
| 21 | `t_deliverable_feedback` | 交付物修改反馈 | 02-新增表 |
| 22 | `t_workflow_subtask` | 工作流子任务 | 02-新增表 |
| 23 | `t_deliverable_change_log` | 交付物变更记录 | 02-新增表 |
| 24 | `t_workflow_preview_state` | 工作流预览状态 | 02-新增表 |

## 种子数据概览

| 数据类型 | 数量 | 关键 ID |
|----------|------|---------|
| 用户 | 4 条 | u1(admin) / u2(user) / u3(operator) / u4(manager) |
| 角色 | 4 条 | r1(超级管理员) / r2(管理员) / r3(运营人员) / r4(普通用户) |
| 菜单 | 22 条 | m1~m22（含目录/MENU/按钮） |
| 角色-菜单关联 | 49 条 | 按角色分级分配 |
| 角色-API关联 | 41 条 | 按角色分级分配 |
| 功能模块 | 17 条 | md1~md17 |
| 排版规则 | 6 条 | ly1~ly6 |
| 项目模板 | 5 条 | t1(电商) / t2(管理后台) / t3(小程序) / t4(CMS) / t5(API) |
| 模板-模块关联 | 30 条 | tf01~tf30 |
| 模板-排版关联 | 8 条 | tl01~tl08 |
| 功能管理 | 22 条 | f1~f22（树结构） |
| AI提示词模板 | 9 条 | p1~p9 |
| LLM模型配置 | 3 条 | mc1(deepseek) / mc2(gpt-4o) / mc3(claude) |

> **密码说明**：所有种子用户密码 BCrypt 加密，明文统一为 `admin123` / `user123`。
