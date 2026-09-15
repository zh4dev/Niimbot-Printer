                    #import <Foundation/Foundation.h>
#import "PrintLabelModel.h"
#import "PrintQrCodeModel.h"
#import <Flutter/Flutter.h>

@interface PrintUtility : NSObject

- (void)printLabel:(NSArray<PrintLabelModel *> *)printLabelModels result:(FlutterResult)result;
- (void)printQrCode:(PrintQrCodeModel *)qrCode result:(FlutterResult)result;

@end
