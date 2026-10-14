package com.zh4dev.niimbot_print.Utility;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.LinkedHashMap;
import java.util.Map;

/** Bounded session cache of geometry only. Never retains text, images or label JSON. */
public final class RenderCorrectionCache {
    private final Map<String, float[]> entries;
    public RenderCorrectionCache(int capacity) {
        entries = new LinkedHashMap<String, float[]>(capacity, 0.75F, true) {
            @Override protected boolean removeEldestEntry(Map.Entry<String, float[]> entry) {
                return size() > capacity;
            }
        };
    }
    public static String key(String payload) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(payload.getBytes(StandardCharsets.UTF_8));
            StringBuilder value = new StringBuilder();
            for (byte item : digest) value.append(String.format("%02x", item & 255));
            return value.toString();
        } catch (NoSuchAlgorithmException error) { throw new IllegalStateException(error); }
    }
    public synchronized float[] get(String key) {
        float[] value = entries.get(key);
        return value == null ? null : value.clone();
    }
    public synchronized void put(String key, float x, float y) { entries.put(key, new float[]{x, y}); }
}
