local scripts = require("lua1.scripts_caller")
local apps = require("lua1.app_controls")
local runner = require("lua1.script_runner")
-- ===== 文件转换热键 =====
-- CSV/Excel转换热键组合 (⌘⌥⇧ + 字母)
local convert_hotkeys = {
    -- -- CSV转换
    -- { { "cmd", "alt", "shift" }, "1", "CSV→TXT", function() scripts.convert.csv_to_txt() end },
    -- { { "cmd", "alt", "shift" }, "2", "CSV→XLSX", function() scripts.convert.csv_to_xlsx() end },
    -- { { "cmd", "alt", "shift" }, "3", "TXT→CSV", function() scripts.convert.txt_to_csv() end },
    -- { { "cmd", "alt", "shift" }, "4", "XLSX→CSV", function() scripts.convert.xlsx_to_csv() end },
    -- -- 文档转换
    -- { { "cmd", "alt", "shift" }, "d", "DOCX→MD", function() scripts.convert.docx_to_md() end },
    -- { { "cmd", "alt", "shift" }, "p", "PPTX→MD", function() scripts.convert.pptx_to_md() end },
    -- -- 批量转换
    -- { { "cmd", "alt", "shift" }, "a", "批量转换所有", function()
    -- 	scripts.convert.office_batch({ all = true, recursive = true })
    -- end },
}
-- ===== 内容提取热键 =====
local extract_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "i", "提取图片", function() scripts.extract.images() end },
    { { "cmd", "ctrl", "shift" }, "t", "提取表格", function() scripts.extract.tables() end },
    { { "cmd", "ctrl", "shift" }, "k", "计算Tokens", function() scripts.extract.text_tokens() end },
}
-- ===== 文件管理热键 =====
local file_hotkeys = {
    { { "cmd", "ctrl", "alt" }, "u", "文件上移", function() scripts.file.move_up_level() end },
    { { "cmd", "ctrl", "alt" }, "c", "合并CSV", function() scripts.merge.csv_files() end },
    { { "cmd", "ctrl", "alt" }, "m", "合并Markdown", function() scripts.merge.markdown_files() end },
}
-- ===== 应用管理热键 =====
local manage_hotkeys = {
    { { "cmd", "ctrl", "alt", "shift" }, "l", "启动应用", function() scripts.manage.launch_apps() end },
    { { "cmd", "ctrl", "alt", "shift" }, "p", "Python包管理", function() scripts.manage.pip_packages() end },
}

-- ===== 应用控制热键 =====
local app_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "t", "Ghostty在此处打开", function() apps.open_ghostty_here() end },
    -- { { "cmd", "alt", "shift" }, "t", "Terminal在此处打开", function() apps.open_terminal_here() end },
    -- { { "cmd", "alt", "shift" }, "v", "VS Code在此处打开", function() apps.open_vscode_here() end },
    { { "cmd", "ctrl", "shift" }, "w", "Cursor在此处打开", function() apps.open_cursor_here() end },
    { { "cmd", "ctrl", "shift" }, "v", "Nvim在Ghostty中打开文件", function() apps.open_file_in_nvim_ghostty() end },
    { { "cmd", "shift" }, "n", "创建新文件夹", function() apps.create_folder() end },
}

-- ===== 脚本运行热键 =====
local script_hotkeys = {
    { { "cmd", "ctrl", "shift" }, "s", "运行选中脚本", function() runner.run_single() end },
    { { "cmd", "ctrl", "shift" }, "r", "并行运行脚本", function() runner.run_parallel() end },
}

-- ===== 测试热键 =====
local test_hotkeys = {
    -- { { "cmd", "ctrl", "shift" }, "t", "测试脚本功能", function()
    --     hs.alert.show("测试 Python 版本检查...")
    --     -- 测试一个简单的Python脚本
    --     scripts.utils.execute_script("convert_csv_to_txt.py", { "--help" }, function(exit_code, stdout, stderr)
    --         if exit_code == 0 then
    --             hs.alert.show("Python 脚本测试成功！")
    --         else
    --             hs.alert.show("Python 脚本测试失败: " .. tostring(exit_code))
    --         end
    --     end)
    -- end },
}
-- ===== 智能上下文菜单 =====
-- 根据选中文件类型显示不同的转换选项
local function show_context_menu()
    local files = scripts.utils.get_selected_files()
    if #files == 0 then
        hs.alert.show("请先在Finder中选择文件")
        return
    end
    local menu_items = {}
    local file_types = {}
    -- 分析文件类型
    for _, file in ipairs(files) do
        local ext = file:match("%.([^%.]+)$")
        if ext then
            file_types[ext:lower()] = true
        end
    end
    -- 根据文件类型构建菜单
    if file_types.csv then
        table.insert(menu_items, {
            title = "CSV转换",
            menu = {
                { title = "CSV → TXT", fn = function() scripts.convert.csv_to_txt(files) end },
                { title = "CSV → XLSX", fn = function() scripts.convert.csv_to_xlsx(files) end },
            }
        })
    end
    if file_types.txt then
        table.insert(menu_items, {
            title = "TXT转换",
            menu = {
                { title = "TXT → CSV", fn = function() scripts.convert.txt_to_csv(files) end },
                { title = "TXT → XLSX", fn = function() scripts.convert.txt_to_xlsx(files) end },
            }
        })
    end
    if file_types.xlsx or file_types.xls then
        table.insert(menu_items, {
            title = "Excel转换",
            menu = {
                { title = "XLSX → CSV", fn = function() scripts.convert.xlsx_to_csv(files) end },
                { title = "XLSX → TXT", fn = function() scripts.convert.xlsx_to_txt(files) end },
            }
        })
    end
    if file_types.docx then
        table.insert(menu_items, {
            title = "Word转换",
            fn = function() scripts.convert.docx_to_md(files) end
        })
    end
    if file_types.pptx then
        table.insert(menu_items, {
            title = "PowerPoint转换",
            fn = function() scripts.convert.pptx_to_md(files) end
        })
    end
    -- Office文档提取选项
    if file_types.docx or file_types.pptx then
        table.insert(menu_items, {
            title = "内容提取",
            menu = {
                { title = "提取图片", fn = function() scripts.extract.images(files) end },
                { title = "提取表格", fn = function() scripts.extract.tables(files) end },
            }
        })
    end
    if #menu_items > 0 then
        local menu = hs.menubar.new()
        menu:setTitle("📁")
        menu:setMenu(menu_items)
        menu:removeFromMenuBar()
        -- 显示上下文菜单
        hs.alert.show("右键点击菜单栏图标选择操作")
        hs.timer.doAfter(0.1, function()
            menu:popupMenu(hs.mouse.getAbsolutePosition())
        end)
    else
        hs.alert.show("选中的文件类型暂不支持转换")
    end
end
-- ===== 智能文件监控 =====
-- 监控下载文件夹，自动处理特定类型文件
local function setup_file_watcher()
    local downloads_path = os.getenv("HOME") .. "/Downloads"
    local watcher = hs.pathwatcher.new(downloads_path, function(files)
        for _, file in ipairs(files) do
            if file:match("%.csv$") then
                hs.notify.new({
                    title = "发现CSV文件",
                    informativeText = "是否转换为Excel？",
                    actionButtonTitle = "转换",
                    otherButtonTitle = "忽略",
                    hasActionButton = true
                }, function(notification)
                    if notification:activationType() == hs.notify.activationTypes.actionButtonClicked then
                        scripts.convert.csv_to_xlsx({ file })
                    end
                end):send()
            end
        end
    end)
    watcher:start()
    return watcher
end
-- ===== 注册所有热键 =====
local function register_hotkeys()
    local all_hotkeys = {}
    -- 合并所有热键
    for _, hotkey_group in ipairs({ convert_hotkeys, extract_hotkeys, file_hotkeys, manage_hotkeys, app_hotkeys, script_hotkeys, test_hotkeys }) do
        for _, hotkey in ipairs(hotkey_group) do
            table.insert(all_hotkeys, hotkey)
        end
    end
    -- 注册热键
    for _, hotkey in ipairs(all_hotkeys) do
        local mods, key, desc, fn = hotkey[1], hotkey[2], hotkey[3], hotkey[4]
        hs.hotkey.bind(mods, key, desc, fn)
    end
    -- 注册上下文菜单热键
    hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "space", "智能转换菜单", show_context_menu)
    print("✅ Scripts Hotkeys 已加载，共注册 " .. (#all_hotkeys + 1) .. " 个热键")
end
-- ===== 自动化规则 =====
-- 应用切换自动化
local function setup_app_automation()
    -- 当切换到Finder时，预加载文件信息
    hs.application.watcher.new(function(appName, eventType, appObject)
        if appName == "Finder" and eventType == hs.application.watcher.activated then
            -- 可以在这里预处理一些信息
            local files = scripts.utils.get_selected_files()
            if #files > 0 then
                print("Finder激活，选中了 " .. #files .. " 个文件")
            end
        end
    end):start()
end
-- ===== 模块导出 =====
local scripts_hotkeys = {}
function scripts_hotkeys.init()
    register_hotkeys()
    setup_app_automation()
    -- setup_file_watcher() -- 可选：自动文件监控
    hs.alert.show("📁 Scripts Hotkeys 已启动")
end

function scripts_hotkeys.show_help()
    local help_text = [[
🔥 Scripts Hotkeys 快捷键说明
📄 文件转换 (⌘⌥⇧ + 数字/字母):
  1: CSV→TXT    2: CSV→XLSX
  3: TXT→CSV    4: XLSX→CSV
  D: DOCX→MD    P: PPTX→MD
  A: 批量转换所有
🎯 内容提取 (⌘⌃⇧ + 字母):
  I: 提取图片    T: 提取表格
  K: 计算Tokens
📁 文件管理 (⌘⌃⌥ + 字母):
  U: 文件上移    C: 合并CSV
  M: 合并Markdown
⚙️ 系统管理:
  ⌘⌃⌥⇧+L: 启动应用  ⌘⌃⇧+P: Python包管理
📱 应用控制 (⌘⌃⇧ + 字母):
  T: Ghostty在此处打开  W: Cursor在此处打开
  V: Nvim在Ghostty中打开文件  N: 创建新文件夹
🏃 脚本运行 (⌘⌃⇧ + 字母):
  S: 运行选中脚本  R: 并行运行脚本
🎛️ 智能菜单:
  ⌘⌃⌥ + Space: 智能转换菜单
]]
    hs.alert.show(help_text, 10)
end

-- 自动初始化
scripts_hotkeys.init()

return scripts_hotkeys
