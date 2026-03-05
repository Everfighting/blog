---
title: OpenClaw完全速查手册2026：一份搞定AI助手配置的所有命令
date: 2026-03-05 17:10:00
tags:
  - OpenClaw
  - AI工具
  - CLI工具
  - 开发工具
  - 速查手册

categories: 开发工具
description: OpenClaw社区参考指南2026版本：从快速安装、通道管理到工作区结构、故障排查，一站式掌握OpenClaw的所有核心命令
abbrlink: openclaw-cheatsheet-2026
toc: true
---

# OpenClaw 完全速查手册 🚀
**社区参考指南 | 2026 版本**

---

## 📌 快速安装

### 全局安装
```bash
npm install -g openclaw@latest
```

### 安装守护进程
```bash
openclaw onboarding --install-daemon
```

### 全局标志
| 标志 | 说明 |
| :--- | :--- |
| `--dev` | 隔离状态到 `~/.openclaw-dev` |
| `--profile <name>` | 隔离状态到 `~/.openclaw-<name>` |
| `--json` | 输出机器可读的 JSON 格式 |
| `--no-color` | 禁用 ANSI 颜色输出 |

---

## 🔧 核心CLI命令

### 基础服务管理

| 命令 | 功能说明 | 示例 |
| :--- | :--- | :--- |
| `openclaw gateway` | 启动 WebSocket 网关服务器 | `openclaw gateway --port 8080` |
| `openclaw gateway start\|stop\|restart` | 管理网关服务生命周期 | `openclaw gateway restart` |
| `openclaw onboard --install-daemon` | 运行交互式设置向导 | `openclaw onboard --install-daemon` |
| `openclaw doctor --deep` | 执行健康检查和快速修复 | `openclaw doctor --deep` |

### 配置与模型

| 命令 | 功能说明 | 示例 |
| :--- | :--- | :--- |
| `openclaw config get\|set\|unset` | 读取/写入/删除配置值 | `openclaw config set openai.api_key "sk-..."` |
| `openclaw models list\|set\|status` | 管理和查看可用模型 | `openclaw models set claude-3-opus-20240229` |
| `openclaw models auth setup --token` | 设置模型认证流程 | `openclaw models auth setup --token "ANTHROPIC_API_KEY"` |

---

## 📱 通道管理

### 添加聊天平台通道

| 平台 | 命令 | 说明 |
| :--- | :--- | :--- |
| **WhatsApp** | `openclaw channels login` | 扫描二维码完成绑定 |
| **Telegram** | `openclaw channels add --channel telegram` | 需要提供 Bot Token |
| **Discord** | `openclaw channels add --channel discord` | 需要提供 Bot Token |
| **Slack** | `openclaw channels add --channel slack` | 需要提供 Bot Token |
| **iMessage** | 原生支持 | macOS 原生桥接 |

### 通道状态检查

```bash
openclaw channels status --probe
```

---

## 📁 工作区结构

OpenClaw 的工作区默认位于 `~/.openclaw/workspace`：

| 文件 | 用途 |
| :--- | :--- |
| `AGENTS.md` | 存储智能体的指令和配置 |
| `USER.md` | 用户偏好设置 |
| `MEMORY.md` | 长期记忆存储 |
| `HEARTBEAT.md` | 系统检查清单 |
| `SOUL.md` | 角色设定 (Persona) 和语气 (Tone) |
| `IDENTITY.md` | 名称和主题 |
| `BOOTSTRAP.md` | 启动脚本 |
| `memory/YYYY-MM-DD.md` | 每日对话日志 |

---

## 💬 聊天内斜杠命令

| 命令 | 功能 |
| :--- | :--- |
| `/status` | 显示健康状态和当前上下文 |
| `/context list` | 列出所有上下文贡献者 |
| `/model <m>` | 切换当前使用的模型 |
| `/compact` | 释放窗口空间 |
| `/new` | 开启全新会话 |
| `/stop` | 中止当前运行的任务 |
| `/tts on\|off` | 开启/关闭文本转语音 |
| `/think` | 开启/关闭推理模式 |

**示例：**
```
/new
帮我写一份市场分析报告
```

---

## 🧠 记忆与模型管理

| 功能 | 命令 | 示例 |
| :--- | :--- | :--- |
| 向量搜索 | `memory search "X"` | `memory search "2024年Q1销售数据"` |
| 模型切换 | `models set <model>` | `models set gpt-4-turbo-preview` |
| 认证设置 | `models auth setup` | `models auth setup` |

---

## 🎣 Hooks & Skills 扩展

| 命令 | 功能 | 示例 |
| :--- | :--- | :--- |
| `clawhub install <slug>` | 从 ClawHub 安装技能/钩子 | `clawhub install weather` |
| `openclaw hooks list` | 列出所有已安装的钩子 | `openclaw hooks list` |

---

## 🔍 故障排查

| 问题 | 解决方案 |
| :--- | :--- |
| 无 DM 回复 | 检查配对列表并批准 |
| 群组中保持静默 | 检查提及模式 (Mention Patterns) 配置 |
| 认证过期 | 重新运行 `models auth setup --token` |
| 网关关闭 | 执行 `doctor --deep` 进行深度诊断 |
| 内存 Bug | 重建内存索引 (`MEMORY INDEX`) |

---

## 🗂️ 核心文件路径

```
主配置:         ~/.openclaw/openclaw.json
默认工作区:     ~/.openclaw/workspace/
智能体状态:     ~/.openclaw/agents/<id>/
OAuth & 密钥:   ~/.openclaw/credentials/
向量索引存储:   ~/.openclaw/memory/<id>.sqlite
全局共享技能:   ~/.openclaw/skills/
网关日志:       /tmp/openclaw/*.log
```

---

## 🎤 语音与文本转语音

### 支持的服务

| 类型 | 服务 | API Key |
| :--- | :--- | :--- |
| **付费服务** | OpenAI / ElevenLabs | ✅ 需要 |
| **免费服务** | Edge TTS | ❌ 不需要 |

### 自动TTS配置

```bash
openclaw config set messages.tts.auto "always"
```

---

## 🤖 自动化与研究

| 功能 | 命令 | 示例 |
| :--- | :--- | :--- |
| 浏览器自动化 | `browser start\|screenshot` | `browser screenshot "https://example.com"` |
| 子智能体管理 | `/subagents list\|info` | `/subagents list` |
| 定时任务 | `cron list\|run <id>` | `cron run "daily-report"` |
| 心跳设置 | `heartbeat.every: "30m"` | 配置中设置每30分钟检查 |

---

**💡 提示：保存这份速查手册到你的常用位置，随时查阅！**
