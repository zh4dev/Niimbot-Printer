package com.zh4dev.niimbot_print.Helper;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Keeps discovered devices isolated to a single Bluetooth scan session. */
final class ScanResultStore {
    private final Map<String, String> devicesByAddress = new LinkedHashMap<>();

    synchronized void beginScan() {
        devicesByAddress.clear();
    }

    synchronized void add(String address, String serializedDevice) {
        devicesByAddress.put(address, serializedDevice);
    }

    synchronized List<String> takeResults() {
        List<String> results = new ArrayList<>(devicesByAddress.values());
        devicesByAddress.clear();
        return results;
    }

    synchronized void clear() {
        devicesByAddress.clear();
    }
}
