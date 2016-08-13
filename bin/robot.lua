local sides     = require("sides")
local component = require("component")
local robot     = require("robot")

local range = 1000
local destination = "Charger"
local navData
local curFacing
local curOffset

local whichDir = {
  x = {
    [true]  = sides.east,
    [false] = sides.west
  },
  y = {
    [true]  = sides.up,
    [false] = sides.down
  },
  z = {
    [true]  = sides.south,
    [false] = sides.north
  }
}

local turnRight = {
  [2] = {[5] = true},
  [5] = {[3] = true},
  [3] = {[4] = true},
  [4] = {[2] = true}
}

local turnLeft = {
  [2] = {[4] = true},
  [5] = {[2] = true},
  [3] = {[5] = true},
  [4] = {[3] = true}
}

local function getNavData()
  local navData = {}
  local status, err = pcall(function()
    local nav = component.navigation
    navData["waypoints"] = nav.findWaypoints(range)
    navData["facing"] = nav.getFacing()
  end)
  return navData
end

local function getWaypointsByLabel(label)
  local waypoints = navData["waypoints"]
  local matches = {}
  local index = 1

  for i, t in ipairs(waypoints) do
    for k, v in pairs(t) do
      if v == label then
        matches[index] = t
        index = index + 1
      end
    end
  end

  return matches
end

local function getWaypointPosition(label)
  local position = {}

  local waypoints = getWaypointsByLabel(label)
  if waypoints[1] then
    position["x"] = waypoints[1]["position"][1]  
    position["y"] = waypoints[1]["position"][2]
    position["z"] = waypoints[1]["position"][3]
  end

  return position
end

local function turn(side)
  if side ~= curFacing then
    if turnRight[curFacing][side] then
      robot.turnRight()
    elseif turnLeft[curFacing][side] then
      robot.turnLeft()
    else
      robot.turnAround()
    end
    curFacing = side
  end   
end

local function move(dir, isPos)
  if dir == "y" then
    if (isPos) then
      if not robot.detectUp() then
        robot.up()
      else
        os.exit()
      end
    else
      if not robot.detectDown() then
        robot.down()
      else
        os.exit()
      end
    end
  else
    turn(whichDir[dir][isPos])
    if not robot.detect() then
      robot.forward()
    else
      os.exit()
    end
  end
  curOffset[dir] = curOffset[dir] - (isPos and 1 or -1)
end

local function moveToWaypoint(label)
  curOffset = getWaypointPosition(label)

  local isMoving = true
  while isMoving do
    isMoving = false

    for dir, dist in pairs(curOffset) do
      if dist ~= 0 then
        isMoving = true
        print(dir..": "..dist)
        local isPos = dist >= 0
        move(dir, isPos)
      end
    end
  end
end

navData = getNavData()
curFacing = navData["facing"]
moveToWaypoint(destination)