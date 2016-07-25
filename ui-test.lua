local colors    = require("colors")
local component = require("component")
local ui        = require("ui")

local gpu        = component.gpu
local panelCount = 3

local function getRightAlignX(endX, val)
  local len = string.len(val)
  return endX-len
end

local function getCenterAlignX(startX, width, val)
  local len = string.len(val)
  local mid = math.floor(width/2)
  local midStr = math.floor(len/2)
  return startX+mid-midStr
end

ui.setScreenPaddingPercent(10, 5, 10, 5)
local panels = ui.getPanelDimensions(panelCount)

ui.clear()

ui.drawPanelBackground(panels[0], colors.white, true)
ui.drawHorizontalPercentageBar(panels[0]["x"], panels[0]["middle"], 1, colors.black, true, colors.gray, true, 20, 50, panels[0]["w"])

ui.drawPanelText(panels[0], nil, panels[0]["middle"]-1, "Label1 Above Left", "left", colors.black, true, colors.white, true)
ui.drawPanelText(panels[0], nil, panels[0]["middle"]-1, "Label1 Above Right", "right", colors.black, true, colors.white, true)
ui.drawPanelText(panels[0], nil, panels[0]["middle"]+1, "Label1 Below Left", "center", colors.black, true, colors.white, true)


ui.drawPanelBackground(panels[1], colors.yellow, true)
ui.drawHorizontalPercentageBar(panels[1]["x"], panels[1]["middle"], 1, colors.red, true, colors.gray, true, 50, 100, panels[1]["w"])


ui.drawPanelText(panels[1], 5, panels[0]["middle"]+1, "Label2 Above Right+5", nil, colors.black, true, colors.yellow, true)

ui.drawPanelBackground(panels[2], colors.pink, true)
ui.drawHorizontalPercentageBar(panels[2]["x"], panels[2]["middle"], 1, colors.lightblue, true, colors.gray, true, 80, 100, panels[2]["w"])
