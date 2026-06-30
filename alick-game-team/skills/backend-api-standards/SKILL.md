---
name: backend-api-standards
description: 使用当开发后端 RESTful API（Node.js/Express 等框架）时，对接口设计、参数校验、错误码定义和 Swagger 文档生成提供规范约束。触发词：API规范、接口设计、后端规范、RESTful规范、错误码定义、Swagger文档
---

# 后端 API 开发规范

## 概述

团队后端 API 开发需遵循统一的 RESTful 接口设计、参数校验、错误码定义和 Swagger 文档生成标准。所有新建接口必须同时包含以下四个要素：

1. **接口设计** — RESTful 路径和 HTTP 方法
2. **参数校验** — 入参合法性检查
3. **错误码** — 统一的业务错误码体系
4. **Swagger 文档** — 可交互的 API 文档

缺少以上任一要素的接口视为未完成，不允许提交。

## 接口设计规范

### 路径命名

```
✅ /api/users          ✅ /api/users/:id
✅ /api/orders         ✅ /api/orders/:id/items
❌ /api/getUsers       ❌ /api/createUser
❌ /api/user_list      ❌ /api/deleteUserById
```

**规则：**
- 统一前缀 `/api`，版本化时加 `/api/v1/`
- 资源名用复数名词，全小写 + 连字符（`/api/order-items`）
- 嵌套资源不超过两级，超过时考虑扁平化或用 query 参数
- 路径只表示资源，操作由 HTTP 方法表达

### HTTP 方法与 CRUD

| 方法 | 路径 | 语义 | 请求体 | 响应码 |
|------|------|------|--------|--------|
| POST | `/api/users` | 创建 | ✅ | 201 |
| GET | `/api/users` | 列表 | ❌ | 200 |
| GET | `/api/users/:id` | 详情 | ❌ | 200 |
| PUT | `/api/users/:id` | 全量替换 | ✅ | 200 |
| PATCH | `/api/users/:id` | 部分更新 | ✅ | 200 |
| DELETE | `/api/users/:id` | 删除 | ❌ | 204 |

**严禁：**
- `GET` 带 request body
- `DELETE` 用 `POST` 模拟
- `PUT` 做部分更新（PATCH 才是部分更新）

### 统一响应格式

**成功响应：**
```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

**列表响应：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "list": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```

**错误响应：**
```json
{
  "code": 40001,
  "message": "参数错误：邮箱格式不正确",
  "data": null
}
```

## 参数校验规范

### 校验位置

所有校验在路由层（或中间件层）完成，业务层不处理格式校验。

### 校验清单

| 参数类型 | 检查项 | 示例 |
|----------|--------|------|
| string | 必填、长度、格式（email/url/uuid） | `isEmail()` |
| number | 必填、范围、整数限制 | `isInt({ min: 1 })` |
| boolean | 是否合法的 boolean 值 | `isBoolean()` |
| array | 类型、长度、元素类型 | `isArray({ min: 1 })` |
| pagination | page ≥ 1、pageSize 在 [1, 100] | page 默认 1, pageSize 默认 20 |
| id | 数字或 UUID 格式校验 | `isMongoId()` 或 `isUUID()` |

### 校验失败处理

- 收集所有错误字段，一次性返回，不要逐个字段返回
- 使用统一的校验错误码（40001）

```javascript
// ✅ 正确：收集所有错误统一返回
const errors = [];
if (!name) errors.push('name 不能为空');
if (email && !isEmail(email)) errors.push('email 格式不正确');
if (errors.length > 0) {
  return res.status(400).json({ code: 40001, message: errors.join('; '), data: null });
}

// ❌ 错误：逐个字段返回
if (!name) return res.status(400).json({ ... }); // 用户刚改完 name 又提示 email 错了
```

### 校验库推荐

- Node.js: `express-validator`, `joi`, `zod`
- Python: `pydantic`, `marshmallow`
- Go: `go-playground/validator`

## 错误码定义规范

### 错误码分段

| 范围 | 类型 | 说明 |
|------|------|------|
| 0 | 成功 | 请求处理成功 |
| 10000-19999 | 通用错误 | 系统级错误，与业务无关 |
| 20000-29999 | 鉴权错误 | 登录、权限相关 |
| 30000-39999 | 资源错误 | 资源不存在、冲突 |
| 40000-49999 | 参数错误 | 请求参数校验失败 |
| 50000-59999 | 业务错误 | 各业务模块独有错误 |

### 通用错误码表

| 错误码 | message | HTTP 状态码 | 说明 |
|--------|---------|------------|------|
| 0 | success | 200/201 | 成功 |
| 10001 | 系统繁忙，请稍后重试 | 500 | 服务器内部错误 |
| 10002 | 服务暂不可用 | 503 | 服务维护中 |
| 20001 | 未登录或 token 已过期 | 401 | 身份认证失败 |
| 20002 | 无权限访问 | 403 | 权限不足 |
| 30001 | 资源不存在 | 404 | 请求的资源未找到 |
| 30002 | 资源已存在 | 409 | 创建重复资源 |
| 40001 | 参数错误：{具体原因} | 400 | 请求参数校验失败 |
| 40002 | 请求方法不允许 | 405 | HTTP 方法错误 |

### 错误码设计原则

1. **错误码一旦确定不可修改或删除**（前端/客户端可能已依赖）
2. 新业务模块从 50001 开始分配
3. HTTP 状态码代表传输层状态，业务错误码代表业务状态，二者不同
4. 严禁 HTTP 200 返回业务错误（true/false 方式）

## Swagger 文档规范

### 安装

```bash
npm install swagger-jsdoc swagger-ui-express
```

### 基础配置

```javascript
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: '项目 API 文档',
      version: '1.0.0',
      description: 'API 描述',
    },
    servers: [{ url: '/api' }],
  },
  apis: ['./routes/*.js'], // 从路由文件读取 JSDoc 注释
};

const swaggerSpec = swaggerJsdoc(options);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
```

### JSDoc 注释模板

```javascript
/**
 * @openapi
 * /users:
 *   post:
 *     tags: [用户管理]
 *     summary: 创建用户
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email]
 *             properties:
 *               name:
 *                 type: string
 *                 description: 用户姓名
 *               email:
 *                 type: string
 *                 format: email
 *               age:
 *                 type: integer
 *                 minimum: 0
 *               gender:
 *                 type: string
 *                 enum: [male, female]
 *     responses:
 *       '201':
 *         description: 创建成功
 *       '400':
 *         description: 参数错误
 */
```

### 规范要求

- 每个接口都必须有 JSDoc 注释
- `tags` 按模块分组（用户管理、订单管理）
- 请求参数标注 `required`、类型、格式约束
- 响应需标注所有可能的 HTTP 状态码和对应说明
- 枚举字段使用 `enum` 标注可选值

## 完整示例

```javascript
const { body, validationResult, query } = require('express-validator');

/**
 * @openapi
 * /users:
 *   get:
 *     tags: [用户管理]
 *     summary: 获取用户列表
 *     parameters:
 *       - in: query
 *         name: page
 *         schema: { type: integer, minimum: 1, default: 1 }
 *       - in: query
 *         name: pageSize
 *         schema: { type: integer, minimum: 1, maximum: 100, default: 20 }
 *     responses:
 *       '200': { description: 用户列表 }
 *       '400': { description: 参数错误 }
 */
app.get(
  '/api/users',
  [
    query('page').optional().isInt({ min: 1 }).toInt(),
    query('pageSize').optional().isInt({ min: 1, max: 100 }).toInt(),
  ],
  (req, res) => {
    const errs = validationResult(req);
    if (!errs.isEmpty()) {
      return res.status(400).json({
        code: 40001,
        message: '参数错误：' + errs.array().map(e => e.msg).join('; '),
        data: null,
      });
    }

    const { page = 1, pageSize = 20 } = req.query;
    const list = users.slice((page - 1) * pageSize, page * pageSize);

    res.json({
      code: 0,
      message: 'success',
      data: { list, total: users.length, page, pageSize },
    });
  }
);
```

## 必须包含的中间件

```javascript
// 1. 请求日志
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// 2. 全局错误处理（必须放在所有路由之后）
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ code: 10001, message: '系统繁忙，请稍后重试', data: null });
});

// 3. 404 兜底
app.use((req, res) => {
  res.status(404).json({ code: 30001, message: '资源不存在', data: null });
});
```

## 检查清单

创建每个接口时逐项确认：

- [ ] 路径使用 RESTful 命名（复数名词 + HTTP 方法表达语义）
- [ ] 参数校验覆盖所有入参（必填、类型、格式、范围）
- [ ] 校验错误统一收集后返回，不逐字段返回
- [ ] 错误码使用规范中的预定义值
- [ ] 响应格式统一为 `{ code, message, data }`
- [ ] Swagger JSDoc 注释完整
- [ ] 日志中间件和错误处理中间件已添加
- [ ] `/api-docs` 端点可访问

## 常见错误

| 错误做法 | 问题 | 正确做法 |
|----------|------|----------|
| 路径用动词（`/getUsers`） | 不符合 REST 语义 | `/api/users` + `GET` |
| PUT 做部分更新 | PUT 语义是全量替换 | 用 `PATCH` |
| 错误格式不统一 | 客户端解析困难 | `{ code, message, data }` |
| 没有 Swagger 注释 | 前端/测试无法对接 | 每个接口添加 JSDoc |
| 不校验 page/limit | 负数导致 SQL 异常 | `isInt({ min: 1 })` |
| HTTP 200 + 业务 false | 无法利用 HTTP 状态码机制 | 正确的 HTTP 状态码 |

## 坚持规范

即使需求紧急、时间紧张，以下内容也不可省略：
- 参数校验（不校验 = 不安全）
- 统一响应格式（不统一 = 不可维护）
- 错误码（无错误码 = 不可排查）

Swagger 文档可以在路由确定后补充，但接口提交前必须有。
