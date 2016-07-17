-- Finite state machine
local FSM={
	_owner=nil,
	_currentState={1},
	_globalState=nil,
	_previousState=nil
} --由一个状态机所有者，初始状态和全局状态来初始化状态机

function FSM:new()
	local p={}
	setmetatable(p,self)
	self.__index=self
	return p
end

function FSM:ctor(owner,CS,GS)
	self._owner=owner
	self._currentState=CS
	self._currentState:enter(self._owner)
	self._globalState=GS
	self._previousState=nil
end

function FSM:update()
	if self._globalState then 
		self._globalState:execute(self._owner)
	end

	if self._currentState then
		self._currentState:execute(self._owner)
	end
end

function FSM:handleMsg(msg)
	if self._currentState and self._currentState:handleMsg(self._owner,msg) then
		return true
	end

	if self._globalState and self._globalState:handleMsg(self._owner,msg) then
		return true
	end

	return false
end

function FSM:changeState(next_state)
	if next_state ~=nil then
		self._previousState = self._currentState
		self._currentState:exit(self._owner)
		self._currentState = next_state
		self._currentState:enter(self._owner)
	else
		print("Error: Null State!")
	end
end

function FSM:revert()
	self:changeState(_previousState)
end

return FSM