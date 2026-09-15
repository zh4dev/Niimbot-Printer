#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "PrintUtility.h"
#import "JCAPI.h"
#import "PrinterConfigurationModel.h"
#import "LocalDataHelper.h"
#import "KeyConstant.h"

static const float JCLabelWidth = 50.0f;
static const float JCLabelHeight = 30.0f;
static const int JCQrCodeType = 31;
static BOOL JCPrintInProgress = NO;

typedef BOOL (^JCDrawingBlock)(void);

@implementation PrintUtility

- (NSString *)printErrorMessage:(int)code {
    switch (code) {
        case 1: return @"Lid open";
        case 2: return @"Out of paper";
        case 3: return @"Not enough power";
        case 4: return @"Battery abnormality";
        case 5: return @"Manual stop";
        case 6: return @"Data error";
        case 7: return @"Temperature is too high";
        case 8: return @"Paper ejection abnormality";
        case 9: return @"Printer is busy";
        case 10: return @"No printhead detected";
        case 11: return @"Ambient temperature is too low";
        case 12: return @"The print head is not locked";
        case 13: return @"Ribbon not detected";
        case 14: return @"Mismatched ribbon";
        case 15: return @"Ribbon is used up";
        case 16: return @"Unsupported paper type";
        case 17: return @"Paper type setting failed";
        case 18: return @"Print mode setting failed";
        case 19: return @"Failed to set density";
        case 20: return @"Failed to write RFID";
        case 21: return @"Margin setting failed";
        case 22: return @"Communication error";
        case 23: return @"Printer disconnected";
        case 24: return @"Artboard parameter error";
        case 25: return @"Wrong rotation angle";
        case 26: return @"JSON parameter error";
        case 27: return @"Paper ejection abnormality (B3S)";
        case 28: return @"Check paper type";
        case 29: return @"RFID tag is not writable";
        case 30: return @"Density setting is not supported";
        case 31: return @"Unsupported print mode";
        default:
            return [NSString stringWithFormat:@"Unknown print error (%d)", code];
    }
}

- (void)printLabel:(NSArray<PrintLabelModel *> *)models
             result:(FlutterResult)result {
    [self startPrintWithDrawingBlock:^BOOL {
        [JCAPI initDrawingBoard:JCLabelWidth
                     withHeight:JCLabelHeight
            withHorizontalShift:0
              withVerticalShift:0
                         rotate:0
                           font:defaultFontName];
        float lineHeight = JCLabelHeight / 5.0f;
        for (NSInteger index = 0; index < models.count; index++) {
            PrintLabelModel *model = models[index];
            BOOL drawn = [JCAPI drawLableText:0
                                        withY:lineHeight * (index + 1)
                                    withWidth:JCLabelWidth
                                   withHeight:lineHeight
                                   withString:model.text
                               withFontFamily:defaultFontName
                                 withFontSize:model.fontSize / 4.5
                                   withRotate:0
                    withTextAlignHorizonral:1
                       withTextAlignVertical:1
                                 withLineMode:6
                            withLetterSpacing:0
                              withLineSpacing:1
                                withFontStyle:@[@NO, @NO, @NO, @NO]];
            if (!drawn) {
                return NO;
            }
        }
        return YES;
    } result:result];
}

- (void)printQrCode:(PrintQrCodeModel *)qrCode result:(FlutterResult)result {
    [self startPrintWithDrawingBlock:^BOOL {
        float size = (float)qrCode.size;
        float x = (JCLabelWidth - size) / 2.0f;
        float y = (JCLabelHeight - size) / 2.0f;
        [JCAPI initDrawingBoard:JCLabelWidth
                     withHeight:JCLabelHeight
            withHorizontalShift:0
              withVerticalShift:0
                         rotate:0
                           font:defaultFontName];
        return [JCAPI drawLableQrCode:x
                                withY:y
                            withWidth:size
                           withHeight:size
                           withString:qrCode.data
                           withRotate:0
                         withCodeType:JCQrCodeType];
    } result:result];
}

- (void)startPrintWithDrawingBlock:(JCDrawingBlock)drawingBlock
                             result:(FlutterResult)result {
    if ([JCAPI isConnectingState] == 0) {
        result([FlutterError errorWithCode:errorPrint
                                   message:@"Printer not connected"
                                   details:nil]);
        return;
    }
    @synchronized ([JCAPI class]) {
        if (JCPrintInProgress) {
            result([FlutterError errorWithCode:errorPrint
                                       message:@"Another print job is in progress"
                                       details:nil]);
            return;
        }
        JCPrintInProgress = YES;
    }

    __block BOOL completed = NO;
    void (^complete)(BOOL, NSString *) = ^(BOOL success, NSString *message) {
        @synchronized ([JCAPI class]) {
            if (completed) {
                return;
            }
            completed = YES;
            JCPrintInProgress = NO;
        }
        if (success) {
            result(@(YES));
        } else {
            result([FlutterError errorWithCode:errorPrint
                                       message:message ?: @"Print failed"
                                       details:nil]);
        }
    };

    NSString *fontPath = [[NSBundle mainBundle]
        pathForResource:@"SourceHanSans-Regular"
                 ofType:@"ttc"];
    [JCAPI initImageProcessing:fontPath error:nil];
    [JCAPI setPrintWithCache:YES];

    [JCAPI getPrintingErrorInfo:^(NSString *printInfo) {
        complete(NO, [self printErrorMessage:printInfo.intValue]);
    }];
    [JCAPI getPrintingCountInfo:^(NSDictionary *printInfo) {
        if ([printInfo[@"totalCount"] integerValue] == 1) {
            [JCAPI endPrint:^(BOOL success) {
                complete(success, @"End printing failed");
            }];
        }
    }];

    PrinterConfigurationModel *configuration =
        [[[LocalDataHelper alloc] init] getPrinterModel];
    [JCAPI setTotalQuantityOfPrints:1];
    [JCAPI startJob:configuration.printDensity
     withPaperStyle:configuration.printModel
     withCompletion:^(BOOL success) {
        if (!success) {
            complete(NO, @"Unable to start print job");
            return;
        }
        if (!drawingBlock()) {
            complete(NO, @"Unable to draw label content");
            return;
        }
        [JCAPI commit:[JCAPI GenerateLableJson]
          withOnePageNumbers:1
          withComplete:^(BOOL committed) {
            if (!committed) {
                complete(NO, @"Unable to send print data");
            }
        }];
    }];
}

@end
