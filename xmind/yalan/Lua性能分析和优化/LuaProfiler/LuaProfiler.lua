

--[[
    Lua profiler
]]

LuaProfiler = {}


--[[
	函数探测
]]

local FuncProfiler = require("Framework/LuaProfiler/Base/FuncProfiler")

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
    ToolsMgr.PT(40, "函数总运行时间， 占用总时间多少，  被调用次数，    名字，    路径，     行数")

    for _, report in ipairs(reports) do
        local percent = (report.totaltime / totaltime) * 100
        if percent > 0.1 then
            ToolsMgr.PT(40, string.format("%6.3f, %18.2f%%, %14d, %s", report.totaltime, percent, report.callcount, report.title))
        end
    end
end

--[[
    内存探测
]]
local MemProfiler = require("Framework/LuaProfiler/Base/MemProfiler")
local resA = "c:\\b.txt"
local resB = "c:\\a.txt"

function LuaProfiler.CountObjRef(filePath)
    collectgarbage("collect")
    local list = MemProfiler:InitDate()
    MemProfiler:CalObjRef("registry", debug.getregistry(), list)

    -- 根据list操作
    local objRefCountList = list.objRefCountList
    local objNameList = list.objNameList

    local curList = {}
    for obj, count in pairs(objRefCountList) do 
        local tmp = {}
        tmp.count = count
        tmp.obj = obj
        tmp.name = objNameList[obj]
        table.insert(curList, tmp)
    end
    local function sortFunc(n1, n2)
        return n1.count > n2.count
    end
    table.sort(curList, sortFunc)


    filePath = filePath and filePath or "c:\\b.txt"
    print(filePath)

    local file = assert(io.open(filePath, "wb"))
    for i = 1, #curList do 
        local vo = curList[i]
        if LuaProfiler.Filter(MemProfiler:GetObjName(vo.name)) then
            file:write(string.format("obj=> %s, name=> %s, num=> %d\n", MemProfiler:GetObjName(vo.obj), MemProfiler:GetObjName(vo.name), vo.count))
        end
    end
    io.close(file)

    resB = resA
    resA = filePath
end

function LuaProfiler.Compire(filePath)
    if not resA or not resB then
        return
    end
    -- 对比
    local list1 = {}
    local list2 = {}
    local file1 = assert(io.open(resA, "rb"))

    for line in file1:lines() do 
        local obj, name, num = string.match(line, "obj=> (.*), name=> (.*), num=> (.*)")
        obj = tostring(obj)
        name = tostring(name)
        num = tostring(num)
        list1[obj] = {}
        list1[obj].name = name
        list1[obj].num = num
    end
    io.close(file1)

    local file2 = assert(io.open(resB, "rb"))
    for line in file2:lines() do 
        local obj, name, num = string.match(line, "obj=> (.*), name=> (.*), num=> (.*)")
        obj = tostring(obj)
        name = tostring(name)
        num = tostring(num)
        list2[obj] = {}
        list2[obj].name = name
        list2[obj].num = num
    end
    io.close(file2)

    filePath = filePath and filePath or "c:\\compire.txt"
    local file = assert(io.open(filePath, "wb"))
    file:write(string.format(LuaProfiler.splitString(), "共有"))
    for obj, vo in pairs(list1) do 
        if list2[obj] then
            file:write(string.format("obj=> %s, name=> %s, num=> %s, %s\n", obj, vo.name, vo.num, list2[obj].num))
        end
    end

    file:write(string.format(LuaProfiler.splitString(), "删除"))
    for obj, vo in pairs(list1) do 
        if not list2[obj] then
            file:write(string.format("obj=> %s, name=> %s, num=> %s\n", obj, vo.name, vo.num))
        end
    end

    file:write(string.format(LuaProfiler.splitString(), "新增"))
    for obj, vo in pairs(list2) do 
        if not list1[obj] then
            file:write(string.format("obj=> %s, name=> %s, num=> %s\n", obj, vo.name, vo.num))
        end
    end
    io.close(file)
end

function LuaProfiler.Filter(str)
    if string.find(str, "Res.") then
        return false
    elseif string.find(str, "protobuf/") then
        return false
    else
        return true
    end
end

function LuaProfiler.splitString()
    return 
    "\n\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"..
    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     %s   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"..
    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"
end