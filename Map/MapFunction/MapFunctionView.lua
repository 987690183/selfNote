require "Module/Map/MapCtrl"
require "Module/Map/MapFunction/SubView/MapBuildView"
require "Module/Map/MapFunction/SubView/MapEmptyView"
require "Module/Map/MapFunction/SubView/MapLairdView"
require "Module/Map/MapFunction/SubView/MapMonsterView"
require "Module/Map/MapFunction/SubView/MapSoldierLineView"
require "Module/Map/MapFunction/SubView/MapPassView"
require "Module/Map/MapFunction/SubView/MapCityView"
require "Module/Map/MapFunction/SubView/MapMarchView"
require "Module/Map/MapFunction/SubView/MapFarmView"
require "Module/Map/MapFunction/SubView/MapGarrisonView"
require "Module/Map/MapFunction/SubView/MapWildBossView"

local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapFunctionView=Class(BaseView)

function MapFunctionView:ConfigUI()

	self.MapLairdView 		= MapLairdView:Init(		Find(self.gameObject,"Type_1"),self)
	self.MapBuildView 		= MapBuildView:Init(		Find(self.gameObject,"Type_2"),self)
	self.MapEmptyView 		= MapEmptyView:Init(		Find(self.gameObject,"Type_3"),self)
	self.MapSoldierLineView = MapSoldierLineView:Init(	Find(self.gameObject,"Type_4"),self)
	self.MapMonsterView 	= MapMonsterView:Init(		Find(self.gameObject,"Type_5"),self)
	self.MapPassView 		= MapPassView:Init(			Find(self.gameObject,"Type_6"),self)
	self.MapCityView 		= MapCityView:Init(			Find(self.gameObject,"Type_7"),self)
	self.MapMarchView 		= MapMarchView:Init(		Find(self.gameObject,"Type_8"),self)
	-- self.MapMarchView 		= MapMarchView:Init(		Find(self.gameObject,"Type_9"),self)
	self.MapFarmView 		= MapFarmView:Init(			Find(self.gameObject,"Type_10"),self)
	self.MapGarrisonView 	= MapGarrisonView:Init(		Find(self.gameObject,"Type_11"),self)
	self.MapWildBossView 	= MapWildBossView:Init(		Find(self.gameObject,"Type_12"),self)

	self.TypeList = 
	{
		self.MapLairdView,
		self.MapBuildView,
		self.MapEmptyView,
		self.MapSoldierLineView,
		self.MapMonsterView,
		self.MapPassView,
		self.MapCityView,
		self.MapMarchView,
		nil,
		self.MapFarmView,
		self.MapGarrisonView,
		self.MapWildBossView,
	}
	self.Data = {}
	self.CurView = nil
end

function MapFunctionView:AfterOpenView(t)
	EventMgr.SendEvent(ED.MianViewCloseTabView)
	if MapCtrl.IsNearFrame() then return end
	if t == nil then return end
    TerrainCtrl:SetSelectedCell(-1, -1)--隐藏地表选中
	if self.CurView ~= nil then
		MapCtrl.SetCurFrame()
		self.CurView.gameObject:SetActive(false)
		self.CurView = nil
		MapObjCtrl.SetShowName(true)
		return
	end
	if t.type ~= 4 and t.type ~= 8 then
    	TerrainCtrl:MoveToPosition(t.x, t.y)--平移摄像机
	end
	MapCtrl.mode.CurTypeViewOpen = t.key
	self.Data = t
	self.CurView = self.TypeList[self.Data.type]
	self.CurView.gameObject:SetActive(true)
	self.CurView:SetView(self.Data)

	-- self.CurView.gameObject:GetComponent("RectTransform").localScale = Vector3.one
	-------------------------------------------------------界面动态
	self.CurView.gameObject.transform:DOKill()
	self.CurView.gameObject:GetComponent("RectTransform").localScale = Vector3.zero
	self.CurView.gameObject:GetComponent("RectTransform"):DOScale(Vector3.one, 0.5)
	:SetEase(DG.Tweening.Ease.OutExpo)
	:OnComplete(function()
	end)
end

function MapFunctionView:ClearView(t)
	if self.CurView ~= nil then
		MapCtrl.SetCurFrame()
		self.CurView.gameObject:SetActive(false)
		self.CurView = nil
	end
	MapCtrl.mode.CurTypeViewOpen = ""
	TerrainCtrl:SetSelectedCell(-1, -1)
end

function MapFunctionView:UpdateView()
end

function MapFunctionView:AddListener()
	self:AddEvent(ED.TerrainCtrlBeginMove, function(data) self:ClearView(data) end)
	self:AddEvent(ED.UICloseSucc, function(data) self:ClearView(data) end)
end

function MapFunctionView:BeforeCloseView()	
	if self.CurView ~= nil then
		MapCtrl.SetCurFrame()
		self.CurView.gameObject:SetActive(false)
		self.CurView = nil
	end
	MapCtrl.mode.CurTypeViewOpen = ""
end

function MapFunctionView:OnDestory()
end

function MapFunctionView:CurClose()
	if self.CurView ~= nil then
		MapCtrl.SetCurFrame()
		self.CurView.gameObject:SetActive(false)
		self.CurView = nil
	end
	MapCtrl.mode.CurTypeViewOpen = ""
	MapObjCtrl.SetShowName(true)
	TerrainCtrl:SetSelectedCell(-1,-1)
end

-----------------------------------------------------统一处理子界面初始化方法【开始】
function MapFunctionView:InitSubView(id,sub)
	local TextList = {}
	for i = 1, 3 do
		table.insert(TextList, Find(sub.gameObject, "TextBox/Text_"..i))
	end
	local BtnList = {}
	for i = 1, 2 do
		local btn = Find(sub.gameObject, "BtnBox/Btn_"..i).gameObject
		LH.AddOnClick(btn,function (go) self:OnClickSubBtn(go) end)
		table.insert(BtnList, btn)
	end
	local FucList = self:GetFunList(id,sub)
	EffectMgr.GetEffectById(3002, sub.gameObject, nil, nil)
	return TextList, BtnList, FucList
end

function MapFunctionView:GetFunList(id,sub)
	local FucItem = Find(self.gameObject,"Item").gameObject
	FucItem:SetActive(false)
	local BtnDataList = self:GetBtnList(id)
	local FucList = {}
	for i=1,#BtnDataList do
		local temp = UnityEngine.GameObject.Instantiate(FucItem)
		temp.transform:SetParent(Find(sub.gameObject, "FucBox").transform)
		temp.transform.localScale = Vector3.one
		temp.name = tostring(BtnDataList[i].id)
		temp:SetActive(true)
		local t = {}
		t.data = BtnDataList[i]
		t.go = temp
		table.insert(FucList,t)
		L(temp.transform:Find("L/Text"),BtnDataList[i].name)
		L(temp.transform:Find("R/Text"),BtnDataList[i].name)
		temp.transform:Find("Button"):GetComponent("Image").sprite = LH.SetSprite(ED.MainUIPath, BtnDataList[i].icon)
		LH.AddOnClick(temp.transform:Find("Button").gameObject,function (go) self:OnClickFunBtn(sub,t) end)
	end
	return FucList
end

function MapFunctionView:GetBtnList(type)
	local t = {}
	for k,v in pairs(Res.button) do
		local types = string.Split(v.types,",")
		for i=1,#types do
			if types[i] == tostring(type) then
				table.insert(t,v)
			end
		end
	end
	return t
end

function MapFunctionView:OnClickSubBtn(go)
	local s = self.CurView:GetName()
	if go.name == "Btn_1" then
		local tPos = string.format("%d,%d", self.Data.x, self.Data.y)
		--标记
		-- LogError("type = " .. self.Data.type .. " ,num = " .. tonumber(self.Data.type))
		MapCtrl.C2SMarkTab(tonumber(self.Data.type), tostring(s), tostring(tPos))
	elseif go.name == "Btn_2" then
		ChatUICtrl.SharePosition(s,self.Data.x,self.Data.y,1)
	end
	self:CurClose()
end

function MapFunctionView:OnClickFunBtn(sub,t)
	if sub~=nil then
		sub:OnClickFucBtn(t)
	end
	self:CurClose()
end
-----------------------------------------------------统一处理子界面初始化方法【结束】
-----------------------------------------------------统一处理子界面按钮状态方法【开始】
function MapFunctionView:SetBtnPos(list)
	table.sort(list,function(a,b)
					return a.data.num < b.data.num
				end)
	local pDate = Res.buttonPos[#list]
	for i=1,#list do
		if pDate["p_"..i].x < 0 then
			list[i].go.transform.localPosition = pDate["p_"..i] + Vector3.New(70,0,0)
		else
			list[i].go.transform.localPosition = pDate["p_"..i] - Vector3.New(70,0,0)
		end
		list[i].go.transform:Find("L").gameObject:SetActive(pDate["p_"..i].x < 0)
		list[i].go.transform:Find("R").gameObject:SetActive(pDate["p_"..i].x > 0)
	end
end
-----------------------------------------------------统一处理子界面按钮状态方法【结束】