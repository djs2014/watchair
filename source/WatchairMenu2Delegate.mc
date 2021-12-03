import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

//! This is the menu input delegate for the main menu of the application
class WatchairMenu2Delegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle an item being selected
    //! @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        var id = item.getId() as String;
        if (id.equals("observation")) {
            // When the toggle menu item is selected, push a new menu that demonstrates
            // left and right toggles with automatic substring toggles.
            var toggleMenu = new WatchUi.Menu2({:title=>"Observation"});
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Time", {:enabled=>"Show", :disabled=>"Hide"}, "obsTimeShow", mObsTimeShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Location", {:enabled=>"Show", :disabled=>"Hide"}, "obsLocationShow", mObsLocationShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Distance to", {:enabled=>"Show", :disabled=>"Hide"}, "obsDistanceShow", mObsDistanceShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Units", {:enabled=>"ppm (per million)", :disabled=>"μg/m3"}, "unitsInPPM", mUnitsInPPM, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(toggleMenu, new $.WatchairSubMenuDelegate(), WatchUi.SLIDE_UP);
        } else if (id.equals("alerts")) {
            // // When the check menu item is selected, push a new menu that demonstrates
            // // left and right checkbox menu items
            // var checkMenu = new WatchUi.CheckboxMenu({:title=>"Checkboxes"});
            // checkMenu.addItem(new WatchUi.CheckboxMenuItem("Item 1", "Left Check", "left", false, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            // checkMenu.addItem(new WatchUi.CheckboxMenuItem("Item 2", "Right Check", "right", false, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
            // checkMenu.addItem(new WatchUi.CheckboxMenuItem("Item 3", "Check", "default", true, null));
            // WatchUi.pushView(checkMenu, new $.WatchairSubMenuDelegate(), WatchUi.SLIDE_UP);                 
        } else if (id.equals("colors")) {
            WatchUi.pushView(new $.ColorPicker("colorAdditionalData", "Additional data", [Graphics.COLOR_WHITE, Graphics.COLOR_LT_GRAY, 
                Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GREEN, Graphics.COLOR_DK_BLUE, Graphics.COLOR_PURPLE] as Array<ColorType>), 
                new $.ColorPickerDelegate("colorAdditionalData"), WatchUi.SLIDE_IMMEDIATE);
        } else if (id.equals("reset")) {
            Storage.clearValues();
            onBack();
        } else {
            WatchUi.requestUpdate();
        }
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        Storage.setValue("backFromMenu", 1);
        updateWatchSettings();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class WatchairSubMenuDelegate extends WatchUi.Menu2InputDelegate {

    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) as Void {

        if (item instanceof WatchUi.ToggleMenuItem) {
            var property = item.getId() as String;            
            Application.Properties.setValue(property, (item as ToggleMenuItem).isEnabled() );
        }

        WatchUi.requestUpdate();
    }

    //! Handle the back key being pressed
    public function onBack() as Void {        
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //! Handle the done item being selected
    public function onDone() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}