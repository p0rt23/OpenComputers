local component = require("component")
local keyboard  = require("keyboard")
local format    = require("format")
local ui        = require("ui")
local colors    = require("colors")

local matrix  = component.induction_matrix
local reactor = component.reactor_logic_adapter

local function toRf(joules)
  joules = tonumber(joules) or 0 
  return joules/2.5
end

local function formatNumber(n)
  return format.formatNumber(toRf(n))
end

local function formatPercent(n, max)
  n   = tonumber(n) or 0
  max = tonumber(max) or 0
  if max > 0 then
    return format.formatNumber((n/max)*100)
  else
    return 0
  end
end

local function getReactorStatus()
  if reactor.isIgnited() then
    return "Online"
  else
    return "Offline"
  end
end  

local function handleMatrixFull()
  if matrix.getEnergy() == matrix.getMaxEnergy() then
    if reactor.isIgnited() then
      reactor.setInjectionRate(0)
    end
  end
end


local matrixMaxEnergy, matrixEnergy, matrixEnergyPercent
local matrixInputRate, matrixInputPercent
local matrixOutputRate, matrixOutputPercent, matrixTransferCap
local reactorStatus, reactorPlasmaHeatPercent, reactorProducing
local scaledTransferCap

local function getScaledTransferCap(input, output, cap)
  input  = tonumber(input)  or 0
  output = tonumber(output) or 0
  cap    = tonumber(cap)    or 0

  if (output < cap/2) and (input < cap/2) then
    if output < input then 
      cap = input*1.25
    else
      cap = output*1.25
    end
  end    
  return cap
end

local function setEnergyValues()
  matrixMaxEnergy     = formatNumber(matrix.getMaxEnergy())
  matrixEnergy        = formatNumber(matrix.getEnergy())
  matrixEnergyPercent = formatPercent(matrix.getEnergy(), matrix.getMaxEnergy())
  matrixInputRate     = formatNumber(matrix.getInput())
  matrixInputPercent  = formatPercent(matrix.getInput(), matrix.getTransferCap())
  matrixOutputRate    = formatNumber(matrix.getOutput())
  matrixOutputPercent = formatPercent(matrix.getOutput(), matrix.getTransferCap())
  matrixTransferCap   = formatNumber(matrix.getTransferCap())

  reactorStatus            = getReactorStatus()
  reactorPlasmaHeatPercent = formatPercent(reactor.getPlasmaHeat(), reactor.getMaxPlasmaHeat())
  reactorProducing         = formatNumber(reactor.getProducing())

  scaledTransferCap = getScaledTransferCap(matrix.getInput(), matrix.getOutput(), matrix.getTransferCap())  
end

local function drawStatus()
  local panelCount = 3  
  ui.setScreenPaddingPercent(5, 0, 0, 0)
  local panels = ui.getPanelDimensions(panelCount)

  ui.clear()

  ui.drawScreenText(nil, 1, "Induction Matrix and Reactor Status", "center")

  ui.drawHorizontalPercentageBar(panels[0]["x"], panels[0]["middle"], 1, colors.lime, true, colors.gray, true, matrix.getEnergy(), matrix.getMaxEnergy(), panels[0]["w"])
  ui.drawHorizontalPercentageBar(panels[1]["x"], panels[1]["middle"]-1, 1, colors.lightblue, true, colors.gray, true, matrix.getInput(), scaledTransferCap, panels[1]["w"])
  ui.drawHorizontalPercentageBar(panels[1]["x"], panels[1]["middle"]+1, 1, colors.yellow, true, colors.gray, true, matrix.getOutput(), scaledTransferCap, panels[1]["w"])
  ui.drawHorizontalPercentageBar(panels[2]["x"], panels[2]["middle"], 1, colors.red, true, colors.gray, true, reactor.getPlasmaHeat(), reactor.getMaxPlasmaHeat(), panels[2]["w"])

  ui.drawPanelText(panels[0], nil, panels[0]["middle"]-1, "Energy Level: "..matrixEnergy.." RF", "left")    
  ui.drawPanelText(panels[0], nil, panels[0]["middle"]+1, "Matrix Capacity: "..matrixMaxEnergy.." RF", "right")

  ui.drawPanelText(panels[1], nil, panels[1]["middle"]-2, "Input Rate: "..matrixInputRate.." RF/t", "left")
  ui.drawPanelText(panels[1], nil, panels[1]["middle"], "Max Rate: "..matrixTransferCap.." RF/t", "right")
  ui.drawPanelText(panels[1], nil, panels[1]["middle"]+2, "Output Rate: "..matrixOutputRate.." RF/t", "left")

  if reactor.isIgnited() then
    ui.drawPanelText(panels[2], nil, panels[2]["middle"]-1, "Reactor Status:  "..reactorStatus, "left")
    ui.drawPanelText(panels[2], nil, panels[2]["middle"]+1, "Reactor Production: "..reactorProducing.." RF/t", "left")
  end
end

local oldW, oldH = ui.setResolution(60, 20)

while true do
  setEnergyValues()
  drawStatus()
  handleMatrixFull()

  if keyboard.isControlDown() and keyboard.isKeyDown(keyboard.keys.w) then
    ui.setResolution(oldW, oldH)
    os.exit()
  end

  os.sleep(.25)
end