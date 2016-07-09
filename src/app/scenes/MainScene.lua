local HeroPlane=require("app.entities.HeroPlane")
local Bullet=require("app.entities.Bullet")
local Enemy=require("app.entities.Enemy")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	-- bg
	self.bgLayer=display.newLayer()
	self.bgLayer:setAnchorPoint(0.5,0)
	self.bgLayer:setPosition(display.cx,0)
	self:addChild(self.bgLayer,0)

	self.bgSp1=display.newSprite("#background.png")
	self.bgSp1:setAnchorPoint(0.5,0)
	self.bgSp1:setPosition(display.cx,0)
	self:addChild(self.bgSp1,1)

	self.bgSp2=display.newSprite("#background.png")
	self.bgSp2:setAnchorPoint(0.5,0)
	self.bgSp2:setPosition(display.cx,2*display.cy)
	self:addChild(self.bgSp2,1)	

	-- hero
    self.plane=HeroPlane:new()
    self:addChild(self.plane,10)

    -- bullet type
    self.bulletType=1

    -- bullet arr
    self.bullets={}

    -- enemies
    self.enemies={}
    
    self:schedule(function()
    	self:shoot(1)
    	self:shoot(2)
    	self:shoot(3)
    	end, 0.3)

    self:schedule(function()
    	self:bgAutoMove()
    	self:bulletTraversal()
    	self.e:enemyUpdate()
    	end,0.1)

    self:onLayerClicked()

    -- test
    self.e=Enemy.new(1,100,600)
    self:addChild(self.e,10)

end


function MainScene:bgAutoMove()
	
	local disHeight=display.height

	local poy1=self.bgSp1:getPositionY()
	
	poy1=(poy1-4)%disHeight

	local poy2=poy1-disHeight+1

	self.bgSp1:setPositionY(poy1)
	self.bgSp2:setPositionY(poy2)

end

function MainScene:onLayerClicked()
	self.bgLayer:setTouchEnabled(true)

	self.bgLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
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

		k:move()

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
