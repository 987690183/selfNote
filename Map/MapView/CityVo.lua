local CityVo = Class();

--message City{		//城市
--	required int32 gridId = 1;					//格子信息
--	required int32 cityId = 2;					//格子信息
--	required int32 status = 3;					//城市状态，0：无人占领，1：被占领
--	required int32 guildId = 4;					//占领的帮派ID
--	required string guildName = 5;					//占领的帮派名字
--}

local mCities = nil;


function CityVo:ctor(id)
	self.mData = Res.city[id];
	self.mStatus = 0;
	self.mGuildName = "";
end

function CityVo:GetCityConfig(id)
	if not mCities then
		mCities = {};
		for k,v in pairs(Res.mCityList) do
			mCities[v.id] = v;
		end
	end
	return mCities[id];
end

function CityVo:GetName()
	return self.mData.cityname;
end

function CityVo:GetCityType()
	return self.mData.citytype;
end

function CityVo:GetLevel()
	return self.mData.resLv;
end

function CityVo:RecData(pbCity)
	self.mStatus = pbCity.status;
	self.mGuildName = pbCity.guildName;
end

function CityVo:GetLocation()
	local location = self:GetCityConfig(self.mData.id);
	return location.x,location.y;
end

function CityVo:GetMapTexturePath()
	return "Res/UI/BigTexture/xiaoditu/Map_7";--..self.mData.stateid;
end

function CityVo:GetMapOffset()
	local bounds = Res.mSubTerrains[self.mData.stateid];
	return bounds.x,bounds.y;
end

function CityVo:GetMapSize()
	local bounds = Res.mSubTerrains[self.mData.stateid];
	return bounds.w,bounds.h;
end

return CityVo;