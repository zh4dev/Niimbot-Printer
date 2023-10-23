package com.zh4dev.niimbot_print.Model;

import com.google.gson.Gson;

public class PrinterConfigurationModel {

    public int printModel;
    public int printDensity;
    public float printMultiple;
    public PrinterConfigurationModel() {
    }
    public PrinterConfigurationModel(int printModel, int printDensity, float printMultiple) {
        this.printModel = printModel;
        this.printDensity = printDensity;
        this.printMultiple = printMultiple;}

    public String toMap() {
        return new Gson().toJson(this);
    }

    public PrinterConfigurationModel fromMap(String json) {
        return new Gson().fromJson(json, PrinterConfigurationModel.class);
    }

}
