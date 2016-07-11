local Bullet=require("app.entities.bullet")

local Enemy = class("Enemy",function(ty,pox,poy,target)
	if ty==1 then
		return display.newSprite("#enemy1.png")
		elseif ty==2 then
			return display.newSprite("#enemy2.png")
		else
			return display.newSprite("#enemy3_hit.png")
		end
end)


function Enemy:ctor(ty,pox,poy,target)

	self.Hp=0

	if ty==1 then 
		self.HP=1
		elseif ty==2 then
			self.HP=4
		else
			self.HP=20
	end

	math.randomseed(os.time())

	self.speed=2

	self.t=ty

	self:setPosition(cc.p(pox,poy))

	self:setAnchorPoint(0.5,0.5)

	self.wanderTarget=cc.p(40,0)

	self.wanderDis=400

	self.wanderRadius=20

	self.wanderJitter=10

	self.pursuitTarget=target
end

-- move behaviors 

function Enemy:wander()

	local randDetax=math.random(-self.wanderJitter,self.wanderJitter)
	local randDetay=math.random(-self.wanderJitter,self.wanderJitter)
-- 获取随机点
	self.wanderTarget=cc.pAdd(self.wanderTarget,cc.p(randDetax,randDetay))
-- -- 投影到辅助圆上
	self.wanderTarget=cc.pNormalize(self.wanderTarget)
	self.wanderTarget=cc.pMul(self.wanderTarget,self.wanderRadius)
	local po_local=cc.p(self.wanderTarget.x,self.wanderTarget.y-self.wanderDis)

	-- print("local_position",po_local.x,po_local.y)

	-- print("rotation",self:getRotation())
-- 转换到世界坐标系
	local po_world=self:convertToWorldSpaceAR(cc.p(po_local.x,po_local.y))

	-- print("world_position",po_world.x,po_world.y)
-- 向这个点运动
	self:seek(po_world.x,po_world.y)

end

-- function Enemy:wander()

-- 	local randDetay=math.random(-90,90)

-- 	self.wanderTarget=cc.p(self.wanderDis,(self.wanderTarget.y+math.sin(randDetay)))

-- 	local po_world=self:convertToWorldSpaceAR(self.wanderTarget)

-- 	self:seek(po_world.x,po_world.y)
-- end

function Enemy:seek(pox,poy) -- world space 朝向这个点的运动

	-- print(pox,poy)
	local toTarget=cc.p(pox-self:getPositionX(),poy-self:getPositionY())

	local n_toTarget=cc.pNormalize(toTarget)

	local toTarget_unit=cc.pMul(n_toTarget,self.speed)

	self:setPosition(cc.p(self:getPositionX()+toTarget_unit.x,
	self:getPositionY()+toTarget_unit.y))

	self:setRotation(math.atan2((pox-self:getPositionX()),(poy-self:getPositionY()))*180/3.1415926+180)
end

function Enemy:hit()
	if self.t==3 then
		-- action
		local frames=display.newFrames("enemy3_n%d.png",1,2)
		local animation=display.newAnimation(frames,0.2)
		local animate=cc.Animate:create(animation)
		local repeatAction=cc.RepeatForever:create(animate)
		self:runAction(repeatAction)
	end
end

function Enemy:enemyUpdate()
	self:wander()
end

function Enemy:enemyDown()
	self:stopAllActions()

	local call=cc.CallFunc:create(function()
		self:removeFromParent()
		end)

	if self.t==1 then
		local frames=display.newFrames("enemy1_down%d.png",1,4)
		local animation=display.newAnimation(frames,0.2)
		local animate=cc.Animate:create(animation)
		local callAction=cc.Sequence:create(animate,call)
		self:runAction(callAction)
		elseif self.t==2 then
			local frames=display.newFrames("enemy2_down%d.png",1,4)
			local animation=display.newAnimation(frames,0.2)
			local animate=cc.Animate:create(animation)
			local callAction=cc.Sequence:create(animate,call)
			self:runAction(callAction)
		else
			local frames=display.newFrames("enemy3_down%d.png",1,6)
			local animation=display.newAnimation(frames,0.2)
			local animate=cc.Animate:create(animation)
			local callAction=cc.Sequence:create(animate,call)
			self:runAction(callAction)
		end
end


return Enemy