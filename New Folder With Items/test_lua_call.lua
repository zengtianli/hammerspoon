-- 测试 lua 调用脚本
local common = require("lua.common_functions")

print("🧪 开始测试 lua 脚本调用...")

-- 测试脚本路径
local scriptPath = common.scripts.getPath("mouse_follow_toggle.sh")
print("📁 脚本路径:", scriptPath)

-- 检查文件是否存在
if common.fileExists(scriptPath) then
    print("✅ 脚本文件存在")
else
    print("❌ 脚本文件不存在")
    return
end

-- 执行脚本并监控输出
print("🚀 开始执行脚本...")
local task = hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
    print("🔍 脚本执行完成:")
    print("   退出码:", exitCode)
    print("   标准输出:", stdOut or "无")
    print("   标准错误:", stdErr or "无")

    -- 检查执行后的状态
    hs.timer.doAfter(1, function()
        print("📊 执行后状态检查:")
        local statusExists = hs.fs.attributes("/tmp/mouse_follow_status") ~= nil
        print("   状态文件存在:", statusExists)

        -- 检查进程
        local checkTask = hs.task.new("/bin/bash", function(_, out)
            if out and out:find("mouse_follow_daemon") then
                print("   守护进程运行: ✅")
            else
                print("   守护进程运行: ❌")
            end
        end, { "-c", "ps aux | grep mouse_follow_daemon | grep -v grep" })
        checkTask:start()
    end)
end, { scriptPath })

task:start()
print("✨ 脚本已启动，等待结果...")
