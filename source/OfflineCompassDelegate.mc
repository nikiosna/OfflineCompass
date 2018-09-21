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
		confirm();
        return true;
    }
    
    function onSwipe(swipeEvent) {
        if(swipeEvent.getDirection()==1) {
			right();
        }
        if(swipeEvent.getDirection()==3) {
			left();
        }
        if(swipeEvent.getDirection()==0) {
			up();
        }
        if(swipeEvent.getDirection()==2) {
			down();
        }
        return true;
    }
    
    function onKey(keyEvent) {
        //System.println(keyEvent.getKey());
        //System.println(keyEvent.getType());
        
        if(keyEvent.getKey()==5) {
			right();
        }
        /*if(keyEvent.getKey()==__) {
			left();
        }*/
        if(keyEvent.getKey()==13) {
			up();
        }
        if(keyEvent.getKey()==8) {
			down();
        }
        if(keyEvent.getKey()==4) {
			confirm();
        }
        return true;
    }
    
	function onPosition(info) {
    	myLocation = info.position.toDegrees();
    	calcDistance();
    }
    
    /*function onTap(clickEvent) {
        System.println("TAP - XY:  " + clickEvent.getCoordinates() + "  TYPE:  " + clickEvent.getType());
        return true;
    }*/
    
    function left() {
		OfflineCompassView.active--;
        if(OfflineCompassView.active==-1) {
        	OfflineCompassView.active=16;
        }
        WatchUi.requestUpdate();
    }
    
    function right() {
    	OfflineCompassView.active++;
        if(OfflineCompassView.active==17) {
        	OfflineCompassView.active=0;
        }
        WatchUi.requestUpdate();
    }
    
    function up() {
		var temp = OfflineCompassView.array;
        var i = OfflineCompassView.active;
        	
        if(i==0 || i==8) {
        	if(temp[i]==200) {
        		temp[i]=100;
        	} else {
        		temp[i]=200;
        	}
        } else {
        	temp[i]++;
        	if(temp[i]==10) {
        		temp[i]=0;
        	}
        }
        OfflineCompassView.array = temp;
        WatchUi.requestUpdate();
    }
    
    function down() {
    	var temp = OfflineCompassView.array;
        var i = OfflineCompassView.active;
        
        if(i==0 || i==8) {
        	if(temp[i]==200) {
        		temp[i]=100;
        	} else {
        		temp[i]=200;
        	}
        } else {
        	temp[i]--;
        	if(temp[i]==-1) {
        		temp[i]=9;
        	}
        }
        OfflineCompassView.array = temp;
        WatchUi.requestUpdate();
    }
    
    function confirm() {
		if(myLocation!=null && Sensor.getInfo()!=null) {
			if(OfflineCompassView.navigationMode==true) {
				System.exit();
			}
    		OfflineCompassView.navigationMode = !OfflineCompassView.navigationMode;
    		calcDistance();
    	} else {
    		OfflineCompassView.noGpsFixMessage = true;
    		//System.println("No GPS fix");
    	}
    	WatchUi.requestUpdate();
    }
    
    function calcDistance() {
        if(OfflineCompassView.navigationMode) {
   			var a = OfflineCompassView.array;
   			
   			var lat = 10*a[1] + a[2] + ( 10*a[3] + a[4] + 0.1*a[5]   + 0.01*a[6]  + 0.001*a[7] )/60;
   			if(a[0]==200) {
   				lat = lat*-1;
   			}
        	var lon = 100*a[9] + 10*a[10] + a[11] + ( 10*a[12] + a[13] + 0.1*a[14]  + 0.01*a[15] + 0.001*a[16] )/60;
        	if(a[8]==200) {
   				lat = lat*-1;
   			}
        	
        	var lat1 =  myLocation[0];
        	var lon1 =  myLocation[1];
        
       		/*System.println("lat " + lat + "  lon " + lon);
			System.println("lat1 " + lat1 + "  lon1 " +lon1);*/
        
        	lat = Math.toRadians(lat).toDouble();
        	lon = Math.toRadians(lon).toDouble();
        	lat1= Math.toRadians(lat1).toDouble();
        	lon1= Math.toRadians(lon1).toDouble();
        
			var phi = Math.acos( Math.sin(lat)*Math.sin(lat1) + Math.cos(lat)*Math.cos(lat1) * Math.cos(lon1 - lon) );
			var dist = phi*6371000;
			//var alpha = Math.acos( (Math.sin(lat1) - Math.sin(lat)*Math.cos(phi) )/( Math.cos(lat1)*Math.sin(phi) )); //Direction from A->B
			var beta  = Math.acos( (Math.sin(lat) - Math.sin(lat1)*Math.cos(phi) )/( Math.cos(lat1)*Math.sin(phi) ));   //Direction from B->A

			/*System.println("phi " + Math.toDegrees(phi) + " dist " + dist);
			System.println("beta " + Math.toDegrees(beta));
			System.println("heading " + Math.toDegrees(Sensor.getInfo().heading));*/
			
			OfflineCompassView.direction = Math.toDegrees(beta - Sensor.getInfo().heading);
			OfflineCompassView.distance  = dist;
    	}
    }
    
}