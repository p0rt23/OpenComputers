local ui = {}

local component = require("component")
local gpu       = component.gpu

local screenWidthOuter, screenHeightOuter
local screenWidthInner, screenHeightInner
local screenTopInner, screenLeftInner

local function scaleValue(n1, n1Max, n2Max)
  return math.floor((n2Max*n1)/n1Max)
end  

function ui.clear()
  local w, h = gpu.getResolution()
  gpu.fill(1, 1, w, h, " ")
end

function ui.setScreenPaddingPercent(top, right, bottom, left)
  local topOffset    = math.floor(screenHeightOuter*(top   /100))
  local rightOffset  = math.floor(screenWidthOuter *(right /100))
  local bottomOffset = math.floor(screenHeightOuter*(bottom/100))
  local leftOffset   = math.floor(screenWidthOuter *(left  /100))
  
  screenTopInner    = topOffset+1
  screenLeftInner   = leftOffset+1
  screenWidthInner  = screenWidthOuter-rightOffset-leftOffset
  screenHeightInner = screenHeightOuter-topOffset-bottomOffset
end

function ui.getPanelDimensions(panelCount)
  local panels = {}
  local panelBottomPrevious = screenTopInner
  local panelHeight = math.floor(screenHeightInner/panelCount)
  
  for local i = 0, panelCount - 1 do
    panels[i]           = {}
    panels[i]{"x"}      = screenLeftInner
    panels[i]{"y"}      = panelBottomPrevious
    panels[i]{"w"}      = screenWidthInner
    panels[i]{"h"}      = panelHeight
    panels[i]{"middle"} = panelBottomPrevious+math.floor(panelHeight/2)
    panelBottomPrevious = panel[i]{"y"} + panel[i]{"h"}
  end 
  return panels
end

function ui.drawPanelBackground(panel, color, isIndex)
  local oldColor = gpu.setBackground(color, isIndex)
  gpu.fill(panel{"x"}, panel{"y"}, panel{"w"}, panel{"h"}, " ")
  gpu.setBackground(oldColor)
end

function ui.drawHorizontalPercentageBar(x, y, height, fgColor, isFgIndex, bgColor, isBgIndex, val, maxVal, width)
  local innerWidth = scaleValue(val, maxVal, width)
 
  local oldColor = gpu.setBackground(bgColor, isBgIndex)
  gpu.fill(x, y, width, height, " ")

  gpu.setBackground(fgColor, ifFgIndex)
  gpu.fill(x, y, innerWidth, height, " ")

  gpu.setBackground(oldBg)
end


screenWidthOuter, screenHeightOuter = gpu.getResolution()
screenWidthInner  = screenWidthOuter
screenHeightInner = screenHeightOuter
screenTopInner    = 1
screenLeftInner   = 1 

return ui
