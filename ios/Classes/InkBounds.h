#import <Foundation/Foundation.h>

typedef struct { BOOL hasInk; float x; float y; } JCInkCorrection;
FOUNDATION_EXPORT JCInkCorrection JCMeasureInkBounds(const unsigned char *rgba,
    size_t width, size_t height, float canvasWidth, float canvasHeight,
    float padding, BOOL centerX, BOOL centerY);
