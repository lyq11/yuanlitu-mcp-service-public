# 元狸图 MCP

元狸图 MCP 是面向嘉立创 EDA / EasyEDA 专业版的本地 MCP 工具。它把 EDA 内的原理图能力通过本机白名单 RPC 暴露给 Codex、Claude、Trae 等 MCP Host，让 AI 可以读取、检查并安全修改当前打开的原理图。

这个仓库是公开分发仓库，只提供二进制发布包和使用说明，不包含服务端源代码。

## 当前版本

首个可用测试版：`v0.1.1`

默认连接参数：

- 端口范围：`49640-49649`
- WebSocket 路径：`/yuanlitu-mcp`
- 服务标识：`yuanlitu-mcp`

## 可以做什么

当前版本聚焦原理图，不提供 PCB 布线相关能力。

- 连接状态检查：确认 EasyEDA 扩展、当前工程、当前原理图和当前页面。
- 原理图页读取：列出工程内的原理图和页面。
- 原理图结构化读取：读取器件、引脚、导线、网络标签、网络和器件属性。
- 局部区域检查：只读取指定矩形区域内的器件和导线。
- 元器件库搜索：按型号、封装、参数搜索 EasyEDA / LCSC 器件。
- 器件放置：把库器件放入当前原理图页面。
- 安全连线：创建导线、连接引脚、创建电源/地网络、创建网络端口。
- 属性修改：修改已有器件属性，例如 Value、供应商信息可见性等。
- NC 标记：给确认未使用的引脚添加 / 取消非连接标识。
- 文本标注：添加设计说明、排针定义、布局注意事项。
- 原理图 DRC：触发 EasyEDA 原理图检查。
- 可读性分析：估算导线交叉、零长线、器件拥挤等问题。
- 自动备份：每个会话首次写入时自动备份原理图，降低误操作风险。

典型用途：

- 让 AI 帮你检查原理图悬空、未连接、重复位号、网络命名问题。
- 根据设计要求添加局部电路，例如 USB、LDO、按键、排针、去耦等。
- 根据 DRC 结果修复明确的问题。
- 让 AI 生成或整理核心板、模块板、接口板的原理图草稿。

## 暂不提供

- PCB 自动布线。
- 信号线自动走线、过孔、铺铜等高风险 PCB 写入能力。
- 云端 AI 请求能力。本工具只负责 MCP 与 EDA 的本地连接；AI 能力由 Codex、Claude、Trae 等 MCP Host 提供。
- 源代码公开分发。公开仓库只发布 exe 和 EasyEDA 扩展包。

## 下载

到 GitHub Releases 下载最新版本：

[https://github.com/lyq11/yuanlitu-mcp-service-public/releases](https://github.com/lyq11/yuanlitu-mcp-service-public/releases)

发布包通常包含：

- `yuanlitu-mcp-private-v0.1.1-win-x64.zip`：完整 Windows 分发包。
- `yuanlitu-mcp.exe`：MCP 服务端单文件可执行程序。
- `yuanlitu-mcp-service_v0.1.1.eext`：嘉立创 EDA / EasyEDA 专业版扩展。

## 安装步骤

1. 下载 release 中的 `.zip` 或分别下载 `.exe` 与 `.eext`。
2. 解压到固定目录，例如：

   ```text
   C:\Tools\yuanlitu-mcp\
   ```

3. 在嘉立创 EDA / EasyEDA 专业版中安装 `.eext` 扩展。
4. 打开 EDA 工程和原理图页面。
5. 在 MCP Host 中配置 `yuanlitu-mcp.exe`。
6. 重启 MCP Host，或在 Host 中刷新 MCP 连接。
7. 在 EDA 插件菜单中查看连接状态；必要时点击“重新连接”。

## Codex 配置

添加到：

```text
C:\Users\<你的用户名>\.codex\config.toml
```

示例：

```toml
[mcp_servers.yuanlitu_easyeda]
command = "C:/Tools/yuanlitu-mcp/yuanlitu-mcp.exe"
args = []
startup_timeout_sec = 20
tool_timeout_sec = 120
```

如果你希望 Codex 对只读工具少询问，可以追加：

```toml
[mcp_servers.yuanlitu_easyeda.tools.easyeda_health]
approval_mode = "approve"

[mcp_servers.yuanlitu_easyeda.tools.schematic_list_pages]
approval_mode = "approve"

[mcp_servers.yuanlitu_easyeda.tools.schematic_inspect_page]
approval_mode = "approve"
```

## Claude Desktop 配置

打开 Claude Desktop 配置文件，加入：

```json
{
  "mcpServers": {
    "yuanlitu_easyeda": {
      "command": "C:/Tools/yuanlitu-mcp/yuanlitu-mcp.exe",
      "args": []
    }
  }
}
```

修改后重启 Claude Desktop。

## Trae 配置

在 Trae 的 MCP 配置中加入：

```json
{
  "mcpServers": {
    "yuanlitu_easyeda": {
      "command": "C:/Tools/yuanlitu-mcp/yuanlitu-mcp.exe",
      "args": []
    }
  }
}
```

修改后重启 Trae 或刷新 MCP 服务。

## 使用建议

- 先让 AI 执行连接检查，再读取当前原理图页面。
- 对写入类操作，建议先让 AI 说明将要修改的区域和器件。
- 大范围修改前，确认当前原理图是 `[main]`，备份页应标记为 `[backup]`。
- 如果 EDA 插件显示等待连接，检查 MCP Host 是否已启动 `yuanlitu-mcp.exe`，以及端口 `49640-49649` 是否被占用。

## 常见问题

### 是否必须开放源代码？

不必须。当前公开仓库只发布无源码二进制包。需要说明的是，这不是加密或绝对防逆向方案，只是普通用户分发场景下的无源码可执行包。

### 为什么插件本身不内置 AI API Key？

基础版定位是纯 MCP 工具，AI 请求由 MCP Host 负责。这样用户可以直接使用 Codex、Claude、Trae 等现有工具，不需要在 EDA 插件里额外配置 API Key。

### Windows 提示未知发布者怎么办？

当前 exe 未做代码签名，Windows 可能提示未知发布者。正式商业发布建议增加代码签名。

## 版本记录

### v0.1.1

- 修复扩展状态悬浮窗中文乱码。
- 修复等待状态端口范围显示错误，统一显示 `49640-49649`。
- 拆分为原理图 MCP 工具，移除 PCB 布线相关能力。
- 发布 public 分发仓库，源码仓库保持私有。
