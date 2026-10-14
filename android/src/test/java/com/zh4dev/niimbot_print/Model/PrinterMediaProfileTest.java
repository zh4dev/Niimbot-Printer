package com.zh4dev.niimbot_print.Model;

import org.junit.Test;
import static org.junit.Assert.*;

public class PrinterMediaProfileTest {
    private LabelLayoutModel fixture() {
        return new LabelLayoutModel().fromMap(new com.google.gson.Gson().fromJson(
            "{\"printerProfiles\":[{\"printerName\":\"TEST-B1\",\"width\":50,\"height\":30,\"orientation\":\"portrait\",\"horizontalCorrection\":-2}]}", Object.class));
    }
    @Test public void onlyExactDeviceMediaAndAlignmentMatch() {
        LabelLayoutModel layout = fixture();
        assertEquals(-2, layout.resolveHorizontalCalibration("test-b1", true), 0.001);
        assertEquals(0, layout.resolveHorizontalCalibration("OTHER-B1", true), 0.001);
        assertEquals(0, layout.resolveHorizontalCalibration("TEST-B1", false), 0.001);
        layout.height = 80;
        assertEquals(0, layout.resolveHorizontalCalibration("TEST-B1", true), 0.001);
        layout.height = 30; layout.orientation = "landscape";
        assertEquals(0, layout.resolveHorizontalCalibration("TEST-B1", true), 0.001);
    }
    @Test public void overrideDoesNotDoubleApplyAndProfilesCanBeDisabled() {
        LabelLayoutModel layout = fixture();
        layout.horizontalCalibration = -1;
        assertEquals(-1, layout.resolveHorizontalCalibration("TEST-B1", true), 0.001);
        layout.horizontalCalibration = 0; layout.usePrinterProfiles = false;
        assertEquals(0, layout.resolveHorizontalCalibration("TEST-B1", true), 0.001);
    }
    @Test public void smallPaddingAndEmptyNamesDoNotApplyCorrection() {
        LabelLayoutModel layout = fixture(); layout.padding = 1;
        assertEquals(0, layout.resolveHorizontalCalibration("TEST-B1", true), 0.001);
        assertEquals(0, layout.resolveHorizontalCalibration(null, true), 0.001);
    }
}
