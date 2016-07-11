-- if U filed ,when this occurs

-- although it was called layer,it was a scene in fact

local FailedLayer=class("FailedLayer",function ()
	return display.newScene()
end) 

function ctor()
	local layer=display.newColorLayer(cc.c4b(0,0,0,100)) --rgba
	self:addChild(layer,0)

	local laSp=display.newSprite("lose.png")
	self:addChild(laSp,1)
	laSp:setAnchorPoint(0.5,0.5)
	laSp:setPosition(display.cx,display.height-300)
end



return FailedLayer