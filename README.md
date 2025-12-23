# 🍅 RestTime.nvim

> **Code smarter, not harder.**  
> 一个简单、优雅的 Neovim 休息提醒插件，帮助你保持健康的编码节奏。

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

## ✨ 特性 (Features)

- ⏰ **自动计时**：默认 25 分钟工作周期 (Pomodoro 风格)。
- 🔔 **非侵入式提醒**：使用居中的浮动窗口提醒，不打断你的心流，但足够显眼。
- 💤 **贪睡模式 (Snooze)**：手头工作还没结束？按下 `s` 键再专注 5 分钟。
- 🎨 **醒目样式**：支持自定义高亮，默认红色醒目提示，保护你的视力。
- ⚙️ **完全可配置**：工作时长、贪睡时长、提示信息均可自定义。
- 🕹️ **简单控制**：提供直观的命令来启动、停止和查看状态。

## 📸 预览 (Preview)

当休息时间到达时，你会看到：

```text
╔════════════════════════╗
║      休息时间到！      ║
║  该放松一下眼睛和身体  ║
╚════════════════════════╝
在normal模式下按q退出
再工作五分钟请按下s
```

_(窗口背景和边框默认为醒目的红色高亮)_

## 📦 安装 (Installation)

使用你喜欢的包管理器进行安装。

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "SaintFore/rest-time",
    config = function()
        require("rest_time").setup({
            delay = 25,   -- 工作时长 (分钟)
            snooze = 5,   -- 延续时长 (分钟)
            message = "该休息了", -- (可选) 自定义提示信息
        })
    end,
}
```

## ⚙️ 配置 (Configuration)

你可以通过 `setup` 函数传递配置表：

```lua
require("rest_time").setup({
    -- 默认配置
    delay = 25,    -- 距离下一次提醒的时间 (分钟)
    snooze = 5,    -- 点击 's' 后的延迟时间 (分钟)
    message = "该休息了", -- 提醒时的基础消息 (虽然目前主要由 UI 接管显示)
})
```

## 🚀 使用 (Usage)

插件加载后会自动启动。你可以使用以下命令进行控制：

| 命令          | 描述                              |
| :------------ | :-------------------------------- |
| `:RestEnable` | 启动或重置计时器 (开始新一轮工作) |
| `:RestStop`   | 停止计时器 (不再提醒)             |
| `:RestStatus` | 查看距离下次休息还有多久          |

### 弹窗操作

当休息提醒窗口弹出时（在 Normal 模式下）：

- **`q`**: 确认休息完毕，关闭窗口并开始新一轮计时 (默认 25 分钟)。
- **`s`**: 贪睡模式，关闭窗口并在 5 分钟后再次提醒。

---

**Enjoy coding, but don't forget to rest!** ☕
