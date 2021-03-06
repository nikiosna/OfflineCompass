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
		menu();
		WatchUi.requestUpdate();
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
        WatchUi.requestUpdate();
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
			menu();
        }
        WatchUi.requestUpdate();
        return true;
    }
    
	function onPosition(info) {
    	myLocation = info.position.toDegrees();
    	calcDistance();
    	WatchUi.requestUpdate();
    	return true;
    }
    
    /*function onTap(clickEvent) {
        System.println("TAP - XY:  " + clickEvent.getCoordinates() + "  TYPE:  " + clickEvent.getType());
        return true;
    }*/
    
    function left() {
    	if(OfflineCompassView.currentView.equals("input")) {
    		OfflineCompassView.active--;
        	if(OfflineCompassView.active==-1) {
        		OfflineCompassView.active=16;
        	}
    	}
    }
    
    function right() {
    	if(OfflineCompassView.currentView.equals("input")) {
    	    OfflineCompassView.active++;
    	    if(OfflineCompassView.active==17) {
        		OfflineCompassView.active=0;
        	}
    	}
    }
    
    function up() {
        if(OfflineCompassView.currentView.equals("input")) {
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
    	else if(OfflineCompassView.currentView.equals("menu")) {
    		OfflineCompassView.active--;
        	if(OfflineCompassView.active==-1) {
        		OfflineCompassView.active=5;
        	}
    	}
    }
    
    function down() {
        if(OfflineCompassView.currentView.equals("input")) {
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
    	}
    	else if(OfflineCompassView.currentView.equals("menu")) {
			OfflineCompassView.active++;
        	if(OfflineCompassView.active==6) {
        		OfflineCompassView.active=0;
        	}
    	}
    }
    
    function menu() {
    	if(OfflineCompassView.currentView.equals("menu")) {
    		if(OfflineCompassView.active==0) {
    			if(isGpsReady()) {
    				OfflineCompassView.currentView="compass";
    			} else {
    				OfflineCompassView.currentView="input";
    			}
    		} else if(OfflineCompassView.active==1) {
    			OfflineCompassView.currentView="input";
    		} else if(OfflineCompassView.active==2) {
    			//TODO
    		} else if(OfflineCompassView.active==3) {
    			//TODO
    			if(isGpsReady()) {
    				OfflineCompassView.array=latlonToArray(myLocation[0], myLocation[1]);
    				OfflineCompassView.currentView="input";
    			}
    		} else if(OfflineCompassView.active==4) {
    			//TODO
    		} else if(OfflineCompassView.active==5) {
    			Application.Storage.setValue("location", OfflineCompassView.array);
    			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    		}
    	} else {
    		OfflineCompassView.active=0;
    		OfflineCompassView.currentView="menu";
    	}
    	
    }
    
    public static function isGpsReady() {
		if(myLocation!=null && Sensor.getInfo()!=null) {
    		return true;
    	}
    	return false;
    }
    
    function calcDistance() {
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
    
    function latlonToArray(lat, lon) {
    	//TODO use loops 
    	//System.println("lat " + lat + "  lon " + lon);
    	var temp = [100, 5, 5, 0, 1, 2, 3, 4, 100, 0, 0, 8, 1, 2, 5, 5, 5];
    	if(lat<0) {
    		temp[0] = 200;
    		lat = lat*-1;
    	} else {
    		temp[0] = 100;
    	}
    	temp[1] = (lat/10).toNumber();
    	lat = lat-((lat/10).toNumber()*10);
    	temp[2] = lat.toNumber();
    	lat = (lat-lat.toNumber())*60;
    	temp[3] = (lat/10).toNumber();
    	lat = lat-((lat/10).toNumber()*10);
    	temp[4] = lat.toNumber();
    	lat = (lat*10)-(lat.toNumber()*10);
    	temp[5] = lat.toNumber();
    	lat = (lat*10)-(lat.toNumber()*10);
    	temp[6] = lat.toNumber();
    	lat = (lat*10)-(lat.toNumber()*10);
    	temp[7] = lat.toNumber();
    	lat = (lat*10)-(lat.toNumber()*10);
    	
    	if(lon<0) {
    		temp[8] = 200;
    		lon = lon*-1;
    	} else {
    		temp[8] = 100;
    	}
    	temp[9] = (lon/100).toNumber();
    	lon = lon-((lon/100).toNumber()*100);
    	temp[10] = (lon/10).toNumber();
    	lon = lon-((lon/10).toNumber()*10);
    	temp[11] = lon.toNumber();
    	lon = (lon-lon.toNumber())*60;
    	temp[12] = (lon/10).toNumber();
    	lon = lon-((lon/10).toNumber()*10);
    	temp[13] = lon.toNumber();
    	lon = (lon*10)-(lon.toNumber()*10);
    	temp[14] = lon.toNumber();
    	lon = (lon*10)-(lon.toNumber()*10);
    	temp[15] = lon.toNumber();
    	lon = (lon*10)-(lon.toNumber()*10);
    	temp[16] = lon.toNumber();
    	lon = (lon*10)-(lon.toNumber()*10);
    	
    	return temp;
    }
    
}