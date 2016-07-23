local component = require("component")
local term      = require("term")
local keyboard  = require("keyboard")

local gpu    = component.gpu
local matrix = component.induction_matrix

local oldW, oldH = gpu.getResolution()
gpu.setResolution(40,10)

local function round(f,p)
  if p == nil then
    if     f < 1     then p = 2
    elseif f < 10    then p = 2
    elseif f < 100   then p = 1
    elseif f < 10000 then p = 1
    else   p = 0
    end
  end
  if p > 0 then
    return(math.floor(f*10^p+0.5)/10^p)
  else
    return(math.floor(f+0.5))
  end
end

local function formatNumber(n)
  if     n < 10^3  then n = round(n)
  elseif n < 10^6  then n = round(n/10^3) .."k" 
  elseif n < 10^9  then n = round(n/10^6) .."M"
  elseif n < 10^12 then n = round(n/10^9) .."B"
  else                  n = round(n/10^12).."T"
  end
  return n
end

local function toRf(joules)
  return joules/2.5
end

local function getEnergyRf()
  return toRf(matrix.getEnergy())
end

local function getMaxEnergyRf()
  return toRf(matrix.getMaxEnergy())
end

local function getPercentFull()
  return (matrix.getEnergy()/matrix.getMaxEnergy())*100
end

local function getInputRf()
  return toRf(matrix.getInput())
end

local function getInputPercent()
  return (matrix.getInput()/matrix.getTransferCap())*100
end

local function getOutputRf()
  return toRf(matrix.getOutput())
end

local function getOutputPercent()
  return (matrix.getOutput()/matrix.getTransferCap())*100
end

local function getTransferCapRf()
  return toRf(matrix.getTransferCap())
end


local maxEnergy
local energy
local percentFull
local input
local inputPercent
local output
local outputPercent
local transferCap

local function setEnergyValues()
  maxEnergy     = formatNumber(getMaxEnergyRf())
  energy        = formatNumber(getEnergyRf())
  percentFull   = formatNumber(getPercentFull())
  input         = formatNumber(getInputRf())
  inputPercent  = formatNumber(getInputPercent())
  output        = formatNumber(getOutputRf())
  outputPercent = formatNumber(getOutputPercent())
  transferCap   = formatNumber(getTransferCapRf())
end

local function printStatus()
  print("Max Capacity:      "..maxEnergy.." RF")
  print("Current Capacity:  "..energy.." RF ("..percentFull.."%)")
  print()
  print("Max Transfer Rate: "..transferCap.." RF/t")
  print("Input Rate:        "..input.." RF/t".." ("..inputPercent.."%)")
  print("Output Rate:       "..output.." RF/t".." ("..outputPercent.."%)")
end

term.clear()
setEnergyValues()
printStatus()

while true do
  local oldEnergy = energy
  local oldInput  = input
  local oldOutput = output
  setEnergyValues()
  if oldEnergy ~= energy or oldInput ~= input or oldOutput ~= output then
    term.clear()
    printStatus()
  end
  if keyboard.isControlDown() and keyboard.isKeyDown(keyboard.keys.w) then
    gpu.setResolution(oldW, oldH)
    os.exit()
  end
  os.sleep(0.5)
end
