import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Position;
import Toybox.Application.Storage;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Attention;

class watchairView extends WatchUi.View {
    var mAirQuality as AirQuality?;
    var mMolW as AQMolWeight = new AQMolWeight();

    var mPhoneBitmap as BitmapType?;
    var mLocation as Location?;
    var mAccuracy as Quality = Position.QUALITY_NOT_AVAILABLE;
    var mLastRequestTime as Number = 0;
    var mMessage as String?;
    var mGPSTimerMaxTry as Number = 10;
    var mGPSTimerCount as Number = 0;
    var mGPSTimer as Timer.Timer?;

    var mColor as ColorType = Graphics.COLOR_WHITE;
    //var mColorPending as ColorType = Graphics.COLOR_DK_GRAY;
    var mColorConnectionStats as ColorType = Graphics.COLOR_DK_GRAY;
    var mColorValues as ColorType = Graphics.COLOR_WHITE;

    var mAlertHandled as Boolean = false;    
    function initialize(airQuality as AirQuality) {
        View.initialize();
        mAirQuality = airQuality;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // @@ better icon or poly
        mPhoneBitmap = WatchUi.loadResource(Rez.Drawables.PhoneIcon) as BitmapType;
    }

    function getNewPosition() as Void {        
        var info = Position.getInfo();
        if (info == null || info.accuracy == Position.QUALITY_NOT_AVAILABLE || !hasLocation(info.position, info.accuracy)) {
            setMessage("Waiting for GPS");            
            var setPositionCallBack = self.method(:setPositionAndGetWeatherData) as Method(info as Position.Info) as Void;
            Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, setPositionCallBack);                        
            startGPSTimer();
        } else {
            setPositionAndGetWeatherData(info);
        }
    }

    function getNewWeatherData() as Void {
        if (mGPSTimer == null) {
            getNewPosition();
        } else {
            stopGPSTimer();           
            // Be patient, use last known coordinates
            var msg = checkRequestWeatherData();
            setMessage(msg);
        }
        refreshUiDelayed(2000);
    }
    

    function startGPSTimer() as Void {
        if (mGPSTimer == null) {
            mGPSTimer = new Timer.Timer();
            mGPSTimerCount = mGPSTimerMaxTry;
            var timerCallBack = self.method(:timerCallback) as Method() as Void;
            mGPSTimer.start(timerCallBack, 3000, true); // method(:timerCallback)
        }
    }

    function stopGPSTimer() as Void {
        if (mGPSTimer != null) {
            mGPSTimer.stop();
            mGPSTimer = null;
        }
    }
    function timerCallback() as Void {
        mGPSTimerCount = mGPSTimerCount - 1;
        if (mGPSTimerCount < 0) { 
            stopGPSTimer();
            var msg = checkRequestWeatherData();
            setMessage(msg); 
            WatchUi.requestUpdate();   
            return;
        }
        
        var info = Position.getInfo();
        if (info != null && info has :accuracy && info.accuracy != null) {
            mAccuracy = info.accuracy;                
        }        
        if (info == null || info.accuracy == Position.QUALITY_NOT_AVAILABLE || !hasLocation(info.position, info.accuracy)) {
            setMessage("Waiting (" + mGPSTimerCount.format("%0d") + ") for GPS");
            var setPositionCallBack = self.method(:setPositionAndGetWeatherData) as Method(info as Position.Info) as Void;
            Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, setPositionCallBack);   
        } else if (setPositionAndGetWeatherData(info)) { 
            stopGPSTimer(); 
            setMessage(null);
        }        
        WatchUi.requestUpdate();         
    }
    
    function refreshUiDelayed(time as Lang.Number) as Void {
        var timer = new Timer.Timer();
        var callBack = self.method(:timerRefreshUICallback) as Method() as Void;
        timer.start(callBack, time, false);    
    }

    function timerRefreshUICallback() as Void {
        // clear message
        setMessage(null);   
        WatchUi.requestUpdate(); 
    }

    function setPositionAndGetWeatherData(info as Position.Info) as Boolean {
        if (!setPosition(info)) { return false; }
        var msg = checkRequestWeatherData();
        setMessage(msg); 
        return true;  
    }

    function setPosition(info as Position.Info) as Boolean {
        mAccuracy = Position.QUALITY_NOT_AVAILABLE;
        if (info has :accuracy && info.accuracy != null) {
            mAccuracy = info.accuracy;                
        }        
        if (info has :position && info.position != null) {              
            var location = info.position as Location;
            if (!hasLocation(location, mAccuracy)) { return false; }
            mLocation = location;
            return true;    
        } 
        return false; 
    }

    function hasLocation(location as Position.Location?, accuray as Position.Quality) as Boolean {
        if (location == null || accuray == null) { return false; }

        var degrees = (location as Location).toDegrees();
        //System.println("Location lat/lon: " + degrees + " accuracy: " + mAccuracy);
        return degrees[0] != 0 && degrees[1] != 0 && accuray != Position.QUALITY_NOT_AVAILABLE;                 
    }
    
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {      
        var backFromMenu = Storage.getValue("backFromMenu");  
        if (backFromMenu == null) {
            getNewPosition();        
        } else {
            Storage.deleteValue("backFromMenu");
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);    
        dc.clear();

        // Get latest GPS data
        setPosition(Position.getInfo());

        var airQuality = mAirQuality as AirQuality;
        handleAlert(airQuality);

        drawConnectionStats(dc);
        renderAirQualityStats(dc, airQuality);

        // additional data
        dc.setColor(mColorAdditionalData, Graphics.COLOR_TRANSPARENT);
        
        var degrees = null;
        if (hasLocation(mLocation, mAccuracy)) {  
            // Current position
            degrees = (mLocation as Position.Location).toDegrees();            
        } else {
            // Last known position
            degrees = Storage.getValue("requestCoordinates");
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        }         
        var coordinates = "-- --";
        if (degrees != null) {
            var degreesArray = degrees as Array<Double>;
            coordinates = degreesArray[0].format("%0.4f") + "," + degreesArray[1].format("%0.4f");            
        }

        var lineHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        if (mShowCurrentLocation) {
            var currentCoordWidth = dc.getTextWidthInPixels(coordinates, Graphics.FONT_XTINY);
            drawPerson(dc, dc.getWidth() /2 - currentCoordWidth/2 - 7, lineHeight);            
            dc.drawText(dc.getWidth() /2 , lineHeight, Graphics.FONT_XTINY, coordinates, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
        }

        if (mMessage != null) {
            var message = mMessage as String;
            dc.setColor(mColor, Graphics.COLOR_BLACK);
            dc.drawText(dc.getWidth() /2 , lineHeight * 2, Graphics.FONT_TINY, message, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );            
            dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() /2 , lineHeight * 2, Graphics.FONT_TINY, "Air quality", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );            
        }
        // @@ TODO 
        // var airQualityColor = airQuality.airQualityAsColor();     

        dc.drawText(dc.getWidth() /2 , lineHeight * 3, Graphics.FONT_SMALL, airQuality.airQuality(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );        
        

        dc.setColor(mColorAdditionalData, Graphics.COLOR_TRANSPARENT);
        var startYAdditional = lineHeight * 3.5;
        var lineHeightAdditional = dc.getFontHeight(Graphics.FONT_XTINY) * 0.8;
        var line = 1;
        var xA = dc.getWidth() /2;
        var yA = startYAdditional + lineHeightAdditional;
        if (mObsTimeShow && airQuality.observationTime != null) {
            var obsTime = airQuality.observationTime as Time.Moment;
            var elapsedSeconds = Time.now().value() - obsTime.value();
            if (elapsedSeconds > 0) {
                var ago = secondsToShortTimeString(elapsedSeconds) + " ago";
                dc.drawText(xA , yA, Graphics.FONT_XTINY, ago, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );        
                line = line + 1;
            }
        }
        
        if (mObsLocationShow) {
            coordinates = airQuality.lat.format("%0.4f") + "," + airQuality.lon.format("%0.4f");  
            // var currentCoordWidth = dc.getTextWidthInPixels(coordinates, Graphics.FONT_XTINY);
            yA = startYAdditional + lineHeightAdditional * line;
            dc.drawText(xA , yA, Graphics.FONT_XTINY, coordinates, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );    
            line = line + 1;
        }
        if (mObsDistanceShow) {
            var distToObs = getRelativeToObservation(airQuality.lat, airQuality.lon);
            if (distToObs.length() > 0) {  
                yA = startYAdditional + lineHeightAdditional * line;          
                dc.drawText(xA , yA, Graphics.FONT_XTINY, distToObs, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );        
                line = line + 1;
            }
        }
        
        dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
        var units = "μg/m3";
        if (mUnitsInPPM) { units = "ppm"; }
        yA = startYAdditional + lineHeightAdditional * 4;
        dc.drawText(xA , yA, Graphics.FONT_XTINY, units, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );        
    }
    
    function renderAirQualityStats(dc as Dc, airQuality as AirQuality) as Void {
        if(dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var mean = airQuality.AQM as AQMean;
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var widthCell = 27;
        var radius = (dc.getWidth() / 2) - widthCell - 5;

        var startDeg = -35;
        var endDeg = 215;
        var increment = (startDeg - endDeg) * -1 / 7.0;
        var idx = 0;
        while (idx < 8) {
            var angleInDegrees = startDeg + increment * idx;   
            var x = ((radius * Math.cos(deg2rad(angleInDegrees))) + centerX) as Number;
            var y = ((radius * Math.sin(deg2rad(angleInDegrees))) + centerY) as Number;
            var label = "";
            var value = null;
            var max = 0;
            if (idx == 0) {
                label = "NO2";
                value = airQuality.no2;
                if (mUnitsInPPM) { value = milligramPerM3ToPPM(value, mMolW.NO2); }
                max = mean.NO2;
            } else if (idx == 1) {
                label = "PM10";
                value = airQuality.pm10;
                max = mean.PM10;
            } else if (idx == 2) {
                label = "O3";
                value = airQuality.o3;
                if (mUnitsInPPM) { value = milligramPerM3ToPPM(value, mMolW.O3); }
                max = mean.O3;
            } else if (idx == 3) {
                label = "PM2.5";
                value = airQuality.pm2_5;
                max = mean.PM2_5;
            } else if (idx == 4) {
                label = "SO2";                
                value = airQuality.so2;
                if (mUnitsInPPM) { value = milligramPerM3ToPPM(value, mMolW.SO2); }
                max = mean.SO2;
            } else if (idx == 5) {
                label = "NH3";                
                value = airQuality.nh3;
                if (mUnitsInPPM) { value = milligramPerM3ToPPM(value, mMolW.NH3); }
                max = mean.NH3;
            } else if (idx == 6) {
                label = "CO";                
                value = airQuality.co;
                if (mUnitsInPPM) { value = milligramPerM3ToPPM(value, mMolW.CO); }
                max = mean.CO;
            } else if (idx == 7) {
                label = "NO";                
                value = airQuality.no;
                if (mUnitsInPPM) { value = milligramPerM3ToPPM(value, mMolW.NO); }
                max = mean.NO;
            }

            drawCell(dc, x, y, widthCell, label, value, max, Graphics.FONT_TINY, Graphics.FONT_SYSTEM_XTINY);
            idx = idx + 1;
        }    
    
    }

    function drawCell(dc as Dc, x as Number, y as Number, radius as Number, label as String,
                value as Float?, max as Number, fontLabel as FontType?, fontValue as FontType?) as Void {

        var perc = 0;
        if (value != null && max > 0) {
            var val = value as Float;
            perc = val / (max / 100.0);        
        }
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        fillPercentageCircle(dc, x, y, radius, perc);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, radius);
        
        var labelHeight = 0;       
        if (fontLabel != null) {
            labelHeight = dc.getFontHeight(fontLabel);
            var yLabel = y;
            if (fontValue != null) { yLabel = yLabel - labelHeight / 3; }
            if (perc>=50) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(x, yLabel , fontLabel, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if (fontValue != null) {
            var text = "--";
            if (value != null) {
                text = value.format("%0.2f");
            } 
            dc.setColor(mColorValues, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y + labelHeight / 3, fontValue, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
    
    function fillPercentageCircle(dc as Dc, x as Number, y as Number, radius as Number, perc as Numeric) as Void {
            if (perc == null || perc == 0) {
                return;
            }

            if (perc >= 100.0) {
                dc.fillCircle(x, y, radius);
                return;
            }
            var degrees = 3.6 * perc;

            var degreeStart = 180;                  // 180deg == 9 o-clock
            var degreeEnd = degreeStart - degrees;  // 90deg == 12 o-clock

            dc.setPenWidth(radius);
            dc.drawArc(x, y, radius / 2, Graphics.ARC_CLOCKWISE, degreeStart,
                        degreeEnd);
            dc.setPenWidth(1.0);
        }


    function drawConnectionStats(dc as Dc) as Void {
        var m = dc.getWidth() / 2; 
        var y = 1;
        // var width = 40;
        var height = 20;
        var x = m + 20; 
                
        
        var qna = (mAccuracy == Position.QUALITY_NOT_AVAILABLE);
        if (qna) { 
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }
        var barX = m - 20; //+ 5;
        var bottomY = height;
        var barWidth = 2;
        var space = 2;
        
        if (qna || mAccuracy >= Position.QUALITY_LAST_KNOWN) {
            dc.fillRectangle(barX, y + 15, barWidth, bottomY - 15);
        }
        if (qna || mAccuracy >= Position.QUALITY_POOR) {
            barX = barX + barWidth + space;
            dc.fillRectangle(barX, y + 10, barWidth, bottomY - 10);
        }
        if (qna || mAccuracy >= Position.QUALITY_USABLE) {
            barX = barX + barWidth + space;
            dc.fillRectangle(barX, y + 5, barWidth, bottomY - 5);
        }
        if (qna || mAccuracy >= Position.QUALITY_GOOD) {
            barX = barX + barWidth + space;
            dc.fillRectangle(barX, y, barWidth, bottomY);
        }

        var phoneConnected = System.getDeviceSettings().phoneConnected; 
        if (phoneConnected) {
            y = 1;
            x = m + 5; 
            if (mPhoneBitmap != null) { dc.drawBitmap(x, y, mPhoneBitmap); }
        }            
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}
    
    function checkRequestWeatherData() as String? {
        var apiKey = mApiKey as String;
        if (apiKey.length() == 0) { return "No api key"; }    

        var degrees = null;
        if (hasLocation(mLocation, mAccuracy)) {
            degrees = (mLocation as Position.Location).toDegrees();
        } else {
            degrees = Storage.getValue("requestCoordinates");
        } 
        if (degrees == null) { return "No GPS (Last known)"; }
                
        var lat = (degrees as Array<Double>)[0];
        var lon = (degrees as Array<Double>)[1];
        if (lat == 0.0 && lon == 0.0) { return "No position (0,0)"; }

        var phoneConnected = System.getDeviceSettings().phoneConnected; 
        if (!phoneConnected) { return "Phone not connected"; }

        var diffSeconds = Time.now().value() - mLastRequestTime;
        // @@ Setting
        if (diffSeconds < 10) { return "Wait a moment"; }

        Storage.setValue("requestCoordinates", degrees);
        mLastRequestTime = Time.now().value();
        requestWeatherData(lat, lon, apiKey);
        return "Requesting data";
    }

    // OWM APIDOC: https://openweathermap.org/api/air-pollution
    // - current
    // https://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={API
    // key}
    function requestWeatherData(lat as Double, lon as Double, apiKey as String) as Void {        
        var base = "https://api.openweathermap.org/data/2.5/air_pollution";
        var url = Lang.format("$1$?lat=$2$&lon=$3$&appid=$4$", [ base, lat, lon, apiKey ]);
        
        System.println("requestWeatherData url[" + url + "]");

        var options = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :headers => {
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
                    // "Authorization" => proxyApiKey
                    },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON	
            };
        var responseCallBack = self.method(:onReceiveOpenWeatherResponse)
            as Method(responseCode as Number, responseData as Lang.Dictionary or Null or Lang.String) as Void;

        var params = {};
        Communications.makeWebRequest(url, params, options, responseCallBack);
    }

    function onReceiveOpenWeatherResponse(responseCode as Number, responseData as Lang.Dictionary or Null or Lang.String) as Void {
        if (responseCode == 200 && responseData != null) {
        try {
            // printJson(responseData);

            //    Background: coord: {lon=>4.853500, lat=>52.353600}
            // Background: list: [{components=>{so2=>4.830000, nh3=>0.840000,
            // pm10=>21.190001, no2=>39.070000, co=>387.190002, no=>16.760000,
            // o3=>1.520000, pm2_5=>18.580000}, main=>{aqi=>2}, dt=>1636639200}]                        
                if (responseData instanceof Dictionary) {
                    (mAirQuality as AirQuality).updateData(responseData as Dictionary);
                    setMessage(null);                                      
                } else if (responseData instanceof String) {
                    setMessage(responseData as String);                                      
                }
            } catch (ex) {
                ex.printStackTrace();
                setMessage("Oops: " + ex.getErrorMessage());                
            }
        } else {
            System.println(responseCode);
            setMessage("HTTP error: " + responseCode);                            
        }
        WatchUi.requestUpdate();
    }

    // function printJson(data as Lang.Dictionary or Null or Lang.String) as Void{
    //     if (data == null) {
    //         System.println("No data!");
    //         return;
    //     }
    //     var keys = data.keys();
    //         for (var i = 0; i < keys.size(); i++) {
    //         System.println(Lang.format("$1$: $2$\n", [ keys[i], data[keys[i]] ]));
    //     }  
    // }

    function setMessage(message as String?) as Void {
        mMessage = message;
    }
    
    function secondsToShortTimeString(totalSeconds as Number) as String {  
        if (totalSeconds < 0 ) { return ""; }
        var hours = (totalSeconds / (60 * 60)).toNumber() % 24;
        var minutes = (totalSeconds / 60.0).toNumber() % 60;
        var seconds = (totalSeconds.toNumber() % 60);

        return hours.format("%01d") + ":" + minutes.format("%02d") + ":" + seconds.format("%02d");        
    }

    function getRelativeToObservation(latObservation as Double, lonObservation as Double) as String {
        if (!hasLocation(mLocation, mAccuracy) || latObservation == 0.0 || lonObservation == 0.0 ) {
          return "";
        }

        var degrees = (mLocation as Location).toDegrees();
        var latCurrent = degrees[0];
        var lonCurrent = degrees[1];

        var distanceMetric = "km";
        var distance = getDistanceFromLatLonInKm(latCurrent, lonCurrent, latObservation, lonObservation);

        var deviceSettings = System.getDeviceSettings();
        if (deviceSettings.distanceUnits == System.UNIT_STATUTE) {
          distance = distance / 1.609344; // mile
          distanceMetric = "m";
        }
        var compassDirection = getCompassDirection(getRhumbLineBearing(latCurrent, lonCurrent, latObservation, lonObservation));

        return format("$1$ $2$ ($3$)",[ distance.format("%.2f"), distanceMetric, compassDirection ]);
      }

      function drawPerson(dc as Dc, x as Number, y as Number) as Void {
        dc.fillCircle(x, y - 3, 2);
        dc.drawLine(x, y, x - 1, y + 5);
        dc.drawLine(x, y, x + 1, y + 5);
        dc.drawLine(x - 3, y, x + 3, y);
      }
      
      function handleAlert(airQuality as AirQuality) as Void {
          if (mAlertLevel <= 1 || airQuality.aqi == 0 || airQuality.aqi < mAlertLevel) {
              mAlertHandled = false;
              return;  
          }
          if (mAlertHandled) { return; }

          if (Attention has :vibrate) {
            var vibeData = [
                new Attention.VibeProfile(50, 1000), // On
                new Attention.VibeProfile(0, 500),  // Off
                new Attention.VibeProfile(50, 1000), // On                 
            ] as Array<VibeProfile>;
            Attention.vibrate(vibeData);
          }
          mAlertHandled = true;          
      }
}