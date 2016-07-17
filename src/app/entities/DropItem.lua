-- drop item

local DropItem=class("DropItem", function(parent)
		return display.newSprite("#ufo2.png")
	end)

function DropItem:ctor(parent)
	self:setPosition(cc.p(math.random(0,display.width),math.random(0,display.height)))
	self:addTo(parent,200)
	self:moveTo(4, self:getPositionX(), -100)

	self:schedule(function ()
		self:myUpdate()
	end, 0.1)
end

function DropItem:myUpdate()
	if cc.rectIntersectsRect(self:getBoundingBox(),self:getParent().plane:getBoundingBox()) then
		self:getParent().bulletNum=true
		self:removeFromParent()
	end
end

return DropItem