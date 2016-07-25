local ui = {}
 
local component = require("component")
local gpu       = component.gpu
 
local screenWidthOuter, screenHeightOuter
local screenWidthInner, screenHeightInner
local screenTopInner, screenLeftInner
local maxDepth
 
local function scaleValue(n1, n1Max, n2Max)
  if n1Max > 0 then
    return math.floor((n2Max*n1)/n1Max)
  end
  return 0
end  

local function setBackground(color, isIndex, monoColor)
  monoColor = monoColor or 0x000000
  isIndex   = isIndex   or false
  if maxDepth < 4 then
    color   = monoColor
    isIndex = false
  end
  local oldColor = gpu.setBackground(color, isIndex)
  return oldColor
end

local function setForeground(color, isIndex, monoColor)
  monoColor = monoColor or 0xFFFFFF
  isIndex   = isIndex   or false
  if maxDepth < 4 then
    color   = monoColor
    isIndex = false
  end
  local oldColor = gpu.setForeground(color, isIndex)
  return oldColor
end

local function getXAlignRight(endX, val)
  local len = string.len(val)
  return endX-len
end

local function getXAlignCenter(startX, width, val)
  local len = string.len(val)
  local mid = math.floor(width/2)
  local midStr = math.floor(len/2)
  return startX+mid-midStr
end

local function drawText(x, y, fgColor, isFgIndex, bgColor, isBgIndex)
  local oldFg = setForeground(fgColor, isFgIndex)
  local oldBg = setBackground(bgColor, isBgIndex)
 
  gpu.set(x, y, text)

  setForeground(oldFg)
  setBackground(oldBg)
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
 
  for i = 0, panelCount - 1 do
    panels[i]           = {}
    panels[i]["x"]      = screenLeftInner
    panels[i]["y"]      = panelBottomPrevious
    panels[i]["w"]      = screenWidthInner
    panels[i]["h"]      = panelHeight
    panels[i]["middle"] = panelBottomPrevious+math.floor(panelHeight/2)
    panelBottomPrevious = panels[i]["y"] + panels[i]["h"]
  end
  return panels
end
 
function ui.drawPanelBackground(panel, color, isIndex)
  local oldColor = setBackground(color, isIndex)
  gpu.fill(panel["x"], panel["y"], panel["w"], panel["h"], " ")
  setBackground(oldColor)
end
 
function ui.drawHorizontalPercentageBar(x, y, height, fgColor, isFgIndex, bgColor, isBgIndex, val, maxVal, width)
  local innerWidth = scaleValue(val, maxVal, width)

  local oldColor = setBackground(bgColor, isBgIndex)
  gpu.fill(x, y, width, height, " ")
 
  setBackground(fgColor, isFgIndex, 0xFFFFFF)
  gpu.fill(x, y, innerWidth, height, " ")
 
  setBackground(oldColor)
end

function ui.drawPanelText(panel, x, y, text, align, fgColor, isFgIndex, bgColor, isBgIndex)
  if align == "left" then
    x = panel["x"]
  elseif align == "right" then
    x = getXAlignRight(panel["x"]+panel["w"], text)
  elseif align == "center" then
    x = getXAlignCenter(panel["x"], panel["w"], text)
  else
    x = x or 1
  end

  drawText(x, y, fgColor, isFgIndex, bgColor, isBgIndex)
end
 
function ui.drawScreenText(x, y, text, align, fgColor, isFgIndex, bgColor, isBgIndex)
  if align == "left" then
    x = 1
  elseif align == "right" then
    x = getXAlignRight(1+screenWidthOuter, text)
  elseif align == "center" then
    x = getXAlignCenter(1, screenWidthOuter, text)
  else
    x = x or 1
  end
 
  drawText(x, y, fgColor, isFgIndex, bgColor, isBgIndex)
end

function ui.setResolution(w, h)
  local oldW, oldH = gpu.getResolution()
  gpu.setResolution(w, h)
  return oldW, oldH
end

screenWidthOuter, screenHeightOuter = gpu.getResolution()
screenWidthInner  = screenWidthOuter
screenHeightInner = screenHeightOuter
screenTopInner    = 1
screenLeftInner   = 1
maxDepth          = gpu.maxDepth()
 
return ui
