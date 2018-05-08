MapObj=Class()

local PoolKey = "MapObj"
local PoolManager = require("Module/Mgr/PoolManager")
local TerrainCtrl = DoFileUtil.DoFile("Module/Map/Terrain/TerrainCtrl")

function MapObj:ctor()
	self.mInfo = nil--数据
	self.mTra = nil--主Tra
	self.mGo = nil--主Go
	self.list = {}--动态加载列表
	self.state = true--true使用中，false已销毁
	self.EventDic={}
	self:DoInit()--初始化
	self:DoAddEvent()--时间监听
end

function MapObj:Show(info)
	self.state = true
	self.mInfo = info
	self:DoShow()
	PoolManager:Get(PoolKey,self.mInfo.path,function(go) self:OnLoadCompleted(go) end)--加载
end

function MapObj:OnLoadCompleted(go)
	go:SetActive(false)
	self.mGo = go
	self.mTra = go.transform
	self.mGo.name = self.mInfo.key--名字设置为key方便调试
	self.mTra:SetParent(MapObjCtrl.GetObjPoint(self.mInfo.type).transform)--节点分类收纳
	self.mTra.position = TerrainCtrl:ConvertToWorld(self.mInfo.x,self.mInfo.y)
	self.mTra.localScale = Vector3.one

    local BClist = self.mGo:GetComponentsInChildren(typeof(UnityEngine.BoxCollider),true):ToTable()
    for i,v in ipairs(BClist) do
		LH.AddMonoData(v.gameObject,{function() self:OnClick(v.gameObject.name) end})
    end
	go:SetActive(true)	
	self:DoLoad()
	if not self.state then
		self:Hide()
	end
	self:AddAllEvent()
end
function MapObj:GetMonoData()
    local BClist = self.mGo:GetComponentsInChildren(typeof(MonoData),true):ToTable()
    for i,v in ipairs(BClist) do
		return v
    end
end
function MapObj:Dispose()
	self:Hide()
end

function MapObj:Hide()
	self.state = false
	if not IsNil(self.mGo) then
		for i=1,#self.list do
			GameObject.Destroy(self.list[i])
		end
		self.mGo:SetActive(false)
		self.mGo.name = "InPool"
		PoolManager:Put(PoolKey,self.mInfo.path,self.mGo)
		self.mTra = nil--主Tra
		self.mGo = nil--主Go
	end
	self:RemoveAllEvent()
	self:DoHide()
end

function MapObj:LoadView(go,path,fuc)
	ResMgr.Instance:LoadAsset(path,
	function(res)
		local temp = UnityEngine.GameObject.Instantiate(res)
		table.insert(self.list,temp)
		temp.name = "View"
    	temp.transform:SetParent(go.transform)
    	temp.transform.localScale = Vector3.one
    	temp.transform.localPosition = Vector3.zero
    	if fuc ~= nil then fuc(temp) end
	end)
end

function MapObj:AddEvent(key, action)
	if (self.EventDic[key] == nil and type(action) == "function") then
		self.EventDic[key] = action
	end
end

function MapObj:AddAllEvent()
	for k,v in pairs(self.EventDic) do
		EventMgr.AddEvent(k,v,self.ViewName)
	end
end

function MapObj:RemoveEvent(key, action)
	EventMgr.RemoveEvent(key,action,self.ViewName)
end

function MapObj:RemoveAllEvent()
	for k,v in pairs(self.EventDic) do
		EventMgr.RemoveEvent(k,v,self.ViewName)
	end
end

function MapObj:DoInit() end--子类实现显示方法
function MapObj:DoAddEvent() end--子类实现显示方法
function MapObj:DoShow() end--子类实现显示方法
function MapObj:DoLoad() end--子类实现加载完成
function MapObj:DoHide() end--子类实现隐藏方法
function MapObj:OnClick(keyName) end