ObjMarch = Class(MapObj)

local TerrainCtrl = DoFileUtil.DoFile("Module/Map/Terrain/TerrainCtrl")

function ObjMarch:DoShow()
	if not self.mInfo.totalTime then
		self.mInfo.startTime = tonumber(self.mInfo.serverData.startTime)
		self.mInfo.endTime = tonumber(self.mInfo.serverData.endTime)
		self.mInfo.totalTime = self.mInfo.serverData.endTime - self.mInfo.serverData.startTime
		self.mInfo.leftTime = self.mInfo.serverData.endTime - GetTime()
		self:BeginMove(TerrainCtrl:ConvertToWorld(self.mInfo.tx,self.mInfo.ty),self.mInfo.totalTime-self.mInfo.leftTime,self.mInfo.totalTime)
	end
end

function ObjMarch:DoLoad()
	self.mGo:SetActive(false)
	L(self.mTra:Find("NameBox/Name/Image/Text"),self.mInfo.serverData.laird.playerName)
	  
	self.mMoveGo = self.mTra:Find("GameObject")
	self.mNameBox = self.mTra:Find("NameBox")

	self.mTra:Find("Line/Line_1").gameObject:SetActive(false)
	self.mTra:Find("Line/Line_2").gameObject:SetActive(false)

	-- self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图
    self.mMove_0 = self.mTra:Find("GameObject/0")
    self.mMove_1 = self.mTra:Find("GameObject/1")
    self.mMove_2 = self.mTra:Find("GameObject/2")
    self.mMove_3 = self.mTra:Find("GameObject/3")
    self.mMove_4 = self.mTra:Find("GameObject/4")
end

function ObjMarch:BeginMove(position,current,totalTime)
	local p = Vector3.Lerp(TerrainCtrl:ConvertToWorld(self.mInfo.x,self.mInfo.y),TerrainCtrl:ConvertToWorld(self.mInfo.tx,self.mInfo.ty),(100-self.mInfo.serverData.percent)/100)
	self.mFromPosition = p
	self.mCurrent = current
	self.mTotalTime = totalTime
	-- LogError("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	-- LogError("self.mCurrent",self.mCurrent,"self.mTotalTime",self.mTotalTime)
	self.mTargetPosition = position
	if not self.mUpdateMove then
		self.mUpdateMove = function () self:Move() end
		UpdateBeat:Add(self.mUpdateMove)
	end
end
function ObjMarch:Move()
	self.mCurrent = self.mCurrent + Time.deltaTime
	self.mPosition = Vector3.Lerp(self.mFromPosition,self.mTargetPosition,self.mCurrent/self.mTotalTime)
	if self.mCurrent > self.mTotalTime then
		self:StopMove()
		MapObjCtrl:RemoveObjects({self.mInfo})
	end
	if IsNil(self.mGo) then return end--未加载完成
	-----------------行军线路设置
	local lrFrom = self.mTra:Find("Line/Line_1"):GetComponent("MapLineHelper")
	lrFrom:SetLine(self.mFromPosition,self.mPosition)
	local lrTo = self.mTra:Find("Line/Line_2"):GetComponent("MapLineHelper")
	lrTo:SetLine(self.mFromPosition,self.mTargetPosition)
	-----------------主体移动设置
	self.mMoveGo.position = self.mPosition
	local dir = self.mTargetPosition - self.mPosition
	dir.y = 0
	if dir ~= Vector3.zero then
		self.mMoveGo.rotation = Quaternion.LookRotation(dir,Vector3.up)
	end
	-----------------跟随名字设置
	self.mNameBox.position = self.mMoveGo.position
	-----------------设置士兵位置
	local dis = Vector3.Distance(self.mPosition,self.mFromPosition)
	-- LogEver(1,"self.mInfo.serverData.percent",self.mInfo.serverData.percent)
	local b = (self.mInfo.serverData.percent ~= 100)
	self.mMove_0.gameObject:SetActive(dis>0.2*0 or b)
	self.mMove_1.gameObject:SetActive(dis>0.2*1 and self.mInfo.serverData.rows >= 1 or b)
	self.mMove_2.gameObject:SetActive(dis>0.2*2 and self.mInfo.serverData.rows >= 2 or b)
	self.mMove_3.gameObject:SetActive(dis>0.2*3 and self.mInfo.serverData.rows >= 3 or b)
	self.mMove_4.gameObject:SetActive(dis>0.2*4 and self.mInfo.serverData.rows >= 4 or b)
	lrFrom.gameObject:SetActive(dis>0.1 or b)
	lrTo.gameObject:SetActive(dis>0.1 or b)
	self.mNameBox.gameObject:SetActive(dis>0.1 or b)
	-----------------初始化开启显示
	if self.mGo.activeSelf ~= true then self.mGo:SetActive(true) end
end

function ObjMarch:OnClick(keyName)
	local dis = Vector3.Distance(self.mPosition,self.mFromPosition)
	if dis<0.1 then 
    	EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
    	return
    end
	local x,y=TerrainCtrl:ConvertToCell(self.mNameBox.position)
    TerrainCtrl:MoveToWorldPosition(self.mNameBox.position)--平移摄像机
    EventMgr.SendEvent(ED.MapMoveEvent,{x,y})
    self.mInfo.follow = self.mNameBox
    UIMgr.OpenView("MapFunctionView",self.mInfo)
end

function ObjMarch:StopMove()
	if self.mUpdateMove then
		UpdateBeat:Remove(self.mUpdateMove)
		self.mUpdateMove = nil
	end
	if MapCtrl.mode.CurTypeViewOpen == self.mInfo.key then
		EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
	end
end  

function ObjMarch:DoHide()
	EventMgr.SendEvent(ED.GoToMapPointEnd)
	self:StopMove()
end

function ObjMarch:GetMarchPosInfo()
	return self.mFromPosition, self.mTargetPosition, self.mPosition
end

