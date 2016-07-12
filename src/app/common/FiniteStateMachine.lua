-- Finite state machine
local FSM=class("FSM",function (owner,CS,GS) --由一个状态机所有者，初始状态和全局状态来初始化状态机
end)

function FSM:ctor(owner,CS,GS)
	self._owner=owner
	self._currentState=CS
	self._globalState=GS
	self._previousState=nil
end

function FSM:update()
	if self._globalState then 
		self._globalState:execute()
	end

	if self._currentState then
		self._currentState:execute()
	end
end

function FSM:handleMsg(msg)
	if self._currentState and self._currentState:handleMsg(msg) then
		return true
	end

	if self._globalState and self._globalState:handleMsg(msg) then
		return true
	end

	return false
end

function FSM:changeState(next_state)
	if next_state ~=nil then
		self._previousState = self._currentState
		self._currentState:exit(_owner)
		self._currentState = next_state
		self._currentState:enter(_owner)
	else
		print("Error: Null State!")
	end
end

function FSM:revert()
	self:changeState(_previousState)
end