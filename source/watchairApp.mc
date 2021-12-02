import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.System;
import Toybox.Math;

var mApiKey as String? = "";
var mShowCurrentLocation as Boolean = true;
var mShowObsTime as Boolean = true;
var mShowObsLocation as Boolean = true;
var mShowObsDistance as Boolean = true;

class watchairApp extends Application.AppBase {
    var mAirQuality as AirQuality?;

    function initialize() {
      AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
      System.println("Start");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
      System.println("Stop");
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {        
      if (mAirQuality == null) { mAirQuality = new AirQuality(); }
      var airQuality = mAirQuality as AirQuality;

      loadUserSettings(airQuality);
      var view = new watchairView(airQuality);        
      return [ view, new $.WatchairDelegate(view)] as Array<Views or InputDelegates>;
    }

    function onSettingsChanged() { 
      if (mAirQuality == null) { mAirQuality = new AirQuality(); }
      var airQuality = mAirQuality as AirQuality;
      loadUserSettings(airQuality);
      AppBase.onSettingsChanged();
    }

    function loadUserSettings(airQuality as AirQuality) as Void {
      try {
        System.println("Load usersettings");
        
        // var x = Toybox.Application.Properties;
        var val = Toybox.Application.Properties.getValue("pollutionLimitNO2"); // as Lang.Number;
                
        mApiKey = getStringProperty("openWeatherAPIKey", "");                        
        airQuality.AQM.NO2 = getNumberProperty("pollutionLimitNO2", airQuality.AQM.NO2);
        airQuality.AQM.PM10 = getNumberProperty("pollutionLimitPM10", airQuality.AQM.PM10);
        airQuality.AQM.O3 = getNumberProperty("pollutionLimitO3", airQuality.AQM.O3);
        airQuality.AQM.PM2_5 = getNumberProperty("pollutionLimitPM2_5", airQuality.AQM.PM2_5);
        airQuality.AQM.SO2 = getNumberProperty("pollutionLimitSO2", airQuality.AQM.SO2);
        airQuality.AQM.NH3 = getNumberProperty("pollutionLimitNH3", airQuality.AQM.NH3);
        airQuality.AQM.CO = getNumberProperty("pollutionLimitCO", airQuality.AQM.CO);
        airQuality.AQM.NO = getNumberProperty("pollutionLimitNO", airQuality.AQM.NO);    
    
        System.println("loadUserSettings loaded");
      } catch (ex) {
        ex.printStackTrace();
      }
    }
    
    function getNumberProperty(key as Application.PropertyKeyType, dflt as Lang.Number) as Lang.Number {
      try {
        var val = Toybox.Application.Properties.getValue(key) as Lang.Number;
        if (val != null && val instanceof Lang.Number) {
          return val;
        }
      } catch (e) {
        return dflt;
      }
      return dflt;
    }

    function getStringProperty(key as Application.PropertyKeyType, dflt as Lang.String) as Lang.String {
      try {
        var val = Toybox.Application.Properties.getValue(key as Lang.String) as Lang.String;
        System.println(val);
        if (val != null && val instanceof Lang.String) {
          return val;
        }
      } catch (e) {
        return dflt;
      }
      return dflt;
    }

}

function getApp() as watchairApp {
    return Application.getApp() as watchairApp;
}