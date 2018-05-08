local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapMonsterView = {}
local this = MapMonsterView
function this:Init(go,parent)
	go:SetActive(false)
	self.gameObject = go
	self.parent = parent
	self.data = nil
	self.TextList,self.BtnList,self.FucList=self.parent:InitSubView(5,self)
	return self
end

function this:SetView(data)
	this.data = data
	local x, y = MapCtrl.IdToXY(this.data.serverData.gridId)
	local v = TerrainCtrl:ConvertToWorld(x,y)
	LH.DoFollowPoint(true,self.gameObject,v)
	L(self.TextList[1],"")
	L(self.TextList[2],{txt=Res.wildMonster[this.data.serverData.monster.level].showname})
	L(self.TextList[3],{txt="{1},{2}",param={x,y}})
	
	local t = {}
	for i=1,#self.FucList do
		self.FucList[i].go:SetActive(false)
		if self:CheckBtnState(self.FucList[i]) then
			self.FucList[i].go:SetActive(true)
			table.insert(t,self.FucList[i])
		end
	end
	self.parent:SetBtnPos(t)

	local name = Res.wildMonster[this.data.serverData.monster.level].showname
	local lv = this.data.serverData.monster.level
	-- L(Find(self.gameObject,"Tips/Image/Text"),{txt="<C_11>{1}</C>\n<C_56>守军强度：</C><C_57>{2}</C>\n<C_56>",param={name,lv}})
	L(Find(self.gameObject,"Tips/Image/Text"),{txt="<C_11>{1}</C>\n<C_56>守军强度：</C><C_57>{2}</C>",param={name,lv}})
end

function this:CheckBtnState(t)
	if t.go.name == "1" then
		return true
	elseif t.go.name == "3" then
		return true
	else
		LogError("未判断按钮状态",t.go.name)
		return true
	end
end

function this:OnClickFucBtn(t)
	local s = t.data.name
	if s == "攻打" then
		-- this.data.goalType = 5
		this.data.goalType = this.data.type
		-- LogError("怪物攻打==" .. this.data.goalType)
		this.data.MoveToType = 0 -- 0出征 1驻守
		this.data.toId = 0
		this.data.stype = 1
		UIMgr.OpenView("TroopExpeditionView", this.data)
		self.parent:CurClose()
	elseif s == "侦查" then
		-- LogError("驻守==领主===")
		DetectionCtrl.C2SPVESurvey(this.data.serverData.gridId)
		self.parent:CurClose()
	else
		LogError("没有处理该按钮事件："..s)
	end
end
function this:GetName()
	return Res.wildMonster[this.data.serverData.monster.level].showname
end