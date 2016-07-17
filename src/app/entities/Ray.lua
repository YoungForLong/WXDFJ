-- Ray

local Ray={
	owner=nil
}

function Ray:new()
	local p={}
	setmetatable(p,self)
	self.__index=self
	return p
end

function Ray:init(pox,poy)
	self.circleTable={}
	self.rectTable={}

	self.mainCircle=display.newSprite("circle.png")
	self.mainCircle:setScale(0.01)
	self.mainCircle:setPosition(cc.p(pox,poy))

	for i=0,10 do
		local circle=display.newSprite("circle.png")
		circle:setScale(0.01*math.random(1,10))
		circle:setAnchorPoint(0.5,0.5)
		circle:setPosition(cc.p(math.random(-120,120)+self.mainCircle:getPositionX(),math.random(-120,120)+self.mainCircle:getPositionY()))

		table.insert(self.circleTable,circle)
	end

	self.mainRect=display.newSprite("unit_rect.png")
	self.mainRect:setAnchorPoint(0.5,1)
	self.mainRect:setScaleX(20)
	self.mainRect:setPosition(cc.p(self.mainCircle:getPositionX(),self.mainCircle:getPositionY()))

	for i=1,20 do
		local rectNode=display.newSprite("unit_rect.png")

		local length=math.random(5,20)
		local width=math.random(1,5)

		rectNode:setPosition(cc.p(math.random(-30,30)+self.mainRect:getPositionX(),
			math.random(0,self.mainCircle:getPositionY()-50)))

		rectNode:setScale(1,math.random(20,80))
		rectNode:setOpacity(math.random(50,255))
		rectNode:setVisible(false)

		table.insert(self.rectTable,rectNode)
	end

end


function Ray:addAllToParent(parent)
	parent:addChild(self.mainCircle,100)
	parent:addChild(self.mainRect,100)

	for k,v in pairs(self.circleTable) do
		parent:addChild(v,100)
	end

	for k,v in pairs(self.rectTable) do
		parent:addChild(v,100)
	end

	self.owner=parent
end

function Ray:rayAction()
	
	-- 光球聚集的动画
	local larger=cc.ScaleTo:create(2,0.5)
	
	self.mainCircle:runAction(larger)


	for k,v in pairs(self.circleTable) do

		local timeDelay=cc.pGetDistance(cc.p(v:getPositionX(),v:getPositionY()),
			cc.p(self.mainCircle:getPositionX(),self.mainCircle:getPositionY())
			)/50

		local movement=cc.MoveTo:create(timeDelay,cc.p(self.mainCircle:getPositionX(),self.mainCircle:getPositionY()))
		local smaller=cc.ScaleTo:create(timeDelay,0.05)
		local moveAndSmaller=cc.Spawn:create(movement,smaller)
		v:runAction(moveAndSmaller)
	end
	
	-- 光柱伸长的动画

	local delay=cc.DelayTime:create(2.2)
	local collisionFunc=cc.CallFunc:create(function()
		if cc.rectIntersectsRect(self.owner.plane:getBoundingBox(),self.mainRect:getBoundingBox()) then
			self.owner.plane.HP=self.owner.plane.HP-5
			print(self.owner.plane.HP)
			if self.owner.plane.HP<0 then
				self.owner.plane:blowup()
				self.owner:createFailedLayer()
			end
		end
	end)
	local lengthen=cc.Sequence:create(cc.ScaleTo:create(0.4,20,1000),collisionFunc)

	-- 光柱旁边的光线动画

	callfunc=cc.CallFunc:create(function()
		for k,v in pairs(self.rectTable) do
			v:setVisible(true)

			local movement=cc.MoveBy:create(0.6, cc.p(0,math.random(-40,20)))
			v:runAction(movement)
		end
	end)

	local sequence=cc.Sequence:create(delay,callfunc,lengthen)

	self.mainRect:runAction(sequence)

	
	local completedDelay=cc.DelayTime:create(3.0)

	-- 各种lambda函数，想不出变量名了
	self.owner:runAction(cc.Sequence:create(completedDelay,cc.CallFunc:create(function()
		
		for k,v in pairs(self.rectTable) do
			v:removeFromParent()
		end

		for k,v in pairs(self.circleTable) do
			v:removeFromParent()
		end

		self.mainCircle:removeFromParent()

		self.mainRect:removeFromParent()

	end)))

end

return Ray


