package com.zh4dev.niimbot_print.Model;

import com.google.gson.Gson;

public class PrintLabelModel {

    String text;
    double fontSize;
    String fontFamily;
    String fontStyle = "normal";
    TextSizing sizing;

    public static class TextSizing {
        public String mode = "fixed";
        public double minFontSize = 8.0;
        public double maxFontSize = 32.0;
        public int maxLines = 2;
        public double fontSizeOffset = 0.0;
    }

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

    public String getFontFamily() {
        return fontFamily == null || fontFamily.trim().isEmpty()
                ? "宋体"
                : fontFamily;
    }

    public boolean[] getFontStyles() {
        String style = fontStyle == null ? "normal" : fontStyle;
        boolean italic = "italic".equals(style) || "boldItalic".equals(style);
        boolean bold = "bold".equals(style) || "boldItalic".equals(style);
        boolean underline = "underline".equals(style);
        boolean strikethrough = "strikethrough".equals(style);
        // The bundled SDK binary reads the first flag as bold and the second
        // as italic (the published header describes these two in reverse).
        return new boolean[]{bold, italic, underline, strikethrough};
    }

    public boolean isAutoFit() {
        return sizing != null && "autoFit".equals(sizing.mode);
    }

    public double getMinFontSize() {
        return sizing == null ? fontSize : sizing.minFontSize;
    }

    public double getMaxFontSize() {
        return sizing == null ? fontSize : sizing.maxFontSize;
    }

    public int getMaxLines() {
        return sizing == null ? 1 : Math.max(sizing.maxLines, 1);
    }

    public double getFontSizeOffset() {
        return sizing == null ? 0.0 : sizing.fontSizeOffset;
    }

    public String toMap() {
        return new Gson().toJson(this);
    }

    public PrintLabelModel fromMap(String json) {
        return new Gson().fromJson(json, PrintLabelModel.class);
    }
}
