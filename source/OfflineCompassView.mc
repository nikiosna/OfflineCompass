using Toybox.WatchUi;
using Toybox.Application.Storage;
using Toybox.Math;

class OfflineCompassView extends WatchUi.View {

	public static var active = 0;
	public static var array = [100, 5, 5, 0, 1, 2, 3, 4, 100, 0, 0, 8, 1, 2, 5, 5, 5];
	
	public static var noGpsFixMessage = false;
	public static var navigationMode = false;
	public static var direction = 0;
	public static var distance = 0;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	System.println("width=" + dc.getWidth() + " height=" + dc.getHeight());	
        setLayout(Rez.Layouts.MainLayout(dc));
    }
   
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	var temp = Storage.getValue("location"); 
    	if(temp != null) {
    		array = temp;
    	}
    }

    // Update the view
    function onUpdate(dc) {
		// Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        //dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	//dc.clear();

		if(!navigationMode) {
			drawCoordMenu(dc);
			if(noGpsFixMessage) {
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				dc.drawText(dc.getWidth()/2, (dc.getHeight()/2)+60, Graphics.FONT_TINY, "NO GPS", Graphics.TEXT_JUSTIFY_CENTER);
			}
		} else{
			drawCompass(dc, direction);
			
			var string = "";
			if(distance >= 100000) {
				string = (distance/1000).format("%.0f") + "km";
			} else if(distance >= 10000) {
				string = ((distance/100).toNumber().toFloat()/10).format("%.1f") + "km";
			} else if(distance >= 1000) {
				string = ((distance/10).toNumber().toFloat()/100).format("%.2f") + "km";
			} else {
				string = distance.toNumber().toFloat().format("%.0f") + "m";
			}
			dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
			dc.drawText(dc.getWidth()/2, (dc.getHeight()/2)+80, Graphics.FONT_TINY, string, Graphics.TEXT_JUSTIFY_CENTER);
			
		}
		
	}

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	Application.Storage.setValue("location", array);
    }
    
    function drawCoordMenu(dc) {
        var font = Graphics.FONT_LARGE;
		var c = Graphics.getFontAscent(font)*0.6;
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		var pos = 0;
		for(var i = 0; i < 17; i++) {
			if(i==active) {
				dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_WHITE);
			}
			
			if(i<8) {
				if(i==0) {
					if(array[i]==100) {
						dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*pos), (dc.getHeight()/2)-50, font, "N", Graphics.TEXT_JUSTIFY_CENTER);
					}
					if(array[i]==200) {
						dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*pos), (dc.getHeight()/2)-50, font, "S", Graphics.TEXT_JUSTIFY_CENTER);
					}
					pos++; //Space after the first digit N|S
				} else {
					dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*pos), (dc.getHeight()/2)-50, font, array[i], Graphics.TEXT_JUSTIFY_CENTER);
				}
			} else {
				if(i==8) {
					if(array[i]==100) {
						dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*(pos-11)), (dc.getHeight()/2)-15, font, "E", Graphics.TEXT_JUSTIFY_CENTER);
					}
					if(array[i]==200) {
						dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*(pos-11)), (dc.getHeight()/2)-15, font, "W", Graphics.TEXT_JUSTIFY_CENTER);
					}
				} else {
					dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*(pos-11)), (dc.getHeight()/2)-15, font, array[i], Graphics.TEXT_JUSTIFY_CENTER);
				}
			}
			
			dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
			if(i==2) {
				pos++;
				dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*pos), (dc.getHeight()/2)-50, font, "°", Graphics.TEXT_JUSTIFY_CENTER);
			}
			if(i==4) {
				pos++;
				dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*pos), (dc.getHeight()/2)-50, font, ".", Graphics.TEXT_JUSTIFY_CENTER);
			}
			if(i==11) {
				pos++;
				dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*(pos-11)), (dc.getHeight()/2)-15, font, "°", Graphics.TEXT_JUSTIFY_CENTER);
			}
			if(i==13) {
				pos++;
				dc.drawText((dc.getWidth()/2)-(c*4.5)+(c*(pos-11)), (dc.getHeight()/2)-15, font, ".", Graphics.TEXT_JUSTIFY_CENTER);
			}
			pos++;
		}
		
    }
    
    function drawCompass(dc, angle) {
    	angle = Math.toRadians(angle);
    	var coords = [[120, 60], [90, 180], [120, 170], [150, 180]];
    	var result = [[120, 60], [90, 180], [120, 170], [150, 180]];
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		// Transform the coordinates
		for (var i = 0; i < 4; i++) {
    		var x = ((coords[i][0]-centerX) * cos) - ((coords[i][1]-centerY) * sin);
    		var y = ((coords[i][0]-centerX) * sin) + ((coords[i][1]-centerY) * cos);
    		result[i] = [ centerX+x, centerY+y];
		}
		dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon(result);
    }
     
}
