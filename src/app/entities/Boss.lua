local Bullet=require("app.entities.Bullet")

-- Boss

local Boss=class("Boss",function (pox,poy,target)
	return display.newSprite("#enemy3_hit.png")
end)

function Boss:ctor(pox,poy,target)
	self:setPosition(cc.p(pox,poy))
	self:setAnchorPoint(0.5,0.5)
	self.heroTarget=target

	self.HP=100
	self.speed=1 -- boss的移动速度很慢

	self.effectDis=300 --影响范围

	self:hit()
end

function Boss:injur()
	self.HP=self.HP-1
	if self.HP==0 then
		self:blowDown()
	end
end

function Boss:blowDown()
	local frames=display.newFrames("enemy3_down%d.png",1,6)
	local animation=display.newAnimation(frames,0.2)
	local animate=cc.Animate:create(animation)
	local callAction=cc.Sequence:create(animate,call)
	self:runAction(callAction)

	self:removeFromParent()
end
function Boss:spread(msg) -- 扩散，指的是不停向周围发送消息的行为
	for k,v in pairs(enemies) do
		if cc.pGetDistance(self:getPosition(),v:getPosition())<self.effectDis then
			v:handleMsg(msg)
		end
	end
end

function Boss:hit() -- 开火
	local frames=display.newFrames("enemy3_n%d.png",1,2)
	local animation=display.newAnimation(frames,0.2)
	local animate=cc.Animate:create(animation)
	local repeatAction=cc.RepeatForever:create(animate)
	self:runAction(repeatAction)
end

function Boss:normal_attack()
	local bullet=Bullet.new("#track.png",self:getPositionX(),self:getPositionY()-self:getContentSize().height)
	bullet.speed=10
	table.insert(bossBullets,bullet)
end

function Boss:ray_attack()
	local drawNode=cc.DrawNode:create()
end


function Boss:bossUpdate()
	self:spread("Boss_born")
	self:search()
	-- self:normal_attack()
end


function Boss:search()-- 找到一个运动方向，尽量避免子弹的同时攻击hero
	
	local nearestBullet=nil
	local minDis=100000
	
	for k,v in pairs(bullets) do
		local tempDis=cc.pGetDistance(v:getPosition(),self:getPosition())
		if tempDis<minDis then
			minDis=tempDis
			nearestBullet=bullets[k]
		end
	end

	local xToHero=self:getPositionX()-self.heroTarget:getPositionX()

	local xFromBullet=nearestBullet:getPositionX()-self:getPositionX()

	local result=xToHero+xFromBullet

	result=cc.pNormalize(result)*self.speed

	local assumeX=self:getPositionX()+result

	if assumeX>0 and assumeX<display.width then
		self:setPositionX(assumeX)
	end
end

return Boss