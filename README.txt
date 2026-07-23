元狸图MCP 公开分发包 v0.1.1

内容：
- yuanlitu-mcp.exe：MCP 服务端，可直接作为 stdio MCP server 启动，不需要分发源码。
- yuanlitu-mcp-service_v0.1.1.eext：嘉立创 EDA / EasyEDA 专业版扩展。

v0.1.1 修复：
- 修复扩展状态悬浮窗中文乱码。
- 修复等待状态端口范围显示错误，统一显示 49640-49649。

默认连接：
- 端口范围：49640-49649
- WebSocket 路径：/yuanlitu-mcp
- 服务标识：yuanlitu-mcp

Codex 配置示例：
添加到 C:\Users\<你的用户名>\.codex\config.toml 或项目 .codex/config.toml：

[mcp_servers.yuanlitu-mcp]
command = "C:/path/to/yuanlitu-mcp.exe"
startup_timeout_sec = 10
tool_timeout_sec = 60

Claude Desktop / Trae 配置示例：

{
  "mcpServers": {
    "yuanlitu-mcp": {
      "command": "C:/path/to/yuanlitu-mcp.exe",
      "args": []
    }
  }
}

注意：
- 请把 C:/path/to/yuanlitu-mcp.exe 改成实际 exe 路径。
- exe 为 Node SEA 单文件封装，不直接分发 src 源码。
- 这不是加密或绝对防逆向；它是面向普通分发的无源码可执行包。
- Windows 可能提示未签名程序，正式发布建议做代码签名。
