local WorldMapView = Class(require("Framework/View/BaseItemView"))
local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")
local PoolKey = "UI";
local m3DMapPath = "Res/UI/Prefab/3DMap";
local mViewName = "MapView";
function WorldMapView:InitView()
	self:FindAndAddClickListener(function ()
		UIMgr.CloseView(mViewName);
	end,"BtnBack/Button");

	self:Init3DMap(GameObject.Find("XDT"));
end

function WorldMapView:OnViewShow()
	TerrainCtrl:EnableInput(false);
	if self.mRoot then
		self.mRoot:SetActive(true);
	end
	UIMgr.CloseView("MainView");
	UIMgr.CloseView("MainMapView");
end

function WorldMapView:Init3DMap(go)
	self.mRoot = go.transform:Find("Root").gameObject;
	self.mCameraCtrl = self.mRoot:GetComponentInChildren(typeof(WorldMapCameraCtrl));
	self.mCameraCtrl.onClickState = function (state)
		EventMgr.SendEvent(ED.OpenStateMapView,state);
	end
end

function WorldMapView:OnViewHide()
	TerrainCtrl:EnableInput(true);
	if self.mRoot then
		self.mRoot:SetActive(false);
	end
	UIMgr.OpenView("MainView");
	UIMgr.OpenView("MainMapView");
end

return WorldMapView;