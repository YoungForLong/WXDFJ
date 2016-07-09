local HeroPlane=require("app.entities.HeroPlane")
local Bullet=require("app.entities.Bullet")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	-- bg
	self.bgSp=cc.Sprite:createWithSpriteFrameName("background.png")

	self.bgSp:setAnchorPoint(0.5,0)
	self.bgSp:setPosition(display.cx,0)
	self:addChild(self.bgSp,0)

	-- hero
    self.plane=HeroPlane:new()
    self:addChild(self.plane,10)

    -- bullet type
    self.bulletType=1

    -- bullet arr
    self.bullets={}

    
    self:schedule(function()
    	self:shoot(1)
    	self:shoot(2)
    	self:shoot(3)
    	self:bulletTraversal()
    	end, 0.3)

    self:onLayerClicked()

end

function MainScene:onLayerClicked()
	self.bgSp:setTouchEnabled(true)

	self.bgSp:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
		if event.name=="began" then
			self.plane:move(event.x,event.y)
			return true
		elseif event.name=="ended" then
			
			end
		end)
end

function MainScene:shoot(ty)

	if self.bulletType==1 then
		local filepath="#bullet1.png"
		local bullet=Bullet.new(filepath,self.plane:getPositionX(),(self.plane:getPositionY()+self.plane:getContentSize().height),ty,self)
		table.insert(self.bullets,bullet)
		return
	end

	if self.bulletType==2 then
		local filepath="#bullet2.png"
		local bullet=Bullet.new(filepath,self.plane:getPositionX(),(self.plane:getPositionY()+self.plane:getContentSize().height),ty,self)
		table.insert(self.bullets,bullet)
	end
end

function MainScene:bulletTraversal()
	
	for i,k in pairs(self.bullets) do
		local positionX=k:getPositionX()
		local positionY=k:getPositionY()

		local tag=0

		if positionY>(2*display.cy) then
			tag=tag+1
		end

		if positionX>(2*display.cx) then
			tag=tag+1
		end

		if positionX<0 then
			tag=tag+1
		end
		if tag~=0 then
			k:removeFromParent()
			table.remove(self.bullets,i)
		end

	end
end


function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
