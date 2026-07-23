# 元狸图MCP

元狸图MCP是嘉立创 EDA / EasyEDA 专业版的原理图专用 MCP 服务。

这是公开分发仓库，只提供二进制发布包和使用说明，不包含服务端源码。

## 下载

请到 GitHub Releases 下载最新版本：

- `yuanlitu-mcp-private-v0.1.1-win-x64.zip`：完整分发包
- `yuanlitu-mcp.exe`：MCP 服务端单文件可执行程序
- `yuanlitu-mcp-service_v0.1.1.eext`：嘉立创 EDA / EasyEDA 专业版扩展

## 版本

### v0.1.1

- 修复扩展状态悬浮窗中文乱码。
- 修复等待状态端口范围显示错误，统一显示 `49640-49649`。

## 默认连接参数

- 端口范围：`49640-49649`
- WebSocket 路径：`/yuanlitu-mcp`
- 服务标识：`yuanlitu-mcp`

## Codex 配置

添加到 `C:\Users\<你的用户名>\.codex\config.toml`，或项目内 `.codex/config.toml`：

```toml
[mcp_servers.yuanlitu-mcp]
command = "C:/path/to/yuanlitu-mcp.exe"
startup_timeout_sec = 10
tool_timeout_sec = 60
```

把 `C:/path/to/yuanlitu-mcp.exe` 改成实际路径。

## Claude Desktop / Trae 配置

```json
{
  "mcpServers": {
    "yuanlitu-mcp": {
      "command": "C:/path/to/yuanlitu-mcp.exe",
      "args": []
    }
  }
}
```

## 说明

- 公开分发包不包含 `src/` 源码。
- exe 使用 Node SEA 单文件封装。
- 这不是加密或绝对防逆向；它是面向普通分发的无源码可执行包。
- Windows 可能提示未签名程序，正式发布建议做代码签名。
