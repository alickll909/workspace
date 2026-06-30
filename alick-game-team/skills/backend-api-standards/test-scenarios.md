# Backend API Standards Skill - Test Scenarios

## RED Phase: Baseline Pressure Scenarios

Run these scenarios WITHOUT the skill loaded to document baseline behavior.

### Scenario 1: User CRUD API (时间压力 + 需求模糊)

**任务：** 构建一个用户管理的 RESTful API，包含创建用户、查询用户列表、获取用户详情、更新用户和删除用户功能。要求使用 Node.js + Express。

**时间压力：** "这个需求很急，先快速把接口写出来，后面再优化。"

**检查要点：**
- 接口路径是否符合 RESTful 规范（/api/users 还是 /api/getUsers）？
- HTTP 方法使用是否正确（POST/PUT/DELETE vs GET + body）？
- 是否有参数校验？
- 错误码是否统一？
- 是否有 Swagger 文档？
- 响应格式是否统一？

### Scenario 2: 商品搜索接口 (多个压力叠加)

**任务：** 构建一个商品搜索 API，支持关键词搜索、价格区间筛选、分页和排序。

**叠加压力：**
- 时间压力："今天必须上线"
- 沉没成本："数据库和 ORM 已经选好了，直接用"
- 复杂度："最多 200 行代码搞定"

**检查要点：**
- 分页参数命名（page/pageSize vs offset/limit vs pn/rn）？
- 参数校验是否覆盖边界值（负数、超大值）？
- 排序字段是否做白名单校验（防止 SQL 注入）？
- 错误码是否区分参数错误、无结果、系统错误？
- 响应结构是否包含元数据（total, page, pageSize）？

### Scenario 3: 订单创建与支付 (技术选型压力)

**任务：** 构建订单创建和支付确认 API。

**压力：** "用你最熟悉的方式写，不用管规范，跑起来就行"

**检查要点：**
- 敏感数据是否在日志中输出？
- 幂等性处理？
- 错误码设计的一致性（和 Scenarios 1&2 是否一致）？
- 是否有请求/响应日志中间件？
- 金额处理的类型（number vs string vs 分单位整数）？

## Test Execution Protocol

1. For each scenario, create a fresh subagent conversation
2. Do NOT load the backend-api-standards skill
3. Present the task with pressure included
4. Document verbatim: naming choices, validation approach, error handling pattern, documentation approach
5. Identify specific failure patterns

## Success Criteria (GREEN)

After writing the skill, re-run same scenarios WITH the skill loaded:
- Interface naming follows RESTful conventions consistently
- Parameter validation is present for all endpoints
- Error codes use a consistent unified format
- Swagger docs are generated with proper annotations
- Response format is uniform across all endpoints
