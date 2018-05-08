ObjTransfer = Class(MapObj)

local TerrainCtrl = DoFileUtil.DoFile("Module/Map/Terrain/TerrainCtrl")

function ObjTransfer:DoShow()
	self.flag = false
	self.playAnistr = ""
	if not self.mInfo.totalTime then
		self.mInfo.startTime = tonumber(self.mInfo.serverData.startTime)
		self.mInfo.endTime = tonumber(self.mInfo.serverData.endTime)
		self.mInfo.totalTime = self.mInfo.serverData.endTime - self.mInfo.serverData.startTime
		self.mInfo.leftTime = self.mInfo.serverData.endTime - GetTime()
		self:BeginMove(TerrainCtrl:ConvertToWorld(self.mInfo.tx,self.mInfo.ty),self.mInfo.totalTime-self.mInfo.leftTime,self.mInfo.totalTime)
	end
end

function ObjTransfer:DoLoad()
	self.mGo:SetActive(false)
	L(self.mTra:Find("NameBox/Name/Image/Text"),self.mInfo.serverData.laird.playerName)
	L(self.mTra:Find("F/Name/Image/Text"),self.mInfo.serverData.laird.playerName)
	L(self.mTra:Find("T/Name/Image/Text"),self.mInfo.serverData.laird.playerName)
	  
	self.mMoveGo = self.mTra:Find("GameObject")
	self.mNameBox = self.mTra:Find("NameBox")
	-- 动态加载
	if not self.marchObj then
		ResMgr.Instance:LoadAsset("Res/Map/Models/ATL_DDT_zhuying_01/MarchObj.prefab", function(prefab)
			self.marchObj = UnityEngine.GameObject.Instantiate(prefab)
			self.marchObj.gameObject.name = "MarchObj"
			self.marchObj.gameObject.transform:SetParent(self.mMoveGo.transform)
			self.marchObj.transform.localScale = Vector3.one
			self.marchObj.transform.localPosition = Vector3.zero
			self.marchObj.transform.localEulerAngles = Vector3.zero
		end)
	end

	self.mTra:Find("F").position = self.mFromPosition
	self.mTra:Find("T").position = self.mTargetPosition

	-- self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图
	local b = (self.mInfo.serverData.percent ~= 0)
	if b then
		self:LoadView(self.mTra:Find("F"),self.mInfo.modePathF)--加载F视图
		self:LoadView(self.mTra:Find("T"),self.mInfo.modePathT)--加载T视图
	end
	EventMgr.SendEvent(ED.TransferStatus, self.mFromPosition, self.mTargetPosition, false)
end

function ObjTransfer:BeginMove(position,current,totalTime)
	local p = Vector3.Lerp(TerrainCtrl:ConvertToWorld(self.mInfo.x,self.mInfo.y),TerrainCtrl:ConvertToWorld(self.mInfo.tx,self.mInfo.ty),(100-self.mInfo.serverData.percent)/100)
	self.mFromPosition = p
	self.mCurrent = current
	self.mCurrentSave = current
	self.mTotalTime = totalTime
	self.mTargetPosition = position
	if not self.mUpdateMove then
		self.mUpdateMove = function () self:Move() end
		UpdateBeat:Add(self.mUpdateMove)
	end
end

function ObjTransfer:Move()
	local str = ""
	self.mCurrent = self.mCurrent + Time.deltaTime

	if self.mCurrent > self.mTotalTime then
		self:StopMove()	
		MapObjCtrl:RemoveObjects({self.mInfo})
	else
		if GetTime() - self.mInfo.startTime < 2 and self.mInfo.serverData.percent == 100 then	--升起
    		str = "transfor01"
			self.mPosition = self.mFromPosition
		elseif self.mTotalTime - self.mCurrent < 2 then --下降
    		str = "transfor02"
		else 											--移动
    		str = "move1"
			self.mPosition = Vector3.Lerp(self.mFromPosition, self.mTargetPosition,(self.mCurrent-1)/(self.mTotalTime-4))
		end
	end

	if self.mPosition ~= nil then
		local dir = self.mTargetPosition - self.mPosition
		dir.y = 0
		if self.mMoveGo and dir ~= Vector3.zero and self.mCurrent > self.mCurrentSave then
			self.mMoveGo.rotation = Quaternion.LookRotation(dir, Vector3.up)
		end
	end

	if IsNil(self.mGo) then return end--未加载完成
	-----------------线路设置
	local lrFrom = self.mTra:Find("Line/Line_1"):GetComponent("MapLineHelper")
	lrFrom:SetLine(self.mFromPosition,self.mPosition)
	local lrTo = self.mTra:Find("Line/Line_2"):GetComponent("MapLineHelper")
	lrTo:SetLine(self.mFromPosition,self.mTargetPosition)
	-----------------主体移动设置
	self.mMoveGo.position = self.mPosition

	-----------------跟随名字设置
	self.mNameBox.position = self.mPosition

	if self.marchObj then 
		if str ~= self.playAnistr then
			self.playAnistr = str
			self:StartTimer(str)
		end
	end
	
	-----------------初始化开启显示
	if self.mGo.activeSelf ~= true then self.mGo:SetActive(true) end
end

function ObjTransfer:OnClick(keyName)
	if keyName == "BC_F" then
		self.mInfo.clickPart=1
	elseif keyName == "BC_Main" then
		self.mInfo.clickPart=2
	elseif keyName == "BC_T" then
		self.mInfo.clickPart=3
	end
	local dis = Vector3.Distance(self.mPosition,self.mFromPosition)
	if dis<0.1 then 
    	EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
    	return
    end
	--平移摄像机
	local x,y=TerrainCtrl:ConvertToCell(self.mNameBox.position)
    TerrainCtrl:MoveToWorldPosition(self.mNameBox.position)
    EventMgr.SendEvent(ED.MapMoveEvent,{x,y})
    self.mInfo.follow = self.mNameBox
    UIMgr.OpenView("MapFunctionView", self.mInfo)
end

function ObjTransfer:DoHide()
    self:StopTimer()
    self:StopMove()
	if self.marchObj then
		GameObject.Destroy(self.marchObj)
		self.marchObj = nil
	end
end

function ObjTransfer:PlayAni(str)
	local list = self.marchObj:GetComponentsInChildren(typeof(UnityEngine.Animator)):ToTable()
	for k, v in ipairs(list) do
		v:Play(self.playAnistr)
	end
end

-- 定时器
function ObjTransfer:StartTimer(res)
	-- 确保第一次播放动画延迟0.1秒
	if not self.flag then
		self:StopTimer()
	    self.timer = Timer.New(function()
	    	self.flag = true
			self:PlayAni(res)
	    end, 0.1)
	    self.timer:Start()
	else
		self:PlayAni(res)
	end
end

function ObjTransfer:StopTimer()
    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
end

function ObjTransfer:StopMove()
	if self.mUpdateMove then
    	UpdateBeat:Remove(self.mUpdateMove)
		self.mUpdateMove = nil	
	end
	if MapCtrl.mode.CurTypeViewOpen == self.mInfo.key then
		EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
	end
end

