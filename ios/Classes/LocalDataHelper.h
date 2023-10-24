#import <Foundation/Foundation.h>
#import "PrinterConfigurationModel.h"

@interface LocalDataHelper : NSObject

- (void)setPrinterModel:(NSString *)printerName;
- (PrinterConfigurationModel *)getPrinterModel;

@end
