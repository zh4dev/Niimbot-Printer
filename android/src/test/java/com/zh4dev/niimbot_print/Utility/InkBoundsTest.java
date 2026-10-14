package com.zh4dev.niimbot_print.Utility;

import org.junit.Test;
import static org.junit.Assert.*;

public class InkBoundsTest {
    @Test public void centeredInkHasZeroCorrectionAtAnyCanvasScale() {
        InkBounds bounds = new InkBounds(100, 60);
        bounds.add(20, 10, 0xff000000); bounds.add(79, 49, 0xff000000);
        assertEquals(0, bounds.centerX(50, 2), 0.001);
        assertEquals(0, bounds.centerY(30), 0.001);
        assertEquals(0, bounds.centerX(170, 2), 0.001);
    }
    @Test public void rightAndTopDisplacementMovesLeftAndDown() {
        InkBounds bounds = new InkBounds(100, 60);
        bounds.add(26, 4, 0xff000000); bounds.add(85, 43, 0xff000000);
        assertEquals(-2, bounds.centerX(50, 2), 0.001); // clamps at safe padding
        assertEquals(3, bounds.centerY(30), 0.001);
    }
    @Test public void transparentAndWhitePixelsDoNotChangeInkBounds() {
        InkBounds bounds = new InkBounds(100, 60);
        bounds.add(0, 0, 0x00000000); bounds.add(99, 59, 0xffffffff);
        assertFalse(bounds.hasInk());
        assertEquals(0, bounds.centerX(50, 2), 0.001);
    }
}
