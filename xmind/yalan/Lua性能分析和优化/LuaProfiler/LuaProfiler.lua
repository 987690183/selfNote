

--[[
    Lua profiler
]]

LuaProfiler = {}


--[[
	函数探测
]]

local FuncProfiler = require("Framework/LuaProfiler/Base/FuncProfiler")

function LuaProfiler.InitDate()
    LuaProfiler.funcInfoList = {}
end

function LuaProfiler.StartFuncProfiler()
	FuncProfiler:Start()
end

function LuaProfiler.StopFuncProfilr(sortCallTime)
    local list = FuncProfiler:Stop()
    local reports = list.reports
    local stopTime = list.stopTime
    local startTime = list.startTime
    local totaltime = stopTime - startTime

    if sortCallTime then
        table.sort(reports, function(a, b)
            return a.totaltime > b.totaltime
        end)
    else
        table.sort(reports, function(a, b)
            return a.callcount > b.callcount
        end)
    end
    LogEver(40, "函数总运行时间， 占用总时间多少，  被调用次数，    名字，    路径，     行数")

    for _, report in ipairs(reports) do
        local percent = (report.totaltime / totaltime) * 100
        if percent > 0.5 then
            LogEver(40, string.format("%6.3f, %6.2f%%, %7d, %s", report.totaltime, percent, report.callcount, report.title))
        end
    end
end

--[[
    内存探测
]]

