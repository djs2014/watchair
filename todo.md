cleanup utils - getApplicationProperty, getValue->getDictionaryValue
observation time(zone?)
different fonts for edge / watch device (resource?/check height of screen)

beep alerts
  custom menu
    beep on xxxx / off
    vibrate on xxxx / off
    - toggle on all values

show phone / gps level icons??
memory issue.. prg <= 112 kb
- cleanup | remove unused code - low memory

docu

Getting api key
HTTP 401 -> Api key wrong
next screen - show one item + explanation what it is..
test on edge ..


------
get image / map from web
-> put current location on image

https://gis.stackexchange.com/questions/133205/wmts-convert-geolocation-lat-long-to-tile-index-at-a-given-zoom-level

n = 2 ^ zoom
xtile = n * ((lon_deg + 180) / 360)
ytile = n * (1 - (log(tan(lat_rad) + sec(lat_rad)) / π)) / 2

https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#ECMAScript_.28JavaScript.2FActionScript.2C_etc..29
function lon2tile(lon,zoom) { return (Math.floor((lon+180)/360*Math.pow(2,zoom))); }
 function lat2tile(lat,zoom)  { return (Math.floor((1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom))); }


https://tile.openweathermap.org/map/{layer}/{z}/{x}/{y}.png?appid={API key}
