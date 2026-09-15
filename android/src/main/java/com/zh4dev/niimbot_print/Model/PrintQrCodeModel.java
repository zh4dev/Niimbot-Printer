package com.zh4dev.niimbot_print.Model;

import com.google.gson.Gson;

public class PrintQrCodeModel {

    private String data;
    private double size;

    public String getData() {
        return data;
    }

    public double getSize() {
        return size;
    }

    public static PrintQrCodeModel fromJson(String json) {
        return new Gson().fromJson(json, PrintQrCodeModel.class);
    }
}
