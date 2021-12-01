--> in menu 
serialize last aq data

show phone / gps level icons??
memory issue..

?? toglle ppm / microm3
colors text
keep in memory aq data
show x:x:x ago
xx km (WSW)
alert/vibrate/beep > level
remove msg after x seconds

- cleanup | remove unused code - low memory
- test menu 2 items
    x - see menutest  app
- load settings code
- on show view -> get position etc .. get data
    - gps quality 
        - > see basic custom show the options + indicate selected
        -> handle select

    - update freq / -1 == off -2 == automatic / 5 / 10 / 20 / 30 / 60
    - nox levels
    - api key -> via settings easier

- 
store last known gps coord
get gps
- not found use stored values
- indicate this
- show gps coord on screen
- distance to observation
- phone connected
- call to owm + indicate callpending time
  - on tap / on
- display data

-- if no position found -> use timer for x times -> until onBack pressed -> stop timer
using Toybox.Position;
using Toybox.System;
using Toybox.Timer;
var dataTimer = new Timer.Timer();
dataTimer.start(method(:timerCallback), 1000, true); // A one-second timer
function timerCallback() {
    var positionInfo = Position.getInfo();
    if (positionInfo has :altitude && positionInfo.altitude != null) {
        var altitude = positionInfo.altitude;
        System.println("Altitude: " + altitude);
    }
}