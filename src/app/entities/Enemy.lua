

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

	self.Hp=10

	if ty==1 then 
		self.HP=10
		elseif ty==2 then
			self.HP=20
		else
			self.HP=30
	end

	self.speed=2

	self.t=ty

	self:setPosition(cc.p(pox,poy))

	self:setAnchorPoint(0.5,0)

	self.wanderTarget=cc.p(0,0)

	self.wanderDis=10000

	self.wanderRadius=2

	self.wanderJitter=10

	self.pursuitTarget=target
end

-- move behaviors 

function Enemy:wander()

	math.randomseed(os.time())

	local randDetax=math.random(-self.wanderJitter,self.wanderJitter)
	local randDetay=math.random(-self.wanderJitter,self.wanderJitter)
-- 获取随机点
	self.wanderTarget=cc.pAdd(self.wanderTarget,cc.p(randDetax,randDetay))
-- 投影到辅助圆上
	local n_po=cc.pMul(cc.pNormalize(self.wanderTarget),self.wanderRadius)
	local po=cc.pAdd(n_po,cc.p(0,self.wanderDis))
	-- print(po.x,po.y)
-- 转换到世界坐标系
	local po_world=self:convertToWorldSpace(po)
	print(po_world.x,po_world.y)
--test
	local dis=cc.pGetDistance(cc.p(self:getPositionX(),self:getPositionY()),po_world)
	local length=cc.pGetLength(po)
	if math.abs(dis-length)<0.01 then
		print("Inside")
	else
		print("Outside")
	end
-- 向这个点运动
	self:seek(po_world.x,po_world.y)

end

function Enemy:seek(pox,poy) -- world space 朝向这个点的运动
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

-- reload convert to world space 
-- Vec2 convertToWorldSpace(Vec2 point)
-- 	{
-- 		//该死的数学！ ~TAT`
-- 		double hx = this->_heading.x;
-- 		hx += 0.00001;
-- 		double hy = this->_heading.y;
-- 		hy += 0.00001;
-- 		double x0 = point.x;
-- 		x0 += 0.00001;
-- 		double y0 = point.y;
-- 		y0 += 0.00001;

-- 		//math function:
-- 		/*

-- 		a:本地坐标与世界坐标夹角，即heading
-- 		b:向量的本地坐标
-- 		c:向量的世界坐标

-- 		a+b-c=90

-- 		tan(a)+tan(b)         1
-- 		_____________  = - ________
-- 		1-tan(a)tan(b)      tan(c)

-- 		*/

-- 		Vec2 temp = Vec2::ZERO;

-- 		temp.x = (hy / hx) + (y0 / x0);

-- 		temp.y = (hy / hx) + (y0 / x0) - 1;

-- 		temp.getNormalized();

-- 		return (temp*point.getLength());
-- 	}
function Enemy:conver2World()
	
	
end

return Enemy