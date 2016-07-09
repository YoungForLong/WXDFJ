-- Bullet

local Bullet=class("Bullet", function(filename,poX,poY,style,parentNode)

	local bullet= display.newSprite(filename)
	
	return bullet
end)


function Bullet:ctor(filename,poX,poY,style,parentNode)

	self.moveType=style
	self:setAnchorPoint(0.5,0)
	self:setPosition(cc.p(poX,poY))

	parentNode:addChild(self)

	self.speed=5

	self:schedule(function()
		self:move()
		end, 0.01)
end

function Bullet:move()
	
	local positionX=self:getPositionX()
	local positionY=self:getPositionY()

	if positionY>(2*display.cy) then
		self:removeFromParent()
		return
	end

	if positionX>(2*display.cx) then
		self:removeFromParent()
		return
	end

	if positionX<0 then
		self:removeFromParent()
		return
	end

	-- update

	if self.moveType==1 then
		self:setPosition(cc.p(positionX,positionY+self.speed))
		elseif self.moveType==2 then
			self:setPosition(cc.p(positionX-self.speed/2,positionY+self.speed*0.8660))
			elseif self.moveType==3 then
				self:setPosition(cc.p(positionX+self.speed/2,positionY+self.speed*0.8660))
				end
end

return Bullet