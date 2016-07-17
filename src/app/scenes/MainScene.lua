local HeroPlane=require("app.entities.HeroPlane")
local Bullet=require("app.entities.Bullet")
local Enemy=require("app.entities.Enemy")
local Boss=require("app.entities.Boss")
local DropItem=require("app.entities.DropItem")

-- global containers or refers
MyScore=0
global_fps=100

-- enemies
enemies={}

-- bullet arr
bullets={}

bossBullets={}

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	-- system
	math.randomseed(os.time())
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

    self.enCount=0

    self.enCount1=0
    
    self.bulletNum=false
    -- update
    self:schedule(function()

    	self:shouldCreateBoss()

    	if self.enCount==9 then
    		self:myUpdate()
    		self:shoot(1)
    		if self.bulletNum then
    			self:shoot(2)
    			self:shoot(3)
    		end
    		
		end


		if self.boss.isBorn then	
    		self.boss:bossUpdate()
    	end

		self.enCount=self.enCount+1
		self.enCount=self.enCount%10

		if self.enCount1==19 then
			self:enemyBorn()

			self:shouldCreateItem()
		end

		self.enCount1=self.enCount1+1
		self.enCount1=self.enCount1%40

    	self:bgAutoMove()
    	self:traversal()
    	end,1/global_fps)

    -- close btn

    -- local closeBtn=

    -- Boss

    self.boss=Boss.new(math.random(0,display.width),display.height-100,self.plane)
    self:addChild(self.boss,10)
    self.boss:setVisible(false)
    self.timming=0
end

function MainScene:record()
	if MyScore>cc.UserDefault:getInstance():getFloatForKey("Highest") then
		cc.UserDefault:getInstance():setFloatForKey("Highest",MyScore)
	end
end


function MainScene:shouldCreateItem()
	local i=math.random(0,10)
	if i==1 then
		local item=DropItem.new(self)
	end
end
function MainScene:shouldCreateBoss()
	self.timming=self.timming+1
	if self.timming>1000 then
		if self.boss.isBorn == false then
			self.timming=-100000
			self.boss.isBorn=true
			self.boss:setVisible(true)
		end
	end
end

function MainScene:enemyBorn()
	local randType=math.random(1,2)
	local randX=math.random(0,display.width)
	local e=Enemy.new(randType,randX,display.height,self.plane)
	self:addChild(e,10)
	table.insert(enemies,e)
end

function MainScene:myUpdate()

	self.la:setString("score: "..MyScore)

end

function MainScene:traversal()

	-- 遍历子弹
	for k,v in pairs(bullets) do
		while true do

			-- 移动
			if v then
				v:move()
			end

			-- 是否和敌机碰撞
			local isCollision=false
			for kk,vv in pairs(enemies) do
				if cc.rectIntersectsRect(vv:getBoundingBox(),v:getBoundingBox()) then
					vv:injur(kk) --自带了移除的函数
					isCollision=true
					break
				end
			end
			if isCollision==true then
				MyScore=MyScore+1
				v:removeFromParent()
				table.remove(bullets,k) 
				break
			end

			-- 是否超出便边界
			local pox=v:getPositionX()
			local poy=v:getPositionY()

			if pox<0 or pox>display.width or poy<0 or poy>display.height then
				v:removeFromParent()
				table.remove(bullets,k)
				break
			end
			break
		end		
	end

	-- 遍历敌机
	for k,v in pairs(enemies) do
		-- 用while break来模拟continue
		while true do
			-- 自动更新
			v:allUpdate()
			-- 判断是否超出边界
			if v:getPositionX()<-400 or v:getPositionX()>(display.width+400) then
				v:removeFromParent()
				table.remove(enemies,k)
				break
			end
			-- 是否和hero碰撞
			if cc.rectIntersectsRect(v:getBoundingBox(),self.plane:getNewBox()) then

				self.plane.HP=self.plane.HP-1
				self.bulletNum=false
				v:enemyDown(k)

				if self.plane.HP<0 then
					self.plane:blowup()
					self:createFailedLayer()
				end
			end
			break
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
	lab:setPosition(260,285)
	failedLayer:addChild(lab, 2)


	failedLayer:addChild(ULOSE_sp,2)
end

function MainScene:createWinLayer()
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

	local ULOSE_sp=display.newSprite("win.png")
	ULOSE_sp:setAnchorPoint(0.5,0.5)
	ULOSE_sp:setPosition(display.cx,display.cy-40)

	local lab=cc.ui.UILabel.new({
		text=MyScore,
		size=60,
		color=cc.c4f(242,172,4,255)
		})
	lab:setAnchorPoint(0,0)
	lab:setPosition(260,285)
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
	audio.playMusic("sound/shoot.wav", false)

	if self.bulletType==1 then
		local filepath="#bullet1.png"
		local bullet=Bullet.new(filepath,self.plane:getPositionX(),(self.plane:getPositionY()+self.plane:getContentSize().height),ty,self)
		table.insert(bullets,bullet)
		return
	end

	if self.bulletType==2 then
		local filepath="#bullet2.png"
		local bullet=Bullet.new(filepath,self.plane:getPositionX(),(self.plane:getPositionY()+self.plane:getContentSize().height),ty,self)
		table.insert(bullets,bullet)
	end
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
