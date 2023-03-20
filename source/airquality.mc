import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

class AirQuality {    
  var AQM as AQMean = new AQMean();  

  var lat as Double = 0.0d;
  var lon as Double = 0.0d;
  // Carbon monoxide (CO), Nitrogen monoxide (NO), Nitrogen dioxide (NO2), Ozone
  // (O3), Sulphur dioxide (SO2), Ammonia (NH3), and particulates (PM2.5 and
  // PM10).

  var so2 as Float?;
  var nh3 as Float?;
  var pm10 as Float?;
  var no2 as Float?;
  var co as Float?;
  var no as Float?;
  var o3 as Float?;
  var pm2_5 as Float?;
  // Air quality index
  //   Qualitative name 	Index 	Pollutant concentration in μg/m3
  // 	        NO2 	PM10 	O3 	PM25 (optional)
  // Good 	1 	0-50 	0-25 	0-60 	0-15
  // Fair 	2 	50-100 	25-50 	60-120 	15-30
  // Moderate 	3 	100-200 	50-90 	120-180 	30-55
  // Poor 	4 	200-400 	90-180 	180-240 	55-110
  // Very Poor 	5 	>400 	>180 	>240 	>110
  var aqi as Number = 0;
  // var aqiName as Array = [ "--", "Good", "Fair", "Moderate", "Poor", "Very poor" ];
  var observationTime as Time.Moment?;

  function initialize() {}

  function reset()  as Void {
    lat = 0.0d;
    lon = 0.0d;
    //
    so2 = null;
    nh3 = null;
    pm10 = null;
    no2 = null;
    co = null;
    no = null;
    o3 = null;
    pm2_5 = null;
    //
    aqi = 0;
    observationTime = null;
  }

  
  // Returns observation time
  function updateData(data as Dictionary) as Void {
    //    Background: coord: {lon=>4.853500, lat=>52.353600}
    // Background: list: [{components=>{so2=>4.830000, nh3=>0.840000,
    // pm10=>21.190001, no2=>39.070000, co=>387.190002, no=>16.760000,
    // o3=>1.520000, pm2_5=>18.580000}, main=>{aqi=>2}, dt=>1636639200}]
    try {
      if (data == null) { return; }
      
      reset();
      var coord = data["coord"] as Dictionary; //<String, Float>;
      if (coord != null) {
        lat = getValue(coord, "lat", 0.0d) as Double;
        lon = getValue(coord, "lon", 0.0d) as Double;        
      }
      var list = data["list"] as Array;
      if (list != null) {
        var item = list[0] as Dictionary;
        var main = item["main"] as Dictionary;
        if (main != null) { aqi = getValue(main, "aqi", 0) as Number; }
        var components = item["components"] as Dictionary;
        so2 = getValue(components,"so2", null) as Float?;
        nh3 = getValue(components,"nh3", null) as Float?;
        pm10 = getValue(components,"pm10", null) as Float?;
        no2 = getValue(components,"no2", null) as Float?;
        co = getValue(components,"co", null) as Float?;
        no = getValue(components,"no", null) as Float?;
        o3 = getValue(components,"o3", null) as Float?;
        pm2_5 = getValue(components,"pm2_5", null) as Float?;
            
        var dt = getValue(item, "dt", 0) as Number;
        if (dt > 0) { observationTime = new Time.Moment(dt); }      
      }      
    } catch (ex) {
      ex.printStackTrace();
    }   
  }

  function airQuality() as String {
    if (aqi == null || aqi <= 0 ) {
      return "--";
    } else if (aqi == 1) {
      return "Good";
    } else if (aqi == 2) {
      return "Fair";
    } else if (aqi == 3) {
      return "Moderate";
    } else if (aqi == 4) {
      return "Poor";
    } 
    return "Very poor";
  }

  hidden function getValue(data as Dictionary, key as String, defaultValue as Numeric?) as Numeric? {
    var value = data.get(key);
    if (value == null) { return defaultValue; }
    return value as Numeric;
  }
  
}

// https://www.c40knowledgehub.org/s/article/WHO-Air-Quality-Guidelines?language=en_US
// https://www.ser.nl/nl/thema/arbeidsomstandigheden/Grenswaarden-gevaarlijke-stoffen/Grenswaarden/Ozon    
class AQMean {
    // moderate values in microgram per m3: µg/m3 24-hour mean.
    var NO2 as Number = 25;
    var PM10 as Number = 45; 
    var O3 as Number = 100; 
    var PM2_5 as Number = 15; 

    var SO2 as Number = 40; 
    var NH3 as Number = 14000;
    var CO as Number = 7;
    var NO as Number = 2500;

    function initialize() {}    
}

// https://www.teesing.com/en/page/library/tools/ppm-mg3-converter
// concentration (ppm) = 24.45 x concentration (mg/m3) ÷ molecular weight (g/mol)
function milligramPerM3ToPPM(mgperm3 as Float?, molWeight as Float) as Float? {
    if (molWeight == null || mgperm3 == null ) { return null; }
    if (molWeight == 0) { return 0.0f; }
    return (24.45 * (mgperm3 as Float) / molWeight);
}

// concentration (mg/m3) = 0.0409 x concentration (ppm) x molecular weight (g/mol)
// function ppmTomilligramPerM3(ppm as Number, molWeight as Float) as Float {
//   if (molWeight == 0) { return 0.0; }
//   return 0.0409 * ppm / molWeight;
// }
class AQMolWeight {
    // Molecular weight
    // https://www.breeze-technologies.de/blog/air-pollution-how-to-convert-between-mgm3-%C2%B5gm3-ppm-ppb/
    var NO2 as Float = 46.01f; // g/mol
    var PM10 as Float = 0.0f; // impossible
    var O3 as Float = 48.00f; 
    var PM2_5 as Float = 0.0f; // impossible

    var SO2 as Float = 64.06f; 
    var NH3 as Float = 17.03f;
    var CO as Float = 28.01f;
    var NO as Float = 30.01f;

    // https://www.teesing.com/en/page/library/tools/ppm-mg3-converter

    // NO2 1 ppm = 1.88 μg/m3
    // PM10 1 ppm = 
    // O3 1 ppm = 2.00 μg/m3
    // PM2_5 1 ppm =
    // SO2 1 ppm = 2.62 μg/m3
    // NH3 1 ppm = 0.697 mg/m3
    // CO 1 ppm = 1.145 μg/m3
    // NO 1 ppm = 1.25 μg/m3


    function initialize() {}    
}