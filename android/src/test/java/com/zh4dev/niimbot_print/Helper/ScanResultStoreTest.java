package com.zh4dev.niimbot_print.Helper;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;

public class ScanResultStoreTest {
    @Test
    public void newScanDoesNotContainResultsFromPreviousScan() {
        ScanResultStore store = new ScanResultStore();

        store.beginScan();
        store.add("AA:AA", "old-device");
        assertEquals(Collections.singletonList("old-device"), store.takeResults());

        store.beginScan();
        store.add("BB:BB", "nearby-device");
        assertEquals(Collections.singletonList("nearby-device"), store.takeResults());
    }

    @Test
    public void duplicateAddressUsesLatestAdvertisementWithoutDuplicates() {
        ScanResultStore store = new ScanResultStore();

        store.beginScan();
        store.add("AA:AA", "first-advertisement");
        store.add("AA:AA", "updated-advertisement");
        store.add("BB:BB", "second-device");

        assertEquals(
                Arrays.asList("updated-advertisement", "second-device"),
                store.takeResults()
        );
        assertEquals(Collections.emptyList(), store.takeResults());
    }
}
