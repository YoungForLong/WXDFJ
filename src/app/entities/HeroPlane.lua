-- HeroPlane

local HeroPlane=class("HeroPlane", function()
	return display.newSprite("#hero1.png")
	end)

function HeroPlane:ctor()
	self:setAnchorPoint(0.5,0)
	self:setPosition(display.cx,0)
	self.speed=200

	-- test
	-- self:blowup()
end

function HeroPlane:move(pox,poy)

	self:stopAllActions()

	local dis=cc.pGetDistance(cc.p(pox,poy),cc.p(self:getPositionX(),self:getPositionY()))

	local timeDelay=dis/self.speed
	
	local angle = cc.pGetAngle(cc.p(pox,poy),cc.p(self:getPositionX(),self:getPositionY()))

	print(angle)

	local moveAction=cc.MoveTo:create(timeDelay,cc.p(pox , poy))

	local angleTo=cc.RotateBy:create(0.1, angle*180)

	local totalAction=cc.Spawn:create(moveAction,angleTo)
	self:runAction(totalAction)

end

function HeroPlane:blowup()
	local frames=display.newFrames("hero_blowup_n%d.png",1,4)
	local animation=display.newAnimation(frames,0.2)
	local animate=cc.Animate:create(animation)
	-- local action=cc.RepeatForever:create(animate)
	self:runAction(animate)

	audio.playMusic("sound/hero_down.mp3")
end



return HeroPlane