# M6 AI 工作流引擎 - 后端执行方案

> **依赖**：M1、M2、M3
> **涉及表**：`t_workflow_stage`、`t_workflow_subtask`、`t_deliverable_version`、`t_prompt_template`、`t_model_config`、`t_deliverable`
> **关键模块**：`pick-up-ai-engine`

---

## 1. 工作流执行器核心架构

```
WorkflowExecutor.java
  │
  ├── @Service
  ├── 字段注入:
  │     modelConfigRepository, promptTemplateRepository,
  │     workflowStageRepository, workflowSubtaskRepository,
  │     deliverableRepository, deliverableVersionRepository,
  │     SseEmitterManager, Langgraph4jStateGraph
  │
  ├── execute(projectId, CreateProjectRequest) ─ 入口方法
  │     │
  │     ├── ① 加载/构建 StateGraph (DAG)
  │     │     StateGraph graph = buildOrchestrationGraph(request)
  │     │     // 根据模板配置决定哪些节点需要执行
  │     │     // 根据 selectedModules 决定跳过哪些阶段
  │     │
  │     ├── ② 创建 WorkflowState (持久化到 Redis)
  │     │     WorkflowState state = WorkflowState.builder()
  │     │         .projectId(projectId)
  │     │         .currentStage("DOC_GENERATING")
  │     │         .stageIndex(0)
  │     │         .build()
  │     │     redisRepository.save("workflow:state:" + projectId, state)
  │     │
  │     ├── ③ 遍历阶段执行
  │     │     for (String stage : stages) {
  │     │         executeStage(projectId, stage, state)
  │     │     }
  │     │
  │     └── ④ 工作流完成
  │           projectRepository.updateStatus(projectId, "COMPLETED")
  │           sseEmitterManager.send(projectId, "workflow:complete", result)
  │
  ├── executeStage(projectId, stage, state)
  │     │
  │     ├── ① 更新阶段状态
  │     │     workflowStageRepository.updateStatus(stageId, "RUNNING")
  │     │     sseEmitterManager.send(projectId, "stage:start", { stage })
  │     │
  │     ├── ② 获取对应 Agent
  │     │     Agent agent = agentFactory.getAgent(stage)
  │     │     // 映射: DOC_GENERATING → DocGeneratorAgent
  │     │     //        PROTOTYPE_GENERATING → PrototypeGeneratorAgent
  │     │
  │     ├── ③ 加载 Prompt 模板
  │     │     promptTemplate = promptTemplateRepository.findByKey(
  │     │         getPromptKeyForStage(stage))
  │     │     // 变量替换: {{requirement}} → project.requirementText
  │     │
  │     ├── ④ 调用 LLM
  │     │     modelConfig = modelConfigRepository.findActiveWithHighestPriority()
  │     │     llmResponse = llmClient.chat(
  │     │         model=modelConfig.getModelName(),
  │     │         system=promptTemplate.getSystemPrompt(),
  │     │         user=buildUserPrompt(promptTemplate, projectContext),
  │     │         temperature=modelConfig.getDefaultTemperature(),
  │     │         maxTokens=modelConfig.getMaxTokens()
  │     │     )
  │     │
  │     ├── ⑤ 处理 Agent 输出
  │     │     agentOutput = agent.processResponse(llmResponse)
  │     │     // DocGeneratorAgent → Markdown 文档
  │     │     // PrototypeGeneratorAgent → HTML 原型
  │     │
  │     ├── ⑥ 创建/更新交付物
  │     │     deliverableVersionService.createVersion(
  │     │         deliverableId, "v1.0", agentOutput.getContent())
  │     │
  │     ├── ⑦ 创建子任务记录
  │     │     workflowSubtaskService.createSubtasks(
  │     │         stageId, agentOutput.getSubtasks())
  │     │
  │     ├── ⑧ 更新阶段 + SSE 推送
  │     │     workflowStageRepository.updateStatus(stageId, "COMPLETED")
  │     │     sseEmitterManager.send(projectId, "stage:complete", {
  │     │         stage, deliverableId, version: "v1.0"
  │     │     })
  │     │
  │     └── ⑨ 需要用户确认的阶段 → 发送 preview:ready
  │           if (CONFIRMABLE_STAGES.contains(stage)) {
  │               previewStateService.createPreviewState(projectId, stage, "v1.0")
  │               sseEmitterManager.send(projectId, "preview:ready", data)
  │               waitForUserConfirmation(projectId, stage)  // 阻塞等待
  │           }
  │
  └── 异常处理
        ├── 可重试异常 (LLM RateLimit, NetworkTimeout)
        │     retryCount <= 3 → state.incrementRetry() → 重新 executeStage()
        │     retryCount > 3  → markStageFailed() + SSE push stage:error
        │
        └── 不可恢复异常 (ValidationError, QuotaExceeded)
              markStageFailed() + SSE push stage:error + 停止工作流
```

## 2. Agent 工厂注册

```
AgentFactory.java
  │
  ├── Map<String, WorkflowAgent> agentRegistry = new HashMap<>()
  │
  ├── registerAgent("DOC_GENERATING", new DocGeneratorAgent(...))
  ├── registerAgent("PROTOTYPE_GENERATING", new PrototypeGeneratorAgent(...))
  ├── registerAgent("UI_DESIGNING", new UiDesignGeneratorAgent(...))
  ├── registerAgent("TECH_PLAN_GENERATING", new TechPlanGeneratorAgent(...))
  ├── registerAgent("CODE_GENERATING", new CodeGeneratorAgent(...))
  │
  └── getAgent(stage) → agentRegistry.get(stage)
```

## 3. 增量更新流程（用户提交修改意见后触发）

```
AiEngineServiceImpl.incrementalUpdate(projectId, deliverableId, feedback)
  │
  ├── ① 获取当前交付物内容
  │     currentContent = deliverableVersionRepository.findCurrent(deliverableId)
  │
  ├── ② 加载对应的更新 Prompt 模板
  │     updaterPrompt = promptTemplateRepository.findByKey(
  │         getUpdaterKeyForType(deliverableType))
  │     // DOC_UPDATING / PROTOTYPE_UPDATING / UI_DESIGN_UPDATING
  │
  ├── ③ 调用 LLM 增量更新
  │     newContent = llmClient.chat(
  │         model, updaterPrompt.systemPrompt,
  │         userPrompt = updaterPrompt.userPrompt
  │             .replace("{{current_content}}", currentContent)
  │             .replace("{{feedback}}", feedback.feedbackContent)
  │     )
  │
  ├── ④ 内容校验
  │     └── 确保更新后的内容结构完整、格式正确
  │
  ├── ⑤ 创建新版本
  │     newVersion = versionService.createVersion(
  │         deliverableId, nextVersion(currentVersion),
  │         newContent, triggerType="USER_FEEDBACK")
  │
  ├── ⑥ 生成 Diff 变更记录
  │     diff = aiDiffService.compare(currentContent, newContent)
  │     changeLogService.createChangeLogs(versionId, diff)
  │
  ├── ⑦ 更新反馈状态
  │     feedbackRepository.updateStatus(feedbackId, COMPLETED, toVersion, newContent)
  │
  └── ⑧ SSE 推送完成
        sseEmitterManager.send(projectId, "update:complete", { newVersion, diff })
```

## 4. 核心查询 SQL

```sql
-- 1. 获取工作流阶段当前状态
SELECT stage_name, status, started_at, completed_at,
       total_subtasks, completed_subtasks, output_data, error_message
FROM t_workflow_stage WHERE project_id = ? ORDER BY stage_order;

-- 2. 获取活跃的 LLM 模型配置
SELECT model_name, provider, api_base_url, default_temperature, max_tokens
FROM t_model_config WHERE is_active = TRUE ORDER BY priority DESC;

-- 3. 获取提示词模板
SELECT system_prompt, user_prompt, variables
FROM t_prompt_template WHERE template_key = ? AND is_default = TRUE;

-- 4. 创建工作流子任务（批量）
INSERT INTO t_workflow_subtask (id, project_id, stage_id, stage_name,
       task_name, task_order, status, created_at) VALUES
(?, ?, ?, ?, '解析用户需求文本', 1, 'PENDING', NOW()),
(?, ?, ?, ?, '匹配项目模板',     2, 'PENDING', NOW()),
(?, ?, ?, ?, '提取功能模块清单',  3, 'PENDING', NOW()),
...;

-- 5. 更新子任务状态
UPDATE t_workflow_subtask SET status = ?, started_at = NOW()
WHERE id = ? AND status = 'PENDING';

UPDATE t_workflow_subtask
SET status = 'COMPLETED', completed_at = NOW(), duration_ms = ?,
    output_files = ?::jsonb WHERE id = ?;

-- 6. 更新阶段子任务计数
UPDATE t_workflow_stage
SET completed_subtasks = (SELECT COUNT(*) FROM t_workflow_subtask
    WHERE stage_id = ? AND status = 'COMPLETED')
WHERE id = ?;

-- 7. 保存工作流状态到 Redis（断点恢复）
-- Redis Key: workflow:state:{projectId}
-- Value: JSON { stage, nodeIndex, completedNodes, retryCount }
SET workflow:state:{projectId} '{...}' EX 86400;
```

## 5. Prompt 模板映射

| 工作流阶段 | Prompt Key | 说明 |
|-----------|-----------|------|
| REQUIREMENT_PARSING | `requirement_parser` | 需求解析 |
| DOC_GENERATING | `prd_generator` | PRD 生成 |
| PROTOTYPE_GENERATING | `prototype_generator` | 原型生成 |
| UI_DESIGNING | `ui_designer` | UI 设计 |
| TECH_PLAN_GENERATING | `tech_planner` | 技术方案 |
| CODE_GENERATING | `code_generator` | 代码生成 |
| DOC_UPDATING | `prd_updater` | PRD 增量更新 |
| PROTOTYPE_UPDATING | `prototype_updater` | 原型增量更新 |
| UI_DESIGN_UPDATING | `ui_updater` | UI 增量更新 |

## 6. 接口清单

| METHOD | PATH | 权限 | 说明 |
|--------|------|------|------|
| GET | `/api/v1/workflow/{id}/status` | `project:view` | 轮询状态 |
| GET | `/api/v1/workflow/{id}/stream` | `project:view` | SSE 实时推送 |
| GET | `/api/v1/workflow/{id}/preview-state` | `project:view` | 预览状态 |

## 7. 重试与异常处理策略

| 异常类型 | 重试策略 | 重试次数 | 失败后处理 |
|----------|----------|----------|-----------|
| LLM RateLimit | 指数退避 1s/2s/4s | 3 次 | 切换下一优先级模型 |
| NetworkTimeout | 固定延迟 3s | 3 次 | SSE push stage:error |
| QuotaExceeded | 不可重试 | 0 | SSE push stage:error + 停止 |
| ValidationError | 不可重试 | 0 | SSE push clarification:needed |
| 通用异常 | 固定延迟 2s | 3 次 | SSE push stage:error |
