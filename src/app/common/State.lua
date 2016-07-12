-- State base

local State={

}

function State:new()
	local p={}
	setmetatable(p,self)
	self.__index=self
	return p
end

function State:enter(owner)
end

function State:execute(owner)
	owner:movementUpdate()
end

function State:exit(owner)
end

function State:handleMsg(owner,msg)  --处理消息来进行状态转换
end

return State