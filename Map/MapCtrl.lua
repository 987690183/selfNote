require "Proto/BigMap_pb"
require "Proto/Laird_pb"
local TerrainCtrl = require("Module/Map/Terrain/TerrainCtrl")
MapCtrl = {}
local self = MapCtrl

self.mode = {}
--屏数据列表
self.mode.isInMap = true
self.mode.MapGridData = {}
self.mode.MapMarchData = {}
self.mode.MapTransferData = {}
self.mode.ViewMarchData = {}
self.mode.ViewTransferData = {}
self.mode.EventFrameCount = 0--关闭界面时的帧
self.mode.CurTypeViewOpen = 0--记录当前打开的界面
self.mode.TabDataList = {}

--Start------------------------------------------------------------总数据
function MapCtrl.C2SSendViewCenter(x,y,state)--请求视野中心 state = 0 不做任何处理，1 点击中心
	local t = MapCtrl.XYToId(x,y)
	local sendData = BigMap_pb.C2SSendViewCenter()
	sendData.viewCenterGridId = t.x*1000+t.y
	for i=1,#t.ids do
		table.insert(sendData.dataCenterGridIds, t.ids[i])
	end
    if state == nil then
        sendData.state = 0
    else
        sendData.state = state
    end
	local tnum = ProtocolEnum_pb.GAME_BIGMAP_GETDATA
	local msg = sendData:SerializeToString()
	NetMgr.Instance:SendBinMsgData(tnum, msg)
end

function MapCtrl.UpDateMainViewData()
    if not self.mode.isInMap then return end
    local del = {}
    for k,v in pairs(self.mode.ViewMarchData) do
        self.GetObjMarch(v,del)--删除视图
        self.mode.ViewMarchData[k] = nil
    end
    MapObjCtrl:RemoveObjects(del)
    local add = {}
    local list = TroopsUICtrl.GetLineList()
    for i=1,#list do
        self.GetObjMarch(list[i],add)--新建视图
        self.mode.ViewMarchData[list[i].lineId] = list[i]
    end
    MapObjCtrl:AddObjects(add)

    local del = {}
    for k,v in pairs(self.mode.ViewTransferData) do
        self.GetObjTransfer(v,del)--删除视图
        self.mode.ViewTransferData[k] = nil
    end
    MapObjCtrl:RemoveObjects(del)
    local add = {}
    local list = TroopsUICtrl.GetTransferLineList()
    for i=1,#list do
        self.GetObjTransfer(list[i],add)--新建视图
        self.mode.ViewTransferData[list[i].lineId] = list[i]
    end
    MapObjCtrl:AddObjects(add)
end
function MapCtrl.OnClickViewMarchData(id)
    EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
    for k,v in pairs(self.mode.ViewMarchData) do
        if k == id then
            local t = {}
            self.GetObjMarch(self.mode.ViewMarchData[k],t)
            local obj = MapObjCtrl:GetObj(t[1])
            local monoData = obj:GetMonoData()
            local data = monoData.data
            data[1]()
            MapObjCtrl.mode.CurObj = obj.mGo.transform.parent.parent:Find("NameBox")
            MapObjCtrl.SetShowName(false)
        end
    end
end

function MapCtrl.OnClickViewTransferData(id)
    EventMgr.SendEvent(ED.TerrainCtrlBeginMove,{})
    for k,v in pairs(self.mode.ViewTransferData) do
        if k == id then
            local t = {}
            self.GetObjTransfer(self.mode.ViewTransferData[k],t)
            local obj = MapObjCtrl:GetObj(t[1])
            local monoData = obj:GetMonoData()
            local data = monoData.data
            data[1]()
            MapObjCtrl.mode.CurObj = obj.mGo.transform.parent.parent:Find("NameBox")
            MapObjCtrl.SetShowName(false)
        end
    end
end

function MapCtrl.OnClickGarrison(data)
    local t = {}
    t.type = 11                                                     --类型 type
    t.serverData = data                                             --服务器数据 data
    t.x,t.y,t.z = self.IdToXY(data.gridId)                          --起始点 x,y,z
    t.key = "11_" .. data.gridId .. "_" --.. grid.laird.playerId     --节点命名 key

    UIMgr.OpenView("MapFunctionView",t)
    EventMgr.SendEvent(ED.MapMoveEvent,{t.x,t.y})
end

function MapCtrl.S2CGetMapData(data)
    -- LogError("S2CGetMapData",self.mode.isInMap)
    if not self.mode.isInMap then return end
	local msg = BigMap_pb.S2CGetMapData()
    msg:ParseFromString(data)
    if msg.code == 1 then
    	LogError("视野数据请求失败")
    	return
    end
    LoginCtrl.mode.mapInfo.currPosition = msg.viewCenterGridId--当前视野
    local del = {}
    for k,v in pairs(self.mode.MapGridData) do
    	self.GetObjGrid(v,del)--删除视图
    	self.mode.MapGridData[k] = nil
    end
    for k,v in pairs(self.mode.MapMarchData) do
        if not TroopsUICtrl.IsHaveTroops(v.lineId) then
            self.GetObjMarch(v,del)--删除视图
            self.mode.MapMarchData[k] = nil
        end
    end
    for k,v in pairs(self.mode.MapTransferData) do
        if not TroopsUICtrl.IsHaveTransfer(v.lineId) then
            self.GetObjTransfer(v,del)--删除视图
            self.mode.MapTransferData[k] = nil
        end
    end
    MapObjCtrl:RemoveObjects(del)
    local add = {}
    for i=1,#msg.grid do
    	self.GetObjGrid(msg.grid[i],add)--添加视图
    	self.mode.MapGridData[msg.grid[i].gridId] = msg.grid[i]
    end
    for i=1,#msg.marchLine do
        if not TroopsUICtrl.IsHaveTroops(msg.marchLine[i].lineId) then
            self.GetObjMarch(msg.marchLine[i],add)--添加视图
            self.mode.MapMarchData[msg.marchLine[i].lineId] = msg.marchLine[i]
        end
    end
    for i=1,#msg.transferLine do
        if not TroopsUICtrl.IsHaveTransfer(msg.transferLine[i].lineId) then
            self.GetObjTransfer(msg.transferLine[i],add)--添加视图
            self.mode.MapTransferData[msg.transferLine[i].lineId] = msg.transferLine[i]
        end
    end
    MapObjCtrl:AddObjects(add)
	UIMgr.CloseView("LoginView")
    if msg.state == 1 then
        local clickX,clickY = MapCtrl.GetXYbyID(LoginCtrl.mode.mapInfo.currPosition)
        local id = MapCtrl.XYToId(clickX,clickY)
        TerrainCtrl:MoveToPosition(
            clickX,clickY,
            function()
                TerrainCtrl:OnInputClick(1,TerrainCtrl:CellToScreen(clickX,clickY)) 
            end)
    end
    MapCtrl.UpDateMainViewData()
end
--End------------------------------------------------------------总数据

--Start------------------------------------------------------------格子数据
function MapCtrl.S2CUpdateGridData(data)
    -- LogError("S2CUpdateGridData",self.mode.isInMap)
    if not self.mode.isInMap then return end
	local msg = BigMap_pb.S2CUpdateGridData()
    msg:ParseFromString(data)
    local del = {}
    local add = {}
    for i=1,#msg.grid do
    	if self.mode.MapGridData[msg.grid[i].gridId] ~= nil then
    		self.GetObjGrid(self.mode.MapGridData[msg.grid[i].gridId],del)--删除视图
    	end
    	self.GetObjGrid(msg.grid[i],add)--添加视图
    	self.mode.MapGridData[msg.grid[i].gridId] = msg.grid[i]
    end
    MapObjCtrl:RemoveObjects(del)
    MapObjCtrl:AddObjects(add)
    LoginCtrl.C2SGetLaird() --更新领主信息
    EventMgr.SendEvent(ED.S2CUpdateGridData,msg);
end

function MapCtrl.S2CDeleteGridData(data)
    LogEver(1,"S2CDeleteGridData",self.mode.isInMap)
    if not self.mode.isInMap then return end
	local msg = BigMap_pb.S2CDeleteGridData()
    msg:ParseFromString(data)
    local del = {}
    for i=1,#msg.gridId do
    	if self.mode.MapGridData[msg.gridId[i]] ~= nil then
    		self.GetObjGrid(self.mode.MapGridData[msg.gridId[i]],del)--删除视图
    		self.mode.MapGridData[msg.gridId[i]] = nil
    	end
    end
    MapObjCtrl:RemoveObjects(del)
end
--End------------------------------------------------------------格子数据

--Start------------------------------------------------------------迁营数据
--迁营接口 目标格子key
function MapCtrl.C2SStartTransfer(tData, gridId, goalType, toId)
    -- LogError("C2SStartTransfer",gridId,troopId)
    -- local sendData = BigMap_pb.C2SStartTransfer()
    -- sendData.gridId = gridId
    -- sendData.troopId = troopId
    -- local tnum = ProtocolEnum_pb.GAME_BIGMAP_TRANSFER_START
    -- local msg = sendData:SerializeToString()
    -- NetMgr.Instance:SendBinMsgData(tnum, msg)

    local tsendData = BigMap_pb.C2SStartTransfer()
    tsendData.gridId = gridId
    -- tsendData.st = tData
    tsendData.st.generalId = tData.generalId
    for i=1,#tData.soldiers do
        local tUpSoldierInfo = BigMap_pb.UpSoldierInfo()
        tUpSoldierInfo.soldierId = tData.soldiers[i].soldierId
        tUpSoldierInfo.num = tData.soldiers[i].num
        table.insert(tsendData.st.soldiers, tUpSoldierInfo)
        -- table.insert(tsendData.st.soldiers, tData.soldiers[i])
    end
    -- tsendData.st.staffSkillIds = tData.staffSkillIds
    for i=1,#tData.staffSkillIds do
        table.insert(tsendData.st.staffSkillIds, tData.staffSkillIds[i])
    end

    -- tsendData.goalType = goalType
    local msg = tsendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_BIGMAP_TRANSFER_START, msg)
end

function MapCtrl.S2CStartTransfer(data)
    -- LogError("S2CStartTransfer",self.mode.isInMap)
    if not self.mode.isInMap then return end
    local msg = BigMap_pb.S2CStartTransfer()
    msg:ParseFromString(data)
    if msg.code == 0 then

    else
        LogError("MapCtrl.S2CStartTransfer.code = ",msg.code)
    end
end

function MapCtrl.S2CAddTransferdData(data)
    -- LogError("S2CAddTransferdData",self.mode.isInMap)
    if not self.mode.isInMap then return end
    local msg = BigMap_pb.S2CAddTransferdData()
    msg:ParseFromString(data)
    local add = {}
    for i=1,#msg.lines do
        self.GetObjTransfer(msg.lines[i],add)--添加视图
        self.mode.MapTransferData[msg.lines[i].lineId] = msg.lines[i]
    end
    MapObjCtrl:AddObjects(add)
end

function MapCtrl.S2CDeleteTransferData(data)
    if not self.mode.isInMap then return end
    local msg = BigMap_pb.S2CDeleteTransferData()
    msg:ParseFromString(data)
    local del = {}
    for i=1,#msg.lineIds do
        if self.mode.MapTransferData[msg.lineIds[i]] ~= nil then
            self.GetObjTransfer(self.mode.MapTransferData[msg.lineIds[i]],del)--删除视图
            self.mode.MapTransferData[msg.lineIds[i]] = nil
        end
    end
    MapObjCtrl:RemoveObjects(del)
end

function MapCtrl.C2SCancelTransfer(transferId)
    local sendData = BigMap_pb.C2SCancelTransfer()
    sendData.transferId = transferId
    local tnum = ProtocolEnum_pb.GAME_BIGMAP_TRANSFER_CANCEL
    local msg = sendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(tnum, msg)
end

function MapCtrl.S2CCancelTransfer(data)
    local msg = BigMap_pb.S2CCancelTransfer()
    msg:ParseFromString(data)
    if msg.code == 0 then

    else
        LogError("MapCtrl.S2CCancelTransfer.code = ",msg.code)
    end
end
--End------------------------------------------------------------迁营数据

--Start------------------------------------------------------------行军数据
--攻击接口 目标格子key
-- function MapCtrl.C2SStartTroopMarch(gridId,troopId,goalType)
--     -- LogError("C2SStartTroopMarch",gridId,troopId,goalType)
--     local sendData = BigMap_pb.C2SStartTroopMarch()
--     sendData.gridId = gridId
--     local tId = uint64.new(troopId)
--     sendData.troopId = tostring(tId)
--     sendData.goalType = goalType
--     local tnum = ProtocolEnum_pb.GAME_BIGMAP_MARCH_START
--     local msg = sendData:SerializeToString()
--     NetMgr.Instance:SendBinMsgData(tnum, msg)
-- end

--发起军队行军，cmd=GAME_BIGMAP_MARCH_START
function MapCtrl.C2SStartTroopMarch(tData, gridId, goalType, toId)
    local tsendData = BigMap_pb.C2SStartTroopMarch()
    tsendData.gridId = gridId
    -- tsendData.st = tData
    tsendData.st.generalId = tData.generalId
    for i=1,#tData.soldiers do
        local tUpSoldierInfo = BigMap_pb.UpSoldierInfo()
        tUpSoldierInfo.soldierId = tData.soldiers[i].soldierId
        tUpSoldierInfo.num = tData.soldiers[i].num
        table.insert(tsendData.st.soldiers, tUpSoldierInfo)
        -- table.insert(tsendData.st.soldiers, tData.soldiers[i])
    end
    -- tsendData.st.staffSkillIds = tData.staffSkillIds
    for i=1,#tData.staffSkillIds do
        table.insert(tsendData.st.staffSkillIds, tData.staffSkillIds[i])
    end

    tsendData.goalType = goalType
    local msg = tsendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_BIGMAP_MARCH_START, msg)
end

function MapCtrl.S2CStartTroopMarch(data)
    -- LogError("S2CStartTroopMarch",self.mode.isInMap)
    if not self.mode.isInMap then return end    
    local msg = BigMap_pb.S2CStartTroopMarch()
    msg:ParseFromString(data) 
    if msg.code == 0 then 

    else
        LogError("MapCtrl.S2CStartTroopMarch.code = ",msg.code)
    end
end

function MapCtrl.S2CAddMarchData(data)
    -- LogError("S2CAddMarchData",self.mode.isInMap)
    if not self.mode.isInMap then return end
    local msg = BigMap_pb.S2CAddMarchData()
    msg:ParseFromString(data)
    local add = {}
    for i=1,#msg.lines do
        if not TroopsUICtrl.IsHaveTroops(msg.lines[i].lineId) then
            -- LogError("add msg.lines[i].lineId",msg.lines[i].lineId)
            self.GetObjMarch(msg.lines[i],add)--添加视图
            self.mode.MapMarchData[msg.lines[i].lineId] = msg.lines[i]
        end
    end
    MapObjCtrl:AddObjects(add)
    MapCtrl.UpDateMainViewData()
end

function MapCtrl.S2CDeleteMarchData(data)
    if not self.mode.isInMap then return end
    local msg = BigMap_pb.S2CDeleteMarchData()
    msg:ParseFromString(data)
    local del = {}
    for i=1,#msg.lineIds do
        if not TroopsUICtrl.IsHaveTroops(msg.lineIds[i]) then
            if self.mode.MapMarchData[msg.lineIds[i]] ~= nil then
                -- LogError("add self.mode.MapMarchData[msg.lineIds[i]]",self.mode.MapMarchData[msg.lineIds[i]])
                self.GetObjMarch(self.mode.MapMarchData[msg.lineIds[i]],del)--删除视图
                self.mode.MapMarchData[msg.lineIds[i]] = nil
            end
        end
    end
    MapObjCtrl:RemoveObjects(del)
end
--End------------------------------------------------------------行军数据

--Start------------------------------------------------------------集结进攻
function MapCtrl.C2SStartMarchMulti(gridId,playerIds)
    -- LogError("C2SStartMarchMulti",gridId,playerIds)
    local sendData = BigMap_pb.C2SStartMarchMulti()
    sendData.gridId = gridId

    for i=1,#playerIds do
        table.insert(sendData.playerIds, tostring(uint64.new(playerIds[i])))
        -- LogError("playerIds",playerIds[i])
    end
    -- sendData.playerIds = playerIds

    local tnum = ProtocolEnum_pb.GAME_BIGMAP_MARCH_MULTI
    local msg = sendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(tnum, msg)
end

function MapCtrl.S2CStartMarchMulti(data)
    -- LogError("S2CStartMarchMulti",self.mode.isInMap)
    local msg = BigMap_pb.S2CStartMarchMulti()
    msg:ParseFromString(data)
    if msg.code == 0 then

    else
        LogError("MapCtrl.S2CStartMarchMulti.code = ",msg.code)
    end
end
--End------------------------------------------------------------集结进攻

--Start------------------------------------------------------------驻守
---驻守自己的
function MapCtrl.C2SGarrisonLairdMy(st)--驻守别人的营地,cmd=GAME_GARRISON_LAIRD_MY
    local sendData = Laird_pb.C2SGarrisonLairdMy()
    sendData.st = st --领主id
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_GARRISON_LAIRD_MY, sendData:SerializeToString());
end

function MapCtrl.S2CGarrisonLairdMy(data)
    local msg = Laird_pb.S2CGarrisonLairdMy()
    msg:ParseFromString(data);
    -- EventMgr.SendEvent(ED.S2CGameCityGet,msg); 
    LogWarn("驻守营地 自己= " .. msg.code)
end

---驻守其他人的
function MapCtrl.C2SGarrisonLairdOhter(playerId, st)--驻守别人的营地,cmd=GAME_GARRISON_LAIRD_OTHER
    local sendData = Laird_pb.C2SGarrisonLairdOhter()
    sendData.playerId = playerId --领主id
    sendData.st = st --军队id
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_GARRISON_LAIRD_OTHER, sendData:SerializeToString());
end

function MapCtrl.S2CGarrisonLairdOhter(data)
    local msg = Laird_pb.S2CGarrisonLairdOhter()
    msg:ParseFromString(data);
    -- EventMgr.SendEvent(ED.S2CGameCityGet,msg); 
    LogWarn("驻守营地 别人= " .. msg.code)
end


function MapCtrl.C2SGarrisonLaird(lairdId, troopId)--驻守营地,cmd=GAME_GARRISON_LAIRD
    local sendData = Laird_pb.C2SGarrisonLaird()
    sendData.playerId = lairdId --领主id
    sendData.troopId = troopId --军队id
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_GARRISON_LAIRD, sendData:SerializeToString());
end

function MapCtrl.S2CGarrisonLaird(data)
    local msg = Laird_pb.S2CGarrisonLaird()
    msg:ParseFromString(data);
    -- EventMgr.SendEvent(ED.S2CGameCityGet,msg); 
    LogWarn("驻守营地= " .. msg.code)
end

--------------查看驻军
function MapCtrl.C2SSeeLairdGarrison(tId)--驻守营地,cmd=GAME_SEE_LAIRD_GARRISON
    local sendData = Laird_pb.C2SSeeLairdGarrison()
    sendData.playerId = tId --玩家id
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_SEE_LAIRD_GARRISON, sendData:SerializeToString());
end

function MapCtrl.S2CSeeLairdGarrison(data)
    local msg = Laird_pb.S2CSeeLairdGarrison()
    msg:ParseFromString(data);
    -- EventMgr.SendEvent(ED.S2CGameCityGet,msg)
    LogWarn("驻守队伍= " .. #msg.troops)
    local tD = {}
    tD.type = 1--1、防守列表 2、普通查看军队
    tD.list = msg.troops
    if #msg.troops < 1 then
        CommonCtrl.PopUIInfoData(Res.message[128].word)
        return
    end
    UIMgr.OpenView("TroopDefenseListView", tD)
end

--军队撤守,cmd=GAME_LAIRD_RETREAT_TROOP
function MapCtrl.C2SLairdRetreatTroop(troopId)
    -- body
    local sendData = Laird_pb.C2SLairdRetreatTroop()
    -- sendData.playerId = troopId.player.playerId--LoginCtrl.mode.PlayerBaseInfo.playerId
    sendData.troopId = troopId
    print(troopId.."!!!!!!!!!!!!!")
    local msg = sendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_LAIRD_RETREAT_TROOP, msg)
end

function MapCtrl.S2CLairdRetreatTroop(data)
    local msg = Laird_pb.S2CLairdRetreatTroop()
    msg:ParseFromString(data)

    LogWarn("MapCtrl.S2CLairdRetreatTroop 快速回城 返回= " .. msg.code)
end
--End------------------------------------------------------------驻守

--Start------------------------------------------------------------城市列表
function MapCtrl.C2SGetCity(stateid)
    local sendData = BigMap_pb.C2SGetCity();
    sendData.stateId = stateid;
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_CITY_GET, sendData:SerializeToString());
end

function MapCtrl.S2CGetCity(data)
    local msg = BigMap_pb.S2CGetCity()
    msg:ParseFromString(data);
    EventMgr.SendEvent(ED.S2CGameCityGet,msg);
end
--End------------------------------------------------------------城市列表

--Start------------------------------------------------------------地图操作响应
function MapCtrl.MapMoveEvent(data)
	local x,y = LoginCtrl.GetCurPos()
	local v_1 = Vector2.New(data[1],data[2])
	local v_2 = Vector2.New(x,y)
	if Vector2.Distance(v_1,v_2) > Res.setting.mapDateSize then
		self.C2SSendViewCenter(data[1],data[2])
	end
end
--End------------------------------------------------------------地图操作响应

-------------------------------------------------------------------标记start
--获取标记列表 返回S2CGetTabList cmd = GAME_BIGMAP_TAB_GETTABLIST
function MapCtrl.C2SGetTabList()
    local sendData = BigMap_pb.C2SGetTabList()
    -- sendData.type = data
    local msg = sendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_BIGMAP_TAB_GETTABLIST, msg)
end

function MapCtrl.UpdateMyTabData()
    if self.mode.TabDataList  == nil or LoginCtrl.mode.LairdInfo == nil then
        return
    end
    -- LogError("更新数据====" .. LoginCtrl.mode.LairdInfo.gridId)
    local x1,y1 = MapCtrl.IdToXY(LoginCtrl.mode.LairdInfo.gridId)--GetXYbyID
    if #self.mode.TabDataList < 1 then
        return
    end
    local tD = self.mode.TabDataList[1]
    tD.id = "0"
    tD.type = 1
    tD.name = LoginCtrl.mode.PlayerBaseInfo.playerName
    tD.coordinate = string.format("%u,%u", x1,y1)
end

function MapCtrl.S2CGetTabList(data)
    local msg = BigMap_pb.S2CGetTabList()
    msg:ParseFromString(data)
    -- LogError(" MapCtrl.S2CGetTabList(data) 服务器发送的数据= " .. #msg.tab)

    self.mode.TabDataList = {}
    --第一个是自己的
    local tTab = BigMap_pb.Tab()
    tTab.id = "0"
    tTab.type = 1
    tTab.name = LoginCtrl.mode.PlayerBaseInfo.playerName
    -- tTab.coordinate = string.format("%u,%u", LoginCtrl.mode.LairdInfo.x, LoginCtrl.mode.LairdInfo.y) 
    tTab.coordinate = "1,1"
    
    table.insert(self.mode.TabDataList, tTab)
    -- self.UpdateMyTabData()

    for k,v in ipairs(msg.tab) do
        table.insert(self.mode.TabDataList, v)
    end

    -- LogError("MapCtrl.C2SGetTabList() 获得服务器数据返回====" .. #self.mode.TabDataList)
end

function MapCtrl.S2CUpdateTab(data)
    local msg = BigMap_pb.S2CUpdateTab()
    msg:ParseFromString(data)

    local tIsAdd = true
    for k,v in ipairs(msg.tab) do
        tIsAdd = true
        for i=1,#self.mode.TabDataList do
            local tId1 = tostring(uint64.new(v.id))
            local tId2 = tostring(uint64.new(self.mode.TabDataList[i].id))
            if tId1 == tId2 then
                tIsAdd = false
                self.mode.TabDataList[i] = v
                break
            end 
        end
        if tIsAdd then
            -- LogError("添加了一条消息===" .. v.type)
            table.insert(self.mode.TabDataList,2, v)
        end
    end
    EventMgr.SendEvent(ED.MianViewUpdateTapData)
end

--删除标记 返回S2CDeleteTab cmd =  GAME_BIGMAP_TAB_DELETETAB
function MapCtrl.C2SDeleteTab(tId)
    local sendData = BigMap_pb.C2SDeleteTab()
    sendData.id = tostring(tId)
    local msg = sendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_BIGMAP_TAB_DELETETAB, msg)
end

function MapCtrl.S2CDeleteTab(data)--1成功 0失败
    local msg = BigMap_pb.S2CDeleteTab()
    msg:ParseFromString(data)
    -- LogError("MapCtrl.S2CDeleteTab  id = " .. msg.id .. " , status = " .. msg.status)
    if msg.status == 1 then
        CommonCtrl.PopUIInfoData(Res.message[132].word)--提示删除成功
        for i=1,#self.mode.TabDataList do
            local tId1 = tostring(uint64.new(msg.id))
            local tId2 = tostring(uint64.new(self.mode.TabDataList[i].id))
            if tId1 == tId2 then
                table.remove(self.mode.TabDataList, i)
                break
            end 
        end
    end
    EventMgr.SendEvent(ED.MianViewUpdateTapData)
end

--标记 返回S2CMarkTab cmd = GAME_BIGMAP_TAB_MARKTAB
function MapCtrl.C2SMarkTab(tType,tName,tCoordinate)
    -- LogError("提交标记 --ttype = " .. tType .. " ,name=" .. tName .. ",coordinate = " .. tCoordinate)
    -- print(sendData)
    local tsendData = BigMap_pb.C2SMarkTab()
    tsendData.type = tType --类型  1领主 2建筑物 3野怪 4城市
    tsendData.name = tName --领主名字 当type为1有值
    tsendData.coordinate = tCoordinate---坐标 x,y
    local msg = tsendData:SerializeToString()
    NetMgr.Instance:SendBinMsgData(ProtocolEnum_pb.GAME_BIGMAP_TAB_MARKTAB, msg)
end

function MapCtrl.S2CMarkTab(data)--状态 1成功 0失败
    local msg = BigMap_pb.S2CMarkTab()
    msg:ParseFromString(data)
    -- LogError("MapCtrl.S2CMarkTab   , status = " .. msg.status)
    if msg.status == 1 then
        CommonCtrl.PopUIInfoData(Res.message[131].word)
    else
        CommonCtrl.PopUIInfoData(Res.message[130].word)
    end
end

function MapCtrl.S2CPushFarmRecource(data)
    local msg = BigMap_pb.S2CPushFarmRecource()
    msg:ParseFromString(data)
    EventMgr.SendEvent(ED.MapFarmNum,msg)
end

-------------------------------------------------------------------标记end

--Start------------------------------------------------------------工具方法
function MapCtrl.GetXYbyID(id)--州格子ID转化为州格子XYZ
	local y = id%1000
	local x = ((id - y)%1000000)/1000
    local z = (id - x*1000 - y)/1000000
	return x,y,z
end
function MapCtrl.GetIDbyXY(x,y,z)--州格子XYZ转化为州格子ID（虚空z=0）
    if z == nil then z = 0 end
	return z*1000000+x*1000+y
end
function MapCtrl.IdToXY(id)--州格子ID转化为世界XYZ
	local x,y,z = MapCtrl.GetXYbyID(id)
	local rX = Res.mSubTerrains[z].x + x
	local rY = Res.mSubTerrains[z].y + y
	return rX,rY,z
end
function MapCtrl.XYToId(x,y)--世界XYZ转化州格子ID
	local t={}
	t.x=x
	t.y=y
	t.ids={}
    local z = TerrainCtrl:GetSubIndex(x,y)
	local rX=0
	local rY=0
	for k,v in pairs(Res.mSubTerrains) do
		if x>=v.x and x<=v.x+v.w then
			if y>=v.y and y<=v.y+v.h then
                if z == v.id then
				    rX=x-v.x
				    rY=y-v.y
				    local id=v.id*1000000+rX*1000+rY
				    table.insert(t.ids,id)
                end
			end
		end
	end
	return t
end

--1 领主 2 建筑 3 空地 4 军队 5 怪物 6 关卡 7 城市 8 迁营
function MapCtrl.GetObjGrid(grid,list)
    if grid.laird ~= nil and grid.laird.playerId ~= 0 then -- 领主1
        local t = MapObjCtrl.GetObjLairdInfo(grid)
        table.insert(list,t)
    end
    if grid.build ~= nil and grid.build.type ~= 0 then -- 建筑2
        LogError("无此类型")
    end
    if grid.monster ~= nil and grid.monster.monsterId ~= 0 then --怪物5
        local t = MapObjCtrl.GetObjMonsterInfo(grid)
        table.insert(list,t)
    end
    if grid.city ~= nil and grid.city.cityId ~= 0 then --城市7
        local t = MapObjCtrl.GetObjCityInfo(grid)
        table.insert(list,t)
    end
    if grid.mapReport ~= nil and grid.mapReport.fightResultKey ~= "" then --战报9
        LogEver(1,"有加战报哦！")
        local t = MapObjCtrl.GetObjFightInfo(grid)
        table.insert(list,t)
    end
    if grid.farm ~= nil and grid.farm.level ~= 0 then --农田10
        local t = MapObjCtrl.GetObjFarmInfo(grid)
        table.insert(list,t)
    end
    if grid.boss ~= nil and grid.boss.bossId ~= 0 then -- 精英怪 12
        local t = MapObjCtrl.GetObjWildBossInfo(grid)
        table.insert(list,t)
    end
end
function MapCtrl.GetObjMarch(line,list) -- 军队4
    local t = MapObjCtrl.GetObjMarchInfo(line)
    table.insert(list,t)
end
function MapCtrl.GetObjTransfer(line,list) -- 迁营8
    local t = MapObjCtrl.GetObjTransferInfo(line)
    table.insert(list,t)
end

function MapCtrl.ClearData()
    MapCtrl.mode.MapGridData = {}
    MapCtrl.mode.MapMarchData = {}
    MapCtrl.mode.MapTransferData = {}
    MapCtrl.mode.ViewMarchData = {}
end

function MapCtrl.GoBackLaird()--回到领主位置
    local x,y = MapCtrl.IdToXY(LoginCtrl.mode.LairdInfo.gridId)
    TerrainCtrl:MoveToPosition(x,y)
    EventMgr.SendEvent(ED.MapMoveEvent,{x,y})
end

function MapCtrl.IsNearFrame()
    return self.mode.EventFrameCount + 10 >= Time.frameCount
end

function MapCtrl.SetCurFrame()
    self.mode.EventFrameCount = Time.frameCount
end
function MapCtrl.GetScreenPos(x,y)
    MapCtrl.C2SSendViewCenter(x,y,1)
end
function MapCtrl.GoToMapPos(x,y)
    MapCtrl.C2SSendViewCenter(x,y,1)
end
function MapCtrl.UpDateMapView()
    local id = LoginCtrl.mode.mapInfo.currPosition
    local y = id%1000
    local x = ((id - y)%1000000)/1000
    MapCtrl.C2SSendViewCenter(x,y,0)
end
--End------------------------------------------------------------工具方法
--MapCtrl.C2SSendViewCenter(x,y,state)--请求视野中心 state = 0 不做任何处理，1 点击中心

-- 根据格子唯一的id获取格子数据信息
function MapCtrl.GetGridInfoByGridId(gridId)
    return self.mode.MapGridData[gridId]
end

--[[
    当前格子类型是否被覆盖
    gridInfo: 格子服务端信息
    objType: 场景对象类型
]]
function MapCtrl.IsBeCover(gridInfo, objType)
    local sceneObjResConfig = Res.sceneObj
    local order = sceneObjResConfig[objType].order

    if gridInfo.laird ~= nil and gridInfo.laird.playerId ~= 0 then -- 领主1
        if sceneObjResConfig[1].order > order then
            return true
        end
    end
    if gridInfo.build ~= nil and gridInfo.build.type ~= 0 then -- 建筑2
        if sceneObjResConfig[2].order > order then
            return true
        end
    end
    if gridInfo.monster ~= nil and gridInfo.monster.monsterId ~= 0 then --怪物5
        if sceneObjResConfig[5].order > order then
            return true
        end
    end
    if gridInfo.city ~= nil and gridInfo.city.cityId ~= 0 then --城市7
        if sceneObjResConfig[7].order > order then
            return true
        end
    end
    if gridInfo.mapReport ~= nil and gridInfo.mapReport.fightResultKey ~= "" then --战报9
        if sceneObjResConfig[9].order > order then
            return true
        end
    end
    if gridInfo.farm ~= nil and gridInfo.farm.level ~= 0 then --农田10
        if sceneObjResConfig[10].order > order then
            return true
        end
    end
    if gridInfo.boss ~= nil and gridInfo.boss.bossId ~= 0 then -- 精英怪 12
        if sceneObjResConfig[12].order > order then
            return true
        end
    end
    return false
end