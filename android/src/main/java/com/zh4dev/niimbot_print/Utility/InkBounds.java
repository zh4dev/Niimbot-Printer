package com.zh4dev.niimbot_print.Utility;

/** Pixel-only geometry: no Android bitmap dependency, so native layout is testable. */
public final class InkBounds {
    private final int width, height;
    private int minX, minY, maxX = -1, maxY = -1;

    public InkBounds(int width, int height) {
        if (width <= 0 || height <= 0) throw new IllegalArgumentException("Invalid bitmap size");
        this.width = width; this.height = height;
        minX = width; minY = height;
    }

    public void add(int x, int y, int argb) {
        if (((argb >>> 24) & 255) < 128 ||
                (((argb >>> 16) & 255) + ((argb >>> 8) & 255) + (argb & 255)) >= 384) return;
        minX = Math.min(minX, x); maxX = Math.max(maxX, x);
        minY = Math.min(minY, y); maxY = Math.max(maxY, y);
    }

    public boolean hasInk() { return maxX >= minX; }
    public float centerX(float canvasWidth, float padding) {
        if (!hasInk()) return 0;
        float correction = (width - (minX + maxX + 1)) * canvasWidth / (2.0F * width);
        return Math.max(-padding, Math.min(padding, correction));
    }
    public float centerY(float canvasHeight) {
        return hasInk() ? (height - (minY + maxY + 1)) * canvasHeight / (2.0F * height) : 0;
    }
}
