元狸图 MCP 公开分发包 v0.1.35（Windows x64）

内容：
- yuanlitu-mcp.exe：MCP 服务端 v0.1.33，可直接作为 stdio MCP server 启动。
- yuanlitu-mcp-service_v0.1.35.eext：嘉立创 EDA / EasyEDA 专业版扩展。

功能范围：
- 连接 EasyEDA 专业版当前工程。
- 读取原理图页、器件、引脚、导线、网络、属性和自由文本注释。
- 搜索 EasyEDA / LCSC 元器件库。
- 放置和移动器件、创建分页、连接引脚、添加电源地标志和文字注释。
- 预览并导入逻辑设计，查看导入检查点。
- 标记未连接引脚。
- 运行原理图 DRC。
- 每个会话首次写入自动备份原理图。

不包含：
- 服务端源代码。
- PCB 自动布线相关能力。
- 内置 AI API 请求能力。

默认连接：
- 端口范围：49640-49649
- WebSocket 路径：/yuanlitu-mcp
- 服务标识：yuanlitu-mcp

Codex 配置示例：

[mcp_servers.yuanlitu_easyeda]
command = "C:/Tools/yuanlitu-mcp/yuanlitu-mcp.exe"
args = []
startup_timeout_sec = 20
tool_timeout_sec = 120

Claude Desktop / Trae 配置示例：

{
  "mcpServers": {
    "yuanlitu_easyeda": {
      "command": "C:/Tools/yuanlitu-mcp/yuanlitu-mcp.exe",
      "args": []
    }
  }
}

使用步骤：
1. 安装 .eext 到嘉立创 EDA / EasyEDA 专业版。
2. 把 yuanlitu-mcp.exe 放到固定目录。
3. 在 Codex / Claude / Trae 的 MCP 配置中填写 exe 路径。
4. 打开 EDA 工程和原理图。
5. 重启 MCP Host 或刷新 MCP 服务。
6. 在扩展「连接状态」中按需选择「切换主原理图」。
7. 在原理图菜单打开「元狸图 MCP → 功能与版本」，查看功能、连接和近期更新。

注意：
- 请把 C:/Tools/yuanlitu-mcp/yuanlitu-mcp.exe 改成实际路径。
- 当前 exe 未做代码签名，Windows 可能提示未知发布者。
- 这不是加密或绝对防逆向方案，只是面向普通分发的无源码可执行包。
