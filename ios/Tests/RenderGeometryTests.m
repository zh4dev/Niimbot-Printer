// Foundation-only executable. Runs the production geometry/profile code on macOS.
#import "InkBounds.h"
#import "PrinterMediaProfile.h"
#import <assert.h>
#import <math.h>
#import <string.h>

int main(void) { @autoreleasepool {
    unsigned char pixels[100 * 60 * 4];
    memset(pixels, 255, sizeof(pixels));
    size_t first = (4 * 100 + 26) * 4, last = (43 * 100 + 85) * 4;
    memset(pixels + first, 0, 3); memset(pixels + last, 0, 3);
    JCInkCorrection bounds = JCMeasureInkBounds(pixels, 100, 60, 50, 30, 2, YES, YES);
    assert(bounds.hasInk && fabsf(bounds.x + 2) < 0.001 && fabsf(bounds.y - 3) < 0.001);
    bounds = JCMeasureInkBounds(pixels, 100, 60, 50, 30, 2, NO, NO);
    assert(bounds.x == 0 && bounds.y == 0);
    memset(pixels, 0, sizeof(pixels));
    assert(!JCMeasureInkBounds(pixels, 100, 60, 50, 30, 2, YES, YES).hasInk);
    memset(pixels, 255, sizeof(pixels));
    memset(pixels + (10 * 100 + 20) * 4, 0, 3);
    memset(pixels + (49 * 100 + 79) * 4, 0, 3);
    bounds = JCMeasureInkBounds(pixels, 100, 60, 50, 30, 2, YES, YES);
    assert(bounds.hasInk && bounds.x == 0 && bounds.y == 0);

    NSMutableDictionary *layout = [@{ @"width": @50, @"height": @30, @"padding": @2,
      @"orientation": @"portrait", @"printerProfiles": @[
        @{ @"printerName": @"TEST-B1", @"width": @50, @"height": @30,
           @"orientation": @"portrait", @"horizontalCorrection": @-2 }]} mutableCopy];
    assert(JCResolveHorizontalCalibration(layout, @"test-b1", YES) == -2);
    assert(JCResolveHorizontalCalibration(layout, @"OTHER-B1", YES) == 0);
    assert(JCResolveHorizontalCalibration(layout, @"TEST-B1", NO) == 0);
    layout[@"orientation"] = @"landscape";
    assert(JCResolveHorizontalCalibration(layout, @"TEST-B1", YES) == 0);
    layout[@"orientation"] = @"portrait"; layout[@"height"] = @80;
    assert(JCResolveHorizontalCalibration(layout, @"TEST-B1", YES) == 0);
    layout[@"height"] = @30; layout[@"horizontalCalibration"] = @-1;
    assert(JCResolveHorizontalCalibration(layout, @"TEST-B1", YES) == -1);
    layout[@"horizontalCalibration"] = @0; layout[@"usePrinterProfiles"] = @NO;
    assert(JCResolveHorizontalCalibration(layout, @"TEST-B1", YES) == 0);
    NSLog(@"Native geometry/profile tests passed");
} return 0; }
