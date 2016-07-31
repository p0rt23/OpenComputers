local component = require("component")
local keyboard  = require("keyboard")
local format    = require("format")
local ui        = require("ui")
local colors    = require("colors")

local function toRf(joules)
  joules = tonumber(joules) or 0 
  return joules/2.5
end

local function formatNumber(n)
  return format.formatNumber(toRf(n))
end

local function formatPercent(n, max)
  n   = tonumber(n)   or 0
  max = tonumber(max) or 0

  if max > 0 then
    return format.formatNumber((n/max)*100)
  else
    return 0
  end
end

local function getInductionMatrixValues()
  local matrix = {}

  local status, err = pcall(function ()
    local compMatrix = component.induction_matrix
    matrix["maxEnergy"]   = compMatrix.getMaxEnergy()
    matrix["energy"]      = compMatrix.getEnergy()
    matrix["input"]       = compMatrix.getInput()
    matrix["output"]      = compMatrix.getOutput()
    matrix["transferCap"] = compMatrix.getTransferCap()
  end)

  return matrix
end

local function getReactorLogicAdapterValues()
  local reactor = {}

  local status, err = pcall(function ()
    local compReactor = component.reactor_logic_adapter
    reactor["isIgnited"]     = compReactor.isIgnited()
    reactor["plasmaHeat"]    = compReactor.getPlasmaHeat()
    reactor["maxPlasmaHeat"] = compReactor.getMaxPlasmaHeat()
    reactor["producing"]     = compReactor.getProducing()
  end)

  return reactor
end

local function powerReactorOff()
    local status, err = pcall(function ()
      reactor.setInjectionRate(0)
    end)
end

local function getScaledTransferCap(input, output, cap)
  input  = tonumber(input)  or 0
  output = tonumber(output) or 0
  cap    = tonumber(cap)    or 0  

  if (output < cap/25) and (input < cap/25) then
    cap = cap/25
  end

  return cap
end

local function getMatrixReactorStatus()
  local matrix  = getInductionMatrixValues()
  local reactor = getReactorLogicAdapterValues()
  local status  = {}

  status["displayMaxEnergy"]   = formatNumber(matrix["maxEnergy"])
  status["displayEnergy"]      = formatNumber(matrix["energy"])
  status["displayTransferCap"] = formatNumber(matrix["transferCap"])
  status["displayInput"]       = formatNumber(matrix["input"])
  status["displayOutput"]      = formatNumber(matrix["output"])
  
  status["displayProducing"] = formatNumber(reactor["producing"])
  
  status["reactorStatus"]     = reactor["isIgnited"] and "Online" or "Offline"
  status["scaledTransferCap"] = getScaledTransferCap(matrix["input"], matrix["output"], matrix["transferCap"])  
  status["isPowerReactorOff"] = (status["reactorStatus"] == "Online") and (matrix["energy"] == matrix["maxEnergy"])

  status["matrix"]  = matrix
  status["reactor"] = reactor

  return status
end

local function drawStatus(status)
  local panelCount = 3  
  ui.setScreenPaddingPercent(5, 0, 0, 0)
  local panels = ui.getPanelDimensions(panelCount)

  ui.clear()

  ui.drawScreenText(nil, 1, "Induction Matrix and Reactor Status", "center")

  ui.drawHorizontalPercentageBar(panels[0]["x"], panels[0]["middle"], 1, colors.lime, true, colors.gray, true, status["matrix"]["energy"], status["matrix"]["maxEnergy"], panels[0]["w"])
  ui.drawHorizontalPercentageBar(panels[1]["x"], panels[1]["middle"]-1, 1, colors.lightblue, true, colors.gray, true, status["matrix"]["input"], status["scaledTransferCap"], panels[1]["w"])
  ui.drawHorizontalPercentageBar(panels[1]["x"], panels[1]["middle"]+1, 1, colors.yellow, true, colors.gray, true, status["matrix"]["output"], status["scaledTransferCap"], panels[1]["w"])
  ui.drawHorizontalPercentageBar(panels[2]["x"], panels[2]["middle"], 1, colors.red, true, colors.gray, true, status["reactor"]["plasmaHeat"], status["reactor"]["maxPlasmaHeat"], panels[2]["w"])

  ui.drawPanelText(panels[0], nil, panels[0]["middle"]-1, "Energy Level: "..status["displayEnergy"].." RF", "left")    
  ui.drawPanelText(panels[0], nil, panels[0]["middle"]+1, "Matrix Capacity: "..status["displayMaxEnergy"].." RF", "right")

  ui.drawPanelText(panels[1], nil, panels[1]["middle"]-2, "Input Rate: "..status["displayInput"].." RF/t", "left")
  ui.drawPanelText(panels[1], nil, panels[1]["middle"], "Max Rate: "..status["displayTransferCap"].." RF/t", "right")
  ui.drawPanelText(panels[1], nil, panels[1]["middle"]+2, "Output Rate: "..status["displayOutput"].." RF/t", "left")

  ui.drawPanelText(panels[2], nil, panels[2]["middle"]-1, "Reactor Status:  "..status["reactorStatus"], "left")
  if status["reactor"]["isIgnited"] then
    ui.drawPanelText(panels[2], nil, panels[2]["middle"]+1, "Reactor Production: "..status["displayProducing"].." RF/t", "left")  
  end
end

local oldW, oldH = ui.setResolution(60, 20)

while true do
  local status = getMatrixReactorStatus()
  drawStatus(status)
  if status["isPowerReactorOff"] then
    powerReactorOff()
  end

  if keyboard.isControlDown() and keyboard.isKeyDown(keyboard.keys.w) then
    ui.setResolution(oldW, oldH)
    os.exit()
  end

  os.sleep(.25)
end
