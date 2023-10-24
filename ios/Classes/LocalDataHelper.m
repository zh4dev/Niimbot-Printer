#import "LocalDataHelper.h"
#import "PrinterConfigurationModel.h"
#import "LocalDataConstant.h"

@implementation LocalDataHelper

- (void)setPrinterModel:(NSString *)printerName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    PrinterConfigurationModel *model;

    if ([printerName rangeOfString:@"^(B32|Z401|B50|T6|T7|T8).*" options:NSRegularExpressionSearch].location != NSNotFound) {
        model = [[PrinterConfigurationModel alloc] initWithPrintModel:2 printDensity:8 printMultiple:11.81];
    } else {
        model = [[PrinterConfigurationModel alloc] initWithPrintModel:1 printDensity:3 printMultiple:8.0];
    }

    NSString *json = [model toJson];
    [userDefaults setObject:json forKey:printConfiguration];
    [userDefaults synchronize];
}

- (PrinterConfigurationModel *)getPrinterModel {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [userDefaults objectForKey:printConfiguration];
    PrinterConfigurationModel *model = [[PrinterConfigurationModel alloc] initWithPrintModel:1 printDensity:3 printMultiple:8.0];

    if (json) {
        model = [PrinterConfigurationModel fromJson:json];
    }

    return model;
}

@end
