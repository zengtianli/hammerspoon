-- 模块加载器
-- 负责管理所有模块的注册、加载和初始化
local utils = require("modules.core.utils")

local M = {}
local loaded_modules = {}
local module_registry = {}
local loading_order = {}

-- 预定义模块组及其加载顺序
local module_groups = {
    core = {
        "utils",
        "script",
        "hotkeys",
    },
    apps = {
        "manager",
        "restart",
        "wechat",
    },
    tools = {
        "system",
        "clipboard",
        "compress"
    },
    media = {
        "music"
    },
    macro = {
        "player",
        "recorder",
        "hotkeys"
    }
}

-- 注册单个模块
local function register_module(group, name)
    local module_id = group .. "." .. name
    local module_path = "modules." .. module_id

    if not module_registry[module_id] then
        module_registry[module_id] = {
            id = module_id,
            path = module_path,
            loaded = false,
            group = group,
            name = name,
            instance = nil
        }
        table.insert(loading_order, module_id)
    end

    return module_registry[module_id]
end

-- 注册所有预定义模块
function M.register_all()
    for group, modules in pairs(module_groups) do
        for _, name in ipairs(modules) do
            register_module(group, name)
        end
    end

    return M
end

-- 加载单个模块
function M.load_module(module_id)
    local module_info = module_registry[module_id]
    if not module_info then
        utils.log("ModuleLoader", "模块未注册: " .. module_id)
        return nil
    end

    if not module_info.loaded then
        utils.log("ModuleLoader", "加载模块: " .. module_id)

        -- 尝试加载模块
        local ok, mod = pcall(require, module_info.path)
        if not ok then
            utils.log("ModuleLoader", "模块加载失败: " .. module_id .. " - " .. tostring(mod))
            return nil
        end

        -- 初始化模块
        if mod.init and type(mod.init) == "function" then
            ok, result = pcall(mod.init)
            if not ok then
                utils.log("ModuleLoader", "模块初始化失败: " .. module_id .. " - " .. tostring(result))
            end
        end

        -- 更新模块状态
        module_info.instance = mod
        module_info.loaded = true
        loaded_modules[module_id] = mod
    end

    return module_info.instance
end

-- 按顺序加载所有模块
function M.load_all()
    local count = 0

    -- 加载核心模块
    for _, module_id in ipairs(loading_order) do
        if module_id:match("^core%.") then
            local mod = M.load_module(module_id)
            if mod then count = count + 1 end
        end
    end

    -- 加载其他模块
    for _, module_id in ipairs(loading_order) do
        if not module_id:match("^core%.") then
            local mod = M.load_module(module_id)
            if mod then count = count + 1 end
        end
    end

    utils.log("ModuleLoader", "已加载 " .. count .. " 个模块")
    return M
end

-- 获取已加载的模块
function M.get_module(module_id)
    return loaded_modules[module_id]
end

-- 获取已注册模块信息
function M.get_module_info()
    return module_registry
end

-- 按需延迟加载模块的代理工厂
function M.lazy_module(module_id)
    return setmetatable({}, {
        __index = function(_, key)
            local mod = M.load_module(module_id)
            if mod then
                return mod[key]
            end
            return nil
        end,

        __call = function(_, ...)
            local mod = M.load_module(module_id)
            if mod then
                return mod(...)
            end
            return nil
        end
    })
end

print("📦 模块加载器已准备就绪")
return M
