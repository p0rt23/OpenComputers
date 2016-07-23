local component = require("component")
local term      = require("term")
local keyboard  = require("keyboard")
local format    = require("format")

local gpu     = component.gpu
local matrix  = component.induction_matrix
local reactor = component.reactor_logic_adapter

local function toRf(joules)
  return joules/2.5
end

local function getMatrixEnergy()
  return format.formatNumber(toRf(matrix.getEnergy()))
end

local function getMatrixMaxEnergy()
  return format.formatNumber(toRf(matrix.getMaxEnergy()))
end

local function getMatrixEnergyPercent()
  return format.formatNumber((matrix.getEnergy()/matrix.getMaxEnergy())*100)
end

local function getMatrixInputRate()
  return format.formatNumber(toRf(matrix.getInput()))
end

local function getMatrixInputPercent()
  return format.formatNumber((matrix.getInput()/matrix.getTransferCap())*100)
end

local function getMatrixOutputRate()
  return format.formatNumber(toRf(matrix.getOutput()))
end

local function getMatrixOutputPercent()
  return format.formatNumber((matrix.getOutput()/matrix.getTransferCap())*100)
end

local function getMatrixTransferCap()
  return format.formatNumber(toRf(matrix.getTransferCap()))
end

local function getReactorPlasmaHeatPercent()
  if reactor.getMaxPlasmaHeat() > 0 then
    return format.formatNumber((reactor.getPlasmaHeat()/reactor.getMaxPlasmaHeat())*100) 
  else 
    return 0
  end
end

local function getReactorProducing()
  return format.formatNumber(toRf(reactor.getProducing()))
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

local function setEnergyValues()
  matrixMaxEnergy     = getMatrixMaxEnergy()
  matrixEnergy        = getMatrixEnergy()
  matrixEnergyPercent = getMatrixEnergyPercent()
  matrixInputRate     = getMatrixInputRate()
  matrixInputPercent  = getMatrixInputPercent()
  matrixOutputRate    = getMatrixOutputRate()
  matrixOutputPercent = getMatrixOutputPercent()
  matrixTransferCap   = getMatrixTransferCap()

  reactorStatus            = getReactorStatus()
  reactorPlasmaHeatPercent = getReactorPlasmaHeatPercent()
  reactorProducing         = getReactorProducing()
end

local function printStatus()
  print("Max Capacity:      "..matrixMaxEnergy.." RF")
  print("Current Capacity:  "..matrixEnergy.." RF ("..matrixEnergyPercent.."%)")
  print()
--  print("Max Transfer Rate: "..matrixTransferCap.." RF/t")
  print("Input Rate:        "..matrixInputRate.." RF/t".." ("..matrixInputPercent.."%)")
  print("Output Rate:       "..matrixOutputRate.." RF/t".." ("..matrixOutputPercent.."%)")
  print()
  print("Reactor Status:    "..reactorStatus)
  print("Reactor Heat:      "..reactorPlasmaHeatPercent.."%")
  print("Reactor Power:     "..reactorProducing.." RF/t")
end

local oldMatrixEnergy, oldMatrixInputRate, oldMatrixOutputRate

local oldW, oldH = gpu.getResolution()
gpu.setResolution(40, 10)

while true do
  setEnergyValues()
  term.clear()
  printStatus()
  handleMatrixFull()

  if keyboard.isControlDown() and keyboard.isKeyDown(keyboard.keys.w) then
    gpu.setResolution(oldW, oldH)
    os.exit()
  end

  os.sleep(0.5)
end