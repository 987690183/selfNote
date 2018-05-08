local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapGarrisonView = {}
local this = MapGarrisonView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(11,self)
	return self
end

function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.gridId)
	-- LogError("this.data.gridId",this.data.serverData.gridId,x, y)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],this.data.serverData.data.serverData.guildName)
	local b1 = true
	local b2 = true
	local colorId = b1 and 10 or (b2 and 55 or 61)
	L(self.TextList[2],{txt="<C_{2}>{1}</C>",param={this.data.serverData.playerName,colorId}})
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
	return true
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "撤退" then
		MapCtrl.C2SLairdRetreatTroop(this.data.serverData.troop.troopId)
		self.parent:CurClose()
	elseif s == "军队详情" then
		MapCtrl.C2SSeeLairdGarrison(this.data.serverData.playerId)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end
function this:GetName()
	return this.data.serverData.playerName
end
function this:GetPlayerID()
	return this.data.serverData.playerId
end