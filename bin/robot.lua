local robotnav = require("robotnav")

robotnav.setDebugOn(true)
robotnav.setWaypointRange(1000)

robotnav.init()
robotnav.moveToWaypoint("Charger")