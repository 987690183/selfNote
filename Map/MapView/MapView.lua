MapView=Class(BaseView)
local WorldMapView = require("Module/Map/MapView/WorldMapView")
local StateMapView = require("Module/Map/MapView/StateMapView")
local BaseItemView = require("Framework/View/BaseItemView")
local mButtonStr = "Button";
local mViewName = "MapView";
local WorldModel = require("Module/Map/MapView/WorldModel")
local GActionManager = require "Module/Mgr/GActionManager"

function MapView:ConfigUI()
	local go = self.gameObject;
	self.mWorldMap = WorldMapView.new(Find(go,"WorldMapView"));
	self.mStateMap = StateMapView.new(Find(go,"StateMapView"));
	self.mCityTip = BaseItemView.new(Find(go,"CityTipView"));

	self:AddBtnClickListener(Find(go,"BtnClose"),function () UIMgr.CloseView(mViewName); end);

	EventMgr.AddEvent(ED.OpenStateMapView,function (state)
		self:ShowStateMap(WorldModel:GetState(state));
	end,mViewName);
	EventMgr.AddEvent(ED.ReturnWorldMapView,function ()
		self:ReturnWorldMap();
	end,mViewName);

	EventMgr.AddEvent(ED.ShowCityInfoView,function (info)
		self:ShowCityInfoView(info);
	end,mViewName);
end

function MapView:AfterOpenView(t)
	MapCtrl.C2SGetCity(0);
	self.mStateMap:HideView();
	self.mWorldMap:ShowView();
end

function MapView:AddBtnClickListener(btn,listener)
	btn:GetComponent(mButtonStr).onClick:AddListener(listener);
end

function MapView:ShowStateMap(state)
	self.mWorldMap:HideView();
	self.mStateMap:ShowView(state);
end

function MapView:ReturnWorldMap()
	self.mStateMap:HideView();
	self.mWorldMap:ShowView();
end

function MapView:ShowCityInfoView(info)
	local view = self.mCityTip;
	local data = info.mData.mData;
	local group = view:FindComponent("CanvasGroup");

	L(view:Find("unitename"),"可立国国号 "..data.unitename);
	L(view:Find("openTime"),"允许攻打时段 "..data.openTime);
	L(view:Find("garrisonRtime"),"守军恢复时间 "..data.garrisonRtime);
	L(view:Find("btgroupnum"),"组建军团数量 "..data.btgroupnum);

	L(view:Find("moneyOutput/Text"),"产出银两 "..data.moneyOutput);
	L(view:Find("skoutput/Text"),"产出技术 "..data.skoutput);
	L(view:Find("durable/Text"),"城市城防 "..data.durable);

	L(view:Find("zhanling/Text"),"占领者 "..info.mData.mGuildName);
	L(view:Find("shouzhanling/Text"),"首占领同盟 无");

	view.mTransform.position = info.mTransform.position;
	view:ShowView();

	if self.mFadeInAction then
		GActionManager:RemoveAction(self.mFadeInAction);
	end

	if self.mFadeOutAction then
		GActionManager:RemoveAction(self.mFadeOutAction);
	end

	self.mFadeInAction = GActionManager:AddAction(0.5,0,true,
	function (time) 
		group.alpha = Mathf.Lerp(0,1,time*2); 
	end,
	function () 
		group.alpha = 1; 
	end);

	self.mFadeOutAction = GActionManager:AddAction(0.5,2,true,
	function (time)
		group.alpha = Mathf.Lerp(1,0,time*2);
	end,
	function () 
		view:HideView();
	end);
end

function MapView:OnDestory()
	if self.mFadeInAction then
		GActionManager:RemoveAction(self.mFadeInAction);
	end

	if self.mFadeOutAction then
		GActionManager:RemoveAction(self.mFadeOutAction);
	end

	self.mStateMap:CloseView();
	self.mWorldMap:CloseView();
end



