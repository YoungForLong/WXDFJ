-- StartScene

local StartScene=class("StartScene",function()
	return display.newScene("StartScene")
	end)

function StartScene:ctor()
	self:init()
end

function StartScene:init()
	if(self == nil) then
		exit()
	end
		-- 加入缓存
	display.addSpriteFrames("shoot.plist","shoot.png")
	display.addSpriteFrames("shoot_background.plist","shoot_background.png")

	local sharedSpriteFrameCache=cc.SpriteFrameCache:getInstance()
	print(sharedSpriteFrameCache)
end
return StartScene