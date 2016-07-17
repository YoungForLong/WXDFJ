local Bullet=require("app.entities.Bullet")
local Ray=require("app.entities.Ray")

-- Boss

local Boss=class("Boss",function (pox,poy,target)
	return display.newSprite("#enemy3_hit.png")
end)

function Boss:ctor(pox,poy,target)
	self:setPosition(cc.p(pox,poy))
	self:setAnchorPoint(0.5,0.5)
	self.heroTarget=target

	self.HP=100
	self.speed=0.5 -- boss的移动速度很慢

	self.effectDis=300 --影响范围

	self.isBorn=false

	self.count=0

	self:hit()
end

function Boss:injur()
	self.HP=self.HP-1
	if self.HP==0 then
		self:blowDown()
	end
end

function Boss:blowDown()
	audio.playMusic("src/enemy3_down.wav",false)

	local frames=display.newFrames("enemy3_down%d.png",1,6)
	local animation=display.newAnimation(frames,0.2)
	local animate=cc.Animate:create(animation)
	local callAction=cc.Sequence:create(animate,cc.CallFunc:create(function()
		self.isBorn=false
		self:getParent():createWinLayer()
	end
		))
	self:runAction(callAction)
end
function Boss:spread(msg) -- 扩散，指的是不停向周围发送消息的行为
	for k,v in pairs(enemies) do
		if cc.pGetDistance(cc.p(self:getPositionX(),self:getPositionY()),
			cc.p(v:getPositionX(),v:getPositionY()))<self.effectDis then
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

end

function Boss:ray_attack()
	local scene=self:getParent()

	local ray=Ray:new()

	ray:init(self:getPositionX(),self:getPositionY()-self:getContentSize().height/2)

	ray:addAllToParent(scene)

	ray:rayAction()

	return ray
end

function Boss:isAttcked()
	for k,v in pairs(bullets) do
		-- 是否和boss碰撞
		if cc.rectIntersectsRect(v:getBoundingBox(),self:getBoundingBox()) then
			MyScore=MyScore+1
			self:injur()
			v:removeFromParent()
			table.remove(bullets,k)
			break
		end
	end
end

function Boss:bossUpdate()
	self:spread("boss_born")
	self:search()
	self:isAttcked()
	if self.count==99 then
		self:ray_attack()
	end
	self.count=(self.count+1)%100
end

function Boss:search()-- 找到一个运动方向，尽量避免子弹的同时攻击hero

	local xToHero=self.heroTarget:getPositionX()-self:getPositionX()

	local result=xToHero

	result=result/math.abs(result)*self.speed

	local assumeX=self:getPositionX()+result

	if assumeX>0 and assumeX<display.width then
		self:setPositionX(assumeX)
	end
end

return Boss