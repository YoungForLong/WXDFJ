local HeroPlane=require("app.entities.HeroPlane")
local Bullet=require("app.entities.Bullet")
local Enemy=require("app.entities.Enemy")

MyScore=0

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	-- index
	MyScore=0
	self.la=cc.ui.UILabel.new({
		text="score: ",
		size=40
		})
	self.la:addTo(self,100)
	self.la:setPosition(cc.p(display.cx,display.height-100))
	self.la:setAnchorPoint(0.5,0.5)

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

    self:onLayerClicked()

	-- hero
    self.plane=HeroPlane:new()
    self:addChild(self.plane,10)

    -- bullet type
    self.bulletType=1

    -- bullet arr
    self.bullets={}

    -- enemies
    self.enemies={}

    self.enCount=0
    
    self:schedule(function()
    	self:myUpdate()
    	-- self:shoot(1)
    	-- self:shoot(2)
    	self:shoot(1)

    	if self.enCount==3 then
			self:enemyBorn()
		end

		self.enCount=self.enCount+1
		self.enCount=self.enCount%4
    	end, 0.5)

    self:schedule(function()
    	self:bgAutoMove()
    	self:bulletTraversal()
    	self:enemyTraversal()
    	end,0.01)

    -- test
    -- self.e=Enemy.new(1,100,600)
    -- self:addChild(self.e,10)


end

function MainScene:enemyBorn()
	local e=Enemy.new(1,100,600)
	self:addChild(e,10)
	table.insert(self.enemies,e)
end

function MainScene:myUpdate()
	self.la:setString("score: "..MyScore)

end

function MainScene:enemyTraversal()
	-- print(#self.enemies)
	for k,v in pairs(self.enemies) do
		v:enemyUpdate()
		if v:getPositionX()<-100 or v:getPositionX()>(display.width+100) then

			v:removeFromParent()
			table.remove(self.enemies,k)
		end
	end

	for i=#self.enemies,1,-1 do
		for j=#self.bullets,1,-1 do
			if cc.rectIntersectsRect(self.enemies[i]:getBoundingBox(),self.bullets[j]:getBoundingBox()) then
				
				self.enemies[i].HP=self.enemies[i].HP-1

				if self.enemies[i].HP==0 then
					self.enemies[i]:enemyDown()
					table.remove(self.enemies,i)
				end
				MyScore=MyScore+1

				self.bullets[j]:removeFromParent()
				table.remove(self.bullets,j)

				break
			end
		end
	end

	for k,v in pairs(self.enemies) do

		if cc.rectIntersectsRect(v:getBoundingBox(),self.plane:getBoundingBox()) then

			self.plane.HP=self.plane.HP-1

			v:enemyDown()
			if self.plane.HP==0 then
				self.plane:blowup()
				self:createFailedLayer()
			end

			table.remove(self.enemies,k)
		end
	end
end

function MainScene:bgAutoMove()
	
	local disHeight=display.height

	local poy1=self.bgSp1:getPositionY()
	
	poy1=(poy1-4)%disHeight

	local poy2=poy1-disHeight+1

	self.bgSp1:setPositionY(poy1)
	self.bgSp2:setPositionY(poy2)

end
function MainScene:createFailedLayer()
	self:pause()
	self.bgLayer:setTouchEnabled(false)

	local failedLayer=display.newColorLayer(cc.c4f(0, 0, 0, 200))

	local drawNode=cc.DrawNode:create()
	drawNode:drawPolygon({
		cc.p(display.cx-220,display.cy-200),
		cc.p(display.cx+220,display.cy-200),
		cc.p(display.cx+220,display.cy+100),
		cc.p(display.cx-220,display.cy+100)
		})

	failedLayer:addChild(drawNode, 1)

	self:addChild(failedLayer,1000)

	local ULOSE_sp=display.newSprite("lose.png")
	ULOSE_sp:setAnchorPoint(0.5,0.5)
	ULOSE_sp:setPosition(display.cx,display.cy-40)

	local lab=cc.ui.UILabel.new({
		text=MyScore,
		size=60,
		color=cc.c4f(242,172,4,255)
		})
	lab:setAnchorPoint(0,0)
	lab:setPosition(240,280)
	failedLayer:addChild(lab, 2)


	failedLayer:addChild(ULOSE_sp,2)
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
