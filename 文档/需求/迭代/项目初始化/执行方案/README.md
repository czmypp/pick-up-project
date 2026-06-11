# 执行方案

本目录按功能模块拆分为 7 个独立模块，每个模块包含**前端**和**后端**两套执行方案。

## 目录结构

```
执行方案/
├── M1-认证鉴权/
│   ├── 前端/M1-认证鉴权-前端执行方案.md
│   └── 后端/M1-认证鉴权-后端执行方案.md
├── M2-项目管理/
│   ├── 前端/M2-项目管理-前端执行方案.md
│   └── 后端/M2-项目管理-后端执行方案.md
├── M3-工作流预览与交付物/
│   ├── 前端/M3-工作流预览与交付物-前端执行方案.md
│   └── 后端/M3-工作流预览与交付物-后端执行方案.md
├── M4-模板管理/
│   ├── 前端/M4-模板管理-前端执行方案.md
│   └── 后端/M4-模板管理-后端执行方案.md
├── M5-系统管理/
│   ├── 前端/M5-系统管理-前端执行方案.md
│   └── 后端/M5-系统管理-后端执行方案.md
├── M6-AI工作流引擎/
│   ├── 前端/M6-AI工作流引擎-前端执行方案.md
│   └── 后端/M6-AI工作流引擎-后端执行方案.md
└── M7-数据看板/
    ├── 前端/M7-数据看板-前端执行方案.md
    └── 后端/M7-数据看板-后端执行方案.md
```

## 模块概览

| 模块 | 名称 | 涉及核心表 | 依赖 | 前端页面数 | 后端接口数 |
|------|------|-----------|------|-----------|-----------|
| M1 | 认证鉴权 | t_user, t_role, t_user_role, t_login_log | 无 | 1 | 5 |
| M2 | 项目管理 | t_project, t_project_template, t_workflow_stage | M1, M4 | 3 | 6 |
| M3 | 工作流预览与交付物 | t_deliverable, t_deliverable_version, t_deliverable_feedback, t_deliverable_change_log, t_workflow_subtask, t_workflow_preview_state | M1, M2, M6 | 1(核心) | 11 |
| M4 | 模板管理 | t_project_template, t_function_module, t_layout_rule, t_template_function, t_template_layout, t_feature, t_feature_template | M1, M5 | 7 | 20+ |
| M5 | 系统管理 | t_user, t_role, t_menu, t_user_role, t_role_menu, t_role_api | M1 | 5 | 16+ |
| M6 | AI 工作流引擎 | t_workflow_stage, t_workflow_subtask, t_prompt_template, t_model_config | M1, M2, M3 | 0(集成M3) | 3(含SSE) |
| M7 | 数据看板 | t_project, t_user, t_deliverable, t_login_log, t_workflow_stage | M1, M2 | 1 | 6 |

## 推荐交付顺序

```
M1（认证鉴权）
    ↓
M5（系统管理）  ← M1 提供认证后即可上线用户/角色/菜单管理
    ↓
M4（模板管理）  ← 依赖 M5 菜单配置
    ↓
M2（项目管理）  ← 依赖 M1 认证、M4 模板数据
    ↓
M6（AI 工作流） ← 依赖 M1/M2 项目数据
    ↓
M3（工作流预览）← 与 M6 紧密耦合，建议联调
    ↓
M7（数据看板）  ← 最后上线作为运营辅助
```

## 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 前端框架 | Vue 3 + TypeScript | Composition API |
| UI 组件库 | Element Plus | 企业级组件库 |
| 状态管理 | Pinia | Vue 3 官方推荐 |
| 图表库 | ECharts | 数据看板（M7） |
| Markdown | marked.js + github-markdown-css | PRD 预览（M3） |
| SSE 通信 | EventSource API | AI 实时推送（M3/M6） |
| 后端框架 | Spring Boot 3 | Java 微服务 |
| ORM | Spring Data JPA | 数据访问层 |
| 数据库 | PostgreSQL 14+ | 主存储 |
| 缓存 | Redis | 权限缓存 + 看板缓存 + 工作流状态 |
| 认证 | Spring Security + JWT | 无状态认证 |
| AI 引擎 | Langchain4j + Langgraph4j | 工作流编排 |
