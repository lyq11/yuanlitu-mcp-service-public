---
name: yuanlitu-mcp-deploy
description: 在 Windows 上安装、升级或检查元狸图 MCP 和配套的嘉立创 EDA 专业版扩展。用于用户要求一键部署元狸图、配置 Codex 的本地 MCP 服务或排查安装后的连接。原理图设计与修改使用已连接的 MCP 工具。
---

# 部署元狸图 MCP

## 安装与升级

1. 在用户的 Windows 本机运行 [scripts/install.ps1](scripts/install.ps1)。用脚本的绝对路径调用，避免依赖当前工作目录。

   ~~~powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<技能目录>\scripts\install.ps1"
   ~~~

   默认从官方公开仓库获取最新发行版，校验 SHA-256 后按版本安装到 `%LOCALAPPDATA%\YuanlituMCP`，并配置 Codex 的 `yuanlitu_easyeda`。用户指定版本时传 `-Version v0.1.35` 这类参数。为 Claude、Trae 等其他客户端准备文件时传 `-ArtifactsOnly`，向用户提供返回的 `server` 路径供其客户端配置。

2. 读取脚本返回的 JSON。向用户提供 `extension` 的本地绝对路径。在嘉立创 EDA 专业版 V3 的 **高级 → 扩展管理器 → 导入** 中选这个 `.eext` 文件并启用。需要时在扩展管理器允许外部交互。让用户重启或刷新 MCP 客户端，再在 EDA 中打开工程和原理图。
3. 刷新后如果 MCP 工具可用，先调用 `easyeda_get_mcp_server_port` 核对实际端口，再调用 `easyeda_health` 检查扩展连接。若 EDA 指定了固定端口，在「元狸图 MCP → 显示连接状态 → 切换端口」填实际端口。只有健康检查确认扩展已连接时才报告部署连通。需要选择主原理图时，使用扩展的「切换主原理图」入口。

## 异常处理

- 脚本会备份 Codex 配置，只更新自己管理的条目。遇到同名自定义 MCP 条目时，保留用户配置。先说明冲突，再按用户明确指定的现有条目处理。
- 校验失败或包结构异常时停止安装，保留原配置。报告失败的文件和版本。
- 脚本返回文件路径只表示本机部署已完成。EDA 导入、客户端刷新和桥接验证分别确认。部署过程使用只读检查，保持工程内容原样。

[嘉立创 EDA 扩展安装说明](https://prodocs.lceda.cn/cn/api/user-guide/using-extension.html)
