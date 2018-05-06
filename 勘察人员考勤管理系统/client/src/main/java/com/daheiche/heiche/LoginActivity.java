package com.daheiche.heiche;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Toast;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationListener;

public class LoginActivity extends AppCompatActivity {

    public static String tag="pos";
    boolean isDriver=false;
    AMapLocationClient locationClient;
   AMapLocation location=null;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        CheckBox box=(CheckBox)findViewById(R.id.checkbox);
        box.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                isDriver=isChecked;
                if(isChecked)
                {
                    Log.e("1","isChecked works");
                }
                Data.instance().isDriver=isChecked;
            }
        });

        locationClient=new AMapLocationClient(this);

        locationClient.setLocationListener(new AMapLocationListener() {
            @Override
            public void onLocationChanged(AMapLocation aMapLocation) {
                Log.e(tag,"lat："+aMapLocation.getLatitude());
                Log.e(tag,"lng:"+aMapLocation.getLongitude());
                location=aMapLocation;
                Toast.makeText(getApplicationContext(),"定位成功",Toast.LENGTH_LONG).show();
               locationClient.stopLocation();
                locationClient.onDestroy();
            }
        });

        locationClient.startLocation();
    }

    public void onClick(View view)
    {
        String username=((EditText)findViewById(R.id.username)).getText().toString();
        String password=((EditText)findViewById(R.id.password)).getText().toString();

        if(username.length()==0||password.length()==0)
        {
            return;
        }

        if(location==null)
        {
            Toast.makeText(this,"正在定位",Toast.LENGTH_LONG).show();
            return;
        }

//        if(view.getId()==R.id.checkbox)
//        {
//            CheckBox box=(CheckBox)view;
//
//        }
//        else
            if(view.getId()==R.id.button) {

//            CheckBox box=(CheckBox)findViewById(R.id.checkbox);
//
            if (!Jni.instance().login(username, password,isDriver,
                    location.getLatitude(),
                    location.getLongitude())) {
                Log.e("1","1");
                Log.e(Jni.tag, Jni.instance().lastError());
                return;
            }
                Data.instance().username=username;
            ;
            Intent intent=new Intent(getApplicationContext(),MainActivity.class);


            startActivity(intent);

            //finish();

        }
        else if(view.getId()==R.id.reg){
            if(!Jni.instance().reg(username,password))
            {
                Log.e(Jni.tag, Jni.instance().lastError());
            }
        }else
        {
            Log.e(Jni.tag,"which button ...");
        }
    }
}
