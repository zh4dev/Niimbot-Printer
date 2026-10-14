package com.zh4dev.niimbot_print.Model;

import com.google.gson.Gson;

public class LabelLayoutModel {
    public double width = 50.0;
    public double height = 30.0;
    public double padding = 2.0;
    public double textSpacing = 0.0;
    public double horizontalCalibration = 0.0;
    public boolean usePrinterProfiles = true;
    public PrinterMediaProfile[] printerProfiles = new PrinterMediaProfile[0];
    public String orientation = "portrait";
    public String horizontalAlignment = "center";
    public String verticalAlignment = "center";

    public LabelLayoutModel fromMap(Object value) {
        if (value == null) return this;
        LabelLayoutModel parsed = new Gson().fromJson(new Gson().toJson(value), LabelLayoutModel.class);
        return parsed == null ? this : parsed;
    }

    public float getCanvasWidth() {
        return (float) ("landscape".equals(orientation) ? height : width);
    }

    public float getCanvasHeight() {
        return (float) ("landscape".equals(orientation) ? width : height);
    }

    public int getRotation() {
        return "landscape".equals(orientation) ? 90 : 0;
    }

    public int getHorizontalAlignment() {
        if ("start".equals(horizontalAlignment)) return 0;
        if ("end".equals(horizontalAlignment)) return 2;
        return 1;
    }

    public float resolveHorizontalCalibration(String printerName, boolean centeredFlow) {
        if (horizontalCalibration != 0) return (float) horizontalCalibration;
        if (!usePrinterProfiles || !centeredFlow || printerName == null || printerProfiles == null) return 0;
        for (PrinterMediaProfile profile : printerProfiles) {
            if (profile != null && profile.matches(printerName, this)) {
                return (float) profile.horizontalCorrection;
            }
        }
        return 0;
    }
}
