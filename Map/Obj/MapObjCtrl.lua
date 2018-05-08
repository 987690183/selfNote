require("Module/Map/Obj/MapObj")
require("Module/Map/Obj/SubObj/ObjLaird")
require("Module/Map/Obj/SubObj/ObjMarch")
require("Module/Map/Obj/SubObj/ObjMonster")
require("Module/Map/Obj/SubObj/ObjTransfer")
require("Module/Map/Obj/SubObj/ObjCity")
require("Module/Map/Obj/SubObj/ObjFight")
require("Module/Map/Obj/SubObj/ObjFarm")
require("Module/Map/Obj/SubObj/ObjWildBoss")
require("Module/Map/Obj/ObjAI/ObjAIMgr")


local TerrainCameraCtrl = require("Module/Map/Terrain/TerrainCameraCtrl")
local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")

MapObjCtrl = {}
local self = MapObjCtrl
self.mode = {}
self.mode.objList = {}--物件列表
-- 地图类型物件列表
self.mode.objTypeList = {}
self.mode.curObj = nil--当前物件

self.mode.objPointParent = nil--物件节点
self.mode.objPoint={}

local ObjNameList = {
    "ObjLaird",--1领主
    "No",--2建筑
    "No",--3空地
    "ObjMarch",--4军队
    "ObjMonster",--5怪物 
    "No",--6关卡
    "ObjCity",--7城市
    "ObjTransfer",--8迁营
    "ObjFight",--9战报
    "ObjFarm",--10农田
    "No",
    "ObjWildBoss",--12怪物 
}

function MapObjCtrl:AddObjects(list)--添加物件
	for i,info in ipairs(list) do
		TerrainCtrl:HideObjects(info.x,info.y)--隐藏装饰物
		local key = info.x.."_"..info.y.."_"..info.key
		if self.mode.objList[key] ~= nil then
			MapObjCtrl:RemoveObjects({info})
			LogError("添加的物件还没删除")
		end
    	local view = loadstring("return "..ObjNameList[info.type]..".new()")()
		self.mode.objList[key] = view
        self:SaveObjByType(info.type, key, view)
		view:Show(info)
		if info.type == 1 then
			local v = {x=info.x,y=info.y,index=0}
			TerrainCtrl:SetMapCell({v})
		end
	end
end

function MapObjCtrl:RemoveObjects(list)
	for i,info in ipairs(list) do
		TerrainCtrl:ShowObjects(info.x,info.y)--显示装饰物
		local key = info.x.."_"..info.y.."_"..info.key
		local view = self.mode.objList[key]
		if view then
			view:Hide()
			self.mode.objList[key] = nil
            self:RemoveObjByType(info.type, key)
			if info.type == 1 then
				local v = {x=info.x,y=info.y}
				TerrainCtrl:ResetMapCell({v})
			end
		else
			LogError("找不到对应key:",key)
		end
	end
end

-- 分类保存场景对象
function MapObjCtrl:SaveObjByType(type, key, view)
    if not self.mode.objTypeList[type] then
        self.mode.objTypeList[type] = {}
    end
    if self.mode.objTypeList[type][key] then
        LogError("objTypeList 对应数据还没删除", type, key)
    end
    self.mode.objTypeList[type][key] = view
end
-- 根据场景类型移除对象(只是引用移除，正在移除还是在 RemoveObjects 函数执行)
function MapObjCtrl:RemoveObjByType(type, key)
    if not self.mode.objTypeList[type] or not self.mode.objTypeList[type][key] then 
        return 
    end
    self.mode.objTypeList[type][key] = nil
end
-- 根据类型获取场景对象列表
function MapObjCtrl:GetObjByType(type)
    if not self.mode.objTypeList[type] then
        return {}
    end
    return self.mode.objTypeList[type]
end

function MapObjCtrl:GetObj(info)
	local key = info.x.."_"..info.y.."_"..info.key
	local view = self.mode.objList[key]
	if view then
		return view
	else
		LogError("找不到对应key:",key)
		return nil
	end
end

function MapObjCtrl.SetShowName(b)
	if not IsNil(self.mode.curObj) then
		self.mode.curObj.gameObject:SetActive(b)
	end
end
function MapObjCtrl.Dispose()--销毁控制器
	for k,v in pairs(self.mode.objList) do
		v:Dispose()
	end
	self.mode.curObj = nil
	self.mode.objList = {}
	self.mode.objPoint = {}
    self.mode.objTypeList = {}
end
function MapObjCtrl.GetObjPoint(type)--获取物件挂载节点
	if IsNil(self.mode.objPointParent) then
		self.mode.objPointParent = GameObject.New("SceneObj")
	end
	if IsNil(self.mode.objPoint[type]) then
		self.mode.objPoint[type] = GameObject.New(type.."")
		self.mode.objPoint[type].transform:SetParent(self.mode.objPointParent.transform)
	end
	return self.mode.objPoint[type]
end

function MapObjCtrl.GetWildBossModePath(level)
    for k, vo in pairs(Res.wildBoss) do 
        if vo.resLv == level then
            return vo
        end
    end
    LogError("找不到对应等级的精英怪配置", level)
end

function MapObjCtrl.GetMonsterModePath(level)
    for k, vo in pairs(Res.wildMonster) do 
        if vo.resLv == level then
            return vo
        end
    end
    LogError("找不到对应等级的怪配置", level)
end

local objPath = "Res/Map/Obj/"
function MapObjCtrl.GetObjLairdInfo(grid)--1领主
	local t = {}
	t.type = 1                                                      	--类型 type
    t.serverData = grid                                             	--服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(grid.gridId)                          	--起始点 x,y,z
    t.key = t.type.."_"..grid.laird.playerId    						--节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path              			--总视图路径 path
    t.modePath = Res.sceneView[1*10].path           					--显示视图路径 modePath
    --领主特有数据	
    return t
end
function MapObjCtrl.GetObjMarchInfo(line)--4行军
	local t = {}
    t.type = 4                                                          --类型 type
    t.serverData = line                                                 --服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(line.resGridId)                           --起始点 x,y,z
    t.key = t.type.."_"..line.lineId		    						--节点命名 key
    t.path = "Res/Map/Obj/"..Res.sceneObj[t.type].path                  --总视图路径 path
    --行军特有数据	
    t.tx,t.ty,t.tz = MapCtrl.IdToXY(line.tarGridId)                        --目标点 tx,ty,tz
    return t
end
function MapObjCtrl.GetObjMonsterInfo(grid)--5怪物
    local t = {}
    t.type = 5                                                      	--类型 type
    t.serverData = grid                                             	--服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(grid.gridId)                          	--起始点 x,y,z
    t.key = t.type.."_"..grid.monster.monsterId 						--节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path    		          		--总视图路径 path
    t.modePath = MapObjCtrl.GetMonsterModePath(grid.monster.level).model--显示视图路径 modePath
    --怪物特有数据
    return t
end
function MapObjCtrl.GetObjCityInfo(grid)--7城市
    local t = {}
    t.type = 7                                                      	--类型 type
    t.serverData = grid                                             	--服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(grid.gridId)                          	--起始点 x,y,z
    t.key = t.type.."_"..grid.city.cityId       						--节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path              			--总视图路径 path
    t.modePath = Res.city[grid.city.cityId].path 						--显示视图路径 modePath
    --城市特有数据
    return t
end
function MapObjCtrl.GetObjTransferInfo(line)--8迁营
    local t = {}
    t.type = 8                                                          --类型 type
    t.serverData = line                                                 --服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(line.resGridId)                           --起始点 x,y,z
    t.key = t.type.."_"..line.lineId		    						--节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path    		          		--总视图路径 path
    --迁营特有数据
    t.tx,t.ty,t.tz = MapCtrl.IdToXY(line.tarGridId)                     --目标点 tx,ty,tz
    t.modePathT = Res.sceneView[1*10+2].path            				--目标点视图路径 modePathT
    t.modePathF = Res.sceneView[1*10+1].path                            --起点视图路径 modePathF
    return t
end
function MapObjCtrl.GetObjFightInfo(grid)--9战报
    local t = {}
    t.type = 9                                                      	--类型 type
    t.serverData = grid                                                 --服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(grid.gridId)                          	--起始点 x,y,z
    t.key = t.type.."_"..grid.mapReport.fightResultKey					--节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path              			--总视图路径 path
    t.modePath = "Res/Effect/OtherEffect/zhandou__biaoxian_fx"      	--显示视图路径 modePath
    --战报特有数据
    t.targetPath = ""													--攻击目标在原地创建一份 targetPath
    local laird = t.serverData.mapReport.laird
    if laird ~= nil and laird.playerId ~= 0 then 
    	t.targetPath = Res.sceneView[1*10].path 
    end
    local monster = t.serverData.mapReport.monster
    if monster ~= nil and monster.monsterId ~= 0 then 
    	t.targetPath = MapObjCtrl.GetMonsterModePath(monster.level).model
    end
    local city = t.serverData.mapReport.city
    if city ~= nil and city.cityId ~= 0 then 
    	t.targetPath = Res.city[city.cityId].path   
    end
    local boss = t.serverData.mapReport.boss
    if boss ~= nil and boss.bossId ~= 0 then
        t.targetPath = MapObjCtrl.GetWildBossModePath(boss.level).model  
    end
    return t
end
function MapObjCtrl.GetObjFarmInfo(grid)--10农田
    local t = {}
    t.type = 10                                                         --类型 type
    t.serverData = grid                                                 --服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(grid.gridId)                           --起始点 x,y,z
    t.key = t.type.."_"..grid.gridId                                    --节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path                         --总视图路径 path
    t.modePath = Res.farm[grid.farm.level].model                        --显示视图路径 modePath
    --农田特有数据
    -- LogError("~",t.x,t.y)
    return t
end

function MapObjCtrl.GetObjWildBossInfo(grid)--12 精英boss
    local t = {}
    t.type = 12                                                         --类型 type
    t.serverData = grid                                                 --服务器数据 serverData
    t.x,t.y,t.z = MapCtrl.IdToXY(grid.gridId)                           --起始点 x,y,z
    t.key = t.type.."_"..grid.boss.bossId                               --节点命名 key
    t.path = objPath..Res.sceneObj[t.type].path                         --总视图路径 path
    t.modePath = MapObjCtrl.GetWildBossModePath(grid.boss.level).model  --显示视图路径 modePath
    return t
end
