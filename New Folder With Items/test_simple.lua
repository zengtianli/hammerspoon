-- 简单测试
local common = require("lua.common_functions")

print("🔧 测试开始")

-- 检查 scripts.execute 函数
print("📁 basePath:", common.scripts.basePath)
print("📄 scriptPath:", common.scripts.getPath("mouse_follow_toggle.sh"))

-- 直接调用就像 util_mouse_follow.lua 中那样
print("🚀 调用 common.scripts.execute...")
local result = common.scripts.execute("mouse_follow_toggle.sh", function(exitCode, stdOut, stdErr)
    print("📝 回调被调用:")
    print("   exitCode:", exitCode)
    print("   stdOut:", stdOut)
    print("   stdErr:", stdErr)
end)

print("🎯 execute 返回值:", result)
print("🎯 返回值类型:", type(result))
