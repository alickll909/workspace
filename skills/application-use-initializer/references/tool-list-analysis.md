好的，以下是六个工具的详细对比分析：

---

## 📊 工具总览对比表

| 工具 | 检测对象 | 使用方式              | 使用平台 | 定位能力 | 适用场景 | 依赖浏览器 |
|------|---------|-------------------|---------|---------|---------|-----------|
| **Playwright** | Web页面 | MCP / 独立CLI       | 跨平台 | 坐标 + Accessibility树 | 浏览器自动化、测试、爬虫 | ✅ Chrome/Chromium |
| **auto-feedback** | Web + 桌面应用 | MCP               | 跨平台 | 坐标 + Accessibility树 | QA测试、跨平台应用测试 | ✅ (Web部分) |
| **application-use** | macOS桌面应用 | Skill / CLI       | macOS | Accessibility树（字母标签） | macOS应用操作、日常自动化 | ❌ |
| **agent-computer** | macOS桌面应用 | MCP / SDK         | macOS | Accessibility树（类型引用） | 复杂macOS工作流、窗口管理 | ❌ |
| **playwright-spatial-layout-mcp** | Web页面 | MCP               | 跨平台 | 几何空间（坐标/尺寸/重叠） | 布局问题检测、视觉回归 | ✅ Chrome/Chromium |
| **@saifulapm/layoutlint** | Web组件代码 | MCP /  CLI / CI集成 | 跨平台 | 静态代码分析（无真实渲染） | CI/CD、开发阶段布局检测 | ❌（纯代码分析） |

---

## 🔍 详细分析

### 1. auto-feedback

| 维度 | 说明 |
|------|------|
| **检测对象** | Web页面 + 桌面应用（Windows/macOS/Linux） |
| **使用方式** | MCP服务 |
| **使用平台** | Windows、macOS、Linux |
| **定位能力** | 坐标 + Accessibility树（基于Playwright + 原生API） |
| **适用场景** | 跨平台应用测试、QA自动化、可访问性审计 |
| **依赖浏览器** | ✅ Web测试依赖Chromium；桌面测试不依赖 |
| **特点** | 23-43个工具，支持WCAG审计、截图对比、Tauri/Electron应用测试 |

---

### 2. playwright（标准版）

| 维度 | 说明 |
|------|------|
| **检测对象** | Web页面 |
| **使用方式** | MCP服务 / 独立npm包 |
| **使用平台** | Windows、macOS、Linux |
| **定位能力** | 坐标 + CSS选择器 + XPath |
| **适用场景** | 浏览器自动化、Web测试、数据爬取 |
| **依赖浏览器** | ✅ 依赖Chromium/Firefox/WebKit |
| **特点** | 微软官方，生态最成熟，Codegen代码生成，智能等待 |

---

### 3. application-use

| 维度 | 说明 |
|------|------|
| **检测对象** | macOS桌面应用（Safari、邮件、Finder等） |
| **使用方式** | Skill / 独立CLI（`npx skills add`） |
| **使用平台** | macOS |
| **定位能力** | Accessibility树（输出字母标签如JK/AA供AI点击） |
| **适用场景** | 日常macOS应用操作、单步自动化任务 |
| **依赖浏览器** | ❌ 不依赖（但可操作Safari浏览器本身） |
| **特点** | 轻量级，即时命令模式，字母标签节省Token |

---

### 4. agent-computer

| 维度 | 说明 |
|------|------|
| **检测对象** | macOS桌面应用 |
| **使用方式** | MCP服务 / TypeScript SDK |
| **使用平台** | macOS 13+ |
| **定位能力** | Accessibility树（输出类型引用如@b3按钮、@t5文本框） |
| **适用场景** | 复杂macOS工作流（多步操作、窗口管理、菜单控制） |
| **依赖浏览器** | ❌ 不依赖 |
| **特点** | 持久守护进程（~5ms响应），支持窗口分屏、对话框处理、剪贴板 |

---

### 5. playwright-spatial-layout-mcp

| 维度 | 说明 |
|------|------|
| **检测对象** | Web页面的空间布局 |
| **使用方式** | MCP服务 |
| **使用平台** | 跨平台（Node.js环境） |
| **定位能力** | 几何空间（`getBoundingClientRect`获取精确坐标、尺寸、z-index） |
| **适用场景** | 检测元素重叠、遮挡、超出视口、响应式布局变化 |
| **依赖浏览器** | ✅ 依赖Chromium |
| **特点** | 专为布局检测设计，可计算重叠比例、验证`fits_viewport`规则 |

---

### 6. @saifulapm/layoutlint

| 维度 | 说明 |
|------|------|
| **检测对象** | Web组件源代码（React/Vue + Tailwind CSS） |
| **使用方式** | CLI / CI集成（`npx @saifulapm/layoutlint check`） |
| **使用平台** | 跨平台（Node.js环境） |
| **定位能力** | 静态代码分析（Yoga CSS布局引擎模拟计算） |
| **适用场景** | 开发阶段、CI流水线中的布局问题检测 |
| **依赖浏览器** | ❌ 不依赖（纯代码分析，无需启动浏览器） |
| **特点** | 极快（~8ms检测4个视口），误差≤1px，支持GitHub Actions |

---

## 📈 按使用场景选择指南

| 你的需求 | 推荐工具 |
|---------|---------|
| **浏览器自动化（点击/填表/截图）** | Playwright |
| **检测Web页面元素是否重叠或遮挡** | playwright-spatial-layout-mcp |
| **开发时检测组件横向滚动问题** | @saifulapm/layoutlint |
| **操作macOS应用（单步快速任务）** | application-use |
| **操作macOS应用（复杂多步工作流）** | agent-computer |
| **跨平台应用测试（Web + 桌面）** | auto-feedback |
| **一体化QA流程（含可访问性审计）** | auto-feedback |

---

## 💡 组合使用建议

根据你的实际场景，可以组合使用：

1. **Web布局检测工作流**：
   - 开发阶段：`@saifulapm/layoutlint`（CI快速检查）
   - 上线前测试：`playwright-spatial-layout-mcp`（真实浏览器验证）

2. **macOS应用自动化**：
   - 日常单步：`application-use`
   - 复杂流程：`agent-computer`

3. **全栈测试**：
   - 浏览器测试：`Playwright`
   - 桌面测试：`auto-feedback`
   - 布局验证：`playwright-spatial-layout-mcp`

如果需要进一步了解某个工具的安装步骤或具体用法示例，告诉我你的目标场景即可。