//
// Copyright 2018-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! This delegate is for the main page of our application that pushes the menu
//! when the onMenu() behavior is received.
class WatchairDelegate extends WatchUi.BehaviorDelegate {
    var app as watchairApp?;
    var view as watchairView?;

    //! Constructor
    public function initialize(a as watchairApp, v as watchairView) {
        BehaviorDelegate.initialize();
        app = a;
        view = v;        
    }

    //! Handle the menu event
    //! @return true if handled, false otherwise
    public function onMenu() as Boolean {
        // Generate a new Menu with a drawable Title
        var menu = new WatchUi.Menu2({:title=>new $.DrawableMenuTitle()});

        // Add menu items for demonstrating toggles, checkbox and icon menu items
        menu.addItem(new WatchUi.MenuItem("Configuration", "display", "display", null));
        menu.addItem(new WatchUi.MenuItem("Checkboxes", null, "check", null));
        menu.addItem(new WatchUi.MenuItem("Icons", null, "icon", null));
        menu.addItem(new WatchUi.MenuItem("Custom", null, "custom", null));
        WatchUi.pushView(menu, new $.WatchairMenu2Delegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onKey(keyEvent) {        
        var k = keyEvent.getKey();
        if (k == WatchUi.KEY_START || k == WatchUi.KEY_ENTER || k == WatchUi.KEY_RIGHT) {
            if (view != null) {
                var v = view as watchairView;
                v.getNewWeatherData();
                WatchUi.requestUpdate();
                return true;
            }
        }
        if (k == WatchUi.KEY_UP || k == WatchUi.KEY_DOWN) {
            WatchUi.requestUpdate();
        }

        return WatchUi.BehaviorDelegate.onKey(keyEvent);
    }
    
    function onBack() {      
        if (view != null) {
            var v = view as watchairView;
            v.stopGPSTimer();            
        }

        return BehaviorDelegate.onBack();
    }
}

//! This is the custom drawable we will use for our main menu title
class DrawableMenuTitle extends WatchUi.Drawable {

    //! Constructor
    public function initialize() {
        Drawable.initialize({});
    }

    //! Draw the application icon and main menu title
    //! @param dc Device Context
    public function draw(dc as Dc) as Void {
        var spacing = 2;
        var appIcon = WatchUi.loadResource($.Rez.Drawables.LauncherIcon) as BitmapResource;
        var bitmapWidth = appIcon.getWidth();
        var labelWidth = dc.getTextWidthInPixels("Menu2", Graphics.FONT_MEDIUM);

        var bitmapX = (dc.getWidth() - (bitmapWidth + spacing + labelWidth)) / 2;
        var bitmapY = (dc.getHeight() - appIcon.getHeight()) / 2;
        var labelX = bitmapX + bitmapWidth + spacing;
        var labelY = dc.getHeight() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawBitmap(bitmapX, bitmapY, appIcon);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_MEDIUM, "Menu2", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
