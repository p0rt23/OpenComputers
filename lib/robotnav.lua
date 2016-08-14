local robotnav = {}

local sides     = require("sides")
local component = require("component")
local robot     = component.robot

local range   = 100
local debugOn = false
local navData
local curOffset = {}
local curFacing

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

local dirNamesAbs = {
  [0] = "Down",
  [1] = "Up", 
  [2] = "North", 
  [3] = "South", 
  [4] = "West", 
  [5] = "East"
}

local dirNamesRel = {
  [0] = "Down",
  [1] = "Up", 
  [2] = "Back", 
  [3] = "Forward", 
  [4] = "Right", 
  [5] = "Left"
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

local function debugOut(d)
  if debugOn then
    print(d)
  end
end

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

local function turn(side)
  if side ~= curFacing then

    local isClockwise
    if turnRight[curFacing][side] then
      isClockwise = true
    elseif turnLeft[curFacing][side] then 
      isClockwise = false
    else
      isClockwise = nil
    end

    if isClockwise == nil then
      debugOut("Turning Around")
      if not robot.turn(true) then
        debugOut("Can't turn")
        os.exit()
      end
      if not robot.turn(true) then
        debugOut("Can't turn")
        os.exit()
      end
    else
      debugOut("Turning "..(isClockwise and "Right" or "Left"))
      if not robot.turn(isClockwise) then
        debugOut("Can't turn")
        os.exit()
      end
    end
    curFacing = side
  end   
end

local function move(side)
  debugOut("Need to move: "..dirNamesAbs[side])
  if (side ~= sides.up) and (side ~= sides.down) then
    turn(side)
    if robot.detect(sides.forward) then
      debugOut("Can't move "..dirNamesRel[sides.forward])
      return false
    else 
      debugOut("Moving "..dirNamesRel[sides.forward])
      return robot.move(sides.forward)
    end
  else
    if robot.detect(side) then
      debugOut("Can't move "..dirNamesRel[side])
      return false
    else
      debugOut("Moving: "..dirNamesRel[side])
      return robot.move(side)
    end
  end
end

local function setCurrentOffset(waypoint)
  if waypoint["position"] then
    curOffset["x"] = waypoint["position"][1]  
    curOffset["y"] = waypoint["position"][2]
    curOffset["z"] = waypoint["position"][3]
  end
end

function robotnav.setDebugOn(b)
  debugOn = b
end

function robotnav.moveToWaypoint(label)
  local waypoints = getWaypointsByLabel(label)
  setCurrentOffset(waypoints[1]) 

  local isMoving = true
  while isMoving do
    isMoving = false

    for dir, dist in pairs(curOffset) do
      debugOut("x: "..curOffset["x"].." y: "..curOffset["y"].." z: "..curOffset["z"])
      if dist ~= 0 then
        isMoving = true

        local isPos = dist >= 0

        debugOut("Thinking about moving "..(isPos and "+" or "-")..dir)
 
        if move(whichDir[dir][isPos]) then
          curOffset[dir] = curOffset[dir] - (isPos and 1 or -1)
        else
          os.exit()
        end
      end
    end
  end
end

function robotnav.setWaypointRange(n)
  range = n
end

function robotnav.init()
  navData = getNavData()
  curFacing = navData["facing"]
end

return robotnav