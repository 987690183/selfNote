local GActionManager = require "Module/Mgr/GActionManager"
local TerrainCameraCtrl = Class();
local Physics = UnityEngine.Physics;
local Camera = UnityEngine.Camera;
local Time = Time;
local Mathf = Mathf;
local Quaternion = Quaternion;
local Vector3 = Vector3;
local Vector3Up = Vector3.up;
local Vector3Back = Vector3.back;

local Settings =  loadstring("return "..Res.setting.worldMapCamera)();

local mMinPitch = Settings.Min_Pitch;
local mMaxPitch = Settings.Max_Pitch;

local mMinDistance = Settings.Min_Distance;
local mMaxDistance = Settings.Max_Distance;

local mMinLookOffset = Settings.Min_Look_Offst;
local mMaxLookOffset = Settings.Max_Look_Offst;

local mLerpTime1 = Settings.Move_Time1;
local mLerpTime2 = Settings.Move_Time2;

local mState = Settings.Defalut;

local mYaw = {from = 0,current = 0,target = 0}

local mDefaulPitch = Mathf.Lerp(mMinPitch, mMaxPitch, mState);
local mPitch = {from = mDefaulPitch,current = mDefaulPitch,target = mDefaulPitch};

local mDefaultDistance = Mathf.Lerp(mMinDistance, mMaxDistance, mState);
local mDistance = {from = mDefaultDistance,current = mDefaultDistance,target = mDefaultDistance};

local mPosition = 
{
	from = Vector3.New(0,Mathf.Lerp(mMinLookOffset, mMaxLookOffset, mState),0),
	current = Vector3.New(0,Mathf.Lerp(mMinLookOffset, mMaxLookOffset, mState),0),
	target = Vector3.New(0,Mathf.Lerp(mMinLookOffset, mMaxLookOffset, mState),0)};

local mRotateScale = Settings.Rotate_Scale;
local mMoveScale = Settings.Move_Scale;
local mZoomScale = Mathf.Max(Settings.Zoom_Scale,100);

local mCamera = nil
local mDataCamera = nil

local mUpdate = nil
local mCallback = nil;

local mFov = Settings.Fov;
local mViewSize = Settings.View_Size;
local mBounds = {Left = 0,Bottom = 0,Right = 100,Top = 100}

local mMoveAction = nil;
local mZoomAction = nil;

function TerrainCameraCtrl:GetViewSize()
	return mViewSize + 2;
end

function TerrainCameraCtrl:SetBounds(bounds)
	mBounds.Left = bounds.xMin;
	mBounds.Bottom = bounds.yMin;
	mBounds.Right = bounds.xMax;
	mBounds.Top = bounds.yMax;
end

function TerrainCameraCtrl:SetCallback(callback)
	mCallback = callback;
end

function TerrainCameraCtrl:SendEvent()
	if mCallback then
		mCallback(mPosition.current);
	end
end

function TerrainCameraCtrl:Dispose()
	mCameraTransform = nil;
	mCamera = nil;
	mDataCamera = nil
	mCallback = nil;
	mMoveCompleted = nil;
end

function TerrainCameraCtrl:UpdateCamera()
	if not mCameraTransform then
		mCamera = Camera.main;
		if mCamera then
			mDataCamera = mCamera.transform:Find("SceneUICamera"):GetComponent("Camera")
			mCameraTransform = mCamera.transform;
			mCamera.fieldOfView = mFov;
			mDataCamera.fieldOfView = mFov;
		else
			return;
		end
	end
    mCameraTransform.position = mPosition.current + (Quaternion.Euler(mPitch.current,mYaw.current, 0) * Vector3Back).normalized * mDistance.current;
    mCameraTransform:LookAt(mPosition.current);
end

function TerrainCameraCtrl:PosOffset()
	local direction = (Quaternion.Euler(mPitch.target, mYaw.target, 0) * Vector3Back);
	local offset = direction.normalized * mDistance.current;
	local deltah = offset.y;
	offset.y = 0;
	direction.y = 0;
    return direction.normalized*(mPosition.target.y*offset:Magnitude())/deltah;
end

function TerrainCameraCtrl:SetPosition(position)
	self:SetClampPosition(position + self:PosOffset());
	self:CopyVector(mPosition.target,mPosition.current);
	self:UpdateCamera();
end

function TerrainCameraCtrl:SetClampPosition(position)
	mPosition.target.x =  Mathf.Clamp(position.x,mBounds.Left,mBounds.Right);
	mPosition.target.z =  Mathf.Clamp(position.z,mBounds.Bottom,mBounds.Top);
end

function TerrainCameraCtrl:MoveMent(delta)
	delta = delta/mMoveScale;
    local forward = Quaternion.Euler(mPitch.current, mYaw.current, 0) * Vector3Back;
    forward.y = 0; 
    forward:Normalize();
    local right = Vector3.Cross(Vector3Up, forward):Normalize();
    local moveMent = forward * delta.y + right * delta.x;
    moveMent.y = 0;
    return moveMent;
end

function TerrainCameraCtrl:CopyVector(src,dst)
	dst.x = src.x;
	dst.y = src.y;
	dst.z = src.z;
end

function TerrainCameraCtrl:Move(delta)
    self:SetClampPosition(mPosition.target + self:MoveMent(delta));
    self:CopyVector(mPosition.target,mPosition.current);
    self:UpdateCamera();
    self:SendEvent();
end

function TerrainCameraCtrl:MoveEnd(delta)
	self:SetClampPosition(mPosition.target + self:MoveMent(delta));
	self:AddMoveAction(Mathf.Min(mLerpTime1,Vector3.Distance(mPosition.target,mPosition.current)));
end

function TerrainCameraCtrl:MoveToPosition(position,completedCallback)
	self:SetClampPosition(position + self:PosOffset());
	self:AddMoveAction(Mathf.Min(mLerpTime2,Vector3.Distance(mPosition.target,mPosition.current)),completedCallback);
end

function TerrainCameraCtrl:UpdateMove(time)
    mPosition.current = Vector3.Lerp(mPosition.from, mPosition.target,time);
    self:UpdateCamera();
    self:SendEvent();
end

function TerrainCameraCtrl:AddMoveAction(duration,completedCallback)
	self:CopyVector(mPosition.current,mPosition.from);
	if mMoveAction  then
		GActionManager:RemoveAction(mMoveAction);
	end
	mMoveAction = GActionManager:AddAction(duration+0.2,0,true,
	function (time) self:UpdateMove(time/duration); end,completedCallback);
end

function TerrainCameraCtrl:UpdateZoom(t)
    mPosition.current.y = Mathf.Lerp(mPosition.from.y, mPosition.target.y,t);
    mDistance.current = Mathf.Lerp(mDistance.from, mDistance.target,t);
    mPitch.current = Mathf.Lerp(mPitch.from, mPitch.target,t);
    self:UpdateCamera();
end

function TerrainCameraCtrl:AddZoomAction()
	mDistance.from = mDistance.current;
	mPitch.from = mPitch.current;
	if mZoomAction  then
		GActionManager:RemoveAction(mZoomAction);
	end
	mZoomAction = GActionManager:AddAction(0.5,0,true,
	function (time) self:UpdateZoom(time*5) end,nil);
end

function TerrainCameraCtrl:Zoom(delta)
	delta = delta/mZoomScale;
	local state = Mathf.Clamp(mState - delta,0,1);
	if state ~= mState then
		mState = state;
		mDistance.target = Mathf.Lerp(mMinDistance, mMaxDistance, mState);
	    mPitch.target = Mathf.Lerp(mMinPitch, mMaxPitch, mState);
	    mPosition.target.y = Mathf.Lerp(mMinLookOffset, mMaxLookOffset, mState);
	    self:AddZoomAction(Mathf.Min(0.25,Mathf.Abs(delta)));
	end
end

function TerrainCameraCtrl:ScreenPointToRay(screenPosition)
	if mCamera then
		return mCamera:ScreenPointToRay(Vector3.New(screenPosition.x,screenPosition.y,0));
	end
end

function TerrainCameraCtrl:WorldToScreenPoint(position)
	if mCamera then
		return mCamera:WorldToScreenPoint(position);
	end
end

function TerrainCameraCtrl:CameraView()
	mDataCamera.gameObject:SetActive(not mDataCamera.gameObject.activeSelf)
	EventMgr.SendEvent(ED.IsOpenMapLairdName,mDataCamera.gameObject.activeSelf)
end

return TerrainCameraCtrl.new();
