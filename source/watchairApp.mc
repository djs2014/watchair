import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.System;
import Toybox.Math;
import Toybox.Graphics;

var mApiKey as String? = "";
var mShowCurrentLocation as Boolean = true;
var mObsTimeShow as Boolean = true;
var mObsLocationShow as Boolean = true;
var mObsDistanceShow as Boolean = true;
var mUnitsInPPM as Boolean = false;
var mColorAdditionalData as ColorType = Graphics.COLOR_DK_GRAY;

class watchairApp extends Application.AppBase {
    var mAirQuality as AirQuality?;

    function initialize() {
      AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
      // System.println("Start");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
      // System.println("Stop");
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {        
      if (mAirQuality == null) { mAirQuality = new AirQuality(); }
      var airQuality = mAirQuality as AirQuality;

      loadUserSettings(airQuality);
      var view = new watchairView(airQuality);        
      return [ view, new $.WatchairDelegate(self, view)] as Array<Views or InputDelegates>;
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
        
        //@@ var val = Toybox.Application.Properties.getValue("pollutionLimitNO2"); // as Lang.Number;                
        mApiKey = getApplicationProperty("openWeatherAPIKey", "") as Lang.String;                        
        airQuality.AQM.NO2 = getApplicationProperty("pollutionLimitNO2", airQuality.AQM.NO2) as Lang.Number;
        airQuality.AQM.PM10 = getApplicationProperty("pollutionLimitPM10", airQuality.AQM.PM10) as Lang.Number;
        airQuality.AQM.O3 = getApplicationProperty("pollutionLimitO3", airQuality.AQM.O3) as Lang.Number;
        airQuality.AQM.PM2_5 = getApplicationProperty("pollutionLimitPM2_5", airQuality.AQM.PM2_5) as Lang.Number;
        airQuality.AQM.SO2 = getApplicationProperty("pollutionLimitSO2", airQuality.AQM.SO2) as Lang.Number;
        airQuality.AQM.NH3 = getApplicationProperty("pollutionLimitNH3", airQuality.AQM.NH3) as Lang.Number;
        airQuality.AQM.CO = getApplicationProperty("pollutionLimitCO", airQuality.AQM.CO) as Lang.Number;
        airQuality.AQM.NO = getApplicationProperty("pollutionLimitNO", airQuality.AQM.NO) as Lang.Number;

        updateWatchSettings();
        System.println("loadUserSettings loaded");
      } catch (ex) {
        ex.printStackTrace();
      }
    }
}

function updateWatchSettings() as Void {
  mObsTimeShow = getApplicationProperty("obsTimeShow", mObsTimeShow) as Lang.Boolean;    
  mObsLocationShow = getApplicationProperty("obsLocationShow", mObsLocationShow) as Lang.Boolean;       
  mObsDistanceShow = getApplicationProperty("obsDistanceShow", mObsDistanceShow) as Lang.Boolean;    
  mUnitsInPPM = getApplicationProperty("unitsInPPM", mUnitsInPPM) as Lang.Boolean;       

  // Colorpicker results
  var value = Storage.getValue("colorAdditionalData");
  if (value instanceof Lang.Number) {
    mColorAdditionalData = value as ColorType;         
  }
}

function getApplicationProperty(key as Application.PropertyKeyType, dflt as Application.PropertyValueType ) as Application.PropertyValueType {
  try {
    var val = Toybox.Application.Properties.getValue(key);
    if (val != null) { return val; }
  } catch (e) {
    return dflt;
  }
  return dflt;
}

function getApp() as watchairApp {
    return Application.getApp() as watchairApp;
}