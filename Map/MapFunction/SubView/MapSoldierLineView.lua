local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapSoldierLineView = {}
local this = MapSoldierLineView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(4,self)
	return self
end
function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.tarGridId)
	LH.DoFollow(true,self.gameObject,this.data.follow)
	L(self.TextList[1],"")
    local b1 = LoginCtrl.IsOwnerPlayer(this.data.serverData.laird.playerId)
    local b2 = UnionCtrl.IsMyUnion(this.data.serverData.laird.guildId)
    local colorId = b1 and 10 or (b2 and 55 or 61)
    L(self.TextList[2],{txt="<C_{2}>{1}</C>",param={this.data.serverData.laird.playerName,colorId}})
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
	local b1 = LoginCtrl.IsOwnerPlayer(this.data.serverData.laird.playerId)
	local b2 = (this.data.serverData.tarGridId == LoginCtrl.mode.LairdInfo.gridId)--true回来
	if t.go.name == "16" then
		if b1 then
			return not b2
		end
	elseif t.go.name == "17" then
		if b1 then
			return not b2
		end
	elseif t.go.name == "18" then
		if b1 then
			return true
		end
	elseif t.go.name == "21" then
		if b1 then
			return b2
		end
	else
		LogError("未判断按钮状态",t.go.name)
		return false
	end
	return false
end
function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "加速" then
		if this.data.serverData.remainSpeedUpTimes <=0 then
			return CommonCtrl.CalCommonViewById(166)
		end
		self.parent:CurClose()
		local tD = {}
		tD.line = this.data.data
		tD.marchlineId = this.data.serverData.lineId
		tD.type = 1
		UIMgr.OpenView("TroopSpeedUpView",tD)
	elseif s == "召回" then
		self.parent:CurClose()
		TroopsUICtrl.C2SCancel(this.data.serverData.lineId)
	elseif s == "军队详情" then
	    local tD = {}
	    tD.type = 2--1、防守列表 2、普通查看军队
	    -- tD.list = msg.troops
	    tD.list = {}
	    local tTroop = TroopsUICtrl.GetTroopById(this.data.serverData.troopId)
		-- LogError("===tTroop == nil =========" .. tTroop.player.playerId)
	    table.insert(tD.list, tTroop)
	    UIMgr.OpenView("TroopDefenseListView", tD)
		self.parent:CurClose()
	elseif s == "立即返回" then
		TroopsUICtrl.C2SFastBack(this.data.serverData.lineId)--marchlineId)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end

function this:GetName()
	return this.data.serverData.laird.playerName
end