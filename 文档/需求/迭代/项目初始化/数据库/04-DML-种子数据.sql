-- =====================================================
-- AI Agent 自动接项目系统 - 种子数据 DML（§10.2）
-- 版本：v1.4
-- 日期：2026-06-11
-- 说明：完整初始化种子数据，确保与原型数据一致性
-- 所有 ID 使用固定 UUID 便于调试
-- 执行顺序：00 → 01 → 02 → 03 → 04 → 05
-- =====================================================

-- ============================================================
-- 1. 用户数据 t_user
-- 密码均为 BCrypt 加密后，明文统一为 admin123 / user123
-- ============================================================
INSERT INTO t_user (id, username, email, password_hash, nickname, status, monthly_quota, used_quota, created_at, updated_at) VALUES
('u1', 'admin',     'admin@pickup.local',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '系统管理员', 'ACTIVE', 100, 22, NOW(), NOW()),
('u2', 'user',      'user@pickup.local',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '普通用户',   'ACTIVE',  50, 12, NOW(), NOW()),
('u3', 'operator',  'operator@pickup.local','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '运营人员',   'ACTIVE',  80,  5, NOW(), NOW()),
('u4', 'manager',   'manager@pickup.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '管理员',     'ACTIVE',  80,  8, NOW(), NOW());

-- ============================================================
-- 2. 角色数据 t_role
-- ============================================================
INSERT INTO t_role (id, name, code, description, status, is_system, created_at, updated_at) VALUES
('r1', '超级管理员', 'SUPER_ADMIN', '系统最高权限，管理所有功能',             'ACTIVE', TRUE,  NOW(), NOW()),
('r2', '管理员',     'ADMIN',       '管理系统配置与用户',                    'ACTIVE', TRUE,  NOW(), NOW()),
('r3', '运营人员',   'OPERATOR',    '项目审核与数据统计',                    'ACTIVE', FALSE, NOW(), NOW()),
('r4', '普通用户',   'USER',        '基础用户权限',                          'ACTIVE', TRUE,  NOW(), NOW());

-- ============================================================
-- 3. 用户-角色关联 t_user_role
-- ============================================================
INSERT INTO t_user_role (id, user_id, role_id, created_at) VALUES
('ur1', 'u1', 'r1', NOW()),
('ur2', 'u2', 'r4', NOW()),
('ur3', 'u3', 'r3', NOW()),
('ur4', 'u4', 'r2', NOW());

-- ============================================================
-- 4. 菜单数据 t_menu
-- ============================================================

-- 目录层
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m1',  NULL,   '工作台',       'DIR',  NULL,               NULL,                        'dashboard', NULL,              1, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m3',  NULL,   '项目管理',     'DIR',  NULL,               NULL,                        'project',   NULL,              2, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m6',  NULL,   '系统管理',     'DIR',  NULL,               NULL,                        'setting',   NULL,              3, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m15', NULL,   '日志审计',     'DIR',  NULL,               NULL,                        'audit',     NULL,              4, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 工作台下
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m2', 'm1', '数据概览', 'MENU', '/dashboard', 'dashboard/index', 'chart', 'dashboard:view', 1, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 项目管理下
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m4',  'm3', '项目列表',   'MENU', '/projects',                'projects/list',             'list',      'project:view',      1, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m5',  'm3', '创建项目',   'MENU', '/projects/create',         'projects/create',           'plus',      'project:create',    2, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m22', 'm3', '工作流预览', 'MENU', '/projects/workflow-preview','projects/workflow-preview', 'file-text', 'project:workflow',  3, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 系统管理 → 权限管理（子目录）
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m7', 'm6', '权限管理', 'DIR', NULL, NULL, 'safety', NULL, 1, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m8',  'm7', '用户管理', 'MENU', '/system/users',  'system/users/index',  'user', 'user:view',  1, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m9',  'm7', '角色管理', 'MENU', '/system/roles',  'system/roles/index',  'team', 'role:view',  2, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m10', 'm7', '菜单管理', 'MENU', '/system/menus',  'system/menus/index',  'menu', 'menu:view',  3, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 菜单管理下的按钮权限
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m11', 'm10', '新增菜单', 'BTN', NULL, NULL, NULL, 'menu:create', 1, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m12', 'm10', '编辑菜单', 'BTN', NULL, NULL, NULL, 'menu:edit',   2, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m13', 'm10', '删除菜单', 'BTN', NULL, NULL, NULL, 'menu:delete', 3, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 系统管理 → 系统配置
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m14', 'm6', '系统配置', 'MENU', '/system/config', 'system/config', 'tool', NULL, 2, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 系统管理 → 模板管理（子目录）
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m17', 'm6', '模板管理', 'DIR', NULL, NULL, 'template', NULL, 3, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m18', 'm17', '模板列表',   'MENU', '/system/templates', 'system/templates/index', 'layers',  'template:view', 1, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m19', 'm17', '功能项库',   'MENU', '/system/modules',   'system/modules/index',   'puzzle',  'module:view',   2, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m20', 'm17', '排版规则库', 'MENU', '/system/layouts',   'system/layouts/index',   'layout',  'layout:view',   3, TRUE, FALSE, 'ACTIVE', NOW(), NOW()),
('m21', 'm17', '功能管理',   'MENU', '/system/features',  'system/features/index',  'feature', 'feature:view',  4, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- 日志审计下
INSERT INTO t_menu (id, parent_id, name, type, path, component, icon, permission, sort_order, visible, keep_alive, status, created_at, updated_at) VALUES
('m16', 'm15', '操作日志', 'MENU', '/logs/audit', 'logs/audit', 'file-text', 'log:view', 1, TRUE, FALSE, 'ACTIVE', NOW(), NOW());

-- ============================================================
-- 5. 角色-菜单关联 t_role_menu
-- ============================================================

-- r1 超级管理员：全部菜单
INSERT INTO t_role_menu (id, role_id, menu_id, created_at) VALUES
('rm001','r1','m1',NOW()),('rm002','r1','m2',NOW()),('rm003','r1','m3',NOW()),
('rm004','r1','m4',NOW()),('rm005','r1','m5',NOW()),('rm006','r1','m22',NOW()),
('rm007','r1','m6',NOW()),('rm008','r1','m7',NOW()),('rm009','r1','m8',NOW()),
('rm010','r1','m9',NOW()),('rm011','r1','m10',NOW()),('rm012','r1','m11',NOW()),
('rm013','r1','m12',NOW()),('rm014','r1','m13',NOW()),('rm015','r1','m14',NOW()),
('rm016','r1','m15',NOW()),('rm017','r1','m16',NOW()),('rm018','r1','m17',NOW()),
('rm019','r1','m18',NOW()),('rm020','r1','m19',NOW()),('rm021','r1','m20',NOW()),
('rm022','r1','m21',NOW());

-- r2 管理员：无按钮权限，有管理即可
INSERT INTO t_role_menu (id, role_id, menu_id, created_at) VALUES
('rm023','r2','m1',NOW()),('rm024','r2','m2',NOW()),('rm025','r2','m3',NOW()),
('rm026','r2','m4',NOW()),('rm027','r2','m5',NOW()),('rm028','r2','m22',NOW()),
('rm029','r2','m6',NOW()),('rm030','r2','m7',NOW()),('rm031','r2','m8',NOW()),
('rm032','r2','m14',NOW()),('rm033','r2','m17',NOW()),('rm034','r2','m18',NOW()),
('rm035','r2','m19',NOW()),('rm036','r2','m20',NOW()),('rm037','r2','m21',NOW());

-- r3 / r4 普通用户：仅工作台 + 项目管理
INSERT INTO t_role_menu (id, role_id, menu_id, created_at) VALUES
('rm038','r3','m1',NOW()),('rm039','r3','m2',NOW()),('rm040','r3','m3',NOW()),
('rm041','r3','m4',NOW()),('rm042','r3','m5',NOW()),('rm043','r3','m22',NOW());

INSERT INTO t_role_menu (id, role_id, menu_id, created_at) VALUES
('rm044','r4','m1',NOW()),('rm045','r4','m2',NOW()),('rm046','r4','m3',NOW()),
('rm047','r4','m4',NOW()),('rm048','r4','m5',NOW()),('rm049','r4','m22',NOW());

-- ============================================================
-- 6. 角色-接口权限关联 t_role_api
-- ============================================================

-- r1 超级管理员：全部 API
INSERT INTO t_role_api (id, role_id, method, path_pattern, description, created_at) VALUES
('ra001','r1','GET',    '/api/v1/auth/**',        '认证接口-查询',   NOW()),
('ra002','r1','POST',   '/api/v1/auth/**',        '登录/注册接口',   NOW()),
('ra003','r1','GET',    '/api/v1/projects/**',    '项目管理-查询',   NOW()),
('ra004','r1','POST',   '/api/v1/projects/**',    '项目管理-创建',   NOW()),
('ra005','r1','PUT',    '/api/v1/projects/**',    '项目管理-更新',   NOW()),
('ra006','r1','DELETE', '/api/v1/projects/**',    '项目管理-删除',   NOW()),
('ra007','r1','GET',    '/api/v1/deliverables/**','交付物-查询',     NOW()),
('ra008','r1','PUT',    '/api/v1/deliverables/**','交付物-更新',     NOW()),
('ra009','r1','POST',   '/api/v1/deliverables/**','交付物-写入',     NOW()),
('ra010','r1','DELETE', '/api/v1/deliverables/**','交付物-删除',     NOW()),
('ra011','r1','GET',    '/api/v1/workflow/**',    '工作流-查询',     NOW()),
('ra012','r1','GET',    '/api/v1/admin/**',       '管理接口-查询',   NOW()),
('ra013','r1','POST',   '/api/v1/admin/**',       '管理接口-写入',   NOW()),
('ra014','r1','PUT',    '/api/v1/admin/**',       '管理接口-更新',   NOW()),
('ra015','r1','DELETE', '/api/v1/admin/**',       '管理接口-删除',   NOW()),
('ra016','r1','GET',    '/api/v1/templates/**',   '用户端模板-查询', NOW()),
('ra017','r1','GET',    '/api/v1/modules/**',     '用户端模块-查询', NOW()),
('ra018','r1','GET',    '/api/v1/layouts/**',     '用户端排版-查询', NOW());

-- r2 管理员：可管理配置模块，无权管理角色和菜单删除
INSERT INTO t_role_api (id, role_id, method, path_pattern, description, created_at) VALUES
('ra019','r2','GET',    '/api/v1/auth/**',        '认证接口-查询',   NOW()),
('ra020','r2','POST',   '/api/v1/auth/**',        '登录/注册接口',   NOW()),
('ra021','r2','GET',    '/api/v1/projects/**',    '项目管理-查询',   NOW()),
('ra022','r2','POST',   '/api/v1/projects/**',    '项目管理-创建',   NOW()),
('ra023','r2','PUT',    '/api/v1/projects/**',    '项目管理-更新',   NOW()),
('ra024','r2','GET',    '/api/v1/deliverables/**','交付物-查询',     NOW()),
('ra025','r2','GET',    '/api/v1/workflow/**',    '工作流-查询',     NOW()),
('ra026','r2','GET',    '/api/v1/admin/**',       '管理接口-查询',   NOW()),
('ra027','r2','POST',   '/api/v1/admin/**',       '管理接口-写入',   NOW()),
('ra028','r2','PUT',    '/api/v1/admin/**',       '管理接口-更新',   NOW()),
('ra029','r2','GET',    '/api/v1/templates/**',   '用户端模板-查询', NOW());

-- r3 / r4 普通用户：仅查询项目管理、交付物、工作流、用户端模板
INSERT INTO t_role_api (id, role_id, method, path_pattern, description, created_at) VALUES
('ra030','r3','GET',    '/api/v1/auth/**',        '认证接口-查询',   NOW()),
('ra031','r3','POST',   '/api/v1/auth/**',        '登录/注册接口',   NOW()),
('ra032','r3','GET',    '/api/v1/projects/**',    '项目管理-查询',   NOW()),
('ra033','r3','POST',   '/api/v1/projects/**',    '项目管理-创建',   NOW()),
('ra034','r3','GET',    '/api/v1/deliverables/**','交付物-查询',     NOW()),
('ra035','r3','GET',    '/api/v1/workflow/**',    '工作流-查询',     NOW());

INSERT INTO t_role_api (id, role_id, method, path_pattern, description, created_at) VALUES
('ra036','r4','GET',    '/api/v1/auth/**',        '认证接口-查询',   NOW()),
('ra037','r4','POST',   '/api/v1/auth/**',        '登录/注册接口',   NOW()),
('ra038','r4','GET',    '/api/v1/projects/**',    '项目管理-查询',   NOW()),
('ra039','r4','POST',   '/api/v1/projects/**',    '项目管理-创建',   NOW()),
('ra040','r4','GET',    '/api/v1/deliverables/**','交付物-查询',     NOW()),
('ra041','r4','GET',    '/api/v1/workflow/**',    '工作流-查询',     NOW());

-- ============================================================
-- 7. 功能模块库 t_function_module
-- ============================================================
INSERT INTO t_function_module (id, module_name, module_key, description, domain, icon, tags, is_core, sort_order, is_active, created_at, updated_at) VALUES
('md1',  '用户认证',      'USER_AUTH',      '用户注册、登录、密码找回',                       'GENERAL',      'safety',     '["认证","基础"]',         TRUE,  1,  TRUE, NOW(), NOW()),
('md2',  'RBAC权限管理',  'RBAC',           '角色管理、菜单权限、接口鉴权',                    'GENERAL',      'shield',     '["权限","安全"]',         FALSE, 2,  TRUE, NOW(), NOW()),
('md3',  '商品管理',      'PRODUCT_MGT',    '商品CRUD、分类、SKU、库存',                       'ECOMMERCE',    'box',        '["电商","核心"]',         TRUE,  3,  TRUE, NOW(), NOW()),
('md4',  '订单管理',      'ORDER_MGT',      '订单创建、流转、售后',                            'ECOMMERCE',    'document',   '["电商","核心"]',         TRUE,  4,  TRUE, NOW(), NOW()),
('md5',  '购物车',        'CART',           '购物车管理、凑单推荐',                            'ECOMMERCE',    'shopping-cart','["电商"]',              FALSE, 5,  TRUE, NOW(), NOW()),
('md6',  '支付集成',      'PAYMENT',        '微信/支付宝/银联对接',                            'ECOMMERCE',    'credit-card', '["电商","支付"]',        FALSE, 6,  TRUE, NOW(), NOW()),
('md7',  '文章管理',      'CMS_ARTICLE',    '文章发布、编辑、分类',                            'CMS',          'edit',        '["内容"]',               TRUE,  7,  TRUE, NOW(), NOW()),
('md8',  '分类管理',      'CMS_CATEGORY',   '内容分类树、标签管理',                            'CMS',          'folder',      '["内容"]',               TRUE,  8,  TRUE, NOW(), NOW()),
('md9',  '评论系统',      'CMS_COMMENT',    '文章评论、审核、举报',                            'CMS',          'chat',        '["内容","互动"]',         FALSE, 9,  TRUE, NOW(), NOW()),
('md10', '微信登录',      'WX_LOGIN',       '微信OAuth授权登录',                              'MINI_PROGRAM', 'wechat',      '["小程序","认证"]',       TRUE,  10, TRUE, NOW(), NOW()),
('md11', '微信支付',      'WX_PAY',         '小程序内微信支付',                               'MINI_PROGRAM', 'money',       '["小程序","支付"]',       FALSE, 11, TRUE, NOW(), NOW()),
('md12', '数据看板',      'DASHBOARD',      '关键指标可视化、图表',                            'ADMIN',        'chart',       '["管理","分析"]',         TRUE,  12, TRUE, NOW(), NOW()),
('md13', '数据导出',      'DATA_EXPORT',    'Excel/CSV数据导出',                              'GENERAL',      'download',    '["工具"]',               FALSE, 13, TRUE, NOW(), NOW()),
('md14', '消息通知',      'NOTIFICATION',   '站内信、邮件、短信通知',                          'GENERAL',      'bell',        '["消息"]',               FALSE, 14, TRUE, NOW(), NOW()),
('md15', '文件上传',      'FILE_UPLOAD',    '图片/文件上传、OSS存储',                          'GENERAL',      'paperclip',   '["文件"]',               FALSE, 15, TRUE, NOW(), NOW()),
('md16', '操作日志',      'LOG_AUDIT',      '操作记录、审计追踪',                              'GENERAL',      'scroll',      '["审计"]',               FALSE, 16, TRUE, NOW(), NOW()),
('md17', '搜索功能',      'SEARCH',         '全文搜索、高级筛选',                              'GENERAL',      'search',      '["搜索"]',               FALSE, 17, TRUE, NOW(), NOW());

-- ============================================================
-- 8. 排版规则库 t_layout_rule
-- ============================================================
INSERT INTO t_layout_rule (id, layout_name, layout_type, config_json, description, applicable_scenes, is_active, created_at, updated_at) VALUES
('ly1', '经典侧边栏布局', 'SidebarLayout',      '{"header":{"height":56,"fixed":true,"showLogo":true},"sidebar":{"width":220,"collapsible":true,"position":"left"},"content":{"maxWidth":"100%","padding":24},"footer":{"height":48,"show":false},"themeColors":{"primary":"#4F46E5"}}', '左侧固定导航+右侧内容区（顶部工具栏）',    '["后台管理系统","数据管理平台"]', TRUE, NOW(), NOW()),
('ly2', '上中下布局',      'HeaderMainFooter',   '{"header":{"height":64,"fixed":false,"showLogo":true},"sidebar":null,"content":{"maxWidth":"1200px","padding":32},"footer":{"height":80,"show":true}}', '顶部导航+中间内容+底部信息栏',            '["官网","门户"]',                 TRUE, NOW(), NOW()),
('ly3', '混合导航布局',    'MixedNav',           '{"header":{"height":56,"fixed":true},"sidebar":{"width":200,"collapsible":true},"content":{"padding":24},"footer":{"show":false}}', '顶部一级导航+侧边二级菜单+内容区',        '["大型管理后台"]',                TRUE, NOW(), NOW()),
('ly4', '响应式网格布局',  'GridLayout',         '{"header":{"height":56},"sidebar":null,"content":{"maxWidth":"100%","padding":16,"gridColumns":3},"footer":{"show":false}}', '基于Card/Grid的内容型布局',              '["数据看板","仪表盘"]',           TRUE, NOW(), NOW()),
('ly5', '底部Tab布局',     'TabBarLayout',       '{"header":{"height":48,"showLogo":false},"sidebar":null,"content":{"padding":12},"tabBar":{"position":"bottom","items":4},"footer":{"show":false}}', '底部Tab切换+顶栏标题区',                 '["移动端","小程序"]',             TRUE, NOW(), NOW()),
('ly6', '单页全屏布局',    'FullScreen',         '{"header":{"show":false},"sidebar":null,"content":{"maxWidth":"100%","padding":0},"footer":{"show":false}}', '全屏滚动/无导航纯内容页',                '["登录页","落地页"]',             TRUE, NOW(), NOW());

-- ============================================================
-- 9. 项目模板 t_project_template
-- ============================================================
INSERT INTO t_project_template (id, template_name, template_code, category, description, project_type, tech_stack, is_active, is_system, usage_count, sort_order, created_at, updated_at) VALUES
('t1', '电商管理平台', 'ecommerce-mgmt', 'ECOMMERCE',    '适用于B2C/B2B电商场景，包含商品、订单、支付等核心模块',               'WEB_APP',  '{"frontend":"Vue3+ElementPlus","backend":"Spring Boot 3","database":"PostgreSQL","cache":"Redis"}', TRUE, TRUE,  156, 1, NOW(), NOW()),
('t2', '后台管理系统', 'admin-panel',    'ADMIN_PANEL',  '通用管理后台框架模板，含权限、看板、日志等基础模块',                  'WEB_APP',  '{"frontend":"Vue3+ElementPlus","backend":"Spring Boot 3","database":"PostgreSQL","cache":"Redis"}', TRUE, TRUE,   89, 2, NOW(), NOW()),
('t3', '微信小程序',   'mini-program',   'MINI_PROGRAM', '微信小程序商城模板，包含微信登录、支付等小程序特有模块',              'MINI_PROGRAM','{"frontend":"微信原生+Vue3","backend":"Spring Boot 3","database":"PostgreSQL","cache":"Redis"}', TRUE, TRUE,   64, 3, NOW(), NOW()),
('t4', '内容管理系统', 'cms-system',     'CMS',          '博客/资讯/文档类系统模板，含文章管理、分类、评论',                  'WEB_APP',  '{"frontend":"Vue3+ElementPlus","backend":"Spring Boot 3","database":"PostgreSQL","cache":"Redis"}', TRUE, TRUE,   42, 4, NOW(), NOW()),
('t5', 'API服务',      'api-service',    'API_SERVICE',  '纯后端REST API服务模板，无前端页面',                                'API_SERVICE','{"frontend":"无","backend":"Spring Boot 3","database":"PostgreSQL","cache":"Redis"}',               TRUE, TRUE,   28, 5, NOW(), NOW());

-- ============================================================
-- 10. 模板-功能模块关联 t_template_function
-- ============================================================

-- t1 电商管理平台：md1(必),md3(必),md4(必),md5,md6,md2,md14,md15
INSERT INTO t_template_function (id, template_id, module_id, is_required, sort_order, created_at) VALUES
('tf01','t1','md1',TRUE, 1,NOW()),('tf02','t1','md3',TRUE, 2,NOW()),('tf03','t1','md4',TRUE, 3,NOW()),
('tf04','t1','md5',FALSE,4,NOW()),('tf05','t1','md6',FALSE,5,NOW()),('tf06','t1','md2',FALSE,6,NOW()),
('tf07','t1','md14',FALSE,7,NOW()),('tf08','t1','md15',FALSE,8,NOW());

-- t2 后台管理系统：md1(必),md2(必),md12(必),md16,md13,md15
INSERT INTO t_template_function (id, template_id, module_id, is_required, sort_order, created_at) VALUES
('tf09','t2','md1',TRUE, 1,NOW()),('tf10','t2','md2',TRUE, 2,NOW()),('tf11','t2','md12',TRUE, 3,NOW()),
('tf12','t2','md16',FALSE,4,NOW()),('tf13','t2','md13',FALSE,5,NOW()),('tf14','t2','md15',FALSE,6,NOW());

-- t3 微信小程序：md10(必),md3(必),md4(必),md11,md5,md14
INSERT INTO t_template_function (id, template_id, module_id, is_required, sort_order, created_at) VALUES
('tf15','t3','md10',TRUE, 1,NOW()),('tf16','t3','md3',TRUE, 2,NOW()),('tf17','t3','md4',TRUE, 3,NOW()),
('tf18','t3','md11',FALSE,4,NOW()),('tf19','t3','md5',FALSE,5,NOW()),('tf20','t3','md14',FALSE,6,NOW());

-- t4 内容管理系统：md1(必),md7(必),md8(必),md9,md17,md15
INSERT INTO t_template_function (id, template_id, module_id, is_required, sort_order, created_at) VALUES
('tf21','t4','md1',TRUE, 1,NOW()),('tf22','t4','md7',TRUE, 2,NOW()),('tf23','t4','md8',TRUE, 3,NOW()),
('tf24','t4','md9',FALSE,4,NOW()),('tf25','t4','md17',FALSE,5,NOW()),('tf26','t4','md15',FALSE,6,NOW());

-- t5 API服务：md1(必),md2,md17,md16
INSERT INTO t_template_function (id, template_id, module_id, is_required, sort_order, created_at) VALUES
('tf27','t5','md1',TRUE, 1,NOW()),('tf28','t5','md2',FALSE,2,NOW()),('tf29','t5','md17',FALSE,3,NOW()),
('tf30','t5','md16',FALSE,4,NOW());

-- ============================================================
-- 11. 模板-排版规则关联 t_template_layout
-- ============================================================
INSERT INTO t_template_layout (id, template_id, layout_id, is_default, created_at) VALUES
('tl01','t1','ly1',TRUE, NOW()), ('tl02','t1','ly3',FALSE, NOW()),
('tl03','t2','ly1',TRUE, NOW()), ('tl04','t2','ly3',FALSE, NOW()), ('tl05','t2','ly4',FALSE, NOW()),
('tl06','t3','ly5',TRUE, NOW()),
('tl07','t4','ly1',TRUE, NOW()), ('tl08','t4','ly2',FALSE, NOW());
-- t5 API服务无排版关联

-- ============================================================
-- 12. 功能管理 t_feature
-- ============================================================

-- 根节点
INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f1',  NULL, '系统管理', 'SYS_MANAGEMENT', '系统级管理功能集合',         'setting',     1, 'ACTIVE', NOW(), NOW()),
('f7',  NULL, '商品中心', 'PRODUCT_CENTER',  '商品相关功能集合',           'shop',        2, 'ACTIVE', NOW(), NOW()),
('f13', NULL, '交易管理', 'TRADE_CENTER',    '订单、购物车、支付相关',       'transaction', 3, 'ACTIVE', NOW(), NOW()),
('f17', NULL, '数据分析', 'DATA_ANALYTICS',  '数据报表与可视化分析',        'chart',       4, 'ACTIVE', NOW(), NOW()),
('f20', NULL, '内容管理', 'CMS_CENTER',      '文章、内容发布与管理',        'file-text',   5, 'ACTIVE', NOW(), NOW());

-- 系统管理子节点
INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f2', 'f1', '用户管理',  'USER_MANAGEMENT', '用户增删改查及状态管理',     'user',    1, 'ACTIVE', NOW(), NOW()),
('f5', 'f1', '角色管理',  'ROLE_MANAGEMENT', '角色创建、编辑、权限分配',   'team',    2, 'ACTIVE', NOW(), NOW()),
('f6', 'f1', '权限配置',  'PERM_CONFIG',     '菜单与接口权限配置',         'safety',  3, 'ACTIVE', NOW(), NOW());

INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f3', 'f2', '用户列表',  'USER_LIST',       '查看、搜索、筛选用户',       'list',    1, 'ACTIVE', NOW(), NOW()),
('f4', 'f2', '用户详情',  'USER_DETAIL',     '查看用户详细信息',            'profile', 2, 'ACTIVE', NOW(), NOW());

-- 商品中心子节点
INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f8',  'f7', '商品管理', 'PRODUCT_MGMT',    '商品CRUD、分类、SKU管理',    'box',      1, 'ACTIVE', NOW(), NOW()),
('f12', 'f7', '库存管理', 'INVENTORY_MGMT',  '库存查询、出入库记录',       'database', 2, 'ACTIVE', NOW(), NOW());

INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f9',  'f8', '商品列表', 'PRODUCT_LIST',    '商品分页列表展示',            'list', 1, 'ACTIVE',  NOW(), NOW()),
('f10', 'f8', '商品分类', 'PRODUCT_CATEGORY','商品分类树管理',              'tree', 2, 'ACTIVE',  NOW(), NOW()),
('f11', 'f8', '商品标签', 'PRODUCT_TAG',     '商品标签管理',               'tag',  3, 'DISABLED',NOW(), NOW());

-- 交易管理子节点
INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f14', 'f13', '订单管理', 'ORDER_MGMT',      '订单创建、流转、售后处理',   'order',      1, 'ACTIVE', NOW(), NOW()),
('f15', 'f13', '购物车',   'SHOPPING_CART',   '购物车管理、凑单推荐',      'cart',       2, 'ACTIVE', NOW(), NOW()),
('f16', 'f13', '支付管理', 'PAYMENT_MGMT',    '支付集成与流水管理',         'pay-circle', 3, 'ACTIVE', NOW(), NOW());

-- 数据分析子节点
INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f18', 'f17', '数据看板', 'DASHBOARD',       '关键指标可视化图表',         'dashboard', 1, 'ACTIVE', NOW(), NOW()),
('f19', 'f17', '数据导出', 'DATA_EXPORT',     'Excel/CSV数据导出',          'export',    2, 'ACTIVE', NOW(), NOW());

-- 内容管理子节点
INSERT INTO t_feature (id, parent_id, feature_name, feature_key, description, icon, sort_order, status, created_at, updated_at) VALUES
('f21', 'f20', '文章管理', 'ARTICLE_MGMT',    '文章发布、编辑、分类',       'edit',     1, 'ACTIVE',  NOW(), NOW()),
('f22', 'f20', '评论审核', 'COMMENT_REVIEW',  '评论审核与举报处理',         'message',  2, 'DISABLED',NOW(), NOW());

-- ============================================================
-- 13. 功能-模板关联 t_feature_template
-- ============================================================
INSERT INTO t_feature_template (id, feature_id, template_id, created_at) VALUES
-- 系统管理关联
('ft01','f1','t1',NOW()),('ft02','f1','t2',NOW()),
('ft03','f2','t1',NOW()),('ft04','f2','t2',NOW()),
('ft05','f3','t1',NOW()),
('ft06','f4','t1',NOW()),
('ft07','f5','t1',NOW()),('ft08','f5','t2',NOW()),
('ft09','f6','t1',NOW()),
-- 商品中心关联
('ft10','f7','t1',NOW()),('ft11','f7','t3',NOW()),
('ft12','f8','t1',NOW()),('ft13','f8','t3',NOW()),
('ft14','f9','t1',NOW()),
('ft15','f10','t1',NOW()),
('ft16','f12','t1',NOW()),
-- 交易管理关联
('ft17','f13','t1',NOW()),('ft18','f13','t3',NOW()),
('ft19','f14','t1',NOW()),('ft20','f14','t3',NOW()),
('ft21','f15','t1',NOW()),
('ft22','f16','t1',NOW()),('ft23','f16','t3',NOW()),
-- 数据分析关联
('ft24','f17','t2',NOW()),
('ft25','f18','t2',NOW()),
('ft26','f19','t2',NOW()),
-- 内容管理关联
('ft27','f20','t4',NOW()),
('ft28','f21','t4',NOW());
-- f11(feature:商品标签) 和 f22(feature:评论审核) 无关联模板

-- ============================================================
-- 14. AI 提示词模板 t_prompt_template
-- ============================================================
INSERT INTO t_prompt_template (id, template_key, template_name, node_type, system_prompt, user_prompt, variables, version, is_default, created_at, updated_at) VALUES
('p1', 'requirement_parser',  '需求解析提示词',   'REQUIREMENT_PARSING',   '你是一个资深的需求分析师，擅长将用户的自然语言需求转化为结构化的功能需求列表。', '分析以下用户需求：\n{{requirement}}', '[{"name":"requirement","type":"string","required":true}]', 'v1.0', TRUE, NOW(), NOW()),
('p2', 'prd_generator',      'PRD生成提示词',    'DOC_GENERATING',        '你是一个专业的PRD文档撰写者，根据结构化需求生成符合行业标准的产品需求文档。', '为以下功能需求生成PRD文档章节：\n{{modules_json}}', '[{"name":"modules_json","type":"json","required":true}]', 'v1.0', TRUE, NOW(), NOW()),
('p3', 'prototype_generator','原型生成提示词',   'PROTOTYPE_GENERATING', '你是一个资深的前端设计师，根据PRD文档生成可交互的HTML产品原型。', '基于以下PRD章节设计产品原型：\n{{prd_sections}}', '[{"name":"prd_sections","type":"json","required":true}]', 'v1.0', TRUE, NOW(), NOW()),
('p4', 'ui_designer',        'UI设计提示词',     'UI_DESIGNING',          '你是一个UI/UX设计师，根据原型和设计规范生成专业的UI设计稿。', '基于原型和设计令牌生成UI：\n原型：{{prototype}}\n令牌：{{tokens}}', '[{"name":"prototype","type":"text"},{"name":"tokens","type":"json"}]', 'v1.0', TRUE, NOW(), NOW()),
('p5', 'tech_planner',       '技术方案提示词',   'TECH_PLAN_GENERATING', '你是一个资深技术架构师，根据PRD和原型生成技术方案与执行计划。', '根据以下输入设计技术方案：\nPRD：{{prd}}\n技术栈：{{tech_stack}}', '[{"name":"prd","type":"text"},{"name":"tech_stack","type":"json"}]', 'v1.0', TRUE, NOW(), NOW()),
('p6', 'code_generator',     '代码生成提示词',   'CODE_GENERATING',      '你是一个资深后端/前端开发工程师，根据技术方案生成项目初始化代码。', '生成项目代码：\n方案：{{tech_plan}}\n模板：{{template}}', '[{"name":"tech_plan","type":"text"},{"name":"template","type":"text"}]', 'v1.0', TRUE, NOW(), NOW()),
('p7', 'prd_updater',        'PRD增量更新提示词','DOC_UPDATING',          '你是一个PRD文档编辑者，根据用户的修改意见增量更新PRD文档，保持未修改部分的完整性。', '原PRD：\n{{current_prd}}\n\n修改意见：\n{{feedback}}', '[{"name":"current_prd","type":"text"},{"name":"feedback","type":"text"}]', 'v1.0', TRUE, NOW(), NOW()),
('p8', 'prototype_updater',  '原型增量更新提示词','PROTOTYPE_UPDATING',  '你是一个前端原型设计师，根据用户的修改意见增量更新HTML原型。', '当前原型：\n{{current_prototype}}\n修改意见：\n{{feedback}}', '[{"name":"current_prototype","type":"text"},{"name":"feedback","type":"text"}]', 'v1.0', TRUE, NOW(), NOW()),
('p9', 'ui_updater',         'UI增量更新提示词',  'UI_DESIGN_UPDATING',  '你是一个UI设计师，根据用户的样式修改意见增量更新UI设计稿。', '当前UI：{{current_ui}}\n令牌：{{tokens}}\n修改意见：{{feedback}}', '[{"name":"current_ui","type":"text"},{"name":"tokens","type":"json"},{"name":"feedback","type":"text"}]', 'v1.0', TRUE, NOW(), NOW());

-- ============================================================
-- 15. LLM 模型配置 t_model_config
-- ============================================================
INSERT INTO t_model_config (id, model_name, provider, api_key_encrypted, api_base_url, default_temperature, max_tokens, is_active, priority, created_at, updated_at) VALUES
('mc1', 'deepseek-v3',   'deepseek',  'ENC::base64placeholder::', 'https://api.deepseek.com/v1',         0.7, 4096, TRUE,  10, NOW(), NOW()),
('mc2', 'gpt-4o',        'openai',    'ENC::base64placeholder::', 'https://api.openai.com/v1',           0.7, 4096, TRUE,   5, NOW(), NOW()),
('mc3', 'claude-sonnet', 'anthropic', 'ENC::base64placeholder::', 'https://api.anthropic.com',           0.7, 4096, FALSE,  0, NOW(), NOW());
