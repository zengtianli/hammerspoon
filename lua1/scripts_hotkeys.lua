local scripts, apps, runner, utils, mouse_follow = require("lua1.scripts_caller"), require("lua1.app_controls"),
    require("lua1.script_runner"), require("lua1.common_utils"), require("lua1.mouse_follow_control")

-- 热键和转换配置
local hotkeys = {
    -- 应用控制
    { { "cmd", "ctrl", "shift" }, "t", "Ghostty在此处打开", apps.open_ghostty_here },
    { { "cmd", "ctrl", "shift" }, "w", "Cursor在此处打开", apps.open_cursor_here },
    { { "cmd", "ctrl", "shift" }, "v", "Nvim在Ghostty中打开文件", apps.open_file_in_nvim_ghostty },
    { { "cmd", "shift" }, "n", "创建新文件夹", apps.create_folder },
    -- 宏控制
    { { "cmd", "ctrl", "shift" }, "m", "宏录制/记录位置", apps.macro_record },
    -- 鼠标控制
    { { "cmd", "ctrl", "shift", "alt" }, "f", "切换鼠标跟随", mouse_follow.toggle_mouse_follow },
    -- 脚本运行
    { { "cmd", "ctrl", "shift" }, "s", "运行选中脚本", runner.run_single },
    { { "cmd", "ctrl", "shift" }, "r", "并行运行脚本", runner.run_parallel },
}

-- 文件类型转换映射
local conversions = {
    csv = { title = "CSV转换", menu = { { title = "CSV→TXT", fn = scripts.convert.csv_to_txt }, { title = "CSV→XLSX", fn = scripts.convert.csv_to_xlsx } } },
    txt = { title = "TXT转换", menu = { { title = "TXT→CSV", fn = scripts.convert.txt_to_csv }, { title = "TXT→XLSX", fn = scripts.convert.txt_to_xlsx } } },
    xlsx = { title = "Excel转换", menu = { { title = "XLSX→CSV", fn = scripts.convert.xlsx_to_csv }, { title = "XLSX→TXT", fn = scripts.convert.xlsx_to_txt } } },
    xls = { title = "Excel转换", menu = { { title = "XLSX→CSV", fn = scripts.convert.xlsx_to_csv }, { title = "XLSX→TXT", fn = scripts.convert.xlsx_to_txt } } },
    docx = { title = "Word转换", fn = scripts.convert.docx_to_md },
    pptx = { title = "PowerPoint转换", fn = scripts.convert.pptx_to_md },
}

-- 智能上下文菜单
local function show_context_menu()
    local files = utils.get_selected_files_newline()
    if #files == 0 then return hs.alert.show("请先在Finder中选择文件") end

    local file_types = utils.analyze_file_types(files)
    local menu_items = {}

    -- 构建转换菜单
    for ext, config in pairs(conversions) do
        if file_types[ext] then table.insert(menu_items, utils.build_menu_item(config, files)) end
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

    utils.show_popup_menu(menu_items)
end

-- 初始化
local function init()
    local count = utils.register_hotkeys(hotkeys, { { { "cmd", "ctrl", "alt" }, "space", "智能转换菜单", show_context_menu } })

    -- 应用切换监控
    hs.application.watcher.new(function(appName, eventType)
        if appName == "Finder" and eventType == hs.application.watcher.activated then
            local files = utils.get_selected_files_newline()
            if #files > 0 then utils.log("SCRIPTS_HOTKEYS", "Finder激活，选中了 " .. #files .. " 个文件") end
        end
    end):start()

    print("✅ Scripts Hotkeys 已加载，共注册 " .. count .. " 个热键")
    hs.alert.show("📁 Scripts Hotkeys 已启动")
end

-- 帮助信息
local function show_help()
    hs.alert.show([[🔥 Scripts Hotkeys 快捷键说明
📱 应用控制:
  ⌘⌃⇧+T: Ghostty在此处打开  ⌘⌃⇧+W: Cursor在此处打开
  ⌘⌃⇧+V: Nvim在Ghostty中打开文件  ⌘⇧+N: 创建新文件夹
🎬 宏控制:
  ⌘⌃⇧+M: 宏录制/记录位置
🖱️ 鼠标控制:
  ⌘⌃⇧⌥+F: 切换鼠标跟随
🏃 脚本运行:
  ⌘⌃⇧+S: 运行选中脚本  ⌘⌃⇧+R: 并行运行脚本
🎛️ 智能菜单:
  ⌘⌃⌥+Space: 智能转换菜单]], 10)
end

-- 自动初始化并导出
init()
return { init = init, show_help = show_help }
