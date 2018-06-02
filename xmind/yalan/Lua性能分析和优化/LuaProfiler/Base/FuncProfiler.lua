
--[[
    FunctionProfiler
    函数探测
    edit by LinHuang
]]

local Profiler = {}

function Profiler:FuncTitle(funcinfo)
    assert(funcinfo)
    local name = funcinfo.name or 'anonymous'
    local line = string.format("%d", funcinfo.linedefined or 0)
    local source = funcinfo.short_src or 'null_source'
    return string.format("%s: %-10s: %-10s", name, source, line)
end

function Profiler:GetReport(funcinfo)
    local title = self:FuncTitle(funcinfo)
    local report = self.reportByTitle[title]
    if not report then
        report = {
            title = title,   
            callcount = 0,   
            totaltime = 0,
        }
        self.reportByTitle[title] = report
        table.insert(self.reports, report)
    end
    return report
end

function Profiler:profilingCall(funcinfo)
    local report = self:GetReport(funcinfo)
    assert(report)
    report.calltime = os.clock()
    report.callcount = report.callcount + 1
end

function Profiler:profilingReturn(funcinfo)
    local report = self:GetReport(funcinfo)
    assert(report)

    if report.calltime and report.calltime > 0 then
		report.totaltime = report.totaltime + (os.clock() - report.calltime)
        report.calltime = 0
	end
end

function Profiler.HandlerProfiler(hooktype)
    local funcinfo = debug.getinfo(2, 'nS')
    if hooktype == "call" then
        Profiler:profilingCall(funcinfo)
    elseif hooktype == "return" then
        Profiler:profilingReturn(funcinfo)
    end
end

function Profiler:Start()
    self.reports = {}
    self.reportByTitle = {}
    self.startTime = os.clock()
    debug.sethook(Profiler.HandlerProfiler, 'cr', 0)
end

function Profiler:Stop()
    self.stopTime = os.clock()
    debug.sethook()

    local result = {
        reports = self.reports or {},
        startTime = self.startTime or 0,
        stopTime = self.stopTime or 0,
    }
    return result
end

return Profiler

--[[

    debug.sethook(hookFunc, mask, 0)
    "c": the hook is called every time Lua calls a function;
    "r": the hook is called every time Lua returns from a function;
    "l": the hook is called every time Lua enters a new line of code.

    debug.getinfo ([thread,] function [, what])
    function
    0 is the current function (getinfo itself)
    level 1 is the function that called getinfo
    if function is a number larger than the number of active functions, then getinfo returns nil
    what
    'n': fills in the field name and namewhat;
    'S': fills in the fields source, short_src, linedefined, lastlinedefined, and what;
    'l': fills in the field currentline;
    'u': fills in the field nups;
    'f': pushes onto the stack the function that is running at the given level;
    'L': pushes onto the stack a table whose indices are the numbers of the lines that are valid on the function. (A valid line is a line with some associated code, that is, a line where you can put a break point. Non-valid lines include empty lines and comments.)
]]