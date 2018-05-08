

--[[
	地图物件 - 战报
]]

ObjFight = Class(MapObj)

local TerrainCtrl = DoFileUtil.DoFile("Module/Map/Terrain/TerrainCtrl")

function ObjFight:DoShow() 
	-- 保存最新收到的动画名字
	self.currentStr = ""
	-- 保存当前正在播放的动画名字
	self.playAnistr = ""
	self.mModeObj = nil
end

function ObjFight:DoLoad() 

	L(self.mTra:Find("NameBox/Name/Text"),"")
	self.mMoveGo = self.mTra:Find("GameObject")
	self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图
	local function loadCompleteFunc(obj)
		-- 加载成功, 播放最新的动画
		self.mModeObj = obj
		self:StartPlayerAni(self.currentStr)
	end
	self:LoadView(self.mGo, self.mInfo.targetPath, loadCompleteFunc)--加载主视图
	self.mEndTime = self.mInfo.serverData.mapReport.endTime

	self.mPosition = TerrainCtrl:ConvertToWorld(self.mInfo.x, self.mInfo.y)

	local monster = self.mInfo.serverData.mapReport.monster
    if monster ~= nil and monster.monsterId ~= 0 then 
		self:StartPlayerAni("resurrect1")
    end
	if not self.mUpdateMove then
		self.mUpdateMove = function () self:ShowTime() end
		UpdateBeat:Add(self.mUpdateMove)
	end
end

function ObjFight:OnClick(keyName)
	CombatCtrl.GetFightReport(self.mInfo.serverData.mapReport.fightResultKey,2,0,false,2)
end

function ObjFight:ShowTime()
	if GetTime() >= self.mEndTime then
		UpdateBeat:Remove(self.mUpdateMove)
		self.mUpdateMove = nil
		MapObjCtrl:RemoveObjects({self.mInfo})
	end
end

function ObjFight:PlayAni(str)
	if str == self.playAnistr then
		return
	end
	self.playAnistr = str

	local list = self.mGo:GetComponentsInChildren(typeof(UnityEngine.Animator)):ToTable()
	for k, v in ipairs(list) do
		v:Play(self.playAnistr)
	end
end

-- 开始播放动画
function ObjFight:StartPlayerAni(res)
	if res == "" then return end

	self.currentStr = res
	if not self.mModeObj then 
		return
	end
	self:PlayAni(self.currentStr)
end

-- message MapReport{	//地图战报
-- 	required string fightResultKey = 1; //战报的唯一key
-- 	required int32 endTime = 2;	    //结束时间
-- 	optional City city = 3;		    //城市
-- 	optional Laird laird = 4;	    //领主
-- 	optional Monster monster = 5;	    //怪物
-- }
