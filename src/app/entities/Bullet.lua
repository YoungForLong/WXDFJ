
-- Bullet


local Bullet=class("Bullet", function(filename,poX,poY,style,parentNode)

	local bullet= display.newSprite(filename)
	
	return bullet
end)


function Bullet:ctor(filename,poX,poY,style,parentNode)

	self.moveType=style
	self:setAnchorPoint(0.5,0)
	self:setPosition(cc.p(poX,poY))

	parentNode:addChild(self,2)

	self.speed=5

end

function Bullet:move()
	
	local positionX=self:getPositionX()
	local positionY=self:getPositionY()

	-- update

	if self.moveType==1 then
		self:setPosition(cc.p(positionX,positionY+self.speed))
		elseif self.moveType==2 then
			self:setPosition(cc.p(positionX-self.speed/2,positionY+self.speed*0.8660))
			elseif self.moveType==3 then
				self:setPosition(cc.p(positionX+self.speed/2,positionY+self.speed*0.8660))
				end
end

function Bullet:moveByAngle(angle)
	local positionX=self:getPositionX()
	local positionY=self:getPositionY()

	local dX=self.speed*math.sin(angle)	
	local dY=self.speed*math.cos(angle)

	self:setPosition(cc.p(positionX+dX,positionY+dY))
end

return Bullet