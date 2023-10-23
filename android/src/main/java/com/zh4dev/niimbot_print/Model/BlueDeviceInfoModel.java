package com.zh4dev.niimbot_print.Model;

import com.google.gson.Gson;

public class BlueDeviceInfoModel {

    String deviceName;
    String deviceHardwareAddress;
    int connectionState;

    public BlueDeviceInfoModel(String deviceName, String deviceHardwareAddress, int connectionState) {
        this.deviceName = deviceName;
        this.deviceHardwareAddress = deviceHardwareAddress;
        this.connectionState = connectionState;
    }

    public int getConnectionState() {
        return connectionState;
    }

    public void setConnectionState(int connectionState) {
        this.connectionState = connectionState;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    public String getDeviceHardwareAddress() {
        return deviceHardwareAddress;
    }

    public void setDeviceHardwareAddress(String deviceHardwareAddress) {
        this.deviceHardwareAddress = deviceHardwareAddress;
    }

    public String toMap() {
        return new Gson().toJson(this);
    }

    public BlueDeviceInfoModel fromMap(String json) {
        return new Gson().fromJson(json, BlueDeviceInfoModel.class);
    }

}
