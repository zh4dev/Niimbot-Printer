#import <Foundation/Foundation.h>

/// Resolves device/media policy without depending on the native drawing SDK.
FOUNDATION_EXPORT float JCResolveHorizontalCalibration(NSDictionary *layout,
                                                      NSString *printerName,
                                                      BOOL centeredFlow);
