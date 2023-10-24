#import <Foundation/Foundation.h>
#import "PrintUtility.h"
#import <Flutter/Flutter.h>
#import "JCAPI.h"
#import "PrinterConfigurationModel.h"
#import "LocalDataHelper.h"
#import "KeyConstant.h"

@implementation PrintUtility

- (NSString *)catchPrintError:(int)code {
    NSString *errorMsg = errorPrint;
    switch (code) {
        case 1:
            errorMsg = @"lid open";
            break;
        case 2:
            errorMsg = @"Out of paper";
            break;
        case 3:
            errorMsg = @"Not enough power";
            break;
        case 4:
            errorMsg = @"Battery abnormality";
            break;
        case 5:
            errorMsg = @"Manual stop";
            break;
        case 6:
            errorMsg = @"data error";
            break;
        case 7:
            errorMsg = @"Temperature is too high";
            break;
        case 8:
            errorMsg = @"Paper ejection abnormality";
            break;
        case 9:
            errorMsg = @"Printing";
            break;
        case 10:
            errorMsg = @"No printhead detected";
            break;
        case 11:
            errorMsg = @"Ambient temperature is too low";
            break;
        case 12:
            errorMsg = @"The print head is not locked";
            break;
        case 13:
            errorMsg = @"Ribbon not detected";
            break;
        case 14:
            errorMsg = @"Mismatched ribbon";
            break;
        case 15:
            errorMsg = @"Used up ribbon";
            break;
        case 16:
            errorMsg = @"Unsupported paper types";
            break;
        case 17:
            errorMsg = @"Paper type setting failed";
            break;
        case 18:
            errorMsg = @"Print mode setting failed";
            break;
        case 19:
            errorMsg = @"Failed to set concentration";
            break;
        case 20:
            errorMsg = @"Failed to write rfid";
            break;
        case 21:
            errorMsg = @"Margin setting failed";
            break;
        case 22:
            errorMsg = @"Communication abnormality";
            break;
        case 23:
            errorMsg = @"Printer disconnected";
            break;
        case 24:
            errorMsg = @"Artboard parameter error";
            break;
        case 25:
            errorMsg = @"Wrong rotation angle";
            break;
        case 26:
            errorMsg = @"json parameter error";
            break;
        case 27:
            errorMsg = @"Paper ejection abnormality (B3S)";
            break;
        case 28:
            errorMsg = @"Check paper type";
            break;
        case 29:
            errorMsg = @"The RFID tag is not being written to";
            break;
        case 30:
            errorMsg = @"Density setting is not supported";
            break;
        case 31:
            errorMsg = @"Unsupported print mode";
            break;
        default:
            break;
    }
    
    return errorMsg;
}


- (void)printLabel:(NSArray<PrintLabelModel*> *)printLabelModels result:(FlutterResult)result {
    if ([JCAPI isConnectingState] != 0) {
        result(errorPrint);
        return;
    }
    PrinterConfigurationModel *model = [[LocalDataHelper alloc] getPrinterModel];
    [JCAPI getPrintingErrorInfo:^(NSString *printInfo) {
        NSInteger intergerValue = [printInfo intValue];
        NSString *errorMessage = [self catchPrintError:intergerValue];
        result(errorMessage);
    }];
    NSInteger count = 1;
    [JCAPI getPrintingCountInfo:^(NSDictionary *printDicInfo) {
        NSString *totalCount = [printDicInfo valueForKey:@"totalCount"];
        if(totalCount.intValue == 1){
            [JCAPI endPrint:^(BOOL isSuccess) {
                if (isSuccess) {
                    result(@(YES));
                } else {
                    result(errorPrint);
                }
            }];
        }
    }];
    [JCAPI setTotalQuantityOfPrints:1];
    [JCAPI startJob:model.printDensity withPaperStyle:model.printModel withCompletion:^(BOOL isSuccess) {
        if(isSuccess){
            [JCAPI initDrawingBoard:70 withHeight:50 withHorizontalShift:0 withVerticalShift:0 rotate:90 font:@""];
            [JCAPI drawLableText:7.5 withY:5.0 withWidth: 40.5 withHeight:6.5 withString:@"F金银花开植物饮料" withFontFamily:@"宋体" withFontSize:3.5 withRotate:0 withTextAlignHorizonral:0 withTextAlignVertical:1 withLineMode:1 withLetterSpacing:0 withLineSpacing:1 withFontStyle: @[@0,@0,@0,@0]];
            [JCAPI commit:[JCAPI GenerateLableJson] withOnePageNumbers:1 withComplete:^(BOOL isSuccess) {
                if (isSuccess) {
                 
                }
            }];
        }
    }];
}

@end

