-- 压缩工具模块
local utils = require("modules.core.utils")

local M = {}

-- 调用脚本来压缩在Finder中选中的文件
function M.compress_selection()
    local script_path = utils.scripts.getPath("common", "finder_compress.sh")

    utils.log("CompressTools", "正在调用压缩脚本: " .. script_path)

    -- finder_compress.sh 脚本被设计为在不带参数时自动获取Finder中的选中项
    -- 脚本内部会处理成功或失败的用户通知
    hs.task.new("/bin/bash", function(exit_code, stdout, stderr)
        if exit_code == 0 then
            utils.log("CompressTools", "压缩脚本成功完成")
        else
            utils.log("CompressTools", "压缩脚本执行失败，退出码: " .. tostring(exit_code))
            utils.debug_print("Compress Script Error", stderr)
        end
    end, { script_path }):start()
end

-- 初始化函数
function M.init()
    print("📦 压缩工具模块已加载")
    return true
end

return M
