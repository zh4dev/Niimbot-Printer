                    #import <Foundation/Foundation.h>
#import "PrintLabelModel.h"
#import "PrintQrCodeModel.h"
#import <Flutter/Flutter.h>

@interface PrintUtility : NSObject

- (void)printLabel:(NSArray<PrintLabelModel *> *)printLabelModels
             layout:(NSDictionary *)layout
             result:(FlutterResult)result;
- (void)printQrCode:(PrintQrCodeModel *)qrCode result:(FlutterResult)result;
- (void)printElements:(NSArray<NSDictionary *> *)elements
                layout:(NSDictionary *)layout
                result:(FlutterResult)result;
- (void)generatePreview:(NSArray<NSDictionary *> *)elements
                  layout:(NSDictionary *)layout
                  result:(FlutterResult)result;

@end
