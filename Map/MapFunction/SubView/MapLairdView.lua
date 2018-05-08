local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapLairdView = {}
local this = MapLairdView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(1,self)
	return self
end

function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.gridId)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],this.data.serverData.laird.guildName)
	local b1 = LoginCtrl.IsOwnerPlayer(this.data.serverData.laird.playerId)
	local b2 = UnionCtrl.IsMyUnion(this.data.serverData.laird.guildId)
	local colorId = b1 and 10 or (b2 and 55 or 61)
	L(self.TextList[2],{txt="<C_{2}>{1}</C>",param={this.data.serverData.laird.playerName,colorId}})
	L(self.TextList[3],{txt="{1},{2}",param={x,y}})
    local tdsl = this.data.serverData.laird
	local b1 = LoginCtrl.IsOwnerPlayer(this.data.serverData.laird.playerId)
	local b2 = UnionCtrl.IsMyUnion(this.data.serverData.laird.guildId)
    if b1 or b2 then
    	L(Find(self.gameObject,"HP/Text"),{txt="{1}/{2}",param={ math.floor(tdsl.curCityDefense), math.floor(tdsl.maxCityDefense)}})
    else
    	L(Find(self.gameObject,"HP/Text"),{txt="???"})
    end
    Find(self.gameObject,"HP/BG_1"):GetComponent("Image").fillAmount = tdsl.curCityDefense/tdsl.maxCityDefense


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
	if t.go.name == "1" or t.go.name == "2" then
		if b1 then
			return false
		else
			return not b2
		end
	elseif t.go.name == "3" then
		if b1 then
			return false
		else
			return not b2
		end
	elseif t.go.name == "7" then
		if b1 then
			return true
		else
			return b2
		end
	elseif t.go.name == "9" then
		if b1 then
			return true
		else
			return b2
		end
	elseif t.go.name == "12" then
		return true
	elseif t.go.name == "23" then
		return b1
	else
		LogError("未判断按钮状态",t.go.name)
		return true
	end
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "攻打" then
		this.data.goalType = 1
		this.data.MoveToType = 0 -- 0出征 1驻守
		this.data.toId = 0
		this.data.stype = 1
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "侦查" then
		-- LogError("驻守==领主===")
		DetectionCtrl.C2SPVESurvey(this.data.serverData.gridId)
		self.parent:CurClose()
	elseif s == "驻守" then
		-- LogError("驻守==领主===")
		this.data.MoveToType = 1 -- 0出征 1驻守
		this.data.toId = this.data.serverData.laird.playerId
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "查看驻军" then
		-- LogError("查看驻军====")
		MapCtrl.C2SSeeLairdGarrison(this.data.serverData.laird.playerId)--LoginCtrl.mode.PlayerBaseInfo.playerId)
		self.parent:CurClose()
	elseif s== "科技变身" then
		--判断当前是否正在变身
		--CommonCtrl.PopUIInfoData(Res.message[144].word)
		local isReady = GetTime() - LoginCtrl.mode.LairdInfo.unionTechBuff.unionTechReadTime
		--正在准备中
		if isReady <= 0 then
			CommonCtrl.PopUIInfoData(Res.message[144].word)	
		else
			UIMgr.OpenView("UnionScienceTransformView")
		end
	elseif s == "集结攻打" then
		if not AggregationUICtrl.CanAggregationCommond() then
			return
		end
		this.data.goalType = 1
		this.data.MoveToType = 0 -- 0出征 1驻守
		this.data.toId = 0
		this.data.stype = 2
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end
function this:GetName()
	return this.data.serverData.laird.playerName
end
function this:GetPlayerID()
	return this.data.serverData.laird.playerId
end