local StateMapView = Class(require("Framework/View/BaseItemView"))
local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")
local GroupView = require("Framework/View/GroupView")
local GroupItemView = require("Framework/View/GroupItemView")
local WorldModel = require("Module/Map/MapView/WorldModel")
local SortTable = require "Framework/Base/SortTable"

local Mathf = Mathf;
local Vector3 = Vector3;
local Input = UnityEngine.Input;

local RectTransformUtility = UnityEngine.RectTransformUtility;
local GameObject = UnityEngine.GameObject;
local XSpace = 300;
local YSpace = 100;

function StateMapView:InitView()

	local trigger = EventTriggerListener.Get(self:Find("Mask"));

	trigger.onDown = function (go) self.mDraged = nil; end
	trigger.onDrag = function (go,delta) self:OnDragMap(delta); end
	trigger.onClick = function (go) self:OnClickMap(); end

	self.mMapRoot = self:Find("Mask/MapRoot");
	self.mCurPos = self:Find("Mask/MapRoot/Cur");
	self.mLairdPos = self:Find("Mask/MapRoot/Laird");
	self.mMapTexture = self:FindComponent("RawImage","Mask/MapRoot/Map");
	self.mStateNameText = self:FindComponent("Text","BtnBack/StateName");

	self:FindAndAddClickListener(function ()
		EventMgr.SendEvent(ED.ReturnWorldMapView);
	end,"BtnBack/Button");

	L(self:FindComponent("Text","CityScrollView/Tittle/Text"),"城市列表");

	self.mMaskSize = trigger:GetComponent("RectTransform").sizeDelta;

	self.mCityGroupView = GroupView.new(self:Find("Mask/MapRoot/CityItemsRoot").gameObject,GroupItemView);
	self.mPlayerGroupView = GroupView.new(self:Find("Mask/MapRoot/PlayerItemsRoot").gameObject,GroupItemView);
	self.mCityScrollView = GroupView.new(self:Find("CityScrollView/Mask/Content").gameObject,GroupItemView);

	self.mCityGroupView:Init(
		function (view) self:UpdateCityGroupItemView(view);end,
		function (view) self:OnClickCityItemOnMap(view);end
		);
	self.mPlayerGroupView:Init(
		function (view) self:UpdatePlayerGroupItemView(view);end,
		nil
		);
	self.mCityScrollView:Init(
		function (view) self:UpdateCityScrollItemView(view);end,
		function (view) self:OnClickCityItem(view);end
		);
end

function StateMapView:OnDragMap(delta)
	local mapSize = self.mMapSize;
	local xMin = (self.mMaskSize.x - mapSize.x * self.mMapScale.x)/2 - XSpace;
	local yMin = (self.mMaskSize.y - mapSize.y * self.mMapScale.y)/2 - YSpace;
	local position = self.mMapRoot.localPosition;
	position.x = Mathf.Clamp(position.x + delta.x,xMin,-xMin)
	position.y = Mathf.Clamp(position.y + delta.y,yMin,-yMin)
	self.mMapRoot.localPosition = position;
	self.mDraged = true;
end

function StateMapView:OnClickMap()

	if self.mDraged then
		return;
	end
	local flag,position = RectTransformUtility.ScreenPointToLocalPointInRectangle(self.mMapRoot,Input.mousePosition,LH.GetUICamera(),nil);
	if flag then
		local mapScale = self.mMapScale;
		local xOffset,yOffset = self.mLogicParams:GetMapOffset();
		local x = xOffset + Mathf.Round((position.x + self.mMapSize.x * mapScale.x/2)/mapScale.x);
		local y = yOffset + Mathf.Round((position.y + self.mMapSize.y * mapScale.y/2)/mapScale.y);
		if TerrainCtrl:FindCell(x,y) then
			TerrainCtrl:ForceToPosition(x,y);
			EventMgr.SendEvent(ED.MapMoveEvent,{x,y});
			UIMgr.CloseView("MapView")
		end
	end

end

function StateMapView:GetPlayerDataSource()
	local mapSize = self.mMapSize;
	local mapScale = self.mMapScale;
	local dataSource = SortTable.new();
	return dataSource;
end

function StateMapView:GetPlayer(mapSize,mapScale)
	local x = math.random(0,mapSize.x);
	local y = math.random(0,mapSize.y);
	local xOffset,yOffset = self.mLogicParams:GetMapOffset();
	local player = nil;
	while not player do
		x = math.random(0,mapSize.x);
		y = math.random(0,mapSize.y);
		local cell = TerrainCtrl:FindCell(x+xOffset,y+yOffset);
		if cell and cell:IsReachable() then
			player = {position = Vector3.New((x-mapSize.x/2)*mapScale.x ,(y-mapSize.y/2)*mapScale.y,0)};
		end
	end
	return player;
end

function StateMapView:OnViewShow()
	ResMgr.Instance:LoadAsset(self.mLogicParams:GetMapTexturePath(),function (texture)
		self:UpdateMapTexture(texture);
	end);
end

function StateMapView:OnViewHide()
	self.mCityGroupView:RemoveListeners();
	self.mCityScrollView:RemoveListeners();
	self.mPlayerGroupView:RemoveListeners();
end

function StateMapView:MapToGUIPoint(state,x,y)
	local width,height = state:GetMapSize();
	local xOffset,yOffset = state:GetMapOffset();
	x = x - xOffset;
	y = y - yOffset;
	if x >= 0 and y >= 0 and x < width and y <  height then
		return Vector3.New((x-width/2)*self.mMapScale.x,(y-height/2)*self.mMapScale.y,0);
	end
	return Vector3.New(-100000,0,0);
end

function StateMapView:OnClickCityItem(item)
	local data = item.mData;
	local mapSize = self.mMapSize;
	local mapScale = self.mMapScale;

	local i,j = data:GetLocation();
	local x = mapScale.x * ( i - mapSize .x/2) ;
	local y = mapScale.y * ( j - mapSize .y/2) ;

	local xMin = (self.mMaskSize.x - mapSize.x * mapScale.x)/2 - XSpace;
	local yMin = (self.mMaskSize.y - mapSize.y * mapScale.y)/2 - YSpace;

	local position = self.mMapRoot.localPosition;
	position.x = Mathf.Clamp(-x,xMin,-xMin);
	position.y = Mathf.Clamp(-y,yMin,-yMin);

	self.mMapRoot.localPosition = position;

	--EventMgr.SendEvent(ED.ShowCityInfoView,self.mCityGroupView:GetItemView(data.mData.id));
end

function StateMapView:OnClickCityItemOnMap(view)
	local i,j = view.mData:GetLocation();
	local xOffset,yOffset = self.mLogicParams:GetMapOffset();
	local x = i + xOffset;
	local y = j + yOffset;
	if TerrainCtrl:FindCell(x,y) then
		TerrainCtrl:ForceToPosition(x,y);
		EventMgr.SendEvent(ED.MapMoveEvent,{x,y});
		UIMgr.CloseView("MapView")
	end
end

function StateMapView:UpdateCityScrollItemView(view)
	L(view:Find("Name"),view.mData:GetName().." Lv"..view.mData:GetLevel());
end

function StateMapView:UpdateCityGroupItemView(view)
	local data = view.mData;
	local i,j = data:GetLocation();
	local x = self.mMapScale.x * ( i - self.mMapSize .x/2) ;
	local y = self.mMapScale.y * ( j - self.mMapSize .y/2) ;
	view:FindComponent("UISpriteSwap","Icon"):Swap(data:GetCityType() - 1);
	view.mTransform.localPosition = Vector3.New(x,y,0);
	L(view:Find("Icon/Text"),data:GetName());
end

function StateMapView:UpdatePlayerGroupItemView(view)
	view.mTransform.localPosition = view.mData.position;
end

function StateMapView:UpdateMapTexture(texture)
	local state = self.mLogicParams;
	local mode = LoginCtrl.mode;
	local dataSource = WorldModel:GetCityDataSource(state.mData.stateid);
	local mapTexture = self.mMapTexture;

	mapTexture.texture = texture;
	mapTexture:SetNativeSize();

	local textureSize = mapTexture.rectTransform.sizeDelta;
	L(self.mStateNameText,state:GetName());

	
	self.mMapSize = Vector2.New(state:GetMapSize());
	self.mMapScale = Vector2.New(textureSize.x/self.mMapSize.x,textureSize.y/self.mMapSize.y);

	self.mCityGroupView:UpdateDataSource(dataSource);
	self.mCityScrollView:UpdateDataSource(dataSource);

	self.mPlayerGroupView:UpdateDataSource(self:GetPlayerDataSource());

	self.mCurPos.localPosition = self:MapToGUIPoint(state,MapCtrl.GetXYbyID(mode.mapInfo.currPosition));
	self.mLairdPos.localPosition = self:MapToGUIPoint(state,MapCtrl.IdToXY(mode.LairdInfo.gridId));
end


return StateMapView;