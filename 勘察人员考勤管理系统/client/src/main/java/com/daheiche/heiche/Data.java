package com.daheiche.heiche;

import android.support.annotation.NonNull;
import android.support.v4.util.ArrayMap;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Set;

/**
 * Created by lzx on 2017/7/16.
 */

public class Data {
    private static Data data=new Data();
    public static Data instance(){

        return data;
        };



    public Map<String,NearbyDriver> nearbyDrivers=new ArrayMap<String,NearbyDriver>();//使用ArrayMap表示申请的
    //是Map数组空间，而不是一个Map对象


    public boolean isDriver=false;
    public String username;
}
