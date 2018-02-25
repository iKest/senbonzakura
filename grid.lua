local grid = {}
local tile = require('tile')
local floor = math.floor
local ceil = math.ceil
local round = math.round
local abs = math.abs
local rnd = math.random
local atan2 = math.atan2
local pi  = math.pi
local function reverse(t, i, j)
  while i < j do
    t[i], t[j] = t[j], t[i]
    i, j = i+1, j-1
  end
end

local function rotate(t, d, n)
  n = n or #t
  d = (d or 1) % n
  reverse(t, 1, n)
  reverse(t, 1, d)
  reverse(t, d+1, n)
end
local function shiftAmount (dist, step)
 	return ceil(0.5*floor(dist/(0.5*step)))
end
local function delta (dist, step)
    if dist>=0 then return (dist+.5*step)%step - .5*step end
    return (dist-.5*step)%step - .5*step
end

function grid:new(x,y,num_rows,num_cols)

    -- свойства
    local obj= {}
    obj.rows = num_rows
    obj.cols = num_cols
    obj.moving_col = 1
    obj.moving_row = 1
    obj.x = x
    obj.y = y
    obj.num_tiles = obj.rows*obj.cols
    obj.tiles = {}
    obj.step = 154
    obj.half_step = .5*obj.step

    function obj:Row (pos) return ((pos-1)%(self.rows))+1 end
    function obj:Col (pos) return floor((pos-1)/(self.rows))+1 end
    function obj:Pos (row, col) return (col-1)*self.rows+row end
    function obj:take_direction(distX, distY)
    	local dist = distX*distX+distY*distY
    	if dist > 25 then
    		local drag_angle=abs(atan2(distY,distX))
    		if drag_angle > pi/4 and drag_angle < 3*pi/4 then return 'vertical', distX, distY
    		else return 'horizontal' , distX, distY end
    	end
    	return 'undefined', 0, 0
    end
    function obj:pick_tile (x,y) 
        return floor(x/obj.step)+1, floor(y/obj.step)+1
    end

    for i = 1, obj.num_tiles do
    	local curent_row = obj:Row(i)
    	local curent_col = obj:Col(i)
    	obj.tiles[i] = tile:new(tostring(rnd(1,48)), obj.x+obj.half_step+(curent_row-1)*obj.step, obj.y+obj.half_step+(curent_col-1)*obj.step)
    end
    obj.temp_tile = tile:new(tostring(11), -200, -200)
    obj.touch_area = display.newRect(obj.x, obj.y, obj.step*obj.rows, obj.step*obj.cols)
    obj.touch_area.anchorX = 0
    obj.touch_area.anchorY = 0
    obj.touch_area.isVisible = false
	obj.touch_area.isHitTestable = true
	print (obj.touch_area)

	function obj:tile_moving(row, col, distX, distY, direction)
  		local temp = {}
  		if 'horizontal' == direction then
  			for i = 1, obj.cols do
  				temp[i] = obj.tiles[obj:Pos(i, col)]
  			end
  			rotate(temp, shiftAmount(distX,obj.step))
  			if delta(distX,obj.step) > 0 then
  				obj.temp_tile:setColor(temp[#temp].color)
  				obj.temp_tile:moveTo(obj.x-obj.half_step+delta(distX,obj.step), obj.y+obj.half_step+(col-1)*obj.step, distX/obj.temp_tile.r, 0)
  			elseif delta(distX,obj.step) < 0 then
  				obj.temp_tile:setColor(temp[1].color)
  				obj.temp_tile:moveTo(obj.x+obj.half_step+obj.rows*obj.step+delta(distX,obj.step), obj.y+obj.half_step+(col-1)*obj.step, distX/obj.temp_tile.r, 0)
  			end
  			for i = 1, #temp do
  				temp[i]:moveTo(obj.x+obj.half_step+(i-1)*obj.step+delta(distX,obj.step), temp[i]:getY(), distX/temp[i].r, 0)
  			end
  		elseif 'vertical' == direction then
  			for i = 1, obj.rows do
  				temp[i] = obj.tiles[obj:Pos(row, i)]
  			end
  			rotate(temp, shiftAmount(distY, obj.step))
  			if delta(distY,obj.step) > 0 then
  				obj.temp_tile:setColor(temp[#temp].color)
  				obj.temp_tile:moveTo(obj.x+obj.half_step+(row-1)*obj.step, obj.y-obj.half_step+delta(distY,obj.step), 0, distY/obj.temp_tile.r)
  			elseif delta(distY,obj.step) < 0 then
  				obj.temp_tile:setColor(temp[1].color)
  				obj.temp_tile:moveTo(obj.x+obj.half_step+(row-1)*obj.step, obj.y+obj.half_step+obj.cols*obj.step+delta(distY,obj.step), 0, distY/obj.temp_tile.r)
  			end
  			for i = 1, #temp do
  				temp[i]:moveTo(temp[i]:getX(), obj.y+obj.half_step+(i-1)*obj.step+delta(distY,obj.step), 0, distY/temp[i].r)
  			end  			
  		end
  	end
  	local function relising(event)
  		local step
  		if 'horizontal' == obj.direction then
  			if obj.distX ~= 0 then 
  				step = ceil(abs(obj.distX/10))
                    if abs(obj.distX)<=step then obj.distX = 0
                    elseif obj.distX > 0 then obj.distX = obj.distX - step else obj.distX = obj.distX + step end
                    obj:tile_moving(obj.moving_row, obj.moving_col, obj.distX, obj.distY, obj.direction)
  			else Runtime:removeEventListener("enterFrame", relising) end	

  		elseif 'vertical' == obj.direction then
  			if obj.distY ~= 0 then 
  				step = ceil(abs(obj.distY/10))
                    if abs(obj.distY)<=step then obj.distY = 0
                    elseif obj.distY > 0 then obj.distY = obj.distY - step else obj.distY = obj.distY + step end
                    obj:tile_moving(obj.moving_row, obj.moving_col, obj.distX, obj.distY, obj.direction)
  			else Runtime:removeEventListener("enterFrame", relising) end

  		end
  	end

	function obj.touch_area:touch(event)

		if  event.phase == "began" then
        	display.getCurrentStage():setFocus( self, event.id )
        	self.isFocus = true
        	self.isMoving = true
        	print(event.phase)
        	obj.x0 = event.x - obj.x
			obj.y0 = event.y - obj.y
			obj.moving_row, obj.moving_col = obj:pick_tile(obj.x0, obj.y0)

			print(obj.moving_row..":"..obj.moving_col.."-"..obj:Pos(obj:pick_tile(obj.x0, obj.y0)))
			--obj.tiles[obj:Pos(obj:pick_tile(self.x0, self.y0))].tile:setStrokeColor( 1, 1, 1, 0.9)
			--obj.tiles[obj:Pos(obj:pick_tile(self.x0, self.y0))].tile.strokeWidth = 1
			obj.direction = 'undefined'


        elseif self.isFocus then

			if ( "moved" == event.phase ) then
				obj.distX = event.x - obj.x - obj.x0
				obj.distY = event.y - obj.y - obj.y0
				if obj.direction == 'undefined' then  
					obj.direction, obj.distX, obj.distY= obj:take_direction(obj.distX, obj.distY)
					obj.x0 = obj.x0 + obj.distX
					obj.y0 = obj.y0 + obj.distY
				else 
					obj:tile_moving(obj.moving_row, obj.moving_col, obj.distX, obj.distY, obj.direction)
				end 
			elseif ( "ended" == event.phase or "cancelled" == event.phase ) then
				print(event.phase)
				display.getCurrentStage():setFocus( self, nil )
				self.isFocus = false
				--obj.tiles[obj:Pos(obj:pick_tile(self.x0, self.y0))].tile:setStrokeColor( 1, 1, 1, 0)
				obj.distX = delta(obj.distX, obj.step)
				obj.distY = delta(obj.distY, obj.step)
				Runtime:addEventListener("enterFrame", relising)
			end
		end
        return true
	end
	
	obj.touch_area:addEventListener( "touch" )

	function obj:getTile(x,y)
		local col = floor((y-obj.y)/obj.step)
  		local row = floor((x-obj.x)/obj.step)
  		return col*row
	end

	
    -- метод
    --чистая магия!
    setmetatable(obj, self)
    self.__index = self; return obj
end



return grid