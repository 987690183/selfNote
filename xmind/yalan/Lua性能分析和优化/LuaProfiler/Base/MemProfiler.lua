
--[[
	MemProfiler
	内存探测
]]

local Profiler = {}

function Profiler:InitDate()
	local objNameList = {}
	setmetatable(objNameList, {__mode = "k"})

	local objRefCountList = {}
	setmetatable(objRefCountList, {__mode = "k"})

	local t = {
		objRefCountList = objRefCountList,
		objNameList = objNameList,
	}
	return t
end

-- 核心函数
function Profiler:CalObjRef(strName, obj, tmpList)
	if not obj then return end
 	strName = strName and strName or ""
 	tmpList = tmpList and tmpList or self:InitDate()

	local objRefCountList = tmpList.objRefCountList
	local objNameList = tmpList.objNameList
	
	local objType = type(obj)
	if "table" == objType then
		if obj == _G then
			strName = strName .. "[_G]"
		end
		local meta, bWeakK, bWeakV = self:GetWeakKV(obj)
		objRefCountList[obj] = (objRefCountList[obj] and (objRefCountList[obj] + 1)) or 1
		if objNameList[obj] then
			return
		end
		objNameList[obj] = strName

		for k, v in pairs(obj) do
			local strKeyType = type(k)
			if "table" == strKeyType then
				if not bWeakK then
					self:CalObjRef(strName .. ".[table:key.table]", k, tmpList)
				end
				if not bWeakV then
					self:CalObjRef(strName .. ".[table:value]", v, tmpList)
				end
			elseif "function" == strKeyType then
				if not bWeakK then
					self:CalObjRef(strName .. ".[table:key.function]", k, tmpList)
				end
				if not bWeakV then
					self:CalObjRef(strName .. ".[table:value]", v, tmpList)
				end
			elseif "thread" == strKeyType then
				if not bWeakK then
					self:CalObjRef(strName .. ".[table:key.thread]", k, tmpList)
				end
				if not bWeakV then
					self:CalObjRef(strName .. ".[table:value]", v, tmpList)
				end
			elseif "userdata" == strKeyType then
				if not bWeakK then
					self:CalObjRef(strName .. ".[table:key.userdata]", k, tmpList)
				end
				if not bWeakV then
					self:CalObjRef(strName .. ".[table:value]", v, tmpList)
				end
			else
				self:CalObjRef(strName .. "." .. k, v, tmpList)
			end
		end
		if meta then
			self:CalObjRef(strName ..".[metatable]", meta, tmpList)
		end
	elseif "function" == objType then
		local cDInfo = debug.getinfo(obj, "Su")
		objRefCountList[obj] = (objRefCountList[obj] and (objRefCountList[obj] + 1)) or 1
		if not objNameList[obj] then
			objNameList[obj] = strName .. "[line:" .. tostring(cDInfo.linedefined) .. "@file:" .. cDInfo.short_src .. "]"

			local nUpsNum = cDInfo.nups
			for i = 1, nUpsNum do
				local strUpName, cUpValue = debug.getupvalue(obj, i)
				local strUpValueType = type(cUpValue)
				if "table" == strUpValueType then
					self:CalObjRef(strName .. ".[ups:table:" .. strUpName .. "]", cUpValue, tmpList)
				elseif "function" == strUpValueType then
					self:CalObjRef(strName .. ".[ups:function:" .. strUpName .. "]", cUpValue, tmpList)
				elseif "thread" == strUpValueType then
					self:CalObjRef(strName .. ".[ups:thread:" .. strUpName .. "]", cUpValue, tmpList)
				elseif "userdata" == strUpValueType then
					self:CalObjRef(strName .. ".[ups:userdata:" .. strUpName .. "]", cUpValue, tmpList)
				end
			end
			local getfenv = debug.getfenv
			if getfenv then
				local env = getfenv(obj)
				if env then
					self:CalObjRef(strName ..".[function:environment]", env, tmpList)
				end
			end
		end

	elseif "thread" == objType then
		objRefCountList[obj] = (objRefCountList[obj] and (objRefCountList[obj] + 1)) or 1
		if not objNameList[obj] then
			objNameList[obj] = strName
			local getfenv = debug.getfenv
			if getfenv then
				local env = getfenv(obj)
				if env then
					self:CalObjRef(strName ..".[thread:environment]", env, tmpList)
				end
			end
			local meta = getmetatable(obj)
			if meta then
				self:CalObjRef(strName ..".[thread:metatable]", meta, tmpList)
			end
		end
	elseif "userdata" == objType then
		objRefCountList[obj] = (objRefCountList[obj] and (objRefCountList[obj] + 1)) or 1
		if not objNameList[obj] then
			objNameList[obj] = strName
			local getfenv = debug.getfenv
			if getfenv then
				local env = getfenv(obj)
				if env then
					self:CalObjRef(strName ..".[userdata:environment]", env, tmpList)
				end
			end
			local meta = getmetatable(obj)
			if meta then
				self:CalObjRef(strName ..".[userdata:metatable]", meta, tmpList)
			end
		end
    elseif "string" == objType then
        objRefCountList[obj] = (objRefCountList[obj] and (objRefCountList[obj] + 1)) or 1
	    if not objNameList[obj] then
	    	objNameList[obj] = string.format("%s[%s]", strName, objType)
	    end
	end
end

-- 获取对象名字
function Profiler:GetObjName(obj)
    local meta = getmetatable(obj)
    if not meta then
    	return tostring(obj)
    end

    local objName = ""
    local Tostring = rawget(meta, "__tostring")
    if Tostring then
    	rawset(meta, "__tostring", nil)
    	objName = tostring(obj)
    	rawset(meta, "__tostring", Tostring)
    else
    	objName = tostring(obj)
    end
    return objName
end

-- 返回对象是否有弱表
function Profiler:GetWeakKV(obj)
	local weakK = false
	local weakV = false
	local meta = getmetatable(obj)
	if meta then
		local strMode = rawget(meta, "__mode")
		if strMode then
			if "k" == strMode then
				weakK = true
			elseif "v" == strMode then
				weakV = true
			elseif "kv" == strMode then
				weakK = true
				weakV = true
			end
		end
	end
	return meta, weakK, weakV
end

return Profiler