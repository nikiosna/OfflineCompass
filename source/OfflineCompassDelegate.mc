using Toybox.WatchUi;
using Toybox.Math;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.System;

class OfflineCompassDelegate extends WatchUi.BehaviorDelegate {

	static var myLocation;

    function initialize() {
        BehaviorDelegate.initialize();
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onMenu() {
    	if(myLocation!=null && Sensor.getInfo()!=null) {
    		OfflineCompassView.navigationMode = !OfflineCompassView.navigationMode;
    		calcDistance();
    	} else {
    		System.println("No GPS fix");
    	}
        return true;
    }
    
    function onSwipe(swipeEvent) {
        //System.println("SWIPE:  " + swipeEvent.getDirection()); // e.g. SWIPE_RIGHT = 1
        if(swipeEvent.getDirection()==1) {
        	OfflineCompassView.active++;
        	if(OfflineCompassView.active==14) {
        		OfflineCompassView.active=0;
        	}
        }
        if(swipeEvent.getDirection()==3) {
        	OfflineCompassView.active--;
        	if(OfflineCompassView.active==-1) {
        		OfflineCompassView.active=13;
        	}
        }
        if(swipeEvent.getDirection()==0) {
        	var temp = OfflineCompassView.array;
        	temp[OfflineCompassView.active]++;
        	if(temp[OfflineCompassView.active]==10) {
        		temp[OfflineCompassView.active]=0;
        	}
        	OfflineCompassView.array = temp;
        }
        if(swipeEvent.getDirection()==2) {
        	var temp = OfflineCompassView.array;
        	temp[OfflineCompassView.active]--;
        	if(temp[OfflineCompassView.active]==-1) {
        		temp[OfflineCompassView.active]=9;
        	}
        	OfflineCompassView.array = temp;
        }
        WatchUi.requestUpdate();
        return true;
    }
    
    function onTap(clickEvent) {
        System.println("TAP - XY:  " + clickEvent.getCoordinates() + "  TYPE:  " + clickEvent.getType()); // e.g. [36, 40]
        return true;
    }
    
    function onPosition(info) {
    	myLocation = info.position.toDegrees();
    	calcDistance();
    }
    
    function calcDistance() {
        if(OfflineCompassView.navigationMode) {
   			var a = OfflineCompassView.array;
        	var lat = 10*a[0] + a[1] + ( 10*a[2] + a[3] + 0.1*a[4]   + 0.01*a[5]  + 0.001*a[6] )/60;
        	var lon = 10*a[7] + a[8] + ( 10*a[9] + a[10] + 0.1*a[11]  + 0.01*a[12] + 0.001*a[13] )/60;
        	var lat1 =  myLocation[0];
        	var lon1 =  myLocation[1];
        	/*var lat = 52.517;
        	var lon = 13.4;
        	var lat1= 35.7;
        	var lon1= 139.767;*/
        
       		/*System.println("lat " + lat + "  lon " + lon);
			System.println("lat1 " + lat1 + "  lon1 " +lon1);*/
        
        	lat = Math.toRadians(lat);
        	lon = Math.toRadians(lon);
        	lat1= Math.toRadians(lat1);
        	lon1= Math.toRadians(lon1);
        
			var phi = Math.acos( Math.sin(lat)*Math.sin(lat1) + Math.cos(lat)*Math.cos(lat1) * Math.cos(lon1 - lon) );
			var dist = phi*6370*1000;
			//var alpha = Math.acos( (Math.sin(lat1) - Math.sin(lat)*Math.cos(phi) )/( Math.cos(lat1)*Math.sin(phi) ));
			var beta  = Math.acos( (Math.sin(lat) - Math.sin(lat1)*Math.cos(phi) )/( Math.cos(lat1)*Math.sin(phi) ));

			/*System.println("phi " + Math.toDegrees(phi) + " dist " + dist);
			//System.println("alpha " + Math.toDegrees(alpha));
			System.println("beta " + Math.toDegrees(beta));
			System.println("heading " + Sensor.getInfo().heading);*/
			
			OfflineCompassView.direction = Math.toDegrees(beta + Sensor.getInfo().heading);
			OfflineCompassView.distance  = dist;
			WatchUi.requestUpdate();
    	}
    }
}