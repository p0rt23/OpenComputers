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

local function formatNumber(n)
  return format.formatNumber(toRf(n))
end

local function formatPercent(n, max)
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

local function setEnergyValues()
  matrixMaxEnergy     = formatNumber(matrix.getMaxEnergy())
  matrixEnergy        = formatNumber(matrix.getEnergy())
  matrixEnergyPercent = formatPercent(matrix.getEnergy(), matrix.getMaxEnergy())
  matrixInputRate     = formatNumber(matrix.getInput())
  matrixInputPercent  = formatPercent(matrix.getInput(), matrix.getTransferCap())
  matrixOutputRate    = formatNumber(matrix.getOutput())
  matrixOutputPercent = formatPercent(matrix.getOutput(), matrix.getTransferCap())

  reactorStatus            = getReactorStatus()
  reactorPlasmaHeatPercent = formatPercent(reactor.getPlasmaHeat(), reactor.getMaxPlasmaHeat())
  reactorProducing         = formatNumber(reactor.getProducing())
end

local function printStatus()
  print("Max Capacity:      "..matrixMaxEnergy.." RF")
  print("Current Capacity:  "..matrixEnergy.." RF ("..matrixEnergyPercent.."%)")
  print()
  print("Input Rate:        "..matrixInputRate.." RF/t".." ("..matrixInputPercent.."%)")
  print("Output Rate:       "..matrixOutputRate.." RF/t".." ("..matrixOutputPercent.."%)")
  print()
  print("Reactor Status:    "..reactorStatus)
  print("Reactor Heat:      "..reactorPlasmaHeatPercent.."%")
  print("Reactor Power:     "..reactorProducing.." RF/t")
end

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
