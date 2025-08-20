                    #import <Foundation/Foundation.h>
#import "PrintLabelModel.h"
#import <Flutter/Flutter.h>

@interface PrintUtility : NSObject

- (void)printLabel:(NSArray<PrintLabelModel *> *)printLabelModels result:(FlutterResult)result;

@end
