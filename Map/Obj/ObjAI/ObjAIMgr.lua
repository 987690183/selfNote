

--[[
	简易场景对象AI管理
]]

require("Module/Map/Obj/ObjAI/ObjMonsterAI")

ObjAIMgr = {}

local self = ObjAIMgr

function ObjAIMgr:Init()
	self.mUpdate = nil
	ObjMonsterAI:Init()
end

function ObjAIMgr:Update()
	if not MapCtrl.mode.isInMap then return end
	ObjMonsterAI:Update()
end

function ObjAIMgr:StartUpdate()
	if not self.mUpdate then
		self.mUpdate = function () self:Update() end
		UpdateBeat:Add(self.mUpdate)
	end
end

function ObjAIMgr:StopUpdate()
	if self.mUpdate then
		UpdateBeat:Remove(self.mUpdate)
		self.mUpdate = nil
	end
end
