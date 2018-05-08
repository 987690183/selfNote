local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapEmptyView = {}
local this = MapEmptyView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(3,self)
	return self
end

function this:SetView(data)
	self.data = data
	local x,y = MapCtrl.GetXYbyID(self.data.Data)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],"")
	L(self.TextList[2],{txt="空地"})
	L(self.TextList[3],{txt="{1},{2}",param={x,y}})

	TerrainCtrl:SetSelectedCell(data.x,data.y)--选中地表
	local t = {}
	for i=1,#self.FucList do
		self.FucList[i].go:SetActive(false)
		if self:CheckBtnState(self.FucList[i]) then
			self.FucList[i].go:SetActive(true)
			table.insert(t,self.FucList[i])
		end
	end
	self.parent:SetBtnPos(t)
end

function this:CheckBtnState(t)
	if t.go.name == "10" then
		return true
	else
		LogError("未判断按钮状态",t.go.name)
		return true
	end
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "迁营" then
		local function moveFunc()
			local _t = {}
			_t.serverData = {}
			_t.goalType = 3
			_t.MoveToType = 2 -- 0出征 1驻守 2迁营
			_t.toId = 0

			local x,y = MapCtrl.GetXYbyID(self.data.Data)
			local t = MapCtrl.XYToId(x,y)
			local z = TerrainCtrl:GetSubIndex(x,y)
			for i=1,#t.ids do
				local tempX,tempY,tempZ = MapCtrl.IdToXY(t.ids[i])
				if tempZ == z then
					_t.serverData.gridId = t.ids[i]
					LogError("_t.serverData.gridId",_t.serverData.gridId)
				end
			end
			UIMgr.OpenView("TroopExpeditionView", _t)
			self.parent:CurClose()
		end

		if UnionCtrl.GetChangeStatus() then
			CommonCtrl.CalCommonViewById(158, nil, {okFunc = moveFunc})
		else
			moveFunc()
		end
	else
		LogError("没有处理该按钮事件："..s)
	end
end

function this:GetName()
	return "空地"
end