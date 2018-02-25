local tile = {}

local kernel = require("myshader")
graphics.defineEffect( kernel )

local sin = math.sin
local cos = math.cos
local pi  = math.pi

function tile:new(color, x,y)

    -- свойства
    local obj= {}
        obj.color = color
        obj.x = x 
        obj.y = y 
        obj.pre_x = x
        obj.pre_y = y
        obj.delta_phiX = 0.
        obj.delta_phiY = 0.
        obj.r = 154/pi
        obj.paint =
			{
				type="image",
				filename="images/"..color..".png"
			}
		obj.tile = display.newImageRect( "images/shadow.png", 140, 140 )
			obj.tile.x = obj.x
			obj.tile.y = obj.y	
			obj.tile.alpha = .3
		obj.ball = display.newRect(obj.x, obj.y, 2*obj.r, 2*obj.r )
		obj.ball.fill = obj.paint
		obj.ball.fill.effect = "filter.custom.ball"
		obj.ball.fill.effect.sinX = sin (obj.delta_phiX)
		obj.ball.fill.effect.cosX = cos (obj.delta_phiX)
		obj.ball.fill.effect.sinY = sin (obj.delta_phiX)
		obj.ball.fill.effect.cosY = cos (obj.delta_phiX)

    -- метод
    function obj:getX()
    	return self.x
    end
    function obj:getY()
    	return self.y
    end
    function obj:moveTo(newX,newY, delta_phiX, delta_phiY)
        self.pre_x = self.x
        self.pre_y = self.x
        self.x = newX
        self.y = newY
        self.delta_phiX = (self.x - self.pre_x)
        self.delta_phiY = (self.y - self.pre_y)
        obj.tile.x = self.x
        obj.tile.y = self.y
        obj.ball.x = self.x
        obj.ball.y = self.y
        obj.ball.fill.effect.sinX = sin (delta_phiX)
		obj.ball.fill.effect.cosX = cos (delta_phiX)
		obj.ball.fill.effect.sinY = sin (delta_phiY)
		obj.ball.fill.effect.cosY = cos (delta_phiY)
    end
    function obj:setColor (color)
    	obj.paint.filename="images/"..color..".png"
		obj.ball.fill = obj.paint
		obj.ball.fill.effect = "filter.custom.ball"	
    end
    --чистая магия!
    setmetatable(obj, self)
    self.__index = self; return obj
end

return tile