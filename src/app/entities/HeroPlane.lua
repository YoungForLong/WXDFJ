-- HeroPlane

local HeroPlane=class("HeroPlane", function()
	return display.newSprite("#hero1.png")
	end)

function HeroPlane:ctor()
	self:setAnchorPoint(0.5,0)
	self:setPosition(display.cx,0)
	self.speed=3
	self.HP=20
	-- test
	-- self:blowup()
end

function HeroPlane:move(pox,poy)

	self:stopAllActions()

	local dis=cc.pGetDistance(cc.p(pox,poy),cc.p(self:getPositionX(),self:getPositionY()))

	local timeDelay=dis/self.speed/global_fps
	
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


function HeroPlane:getNewBox()
	local originBox=self:getBoundingBox()

	originBox.x=originBox.x+10
	originBox.y=originBox.y +10
	originBox.width=originBox.width-20
	originBox.height=originBox.height-20

	return originBox
end

function HeroPlane:blowup()
	audio.playMusic("src/hero_down.mp3",false)

	local frames=display.newFrames("hero_blowup_n%d.png",1,4)
	local animation=display.newAnimation(frames,0.2)
	local animate=cc.Animate:create(animation)
	-- local action=cc.RepeatForever:create(animate)
	self:runAction(animate)

	-- audio.playMusic("sound/hero_down.mp3")
end



return HeroPlane