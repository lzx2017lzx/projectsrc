package com.daheiche.heiche;

import android.util.Log;

import java.lang.Boolean;

import org.json.*;

import static com.amap.api.col.dh.D;


public class Jni {

    static{
        System.loadLibrary("jni");
    }
//Java_com_example_lzx_a1myapplicationnew_Jni_ndkCall(JNIenv*,jobject)

    public static final String tag="heiche";
    static Jni This=new Jni();
    static public Jni instance()
    {

        return This;
    }

    public void nearByDrivers(String name,double lat,double lng)
    {
        NearbyDriver driver=new NearbyDriver();
        driver.name=name;
        driver.lat=lat;
        driver.lng=lng;
        Log.e(tag,"driver:name;lat;lng;"+driver.name+" "+driver.lat+" "+driver.lng);
        Log.e(tag,"before Data.instance().nearbyDrivers.size();"+Data.instance().nearbyDrivers.size());


       Data.instance().nearbyDrivers.put(name,driver);

        Log.e(tag,"after Data.instance().nearbyDrivers.size();"+Data.instance().nearbyDrivers.size());

       Log.e(tag,"Data.instance().nearbyDrivers.get(name);"+Data.instance().nearbyDrivers.get(name));

        Log.e(tag,"Data.instance().nearbyDrivers.get(name);get(lat);get(lng):"+Data.instance().nearbyDrivers.get(name).name+
                Data.instance().nearbyDrivers.get(name).lat+Data.instance().nearbyDrivers.get(name).lng
        );


    }


    public void nearbyDrivers(String json)
    {
        JSONArray jsonarray;
        JSONObject object2;
        Log.e(tag,"nearby Drivers:"+json);
        //json转string

       // JSONObject jsonobject=JSONObject.fromObject(json);
       // Log.e(tag,"-----------------------------------------abcd");
       // jsonarray=(JSONArray)(jsonobject.get("drivers"));
       // object2=(jsonarray.getJSONObject(1));
       // Log.e(tag,"drivers：name"+object2.getString("name"));
       // Log.e(tag,"drivers：lat"+object2.getString("lat"));
       // Log.e(tag,"drivers：lng"+object2.getString("lng"));
    }

    public native boolean reg(String username,String password);

    public native boolean login(String username,String password,boolean isDriver,double lat,double lng );
    public native String lastError();
    public native boolean getNearbyDrivers(String username,double lat,double lng);

}
