# M6 AI 工作流引擎 - 前端执行方案

> **依赖**：M1、M2、M3
> **涉及表**：`t_workflow_stage`、`t_workflow_subtask`、`t_deliverable_version`、`t_prompt_template`、`t_model_config`
> **说明**：M6 前端无专属页面，通过 SSE 事件流集成到 M3 的 WorkflowPreview.vue 中

---

## 1. 集成方式

M6 前端代码分布在 M3 的 `composables/useSseStream.ts` 中，监听 AI 引擎的 SSE 事件流。

## 2. SSE 事件类型处理

```typescript
// composables/useSseStream.ts
export function useSseStream(projectId: string) {
  let eventSource: EventSource | null = null

  const eventHandlers: Record<string, (data: any) => void> = {
    'stage:start': (data) => {
      ElNotification.info(`开始生成 ${data.stage}`)
      // 更新阶段状态为 RUNNING
    },

    'stage:progress': (data) => {
      // 更新进度条
      // data = { stageName, percent, currentTask, taskIndex, totalTasks }
    },

    'stage:complete': (data) => {
      ElNotification.success(`${data.stage} 已生成，点击预览`)
      // 有预览确认 → 跳转 WorkflowPreview
      // 无预览确认 → 自动推进下一阶段
    },

    'preview:ready': (data) => {
      // 加载交付物预览数据: deliverableId, currentVersion
      // 加载变更记录 + 子任务列表
    },

    'stage:error': (data) => {
      ElNotification.error(data.errorMessage + '（可重试）')
      // 显示重试按钮
    },

    'workflow:complete': (data) => {
      // 最终的交付物列表 + 项目完成通知
      router.push(`/projects/${projectId}`)
    }
  }

  function connect() {
    eventSource = new EventSource(`/api/v1/workflow/${projectId}/stream`)
    Object.entries(eventHandlers).forEach(([event, handler]) => {
      eventSource!.addEventListener(event, (e) => handler(JSON.parse(e.data)))
    })
    eventSource.onerror = () => setTimeout(connect, 3000) // 自动重连
  }

  function disconnect() { eventSource?.close() }

  return { connect, disconnect }
}
```

## 3. AI 工作流阶段对应的前端状态流转

```
项目创建成功 → ProjectDetail 页
  │
  ├── 阶段1 DOC_GENERATING
  │     ├── SSE: stage:start   → 显示 "PRD 生成中..."
  │     ├── SSE: stage:complete→ 显示 "PRD 已生成，点击预览"
  │     └── 用户点击「预览」  → 跳转 WorkflowPreview
  │           ├── 预览/修改/确认 → 确认后自动触发阶段2
  │
  ├── 阶段2 PROTOTYPE_GENERATING  (同上流程: 生成→预览→修改→确认)
  │
  ├── 阶段3 UI_DESIGNING          (同上流程: 生成→预览→修改→确认)
  │
  ├── 阶段4 TECH_PLAN_GENERATING  (自动执行，无预览确认)
  │     ├── SSE: stage:start   → 显示 "生成技术方案中..."
  │     └── SSE: stage:complete→ 自动推进阶段5
  │
  ├── 阶段5 CODE_GENERATING       (自动执行，完成后展示代码文件列表)
  │     ├── SSE: stage:start
  │     ├── SSE: stage:progress  → 逐个文件生成进度
  │     └── SSE: stage:complete  → 显示代码文件清单
  │
  └── 完成 → ProjectDetail 页显示所有交付物入口
```

## 4. 进度条组件集成

```
ProjectDetail.vue 中的阶段时间线:
┌──────────────────────────────────────────────────┐
│ 阶段时间线                                        │
│                                                   │
│  ● 需求解析 ──── ✓ COMPLETED                      │
│  ● PRD 生成 ──── ⟳ RUNNING  [████████░░] 80%     │
│                   正在: 提取功能模块清单            │
│  ○ 原型生成 ──── PENDING                          │
│  ○ UI 设计 ──── PENDING                           │
│  ○ 技术方案 ──── PENDING                          │
│  ○ 代码生成 ──── PENDING                          │
└──────────────────────────────────────────────────┘
```

## 5. 错误处理

| 错误场景 | 前端处理 |
|----------|----------|
| SSE 连接断开 | 自动重连（3秒延迟） |
| stage:error（可重试） | 显示重试按钮 → POST /projects/{id}/retry |
| stage:error（不可恢复） | 显示错误详情，建议联系管理员 |
| quit 超量 | 提示"月配额已用尽"，引导升级 |
| AI 响应超时 | 显示等待提示 + 取消按钮 |
