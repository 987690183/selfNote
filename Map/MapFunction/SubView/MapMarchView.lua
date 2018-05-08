local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapMarchView = {}
local this = MapMarchView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(8,self)
	return self
end

function this:SetView(data)
	this.data = data
	local b3 = this.data.clickPart--1起点，2中间，3终点
	if b3 == 1 then
		local x, y = MapCtrl.IdToXY(this.data.serverData.resGridId)
		local v = TerrainCtrl:ConvertToWorld(x,y)
		LH.DoFollowPoint(true,self.gameObject,v)
		L(self.TextList[3],{txt="{1},{2}",param={x,y}})
	elseif b3 == 2 then
		local x, y = MapCtrl.IdToXY(this.data.serverData.tarGridId)
		L(self.TextList[3],{txt="{1},{2}",param={x,y}})
		LH.DoFollow(true,self.gameObject,this.data.follow)
	elseif b3 == 3 then
		local x, y = MapCtrl.IdToXY(this.data.serverData.tarGridId)
		local v = TerrainCtrl:ConvertToWorld(x,y)
		LH.DoFollowPoint(true,self.gameObject,v)
		L(self.TextList[3],{txt="{1},{2}",param={x,y}})
	end
	L(self.TextList[1],"")
	L(self.TextList[2],this.data.serverData.laird.playerName)
    
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
	local b1 = LoginCtrl.IsOwnerPlayer(this.data.serverData.laird.playerId)
	local b2 = UnionCtrl.IsMyUnion(this.data.serverData.laird.guildId)
	local b3 = this.data.clickPart--1起点，2中间，3终点
	if b3 == 1 then
		if t.go.name == "1" then
			return (not b1 and not b2)
		elseif t.go.name == "2" then
			return (not b1 and not b2)
		elseif t.go.name == "7" then
			return (b1 or b2)
		elseif t.go.name == "9" then
			return (b1 or b2)
		elseif t.go.name == "12" then
			return true
		elseif t.go.name == "19" then
			return b1
		else
			return false
		end
	elseif b3 == 2 then
		if t.go.name == "19" then
			return b1
		else
			return false
		end
	elseif b3== 3 then
		if t.go.name == "1" then
			return (not b1 and not b2)
		elseif t.go.name == "2" then
			return (not b1 and not b2)
		elseif t.go.name == "7" then
			return false
		elseif t.go.name == "9" then
			return false
		elseif t.go.name == "12" then
			return true
		elseif t.go.name == "19" then
			return b1
		else
			return false
		end
	end
	LogError("未判断按钮状态",t.go.name)
	return true
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "攻打" then
		this.data.goalType = this.data.type
		-- LogError("迁营攻打==" .. this.data.goalType)
		this.data.MoveToType = 0 -- 0出征 1驻守
		this.data.toId = 0
		this.data.stype = 1
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "集结攻打" then
		if not AggregationUICtrl.CanAggregationCommond() then
			return
		end
		this.data.MoveToType = 0
		this.data.toId = 0
		this.data.stype = 2
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "驻守" then
		this.data.goalType = this.data.type
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "查看驻军" then
		MapCtrl.C2SSeeLairdGarrison(this.data.serverData.laird.playerId)--LoginCtrl.mode.PlayerBaseInfo.playerId)
		self.parent:CurClose()
	elseif s == "查看" then
	elseif s == "取消迁营" then
		MapCtrl.C2SCancelTransfer(this.data.serverData.lineId)--LoginCtrl.mode.PlayerBaseInfo.playerId)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end
function this:GetName()
	return this.data.serverData.laird.playerName
end