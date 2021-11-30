import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.System;
import Toybox.Math;

var mAirQuality as AirQuality = new AirQuality();
var mAQIndex as AQIndex = new AQIndex();
var mApiKey as String? = "";

class watchairApp extends Application.AppBase {

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
        loadUserSettings();
        var view = new watchairView();        
        return [ view, new $.WatchairDelegate(view)] as Array<Views or InputDelegates>;
    }

    function onSettingsChanged() { 
      loadUserSettings();
      AppBase.onSettingsChanged();
    }

    function loadUserSettings() as Void {
      try {
        System.println("Load usersettings");

        // var x = Toybox.Application.Properties;
        var val = Toybox.Application.Properties.getValue("pollutionLimitNO2"); // as Lang.Number;
                
        mApiKey = getStringProperty("openWeatherAPIKey", "");                        
        mAQIndex.NO2 = getNumberProperty("pollutionLimitNO2", mAQIndex.NO2);
        mAQIndex.PM10 = getNumberProperty("pollutionLimitPM10", mAQIndex.PM10);
        mAQIndex.O3 = getNumberProperty("pollutionLimitO3", mAQIndex.O3);
        mAQIndex.PM2_5 = getNumberProperty("pollutionLimitPM2_5", mAQIndex.PM2_5);
        mAQIndex.SO2 = getNumberProperty("pollutionLimitSO2", mAQIndex.SO2);
        mAQIndex.NH3 = getNumberProperty("pollutionLimitNH3", mAQIndex.NH3);
        mAQIndex.CO = getNumberProperty("pollutionLimitCO", mAQIndex.CO);
        mAQIndex.NO = getNumberProperty("pollutionLimitNO", mAQIndex.NO);    
    
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