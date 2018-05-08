local WorldModel = Class();
local SortTable = require "Framework/Base/SortTable"
local CityVo = require("Module/Map/MapView/CityVo")
local ipairs = ipairs;
local mStateDataSource = SortTable.new();
local mCityDataSources = {};
local mCities = {};

function WorldModel:ctor()
	self:InitDataSources();
	self:AddNetListeners();
end

function WorldModel:AddNetListeners()
	EventMgr.AddEvent(ED.S2CGameCityGet, function (msg) self:S2C_GAME_CITY_GET(msg); end)
end

function WorldModel:GetState(id)
	return mStateDataSource:GetValue(id);
end

function WorldModel:GetCity(id)
	local city = mCities[id];
	if not city then
		city = CityVo.new(id);
		mCities[id] = city;
	end
	return city;
end

function WorldModel:GetStateDataSource()
	return mStateDataSource;
end

function WorldModel:GetCityDataSource(state)
	local dataSource = mCityDataSources[state];
	if not dataSource then
		dataSource = SortTable.new();
		mCityDataSources[state] = dataSource;
	end
	return dataSource;
end

function WorldModel:InitDataSources()
	local items = Res.city;
	for i,v in pairs(items) do
		local city = self:GetCity(v.id);
		if v.citytype == 3 then
			mStateDataSource:AddOrUpdate(v.stateid,city);
		end
		self:GetCityDataSource(v.stateid):AddOrUpdate(v.id,city);
	end
end

function WorldModel:S2C_GAME_CITY_GET(msg)
	for i,v in ipairs(msg.citys) do
		local city = self:GetCity(v.cityId);
		city:RecData(v);
		self:GetCityDataSource(city.mData.stateid):AddOrUpdate(v.cityId,city);
	end
end

return WorldModel.new();