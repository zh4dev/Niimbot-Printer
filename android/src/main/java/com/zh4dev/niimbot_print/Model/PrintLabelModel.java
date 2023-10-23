package com.zh4dev.niimbot_print.Model;

import com.google.gson.Gson;

public class PrintLabelModel {

    String text;
    double fontSize;

    public PrintLabelModel() {
    }

    public PrintLabelModel(String text, double fontSize) {
        this.text = text;
        this.fontSize = fontSize;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public double getFontSize() {
        return fontSize;
    }

    public void setFontSize(double fontSize) {
        this.fontSize = fontSize;
    }

    public String toMap() {
        return new Gson().toJson(this);
    }

    public PrintLabelModel fromMap(String json) {
        return new Gson().fromJson(json, PrintLabelModel.class);
    }
}
