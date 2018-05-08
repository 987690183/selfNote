ObjCity = Class(MapObj)

function ObjCity:DoShow() end

function ObjCity:DoLoad() 
	L(self.mTra:Find("NameBox/Name/Image/Text"),Res.city[self.mInfo.serverData.city.cityId].cityname)
	self.mMoveGo = self.mTra:Find("GameObject")
	self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图
end

function ObjCity:OnClick(keyName)
    EventMgr.SendEvent(ED.MapMoveEvent,{self.mInfo.x,self.mInfo.y})
    UIMgr.OpenView("MapFunctionView",self.mInfo)
end