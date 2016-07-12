local State=require("app.common.State")

-- enemy states:
-- 敌机的状态为三种：
-- 第一种敌机正常飞行，在视野内会冲撞hero
-- 第二种敌机受到一次攻击，随机飞行，适当躲避飞机的子弹，不会撞击hero
-- 第三种是boss存在时的状态，敌机会为boss挡子弹，依然会撞击hero


Normal={
}

function Normal:enter(owner)
	owner:removeAllBehaviors()
	owner.behaviorTable.onWander=true
	owner.behaviorTabel.onPursuit=true
end

-- 完全引用父类的函数
-- function Normal:execute(owner)
-- 	owner:movementUpdate()
-- end

function Normal:handleMsg(owner,msg)
	if msg=="on_injured" then
		owner.FSM:changeState(Fear)
	end
	if msg=="boss_born" then
		owner.FSM:changeState(BossExisting)
	end
end

setmetatable(Normal,State)


Fear={
}

function  Fear:enter(owner)
	owner:removeAllBehaviors()
	owner.behaviorTabel.onWander=true
	owner.behaviorTable.onHide=true
end

function Fear:handleMsg(owner, msg)
	if msg=="boss_born" then
		owner.FSM:changeState(BossExisting)
	end
end

setmetatable(Fear, State)

BossExisting= {
}

function BossExisting:enter(owner)
	owner:removeAllBehaviors()
	owner.behaviorTabel.onWander=true
	owner.behaviorTable.onPursuit=true
	owner.behaviorTable.onInterpose=true
end

function BossExisting:handleMsg(owner, msg)
	if msg=="boss_die" then
		owner.FSM:changeState(Normal)
	end
end