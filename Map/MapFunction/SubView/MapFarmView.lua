local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapFarmView = {}
local this = MapFarmView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(10,self)
	return self
end

function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.gridId)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],"")
    L(self.TextList[2],{txt="{1}",param={Res.farm[this.data.serverData.farm.level].showname}})
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
	if t.go.name == "22" then
		return true
	elseif t.go.name == "3" then
		return true
	else
		LogError("未判断按钮状态",t.go.name)
		return true
	end
	return true
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "迁营开采" then
		local _t = {}
		_t.serverData = {}
		_t.goalType = 3
		_t.MoveToType = 2 -- 0出征 1驻守 2迁营
		_t.toId = 0

		_t.serverData.gridId = this.data.serverData.gridId

		UIMgr.OpenView("TroopExpeditionView", _t)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end

function this:GetName()
	return Res.farm[this.data.serverData.farm.level].showname
end