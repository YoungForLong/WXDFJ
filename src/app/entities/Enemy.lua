local Bullet=require("app.entities.Bullet")
local FSM=require("app.common.FiniteStateMachine")
require("app.entities.EnemyOwnedStates")

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
	-- 速度
	self.speed=2
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

	-- 行为阈值
	self.weightWander=1.0
	self.weightPursuit=10.0
	self.weightInterpose=10.0
	self.weightHide=1.0

	-- 状态机
	self._fsm=FSM:new()
	self._fsm:ctor(self,Normal,nil)
	-- dump(self._fsm._currentState)

end

-- move behaviors 以下的方法控制敌机的运动，主要有追踪pursuit，闲逛wander，插入interpose（boss出来之后会插入到hero和
-- boss之间来保护boss）

function Enemy:pursuit()

	-- 视野之外不会触发
	if cc.pGetDistance(cc.p(self:getPositionX(),self:getPositionY()),
		cc.p(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY()))>self.sightDis
	then return cc.p(0,0) end

	local toEvade=cc.pSub(cc.p(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY()),
	cc.p(self:getPositionX(),self:getPositionY())) -- 追踪向量

	-- 如果两者朝向相对或者相背，我们直接seek
	-- 反之，我们进行位置预测，seek预测点
	local angleSub=math.abs(self.pursuitTarget:getRotation()-self:getRotation())

	if (angleSub>0 and angleSub<20) or (angleSub>180 and angleSub<200) then
		self:seek(self.pursuitTarget:getPositionX(),self.pursuitTarget:getPositionY())
		return
	end
	-- 预测时间反比于两者速度之和
	local predictTime=cc.pGetLength(toEvade)/(self.speed+self.pursuitTarget.speed)
	
	-- 速度乘时间得到预测位置
	local preX=self.pursuitTarget:getPositionX()+math.sin(self.pursuitTarget:getRotation())*self.pursuitTarget.speed*predictTime
	local preY=self.pursuitTarget:getPositionY()+math.cos(self.pursuitTarget:getRotation())*self.pursuitTarget.speed*predictTime

	return self:seek(preX,preY)
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

	-- print("world_position",po_world.x,po_world.y)
	-- 向这个点运动
	return self:seek(po_world.x,po_world.y)
end

function Enemy:interpose()
	-- 由于被保护的目标----boss是运动缓慢的实体，所以此处我们不做运动预测

	-- 中点
	local midPosition=cc.pMul(cc.pAdd(Boss:getPosition(),self.pursuitTarget:getPosition()),0.5)

	return seek(midPosition.x,midPosition.y)
end

function Enemy:seek(pox,poy) -- world space 朝向这个点的运动

	-- print(pox,poy)
	local toTarget=cc.p(pox-self:getPositionX(),poy-self:getPositionY())

	local n_toTarget=cc.pNormalize(toTarget)

	local toTarget_unit=cc.pMul(n_toTarget,self.speed)

	return toTarget_unit
end

function Enemy:hide()
	local nearestEnemy=nil
	local minDis=1000000
	for k,v in pairs(enemies) do
		local dis=cc.pGetDistance(v:getPosition(),self:getPosition())
		if dis<minDis then
			nearestEnemy=enemies[k]
			minDis=dis
		end
	end
	-- 此处由于找到点到直线的投影运算效率太低，此处我们用固定值10

	-- 躲避目标到遮蔽物的向量
	local friend2target=cc.pSub(self.pursuitTarget:getPosition(),nearestEnemy:getposition())

	-- 将其变为定长
	local plusVec2=cc.pMul(cc.pNormalize(friend2target),10)

	-- 找到目标点
 	local purpose=cc.pAdd(nearestEnemy:getPosition(),plusVec2)

	return seek(purpose)

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

function Enemy:rotate(pox,poy)
	self:setRotation(math.atan2(
		(pox-self:getPositionX()),
		(poy-self:getPositionY())
		)*180/3.1415926+180)
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

function Enemy:accumulateMovement(singleMovement,totalMovement)
	-- 计算是否在最大速度范围之内能继续运动
	-- if not enough ,slice it
	local remindSpeed=self.speed-cc.pGetLength(totalMovement)

	local temp=cc.pAdd(singleMovement,totalMovement)
	
	if math.abs(cc.pGetLength(temp)-self.speed)>0.0001 then
		totalMovement=cc.pAdd(totalMovement,temp)
	else
		-- 此处我们将其裁剪
		totalMovement=cc.pAdd(totalMovement,cc.pMul(cc.pNormalize(temp),remindSpeed))
	end

	return totalMovement
end

function Enemy:movementUpdate()
	-- 此处我们计算所有运动的合运动
	-- 每个运动有它的阈值和优先级，阈值和优先级高的运动会被先执行

	local totalMovement=cc.p(0,0) -- 合运动

	if self.behaviorTable.onHide then
		totalMovement=self:accumulateMovement(cc.pMul(self:hide(),self.weightHide),
			totalMovement)
	end

	if self.behaviorTable.onWander then
		totalMovement=self:accumulateMovement(cc.pMul(self:wander(),self.weightWander), 
			totalMovement)
			print("OUT: ",totalMovement.x)

	end

	if self.behaviorTable.onPursuit then
		totalMovement=self:accumulateMovement(cc.pMul(self:pursuit(),self.weightPursuit), 
			totalMovement)
	end

	if self.behaviorTable.onInterPose then
		totalMovement=self:accumulateMovement(cc.pMul(self:interpose(),self.weightInterpose), 
			totalMovement)
	end

	self:setPosition(cc.p(self:getPositionX()+totalMovement.x,self:getPositionY()+totalMovement.y))
	-- print(totalMovement.x,totalMovement.y)
	self:rotate(totalMovement.x,totalMovement.y)
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