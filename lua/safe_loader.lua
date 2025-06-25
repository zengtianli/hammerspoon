local common = require("lua.common_functions")
local M = common.createStandardModule("安全加载器")
M.loadedModules = {}
function M.loadModule(modulePath, moduleName)
	moduleName = moduleName or modulePath
	local ok, result = pcall(function()
		package.loaded[modulePath] = nil
		return require(modulePath)
	end)
	if ok then
		M.loadedModules[moduleName] = result
		return result
	else
		common.showError("加载失败: " .. moduleName)
		return nil
	end
end

function M.loadModules(moduleList)
	local results = {}
	for _, moduleInfo in ipairs(moduleList) do
		local modulePath, moduleName
		if type(moduleInfo) == "string" then
			modulePath = moduleInfo
			moduleName = moduleInfo:match("([^%.]+)$")
		else
			modulePath = moduleInfo.path
			moduleName = moduleInfo.name or moduleInfo.path
		end
		local module = M.loadModule(modulePath, moduleName)
		if module then
			results[moduleName] = module
		end
	end
	return results
end

function M.requireAllFromDirectory(directory)
	local path = hs.configdir .. '/' .. directory
	if not hs.fs.attributes(path, "mode") then
		common.showError('目录不存在: ' .. path)
		return {}
	end
	local iter, dir_obj = hs.fs.dir(path)
	if not iter then
		common.showError('无法打开目录: ' .. path)
		return {}
	end
	local moduleList = {}
	for file in iter, dir_obj do
		if file:sub(-4) == ".lua" and file ~= "common_functions.lua" and file ~= "safe_loader.lua" then
			local modulePath = directory .. '.' .. file:sub(1, -5)
			local moduleName = file:sub(1, -5)
			table.insert(moduleList, { path = modulePath, name = moduleName })
		end
	end
	return M.loadModules(moduleList)
end

function M.checkDeps()
	return common.checkModule("hs.fs")
end

if M.config.enabled then
	M:init()
end
return M
