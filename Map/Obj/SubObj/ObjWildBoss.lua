
--[[
	地图野外boss
]]

ObjWildBoss = Class(MapObj)

function ObjWildBoss:DoShow() end

function ObjWildBoss:DoLoad() 
	L(self.mTra:Find("NameBox/Name/Image/Text"),self.mInfo.serverData.boss.level.."野外boss")
	self.mMoveGo = self.mTra:Find("GameObject")
	self:LoadView(self.mMoveGo,self.mInfo.modePath)--加载主视图
end

function ObjWildBoss:OnClick(keyName)
    EventMgr.SendEvent(ED.MapMoveEvent,{self.mInfo.x,self.mInfo.y})
    UIMgr.OpenView("MapFunctionView",self.mInfo)
end