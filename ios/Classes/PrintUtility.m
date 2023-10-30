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
    NSString *str = [[NSBundle mainBundle] pathForResource:@"SourceHanSans-Regular" ofType:@"ttc"];
    [JCAPI initImageProcessing:str error:nil];
    [JCAPI setPrintWithCache:YES];
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
                result(isSuccess ? @(YES) : @(NO));
            }];
        }
    }];
    [JCAPI setTotalQuantityOfPrints:1];
    [JCAPI startJob:model.printDensity withPaperStyle:model.printModel withCompletion:^(BOOL isSuccess) {
        if(isSuccess){
            NSInteger width = 50;
            NSInteger height = 30;
            NSInteger orientation = 0;
            [JCAPI
             initDrawingBoard:width
             withHeight:height
             withHorizontalShift:0
             withVerticalShift:0
             rotate:orientation
             font:defaultFontName
            ];
            for (NSInteger i = 0; i < printLabelModels.count; i++) {
                PrintLabelModel *model = printLabelModels[i];
                float marginX = 0;
                float marginY = 0;
                float rectangleWidth = width - marginX * 2;
                float rectangleHeight = height - marginY * 2;
                float lineHeight = rectangleHeight / 5.0f;
                float fontSize = model.fontSize / 4.5;
                [JCAPI
                 drawLableText:marginX
                 withY:marginY + lineHeight * (i + 1)
                 withWidth: rectangleWidth
                 withHeight: lineHeight
                 withString: model.text
                 withFontFamily:defaultFontName
                 withFontSize:fontSize
                 withRotate:orientation
                 withTextAlignHorizonral:1
                 withTextAlignVertical:1
                 withLineMode:6
                 withLetterSpacing:0
                 withLineSpacing:1
                 withFontStyle: @[@0,@0,@0,@0]
                ];
            }
            [JCAPI commit:[JCAPI GenerateLableJson] withOnePageNumbers:1 withComplete:^(BOOL isSuccess) {
                if (isSuccess) {}
            }];
        }
    }];
}

@end

