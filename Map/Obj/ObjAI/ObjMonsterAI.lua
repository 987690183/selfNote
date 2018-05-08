

--[[
	怪物obj的AI
	一类怪物采用一个AI就好，不需要每个怪物new一个AI对象
]]

ObjMonsterAI = {}

local self = ObjMonsterAI

function ObjMonsterAI:Init()
	self.tmpTime = 0
end

function ObjMonsterAI:Update()
	self.tmpTime = self.tmpTime + Time.deltaTime
	if self.tmpTime < 0.1 then
		return
	else
		self.tmpTime = 0
	end
	-- 怪物数据
	local monsterObjList = MapObjCtrl:GetObjByType(5)
	if GetTableLength(monsterObjList) == 0 then return end 

	-- 场景中的行军数据
	local marchObjList = MapObjCtrl:GetObjByType(4)

	-- 枚举每一个怪，当前应当拥有的动作
	for key, monsterObj in pairs(monsterObjList) do 
		local monsterPos = monsterObj:GetPosition()
		if monsterPos then
			-- 初始胡状态列表, 保存当前怪物收到的状态影响
			-- 1.被进攻，范围在2范围内 2.被进攻，范围在2范围外 3.进攻返回，范围在2范围内，4.进攻返回，范围在2范围外
			local statusList = {}
			for key2, marchObj in pairs(marchObjList) do
				local fromPos, endPos, nowPos = marchObj:GetMarchPosInfo()
				if nowPos then
	                -- 前往进攻, 目标点就是当前点
					if endPos == monsterPos then
						local distance = Vector3.Distance(nowPos, monsterPos)
						if distance <= 2 and distance > 0.1 then
							table.insert(statusList, "resurrect")
						else
							table.insert(statusList, "idle")
						end
					-- 战斗结束，出发点就是当前点
					elseif fromPos == monsterPos then
						local distance = Vector3.Distance(nowPos, monsterPos)
						if distance <= 0.9 and distance > 0.1 then
							table.insert(statusList, "resurrect1")
						else
							table.insert(statusList, "die1")
						end
					end
				end
			end

			-- 判断是否正在处于战斗状态
			local mapReport = monsterObj.mInfo.serverData.mapReport
			if mapReport ~= nil and mapReport.fightResultKey ~= "" and GetTime() <= mapReport.endTime  then
				table.insert(statusList, "resurrect1")
			end

			-- 遍历数据, 根据优先级进行选择
			-- 优先展示进攻，然后是撤退
			local aniStr = self:CalStatus(statusList)
			monsterObj:StartPlayerAni(aniStr)
		end
	end
end

function ObjMonsterAI:CalStatus(statusList)
	local aniStr = ""
	for i = 1, #statusList do 
		-- 特判，一旦发现，立即返回
		if statusList[i] == "resurrect1" then
			aniStr = statusList[i]
			return aniStr
		end
		if statusList[i] == "resurrect" then
			aniStr = statusList[i]
		elseif statusList[i] == "die1" and aniStr ~= "resurrect" then
			aniStr = statusList[i]
		elseif statusList[i] == "idle" and aniStr ~= "resurrect" and aniStr ~= "die1" then
			aniStr = statusList[i]
		end
	end
	return aniStr
end
