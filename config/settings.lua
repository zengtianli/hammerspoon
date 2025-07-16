-- 用户配置文件
-- 此文件包含可自定义的配置选项

local M = {}

-- -----------------------------------------------------------------------------
-- 用户首选项设置
-- -----------------------------------------------------------------------------
M.preferred_terminal = "Ghostty" -- 可选: "Ghostty", "Warp", "Terminal"
M.preferred_ide = "Windsurf"     -- 可选: "Cursor", "Windsurf", "VSCode"
M.macro_dir = os.getenv("HOME") .. "/.config/hammerspoon/macros"
M.scripts_dir = os.getenv("HOME") .. "/.config/hammerspoon/scripts"
-- -----------------------------------------------------------------------------

return M
