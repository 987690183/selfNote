ObjLaird = Class(MapObj)

local TerrainCtrl = DoFileUtil.DoFile("Module/Map/Terrain/TerrainCtrl")

function ObjLaird:DoShow() end

function ObjLaird:DoAddEvent()
    -- 绑定事件
    self:AddEvent(ED.TransferStatus, function(...) self:TransferStatusHandler(...) end)
end

function ObjLaird:DoLoad() 
    local b1 = LoginCtrl.IsOwnerPlayer(self.mInfo.serverData.laird.playerId)
    local b2 = UnionCtrl.IsMyUnion(self.mInfo.serverData.laird.guildId)
    local colorId = b1 and 10 or (b2 and 55 or 61)
    L(self.mTra:Find("NameBox/Name/Image/Text"),{txt="<C_{2}>{1}</C>",param={self.mInfo.serverData.laird.playerName,colorId}})
    L(self.mTra:Find("NameBox/Name/Image_1/Text"),self.mInfo.serverData.laird.guildName)
	self.mMoveGo = self.mTra:Find("GameObject")
    self.mMoveGo.gameObject:SetActive(true)
	self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图
    self.mPosition = TerrainCtrl:ConvertToWorld(self.mInfo.x, self.mInfo.y)
end

function ObjLaird:OnClick(keyName)
    EventMgr.SendEvent(ED.MapMoveEvent,{self.mInfo.x,self.mInfo.y})
    UIMgr.OpenView("MapFunctionView",self.mInfo)
end

function ObjLaird:TransferStatusHandler(fromPos, endPos, visible)
    if self.mPosition == fromPos or self.mPosition == endPos then
        self.mMoveGo.gameObject:SetActive(visible)
    end
end



        -- t.x,t.y,t.z = self.IdToXY(grid.gridId)
        -- t.type = 1
        -- t.key = "1_" .. grid.gridId .. "_" .. grid.laird.playerId
        -- t.path = "Res/Map/Obj/"..Res.sceneObj[t.type].path
        -- grid.laird.skinId = 1
        -- t.modePath = Res.sceneView[grid.laird.skinId*10].path
        -- t.data = grid