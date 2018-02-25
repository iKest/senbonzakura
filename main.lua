-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
display.setStatusBar( display.HiddenStatusBar ) 
native.setProperty("androidSystemUiVisibility", "immersiveSticky")
--display.setDefault( "background", 1 )
display.setDefault( 'isShaderCompilerVerbose', true )

local performance = require('performance')
performance:newPerformanceMeter()

-- Some effects are time based (e.g. random),
-- so force Corona to re-blit them.
-- display.setDefault( "textureWrapX", "mirroredRepeat" )
-- display.setDefault( "textureWrapY", "mirroredRepeat" )

local grid = require('grid')


------------------------------
-- CONFIGURE STAGE
------------------------------

local background = display.newImageRect( "images/bg.png", display.contentWidth, 	display.contentHeight )
background.anchorX = 0
background.anchorY = 0
background.x = 0
background.y = 0


local new_grid = grid:new(0, 1920-7*154, 7, 7)
local background1 = display.newImageRect( "images/bg1.png", display.contentWidth, 	display.contentHeight )
background1.anchorX = 0
background1.anchorY = 0
background1.x = 0
background1.y = 0