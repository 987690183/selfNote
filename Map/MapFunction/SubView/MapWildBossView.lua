

--[[
	地图的野外boss界面
]]

local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapWildBossView = {}

local this = MapWildBossView

local Find = Find
local L = L

function this:Init(go, parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList, self.BtnList, self.FucList = self.parent:InitSubView(12, self)

	-- local parameterConfig = Res.parameter
	-- -- 守军等级
	-- self.Txt1 = Find(self.gameObject, "Bg/Texts/Text_1"):GetComponent("InlineText")
	-- L(self.Txt1, {txt = parameterConfig[10034].q_int})
	-- -- 守军数量
	-- self.Txt3 = Find(self.gameObject, "Bg/Texts/Text_3"):GetComponent("InlineText")
	-- L(self.Txt3, {txt = parameterConfig[10035].q_int})
	-- -- 几率掉落
	-- self.Txt7 = Find(self.gameObject, "Bg/Texts/Text_7"):GetComponent("InlineText")
	-- L(self.Txt7, {txt = parameterConfig[10036].q_int})
	-- -- 获得奖励最低伤害要求
	-- self.Txt8 = Find(self.gameObject, "Bg/Texts/Text_8"):GetComponent("InlineText")
	-- L(self.Txt8, {txt = parameterConfig[10037].q_int})
	-- -- 等级
	-- self.TxtLv = Find(self.gameObject, "Bg/Texts/TxtLv"):GetComponent("InlineText")
	-- -- 数量
	-- self.TxtNum = Find(self.gameObject, "Bg/Texts/TxtNum"):GetComponent("InlineText")
	-- -- 百分比
	-- self.TxtPercent = Find(self.gameObject, "Bg/Texts/TxtPercent"):GetComponent("InlineText")
	return self
end

function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.gridId)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],"")
	L(self.TextList[2],{txt=Res.wildMonster[this.data.serverData.boss.level].showname})
	L(self.TextList[3],{txt="{1},{2}",param={x,y}})
	
	local t = {}

	for i = 1, #self.FucList do
		self.FucList[i].go:SetActive(false)
		if self:CheckBtnState(self.FucList[i]) then
			self.FucList[i].go:SetActive(true)
			table.insert(t,self.FucList[i])
		end
	end
	self.parent:SetBtnPos(t)
end

function this:CheckBtnState(t)
	if t.go.name == "2" then
		return true
	else
		return true
	end
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "集结攻打" then
		if not AggregationUICtrl.CanAggregationCommond() then
			return
		end
		this.data.toId = 0
		this.data.goalType = this.data.type
		this.data.stype = 2
		this.data.MoveToType = 0
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "侦查" then
		-- LogError("驻守==领主===")
		DetectionCtrl.C2SPVESurvey(this.data.serverData.gridId)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end

function this:GetName()
	return Res.wildMonster[this.data.serverData.monster.level].showname
end
