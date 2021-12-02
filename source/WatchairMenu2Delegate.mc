import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

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
        if (id.equals("display")) {
            // When the toggle menu item is selected, push a new menu that demonstrates
            // left and right toggles with automatic substring toggles.
            var toggleMenu = new WatchUi.Menu2({:title=>"Display"});
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Observation time", {:enabled=>"Show", :disabled=>"Hide"}, "obsTimeShow", mObsTimeShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Observation location", {:enabled=>"Show", :disabled=>"Hide"}, "obsLocationShow", mObsLocationShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Observation distance", {:enabled=>"Show", :disabled=>"Hide"}, "obsDistanceShow", mObsDistanceShow, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            toggleMenu.addItem(new WatchUi.ToggleMenuItem("Units", {:enabled=>"ppm (per million)", :disabled=>"μg/m3"}, "unitsInPPM", mUnitsInPPM, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            WatchUi.pushView(toggleMenu, new $.Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP);
        } else if (id.equals("check")) {
            // // When the check menu item is selected, push a new menu that demonstrates
            // // left and right checkbox menu items
            // var checkMenu = new WatchUi.CheckboxMenu({:title=>"Checkboxes"});
            // checkMenu.addItem(new WatchUi.CheckboxMenuItem("Item 1", "Left Check", "left", false, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
            // checkMenu.addItem(new WatchUi.CheckboxMenuItem("Item 2", "Right Check", "right", false, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
            // checkMenu.addItem(new WatchUi.CheckboxMenuItem("Item 3", "Check", "default", true, null));
            // WatchUi.pushView(checkMenu, new $.Menu2SampleSubMenuDelegate(), WatchUi.SLIDE_UP);                 
        } else {
            WatchUi.requestUpdate();
        }
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

//! This is the menu input delegate shared by all the basic sub-menus in the application
class Menu2SampleSubMenuDelegate extends WatchUi.Menu2InputDelegate {

    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //! Handle an item being selected
    //! @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {

        if (item instanceof WatchUi.ToggleMenuItem) {
            var property = item.getId() as String;            
            Application.Properties.setValue(property, (item as ToggleMenuItem).isEnabled() );
        }

        // For IconMenuItems, we will change to the next icon state.
        // This demonstrates a custom toggle operation using icons.
        // Static icons can also be used in this layout.
        // if (item instanceof WatchUi.IconMenuItem) {
        //     item.setSubLabel((item.getIcon() as CustomIcon).nextState());
        // }
        WatchUi.requestUpdate();
    }

    //! Handle the back key being pressed
    public function onBack() as Void {
        updateWatchSettings();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //! Handle the done item being selected
    public function onDone() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}