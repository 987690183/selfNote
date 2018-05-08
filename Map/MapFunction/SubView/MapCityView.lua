local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")
MapCityView = {}
local this = MapCityView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(7,self)
	return self
end
function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.gridId)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],"")
	L(self.TextList[2],Res.city[this.data.serverData.city.cityId].cityname)
	L(self.TextList[3],{txt="{1},{2}",param={x,y}})
    
	local t = {}
	for i=1,#self.FucList do
		self.FucList[i].go:SetActive(false)
		if self:CheckBtnState(self.FucList[i]) then
			self.FucList[i].go:SetActive(true)
			table.insert(t,self.FucList[i])
		end
	end
	self.parent:SetBtnPos(t)
end

function this:CheckBtnState(t)
	if t.go.name == "0" then

	elseif s == "侦查" then
		-- LogError("驻守==领主===")
		DetectionCtrl.C2SPVESurvey(this.data.serverData.gridId)
		self.parent:CurClose()
	else
		LogError("未判断按钮状态",t.go.name)
		return true
	end
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "攻打" then
		-- this.data.goalType = 7
		this.data.goalType = this.data.type
		this.data.stype = 1
		this.data.MoveToType = 0
		-- LogError("迁营攻打==" .. this.data.goalType)
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "驻守" then
		-- LogWarn("驻守==city")
		-- this.data.MoveToType = 1 -- 0出征 1驻守
		-- this.data.toId = 0
		-- UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "集结攻打" then
		if not AggregationUICtrl.CanAggregationCommond() then
			return
		end
		this.data.goalType = this.data.type
		this.data.stype = 2
		this.data.MoveToType = 0
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "self.BtnNameList[1]" then
	else
		LogError("没有处理该按钮事件："..s)
	end
end
function this:GetName()
	return Res.city[this.data.serverData.city.cityId].cityname
end