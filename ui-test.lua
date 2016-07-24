local colors = require("colors")
local ui     = require("ui")

local panelCount = 3

ui.setScreenPaddingPercent(10, 5, 10, 5)
local panels = ui.getPanelDimensions(panelCount)

ui.clear()

ui.drawPanelBackground(panels[0], colors.white)
ui.drawPanelBackground(panels[1], colors.yellow)
ui.drawPanelBackground(panels[2], colors.pink)

ui.drawHorizontalPercentageBar(panels[0]{"x"}, panels[0]{"middle"}, 1, colors.black, true, colors.gray, true, 20, 50, panels[0]{"w"})
ui.drawHorizontalPercentageBar(panels[1]{"x"}, panels[1]{"middle"}, 1, colors.red, true, colors.gray, true, 50, 100, panels[1]{"w"})
ui.drawHorizontalPercentageBar(panels[2]{"x"}, panels[2]{"middle"}, 1, colors.lightblue, true, colors.gray, true, 80, 100, panels[2]{"w"})

