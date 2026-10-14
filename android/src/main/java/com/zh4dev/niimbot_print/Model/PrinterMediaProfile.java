package com.zh4dev.niimbot_print.Model;

/** Device/media policy only: independent of drawing, font sizing and previews. */
public class PrinterMediaProfile {
    public String printerName;
    public double width;
    public double height;
    public String orientation;
    public double horizontalCorrection;

    public boolean matches(String connectedName, LabelLayoutModel layout) {
        return printerName != null && printerName.equalsIgnoreCase(connectedName.trim()) &&
                orientation != null && orientation.equals(layout.orientation) &&
                Math.abs(width - layout.width) < 0.01 && Math.abs(height - layout.height) < 0.01 &&
                Double.isFinite(horizontalCorrection) && Math.abs(horizontalCorrection) <= layout.padding;
    }
}
