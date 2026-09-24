package com.zh4dev.niimbot_print.Model;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public final class PrintElementModel {
    public static final class ResolvedFrame {
        public final float x, y, width, height;
        ResolvedFrame(float x, float y, float width, float height) {
            this.x = x; this.y = y; this.width = width; this.height = height;
        }
    }
    private final String source;
    private final JsonObject json;

    public PrintElementModel(String source) {
        this.source = source;
        this.json = JsonParser.parseString(source).getAsJsonObject();
    }

    public String source() { return source; }
    public String type() { return string("type", "text"); }
    public boolean hasFrame() { return json.has("frame") && json.get("frame").isJsonObject(); }
    public float x() { return frame("x"); }
    public float y() { return frame("y"); }
    public float width() { return frame("width"); }
    public float height() { return frame("height"); }
    public ResolvedFrame resolveFrame(float canvasWidth, float canvasHeight, float padding) {
        if (hasFrame()) return new ResolvedFrame(x(), y(), width(), height());
        if (!"qrCode".equals(type()) && !"barcode".equals(type())) {
            throw new IllegalArgumentException(
                    "An explicit frame is required for " + type() + " elements"
            );
        }
        float availableWidth = Math.max(canvasWidth - padding * 2.0F, 1.0F);
        float availableHeight = Math.max(canvasHeight - padding * 2.0F, 1.0F);
        boolean qr = "qrCode".equals(type());
        float requestedWidth = nullableNumber("width");
        float requestedHeight = nullableNumber("height");
        float width;
        float height;
        if (qr) {
            float defaultSize = Math.min(availableWidth, availableHeight) * 0.7F;
            width = Float.isNaN(requestedWidth)
                    ? (Float.isNaN(requestedHeight) ? defaultSize : requestedHeight)
                    : requestedWidth;
            height = Float.isNaN(requestedHeight) ? width : requestedHeight;
        } else {
            width = Float.isNaN(requestedWidth) ? availableWidth : requestedWidth;
            height = Float.isNaN(requestedHeight)
                    ? Math.min(Math.max(canvasHeight * 0.28F, 10.0F), availableHeight)
                    : requestedHeight;
        }
        width = Math.min(Math.max(width, 1.0F), availableWidth);
        height = Math.min(Math.max(height, 1.0F), availableHeight);
        float x = alignedOffset(string("horizontalAlignment", "center"), canvasWidth, width, padding);
        float y = alignedOffset(string("verticalAlignment", "center"), canvasHeight, height, padding);
        return new ResolvedFrame(x, y, width, height);
    }
    public String string(String key, String fallback) {
        return json.has(key) && !json.get(key).isJsonNull() ? json.get(key).getAsString() : fallback;
    }
    public int integer(String key, int fallback) {
        return json.has(key) && !json.get(key).isJsonNull() ? json.get(key).getAsInt() : fallback;
    }
    public float number(String key, float fallback) {
        return json.has(key) && !json.get(key).isJsonNull() ? json.get(key).getAsFloat() : fallback;
    }
    private float nullableNumber(String key) {
        return json.has(key) && !json.get(key).isJsonNull()
                ? json.get(key).getAsFloat()
                : Float.NaN;
    }
    private float alignedOffset(String alignment, float extent, float size, float padding) {
        if ("start".equals(alignment)) return padding;
        if ("end".equals(alignment)) return extent - padding - size;
        return (extent - size) / 2.0F;
    }
    public float[] numbers(String key, float[] fallback) {
        if (!json.has(key) || !json.get(key).isJsonArray()) return fallback;
        JsonArray array = json.getAsJsonArray(key);
        float[] values = new float[array.size()];
        for (int i = 0; i < array.size(); i++) values[i] = array.get(i).getAsFloat();
        return values;
    }
    private float frame(String key) {
        return json.getAsJsonObject("frame").get(key).getAsFloat();
    }
}
