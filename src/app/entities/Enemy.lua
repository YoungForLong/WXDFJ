local Bullet=require("app.entities.Bullet")
local FSM=require("app.common.FiniteStateMachine")
require("app.entities.EnemyOwnedStates")

local Enemy = class("Enemy",function(ty,pox,poy,target)
	if ty==1 then
		return display.newSprite("#enemy1.png")
	else
		return display.newSprite("#enemy2.png")
	end
end)


function Enemy:ctor(ty,pox,poy,target)

	self.Hp=0

	if ty==1 then 
		self.HP=2
	else
		self.HP=4
	end

	-- 速度
	self.speed=4
	-- 类型
	self.t=ty

	self:setPosition(cc.p(pox,poy))

	self:setAnchorPoint(0.5,0.5)

	-- 本地坐标系上的点，被一直维护以进行随机运动
	self.wanderTarget=cc.p(40,0)

	-- 辅助圆在本地的偏移量
	self.wanderDis=400

	-- 辅助圆的大小，表示随机运动的 弧度区间
	self.wanderRadius=20

	-- 表示随机运动的 弧度 变化区间
	self.wanderJitter=10

	-- 维护和更新追踪目标
	self.pursuitTarget=target

	-- 视野
	self.sightDis=300

	-- 行为表，用来存储正在执行的行为
	self.behaviorTable={
		onWander=false,
		onPursuit=false,
		onInterpose=false,
		onHide=false
	}

	-- 行为阈值，该值会被状态机改变
	self.weightWander=0.3
	self.weightPursuit=0.2
	self.weightInterpose=0.4
	self.weightHide=0.1

	-- 状态机
	self._fsm=FSM:new()
	self._fsm:ctor(self,Normal,nil)
	-- dump(self._fsm._currentState)

end

-- move behaviors 以下的方法控制敌机的运动，主要有追踪pursuit，
-- 闲逛wander，躲藏（受伤之后会躲藏到附近的友军后面）
-- 插入interpose（boss出来之后会插入到hero和
-- boss之间来保护boss）

function Enemy:pursuit()

	-- 视野之外不会触发
	if cc.pGetDistance(cc.p(self:getPositionX(),self:getPositionY()),
		cc.p(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY()))>self.sightDis
	then return end

	local toEvade=cc.pSub(cc.p(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY()),
	cc.p(self:getPositionX(),self:getPositionY())) -- 追踪向量

	-- 如果两者朝向相对或者相背，我们直接seek
	-- 反之，我们进行位置预测，seek预测点
	local angleSub=math.abs(self.pursuitTarget:getRotation()-self:getRotation())

	if (angleSub>0 and angleSub<20) or (angleSub>180 and angleSub<200) then
		--为了避免速度过大，我们这里乘上阈值
		self:seek(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY(),self.weightPursuit) 
		return
	end
	-- 预测时间反比于两者速度之和
	local predictTime=cc.pGetLength(toEvade)/(self.speed+self.pursuitTarget.speed)
	
	-- 速度乘时间得到预测位置
	local preX=self.pursuitTarget:getPositionX()+math.sin(self.pursuitTarget:getRotation())*self.pursuitTarget.speed*predictTime
	local preY=self.pursuitTarget:getPositionY()+math.cos(self.pursuitTarget:getRotation())*self.pursuitTarget.speed*predictTime

	self:seek(preX,preY,self.weightPursuit)
end

function Enemy:wander()

	local randDetax=math.random(-self.wanderJitter,self.wanderJitter)
	local randDetay=math.random(-self.wanderJitter,self.wanderJitter)
	-- 获取随机点
	self.wanderTarget=cc.pAdd(self.wanderTarget,cc.p(randDetax,randDetay))
	--  投影到辅助圆上
	self.wanderTarget=cc.pNormalize(self.wanderTarget)
	self.wanderTarget=cc.pMul(self.wanderTarget,self.wanderRadius)
	local po_local=cc.p(self.wanderTarget.x,self.wanderTarget.y-self.wanderDis)

	-- print("local_position",po_local.x,po_local.y)

	-- print("rotation",self:getRotation())
	-- 转换到世界坐标系
	local po_world=self:convertToWorldSpaceAR(cc.p(po_local.x,po_local.y))

	-- 向这个点运动
	self:seek(po_world.x,po_world.y,self.weightWander)
end

function Enemy:interpose()
	-- 由于被保护的目标----boss是运动缓慢的实体，所以此处我们不做运动预测

	local boss=self:getParent().boss
	-- 中点
	local midPosition=cc.pMul(cc.pAdd(cc.p(boss:getPositionX(),boss:getPositionY()),
		cc.p(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY())),0.5)

	self:seek(midPosition.x,midPosition.y,self.weightInterpose)
end

function Enemy:seek(pox,poy,weight) -- world space 朝向这个点的运动

	-- print(pox,poy)
	local toTarget=cc.p(pox-self:getPositionX(),poy-self:getPositionY())

	-- if cc.pGetLength(toTarget)<0.001 then
	-- 	return cc.p(0,0)
	-- end

	local n_toTarget=cc.pNormalize(toTarget)

	local toTarget_unit=cc.pMul(n_toTarget,self.speed*weight)

	self:setPosition(cc.pAdd(cc.p(self:getPositionX(),self:getPositionY()),toTarget_unit))

	self:setRotation(math.atan2((pox-self:getPositionX()),(poy-self:getPositionY()))*180/3.1415926+180)
	
end

function Enemy:hide()
	local nearestEnemy=nil
	local minDis=1000000
	for k,v in pairs(enemies) do
		local dis=cc.pGetDistance(cc.p(v:getPositionX(),v:getPositionX()),
			cc.p(self:getPositionX(),self:getPositionY()))
		if dis<minDis then
			nearestEnemy=enemies[k]
			minDis=dis
		end
	end
	-- 此处由于找到点到直线的投影运算效率太低，此处我们用固定值10

	-- 躲避目标到遮蔽物的向量
	local friend2target=cc.pSub(cc.p(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY()),
		cc.p(nearestEnemy:getPositionX(),nearestEnemy:getPositionY()))

	-- 将其变为定长
	local plusVec2=cc.pMul(cc.pNormalize(friend2target),10)

	-- 找到目标点
 	local purpose=cc.pAdd(cc.p(nearestEnemy:getPositionX(),nearestEnemy:getPositionY()),plusVec2)

	self:seek(purpose.x,purpose.y,self.weightHide)

end

function Enemy:removeAllBehaviors()
	for k,v in pairs(self.behaviorTable) do
		v=false
	end
end
----------------- move behaviors end ------------------


function Enemy:handleMsg(msg)
	self._fsm:handleMsg(msg)
end

function Enemy:allUpdate()
	self._fsm:update()
end

function Enemy:movementUpdate()
	-- 此处我们计算所有运动的合运动
	-- 每个运动有它的阈值和优先级，阈值和优先级高的运动会被先执行，
	-- 并且执行时乘以更大的系数

	local totalMovement=cc.p(0,0) -- 合运动

	if self.behaviorTable.onHide then
		self:hide()
	end

	if self.behaviorTable.onWander then
		self:wander()
	end

	if self.behaviorTable.onPursuit then
		self:pursuit()
	end

	if self.behaviorTable.onInterpose then
		self:interpose()
	end

end

function Enemy:enemyDown(k)
	self:stopAllActions()
	table.remove(enemies,k)
	local call=cc.CallFunc:create(function()
		self:removeFromParent()
		end)

	if self.t==1 then
		local frames=display.newFrames("enemy1_down%d.png",1,4)
		local animation=display.newAnimation(frames,0.2)
		local animate=cc.Animate:create(animation)
		local callAction=cc.Sequence:create(animate,call)
		self:runAction(callAction)

		audio.playMusic("enemy1_down.wav", false)
		elseif self.t==2 then
			local frames=display.newFrames("enemy2_down%d.png",1,4)
			local animation=display.newAnimation(frames,0.2)
			local animate=cc.Animate:create(animation)
			local callAction=cc.Sequence:create(animate,call)
			self:runAction(callAction)

			audio.playMusic("src/enemy2_down.wav", false)
		end
end

function Enemy:injur(k)
	self._fsm:handleMsg("on_injured")
	self.HP=self.HP-1
	if self.HP<0 then
		self:enemyDown(k)
	end
end

return Enemy