-- HeroPlane

local HeroPlane=class("HeroPlane", function()
	return display.newSprite("#hero1.png")
	end)

function HeroPlane:ctor()
	self:setAnchorPoint(0.5,0)
	self:setPosition(display.cx,0)
	self.speed=200

end

function HeroPlane:move(pox,poy)

	self:stopAllActions()

	local dis=cc.pGetDistance(cc.p(pox,poy),cc.p(self:getPositionX(),self:getPositionY()))

	local timeDelay=dis/self.speed
	
	local moveAction=cc.MoveTo:create(timeDelay,cc.p(pox , poy))

	self:runAction(moveAction)

end



return HeroPlane