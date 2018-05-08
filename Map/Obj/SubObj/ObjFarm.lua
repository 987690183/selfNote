ObjFarm = Class(MapObj)

function ObjFarm:DoShow()
end

function ObjFarm:DoLoad() 
    local TxtName = self.mTra:Find("NameBox/Name/Image/Text"):GetComponent("InlineText")
    local ObjName = self.mTra:Find("NameBox/Name/Image/Text").gameObject
    local isBeCover = MapCtrl.IsBeCover(self.mInfo.serverData, self.mInfo.type)
    if isBeCover then
        ObjName:SetActive(false)
    else
        ObjName:SetActive(true)
        L(TxtName, {txt="{1}",param={Res.farm[self.mInfo.serverData.farm.level].showname}})
    end

	self.mMoveGo = self.mTra:Find("GameObject")
	self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图

    self.Num = self.mTra:Find("NameBox/Num").gameObject
    self.Num:SetActive(false)
end

function ObjFarm:OnClick(keyName)
    EventMgr.SendEvent(ED.MapMoveEvent,{self.mInfo.x,self.mInfo.y})
    UIMgr.OpenView("MapFunctionView",self.mInfo)
end

function ObjFarm:DoAddEvent()
    self:AddEvent(ED.MapFarmNum, function(data) self:ShowNum(data) end)
end

function ObjFarm:ShowNum(data)
    if self.mInfo.serverData.gridId == data.gridId then
        self.Num.transform.localPosition = Vector3.zero
        self.Num:SetActive(true)
        L(self.Num,data.recourceNum)
        LH.DoMove(self.Num, 0, Vector3.New(0,0.3,0.3),2, function() self.Num:SetActive(false) end)
    end
end




        -- t.x,t.y,t.z = self.IdToXY(grid.gridId)
        -- t.type = 1
        -- t.key = "1_" .. grid.gridId .. "_" .. grid.laird.playerId
        -- t.path = "Res/Map/Obj/"..Res.sceneObj[t.type].path
        -- grid.laird.skinId = 1
        -- t.modePath = Res.sceneView[grid.laird.skinId*10].path
        -- t.data = grid

-- message S2CPushFarmRecource{// cmd = GAME_PUSH_FARM_RECOURCE
--     required int32 gridId = 1;  //格子ID
--     required int32 recourceNum = 2; //资源数（农田上飘字显示）--银币
-- }