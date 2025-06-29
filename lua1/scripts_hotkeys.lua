local scripts, apps, runner, utils = require("lua1.scripts_caller"), require("lua1.app_controls"),
    require("lua1.script_runner"), require("lua1.common_utils")

-- 热键配置表
local hotkeys = {
    -- 应用控制
    { { "cmd", "ctrl", "shift" }, "t", "Ghostty在此处打开", apps.open_ghostty_here },
    { { "cmd", "ctrl", "shift" }, "w", "Cursor在此处打开", apps.open_cursor_here },
    { { "cmd", "ctrl", "shift" }, "v", "Nvim在Ghostty中打开文件", apps.open_file_in_nvim_ghostty },
    { { "cmd", "shift" }, "n", "创建新文件夹", apps.create_folder },
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

    local file_types, menu_items = {}, {}

    -- 分析文件类型
    for _, file in ipairs(files) do
        local ext = file:match("%.([^%.]+)$")
        if ext then file_types[ext:lower()] = true end
    end

    -- 构建转换菜单
    for ext, config in pairs(conversions) do
        if file_types[ext] then
            local item = { title = config.title }
            if config.menu then
                item.menu = {}
                for _, conv in ipairs(config.menu) do
                    table.insert(item.menu, { title = conv.title, fn = function() conv.fn(files) end })
                end
            else
                item.fn = function() config.fn(files) end
            end
            table.insert(menu_items, item)
        end
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
        local menu = hs.menubar.new():setTitle("📁"):setMenu(menu_items)
        menu:removeFromMenuBar()
        hs.alert.show("右键点击菜单栏图标选择操作")
        hs.timer.doAfter(0.1, function() menu:popupMenu(hs.mouse.getAbsolutePosition()) end)
    else
        hs.alert.show("选中的文件类型暂不支持转换")
    end
end

-- 注册热键和自动化
local function init()
    -- 注册所有热键
    for _, hk in ipairs(hotkeys) do
        hs.hotkey.bind(hk[1], hk[2], hk[3], hk[4])
    end

    -- 注册智能菜单热键
    hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "space", "智能转换菜单", show_context_menu)

    -- 应用切换监控
    hs.application.watcher.new(function(appName, eventType)
        if appName == "Finder" and eventType == hs.application.watcher.activated then
            local files = utils.get_selected_files_newline()
            if #files > 0 then utils.log("SCRIPTS_HOTKEYS", "Finder激活，选中了 " .. #files .. " 个文件") end
        end
    end):start()

    print("✅ Scripts Hotkeys 已加载，共注册 " .. (#hotkeys + 1) .. " 个热键")
    hs.alert.show("📁 Scripts Hotkeys 已启动")
end

-- 帮助信息
local function show_help()
    hs.alert.show([[🔥 Scripts Hotkeys 快捷键说明
📱 应用控制:
  ⌘⌃⇧+T: Ghostty在此处打开  ⌘⌃⇧+W: Cursor在此处打开
  ⌘⌃⇧+V: Nvim在Ghostty中打开文件  ⌘⇧+N: 创建新文件夹
🏃 脚本运行:
  ⌘⌃⇧+S: 运行选中脚本  ⌘⌃⇧+R: 并行运行脚本
🎛️ 智能菜单:
  ⌘⌃⌥+Space: 智能转换菜单]], 10)
end

-- 自动初始化并导出
init()
return { init = init, show_help = show_help }
