-- HeroPlane

local HeroPlane=class("HeroPlane", function()
	return display.newSprite("#hero1.png")
	end)

function HeroPlane:ctor()
	self:setAnchorPoint(0.5,0)
	self:setPosition(display.cx,0)
	self.speed=200
	self.HP=100
	-- test
	-- self:blowup()
end

function HeroPlane:move(pox,poy)

	self:stopAllActions()

	local dis=cc.pGetDistance(cc.p(pox,poy),cc.p(self:getPositionX(),self:getPositionY()))

	local timeDelay=dis/self.speed
	
	local moveAction=cc.MoveTo:create(timeDelay,cc.p(pox , poy))

-- angle test
	-- local tan=(pox-self:getPositionX())/(poy-self:getPositionY())

	-- local angle = math.atan(tan)*180

	-- local angleTo=cc.RotateBy:create(2*timeDelay/3, angle)
	-- local angleBack=cc.RotateBy:create(timeDelay/3, -angle)
	-- local angleRevert=cc.Sequence:create(angleTo,angleBack)

	-- local totalAction=cc.Spawn:create(angleRevert,moveAction)
	self:runAction(moveAction)

end

function HeroPlane:blowup()
	local frames=display.newFrames("hero_blowup_n%d.png",1,4)
	local animation=display.newAnimation(frames,0.2)
	local animate=cc.Animate:create(animation)
	-- local action=cc.RepeatForever:create(animate)
	self:runAction(animate)

	-- audio.playMusic("sound/hero_down.mp3")
end



return HeroPlane