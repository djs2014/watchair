import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Picker that allows the user to choose a color
// Set/get color from Storage field "colorSelected"
class ColorPicker extends WatchUi.Picker {
    //! Constructor
    var mStorageField as String = "colorSelected";

    public function initialize(storageFieldSelectedColor as String?, pickerTitle as String, colors as Array<ColorType>) {        
        if (storageFieldSelectedColor!= null) { mStorageField = storageFieldSelectedColor; }
        var title = new WatchUi.Text({:text=>pickerTitle, :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new $.ColorFactory(colors);
        // var factory = new $.ColorFactory([Graphics.COLOR_WHITE, Graphics.COLOR_LT_GRAY, 
        //     Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GREEN, Graphics.COLOR_DK_BLUE, Graphics.COLOR_PURPLE] as Array<ColorType>);
        var defaults = null;        
        var value = Storage.getValue(mStorageField);
        if (value instanceof Number) {
            defaults = [factory.getIndex(value)];
        }        

        Picker.initialize({:title=>title, :pattern=>[factory], :defaults=>defaults});
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

//! Responds to a color picker selection or cancellation
class ColorPickerDelegate extends WatchUi.PickerDelegate {
    var mStorageField as String = "colorSelected";
    //! Constructor
    public function initialize(storageFieldSelectedColor as String?) {
        if (storageFieldSelectedColor!= null) { mStorageField = storageFieldSelectedColor; }
        PickerDelegate.initialize();    
    }

    //! Handle a cancel event
    //! @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    //! Handle a confirm event
    //! @param values The values chosen
    //! @return true if handled, false otherwise
    public function onAccept(values as Array<Number>) as Boolean {
        Storage.setValue(mStorageField, values[0]);

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

}
