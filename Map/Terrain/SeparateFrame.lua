local Queue = require "Framework/Base/Queue"
local SeparateFrame = Class();
local math = math;

function SeparateFrame:ctor(frameCount)
	self.mActions = Queue.new();
	self.mFrameCount = frameCount;
end

function SeparateFrame:Update()
	local actions = self.mActions;
	local frameCount = math.min(self.mFrameCount,actions.mCount);
	if frameCount > 0 then
		for i = 1,frameCount do
			actions:Dequeue()();
		end
	end
	if actions.mCount == 0 then
		self:SetEnable(false);
	end
end

function SeparateFrame:AddAction(action)
	self.mActions:Enqueue(action);
	self:SetEnable(true);
end

function SeparateFrame:SetEnable(enable)
	if enable then
		if not self.mUpdate then
			self.mUpdate = function ()self:Update();end
			UpdateBeat:Add(self.mUpdate);
		end
	else
		if self.mUpdate then
			UpdateBeat:Remove(mUpdate);
			self.mUpdate = nil;
		end
	end
end

function SeparateFrame:Dispose()
	self.mActions:Clear();
end

return SeparateFrame;