

--[[
	地图物件 - 怪物
]]

ObjMonster = Class(MapObj)

local TerrainCtrl = DoFileUtil.DoFile("Module/Map/Terrain/TerrainCtrl")

function ObjMonster:DoShow() 
	-- 保存最新收到的动画名字
	self.currentStr = ""
	-- 保存当前正在播放的动画名字
	self.playAnistr = ""
	self.mModeObj = nil
end

function ObjMonster:DoLoad() 
	L(self.mTra:Find("NameBox/Name/Image/Text"), self.mInfo.serverData.monster.level)
	self.mMoveGo = self.mTra:Find("GameObject")
	local function loadCompleteFunc(obj)
		-- 加载成功, 播放最新的动画
		self.mModeObj = obj
		self:StartPlayerAni(self.currentStr)
	end
	self:LoadView(self.mMoveGo,self.mInfo.modePath, loadCompleteFunc)--加载主视图
	self.mPosition = TerrainCtrl:ConvertToWorld(self.mInfo.x, self.mInfo.y)

	local mapReport = self.mInfo.serverData.mapReport
	-- 没有死亡有战报
	if mapReport ~= nil and mapReport.fightResultKey ~= "" then
		self:StartPlayerAni("resurrect1")
	else
		self:StartPlayerAni("idle")
	end
end

function ObjMonster:OnClick(keyName)
    EventMgr.SendEvent(ED.MapMoveEvent,{self.mInfo.x,self.mInfo.y})
    UIMgr.OpenView("MapFunctionView",self.mInfo)
end

function ObjMonster:PlayAni(str)
	if str == self.playAnistr then
		return
	end
	self.playAnistr = str

	local list = self.mMoveGo:GetComponentsInChildren(typeof(UnityEngine.Animator)):ToTable()
	for k, v in ipairs(list) do
		v:Play(self.playAnistr)
	end
end

-- 开始播放动画
function ObjMonster:StartPlayerAni(res)
	if res == "" then return end
	self.currentStr = res
	if not self.mModeObj then 
		return
	end
	self:PlayAni(self.currentStr)
end

function ObjMonster:GetPosition()
	return self.mPosition
end
