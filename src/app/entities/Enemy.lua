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

	self.speed=100

	self.t=ty

	self:setPosition(cc.p(pox,poy))

	self.wanderTarget=cc.p(0,0)

	self.wanderDis=50

	self.wanderRadius=100

	self.pursuitTarget=target
end

-- move behaviors 

function Enemy:wander()
	math.randomseed(os.time())

	local randDetax=math.random(-100,100)
	local randDetay=math.random(-100,100)
-- 获取随机点
	self.wanderTarget=cc.pAdd(self.wanderTarget,cc.p(randDetax,randDetay))
-- 投影到辅助圆上
	local po=cc.pAdd(self.wanderTarget,cc.p(0,self.wanderDis))
	local n_po=cc.pMul(cc.pNormalized(po),self.wanderRadius)
-- 

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

function Enemy:nemyUpdate()
	
end

function Enemy:enemyDown()
	self:stopAllActions()

	if self.t==1 then
		local frames=display.newFrames("enemy1_down%d.png",1,4)
		local animation=display.newAnimation(frames,0.2)
		local animate=cc.Animate:create(animation)
		self:runAction(animate)
		elseif self.t==2 then
			local frames=display.newFrames("enemy2_down%d.png",1,4)
			local animation=display.newAnimation(frames,0.2)
			local animate=cc.Animate:create(animation)
			self:runAction(animate)
		else
			local frames=display.newFrames("enemy3_down%d.png",1,6)
			local animation=display.newAnimation(frames,0.2)
			local animate=cc.Animate:create(animation)
			self:runAction(animate)
		end
end

return Enemy