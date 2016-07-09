-- StartScene

local StartScene=class("StartScene",function()
	return display.newScene("StartScene")
	end)

function StartScene:ctor()
	-- init list
	self.count=1

	-- init funcs
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

	local bgSp=cc.DrawNode:create()

	bgSp:drawPolygon({cc.p(0,0),
		cc.p(2*display.cx,0),
		cc.p(2*display.cx,2*display.cy),
		cc.p(0,2*display.cy)})

	self:addChild(bgSp)

	-- btn

	local startBtn=cc.Sprite:createWithSpriteFrameName("game_resume_nor.png")
	startBtn:setPosition(display.cx,display.cy)
	startBtn:setScale(4)
	self:addChild(startBtn,10)

	startBtn:setTouchEnabled(true)
	startBtn:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
	startBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
		if event.name=="began" then
			startBtn:setSpriteFrame("game_resume_pressed.png")
			return true
		elseif event.name=="ended" then
			startBtn:setSpriteFrame("game_resume_nor.png")

			display.replaceScene(require("app.scenes.MainScene").new())
			end
		end)

end

function StartScene:onEnter()
	audio.playSound("sound/bgmusic.mp3",true)
end

return StartScene