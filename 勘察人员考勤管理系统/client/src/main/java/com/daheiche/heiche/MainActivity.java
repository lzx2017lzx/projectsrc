package com.daheiche.heiche;

import android.graphics.BitmapFactory;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps.AMap;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Marker;
import com.amap.api.maps.model.MarkerOptions;

import java.util.Map;

public class MainActivity extends AppCompatActivity {

    private MapView mapView;
    private AMap aMap;
    private AMapLocation myLocation;
    private AMapLocationClient locationClient;
//    public static final String tag="login";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mapView=(MapView)findViewById(R.id.map);
        mapView.onCreate(savedInstanceState);
        aMap=mapView.getMap();
        aMap.setMyLocationEnabled(true);
        Log.e(Jni.tag,"-----------------MainActivity works-------------------");
        Log.e(Jni.tag,"Data.instance.isDriver:"+Data.instance().isDriver);
        AMapLocationClient locationClient=new AMapLocationClient(getApplicationContext());
        locationClient.startLocation();
        Log.e(Jni.tag,"-----------------startLocation-------------------");
       locationClient.setLocationListener(new AMapLocationListener() {
           @Override
           public void onLocationChanged(AMapLocation aMapLocation) {
               myLocation=aMapLocation;

               Log.e(Jni.tag,"-----------------insetLocationListener-------------------");
               if(!Data.instance().isDriver){
                   Log.e(Jni.tag,"-----------------getLatitude:%d-------------------"+aMapLocation.getLatitude());
                   Log.e(Jni.tag,"-----------------getLongitude:%d-------------------"+aMapLocation.getLongitude());
                    if(aMapLocation.getLatitude()!=0.0) {
                        Jni.instance().getNearbyDrivers(
                                Data.instance().username,
                                aMapLocation.getLatitude(),
                                aMapLocation.getLongitude());


                   Log.e(Jni.tag,"-----------------after getNearbyDrivers-------------------");
                    Map<String,NearbyDriver>drivers=Data.instance().nearbyDrivers;

                        NearbyDriver d1=new NearbyDriver();
                        d1.name="oooooo";
                        d1.lat=23.872999;
                        d1.lng=103.589999;
                        drivers.put(d1.name,d1);
                    Log.e(Jni.tag,"====="+drivers.toString());

                  // aMap.clear();
                    for(Map.Entry<String,NearbyDriver>entry:drivers.entrySet()){
                        NearbyDriver driver=entry.getValue();
                        Log.e(Jni.tag,"===driver=="+driver.toString());
                        MarkerOptions options=new MarkerOptions();
                        Log.e(Jni.tag,"==="+driver.lat+"===="+driver.lng);
                        options.position(new LatLng(driver.lat,driver.lng));
                      options.title("driver");
                        options.snippet(driver.name);
                        options.icon(BitmapDescriptorFactory.fromBitmap(
                               // BitmapFactory.decodeResource(getResources(),R.drawable.bmw)
                                BitmapFactory.decodeResource(getResources(),R.drawable.car)
                        )
                        );
                        Marker marker=aMap.addMarker(options);
                    }
                    }
               }
           }
       });
        Log.e(Jni.tag,"-----------------afterlistener-------------------");
        locationClient.startLocation();
        Log.e(Jni.tag,"-----------------beforestartAssistantLocation-------------------");
       // locationClient.startAssistantLocation();


//        getNearbyDrivers();
//        showNearbyDrivers();
    }

//    protected void getNearbyDrivers()
//    {
//
//    }
//
//    protected void showNearbyDrivers()
//    {
//
//
//    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        mapView.onDestroy();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mapView.onSaveInstanceState(outState);
    }
//    public void onClick(View view)
//    {
//        String username=((EditText)findViewById(R.id.username)).getText().toString();
//        String password=((EditText)findViewById(R.id.password)).getText().toString();
//
//        if(username.length()==0||password.length()==0)
//        {
//            return;
//        }
//
//        if(view.getId()==R.id.button) {
//            if (!Jni.instance().login(username, password)) {
//                Log.e(tag, Jni.instance().lastError());
//            }
//            ;
//        }
//        else if(view.getId()==R.id.reg){
//            if(!Jni.instance().reg(username,password))
//            {
//                Log.e(tag, Jni.instance().lastError());
//            }
//        }else
//        {
//            Log.e(tag,"which button ...");
//        }
//    }
}
