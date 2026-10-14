package com.zh4dev.niimbot_print.Utility;

import org.junit.Test;
import static org.junit.Assert.*;

public class RenderCorrectionCacheTest {
    @Test public void cacheEvictsLeastRecentlyUsedAndDoesNotExposeMutableValues() {
        RenderCorrectionCache cache = new RenderCorrectionCache(2);
        cache.put("a", 1, 2); cache.put("b", 3, 4);
        float[] result = cache.get("a"); result[0] = 99;
        cache.put("c", 5, 6);
        assertNull(cache.get("b"));
        assertEquals(1, cache.get("a")[0], 0.001);
    }
    @Test public void differentFontOrLayoutPayloadsHaveDifferentAnonymousKeys() {
        assertEquals(RenderCorrectionCache.key("name:bold:50x30"), RenderCorrectionCache.key("name:bold:50x30"));
        assertNotEquals(RenderCorrectionCache.key("name:bold:50x30"), RenderCorrectionCache.key("name:normal:50x80"));
        assertFalse(RenderCorrectionCache.key("PRIVATE ATTENDEE").contains("PRIVATE"));
    }
}
