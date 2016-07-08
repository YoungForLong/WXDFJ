-- StartScene

local StartScene=class("StartScene",function()
	return display.newScene("StartScene")
	end)

function StartScene:ctor()
	self:init()
	self:setStyle()
end

function StartScene:init()
	
	if self then
		-- 加入缓存
		
		-- img
		display.addSpriteFrames("shoot.plist","shoot.png")
		display.addSpriteFrames("shoot_background.plist","shoot_background.png")

		-- audio
		audio.preloadMusic("sound/bgmusic.mp3")
		audio.preloadMusic("sound/hero_down.mp3")
		audio.preloadMusic("sound/enermy1_down.wav")
		audio.preloadMusic("sound/enermy2_down.wav")
		audio.preloadMusic("sound/enermy3_down.wav")
		audio.preloadMusic("sound/shoot.wav")

		-- data
		if cc.UserDefault:getInstance() then
			cc.UserDefault:getInstance():setStringForKey("initTag", "initialized")
			cc.UserDefault:getInstance():flush()
			print("RunTime : Data Initialized")
		end 

	end
end

function StartScene:setStyle()
	
	-- bg

	local bgSp=cc.Sprite:createWithSpriteFrameName("background.png")
	bgSp:setAnchorPoint(0.5,0)
	bgSp:setPosition(display.cx,0)
	self:addChild(bgSp)

	-- item

	local startBtn=cc.cc.Sprite:createWithSpriteFrameName("game_resume_nor.png")
	self:addChild(startBtn,10)

end


return StartScene