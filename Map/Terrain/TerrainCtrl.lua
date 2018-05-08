local TerrainCameraCtrl = require("Module/Map/Terrain/TerrainCameraCtrl");
local SeparateFrame = require("Module/Map/Terrain/SeparateFrame");
local HideObjectCtrl = SeparateFrame.new(5);

local TerrainCtrl = Class();
local HexTerrain = HexTerrain;
local HexCellValue = HexCellValue;
local HexInput = HexInput;
local Vector3 = Vector3;
local Mathf = Mathf;

local mOuterRadius = HexTerrain.OuterRadius;
local mInnerRadius = HexTerrain.InnerRadius;

local mCenterX = 0;
local mCenterY = 0;
local mViewSize = 12;
local mHexTerrain = nil;
local mPosition = Vector3.zero;
local mMoveInfo = {0,0};
local mVector3Zero = Vector3.zero;
local mSelectedEffect = nil;
local mBounds = {xMin = 0,yMin = 0,xMax = 100,yMax = 100};
local mClouds = {};
local mInput = nil;

function TerrainCtrl:ctor()
	local  effect = "Res/Effect/OtherEffect/dmxz_fx";--for test
	mSelectedEffect = DoFileUtil.DoFile("Framework/Effect/Effect").new(effect);
	mSelectedEffect.mLogicParams = {};	
end

function TerrainCtrl:LoadMap(map,loadedCallback)
	
	--mViewSize = TerrainCameraCtrl:GetViewSize();
	TerrainCameraCtrl:SetPosition(mPosition);
	TerrainCameraCtrl:SetCallback(function (position)
		self:UpdateCenter(position);

	end);

	local input = HexInput.Get(0.5);
	input.onMove = function (delta)
		TerrainCameraCtrl:Move(delta);
	end
	input.onMoveEnd = function (delta)
		TerrainCameraCtrl:MoveEnd(delta);
	end
	--input.onRotate = function (delta)
	--	TerrainCameraCtrl:Rotate(delta);
	--end
	input.onZoom = function (delta)
		TerrainCameraCtrl:Zoom(delta);
	end
	input.onBegan = function (id,position)
		self:OnInputBegan(id,position);
	end
	input.onEnded = function (id,position)
		self:OnInputEnded(id,position);
	end
	input.onClick = function (id,position)
		self:OnInputClick(id,position);
	end

	input.onBeganDrag = function (id,position)
		self:OnInputBeganDrag(id,position);
	end

	ResMgr.Instance:LoadAsset(ED.MapRootPath..map,function (prefab) self:OnLoadCompleted(prefab,loadedCallback) end);

	mInput = input;
end

function TerrainCtrl:EnableInput(enable)
	if mInput then
		mInput.enabled = enable;
	end
end

function TerrainCtrl:OnLoadCompleted(prefab,loadedCallback)
	if prefab then
		local go = GameObject.Instantiate(prefab);
		go.name = "Map"
		mHexTerrain = go:GetComponent(typeof(HexTerrain));
		mHexTerrain:CreateRenderer();
        TerrainCameraCtrl:SetBounds(self:GetBounds());
		self:Render();
		--self:AddClouds();
	end

	if loadedCallback then
		loadedCallback();
	end
end

function TerrainCtrl:AddClouds()
	local cloud = DoFileUtil.DoFile("Framework/Effect/CloudEffect");
	mClouds[1] = cloud.new("Res/Effect/OtherEffect/clouds");
	mClouds[1]:Show(mHexTerrain);

	--mClouds[2] = cloud.new("Res/Effect/OtherEffect/projectors");
	--mClouds[2]:Show(mHexTerrain);
end

function TerrainCtrl:RemoveClouds()
	for i,v in ipairs(mClouds) do
		v:Dispose();
	end
	mClouds = {};
end

function TerrainCtrl:GetBounds()
	--mBounds.xMin 
	--mBounds.yMin 
	--mBounds.xMax 
	--mBounds.yMax 
	if mHexTerrain then
		mBounds.xMax = mHexTerrain.Width  * mInnerRadius * 2.0;
		mBounds.yMax = mHexTerrain.Height * mOuterRadius * 1.5;
	end
    return mBounds;
end

function TerrainCtrl:OnInputBegan(id,pos)

end

function TerrainCtrl:OnInputEnded(id,pos)
    local x,y = self:GetCenter()
    MapObjCtrl.SetShowName(true)
    EventMgr.SendEvent(ED.MapMoveEvent,{x,y})
end

function TerrainCtrl:OnInputClick(id,pos)
	-- LogError("pos",pos.x,pos,y)
	local list = LH.GetRay(pos):ToTable()
	local go = nil
	for i=1,#list do
		if list[i].collider.gameObject.name ~= "Map" then
			go = list[i].collider.gameObject
		end
	end
	MapObjCtrl.SetShowName(true)
	if go ~= nil then
		-- LogError("go.name",go.name)
		local monoData = go:GetComponent("MonoData")
		local data = monoData.data
		data[1]()
		MapObjCtrl.mode.CurObj = go.transform.parent.parent:Find("NameBox")
		MapObjCtrl.SetShowName(false)
	else
    	local x,y = self:ScreenToCell(pos)
    	if x==nil or y==nil then return end
    	if self:Reachable(x,y) then--是否可以到达
        	local t = {}
        	t.type = 3
        	t.Data = MapCtrl.GetIDbyXY(x,y)
        	t.x = x
        	t.y = y
        	UIMgr.OpenView("MapFunctionView",t)
        	EventMgr.SendEvent(ED.MapMoveEvent,{x,y})
    	else
			EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
			self:SetSelectedCell(-1,-1)
    	end
	end
end

function TerrainCtrl:OnInputBeganDrag(id,pos)
	EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{id = id,pos = pos})
end

function TerrainCtrl:Dispose()
	mHexTerrain = nil;
	mInput = nil;
	mSelectedEffect:Dispose();
	TerrainCameraCtrl:Dispose();
	HideObjectCtrl:Dispose();
	--self:RemoveClouds();
end

function TerrainCtrl:Render()
	if mHexTerrain then
		mHexTerrain:Render(mPosition,mViewSize);
	end
end

function TerrainCtrl:ForceToPosition(i,j)
	self:UpdateCenter(self:ConvertToWorld(i,j,0));
	TerrainCameraCtrl:SetPosition(mPosition);
end

function TerrainCtrl:MoveToPosition(i,j,callback)
	TerrainCameraCtrl:MoveToPosition(self:ConvertToWorld(i,j,0),callback);
end

function TerrainCtrl:MoveToWorldPosition(position,callback)
	TerrainCameraCtrl:MoveToPosition(position,callback);
end

function TerrainCtrl:UpdateCenter(position)
	mPosition.x = position.x;
	mPosition.z = position.z;
	local xCoord,yCoord =self:ConvertToCell(mPosition);
	if xCoord~=mCenterX or yCoord ~= mCenterY then
		mCenterX = xCoord;
		mCenterY = yCoord;
		self:Render();
	end
end

function TerrainCtrl:GetCenter()
	return mCenterX,mCenterY;
end

function TerrainCtrl:ConvertToCell(position)
    local yCoord = Mathf.Round(position.z / (mOuterRadius * 1.5));
    local xCoord = Mathf.Round((position.x - (yCoord % 2) * mInnerRadius) / (mInnerRadius * 2));

    return xCoord,yCoord;
end

function TerrainCtrl:GetHeight(i,j)
    local cell = self:FindCell(i,j);
    if cell then
    	return cell.SolidSurfaceY;
    end
    return 0;
end


function TerrainCtrl:ConvertToWorld(i,j,height)
	-- LogError("ConvertToWorld",i,j)
	local x = i * (mInnerRadius * 2) + (j % 2) * mInnerRadius;
	local y = height or self:GetHeight(i,j);
    local z = j * (mOuterRadius * 1.5);
    return Vector3.New(x,y,z);
end

function TerrainCtrl:HideObjects(i,j)
	local action = function ()
		if mHexTerrain then
			mHexTerrain:HideObjects(i,j);
		end
	end
	HideObjectCtrl:AddAction(action);
end

function TerrainCtrl:ShowObjects(i,j)
	-- if mHexTerrain then
	-- 	mHexTerrain:RemoveObjects(self:ConvertToWorld(i,j,0),1,1);
	-- end
end

function TerrainCtrl:SetMapCell(list)
    if mHexTerrain then
	    for i,v in pairs(list) do
	    	self:Replace(v.x,v.y,v.index);
	    end
	    mHexTerrain:Refresh();
	end
end

function TerrainCtrl:ResetMapCell(list)
    if mHexTerrain then
	    for i,v in pairs(list) do
	    	self:Restore(v.x,v.y);
	    end
	    mHexTerrain:Refresh();
	end
end

function TerrainCtrl:FindCell(x,y)
	if mHexTerrain then
		return mHexTerrain:FindCell(x,y);
	end
end

function TerrainCtrl:ScreenToCell(screenPosition)
	if mHexTerrain then
		local cell = mHexTerrain:RaycastCell(TerrainCameraCtrl:ScreenPointToRay(screenPosition));
		if cell then
			return cell.xCoord,cell.yCoord;
		end
	end
end

function TerrainCtrl:CellToScreen(x,y)
	return TerrainCameraCtrl:WorldToScreenPoint(self:ConvertToWorld(x,y))
end

function TerrainCtrl:Reachable(x,y)
	if mHexTerrain then
		local cell = mHexTerrain:FindCell(x,y);
		if cell then
			return cell:IsReachable();
		end
	end
	return false;
end

function TerrainCtrl:Replace(x,y,decalType)
	local cell = mHexTerrain:FindCell(x,y);
	if cell then
		cell:Replace(decalType, HexCellValue.DecalType)
	end
end

function TerrainCtrl:Restore(x,y)
	local cell = mHexTerrain:FindCell(x,y);
	if cell then
		cell:Restore(HexCellValue.DecalType)
	end
end

function TerrainCtrl:SetSelectedCell(x,y)
	if mHexTerrain then
		local cell = mHexTerrain:FindCell(x,y);
		if cell then
			local logicParams = mSelectedEffect.mLogicParams;
			logicParams.position = cell.Position;
			if mSelectedEffect:IsActive() then
				mSelectedEffect:Update(logicParams);
			else
				mSelectedEffect:Show(logicParams);
			end
		else
			mSelectedEffect:Hide();
		end
	end
end

function TerrainCtrl:GetSubIndex(x,y)
	if mHexTerrain then
		local cell = mHexTerrain:FindCell(x,y);
		if cell then
			return cell.SubIndex;
		end
	end
	return 0;
end

function TerrainCtrl:ToggleTrees()
	HexTerrain.HideTrees = not HexTerrain.HideTrees;
	if mHexTerrain then
		mHexTerrain:Refresh();
	end
end

function TerrainCtrl:ToggleTerrains()
	HexTerrain.HideTerrains = not HexTerrain.HideTerrains;
	if mHexTerrain then
		mHexTerrain:Refresh();
	end
end
return TerrainCtrl.new();