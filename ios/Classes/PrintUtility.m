#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "PrintUtility.h"
#import "JCAPI.h"
#import "PrinterConfigurationModel.h"
#import "LocalDataHelper.h"
#import "KeyConstant.h"

static const float JCLabelWidth = 50.0f;
static const float JCLabelHeight = 30.0f;
static const float JCTextHorizontalPadding = 2.0f;
static const int JCQrCodeType = 31;
static const NSTimeInterval JCPrintTimeoutSeconds = 30.0;
static NSString * const JCDefaultFontFile = @"ZT001.ttf";
static BOOL JCPrintInProgress = NO;

typedef BOOL (^JCDrawingBlock)(void);

static BOOL JCIsPrinterConnected(void) {
    int connectionState = [JCAPI isConnectingState];
    NSString *printerName = [JCAPI connectingPrinterName];
    return connectionState != 0 || printerName.length > 0;
}

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
                      fontArray:@[JCDefaultFontFile]];
        NSInteger totalLineCount = 0;
        for (NSInteger index = 0; index < models.count; index++) {
            PrintLabelModel *model = models[index];
            NSInteger lineCount = [model.text
                componentsSeparatedByCharactersInSet:
                    [NSCharacterSet newlineCharacterSet]].count;
            totalLineCount += MAX(lineCount, 1);
        }

        float defaultLineHeight = JCLabelHeight / 5.0f;
        float lineHeight = MIN(
            defaultLineHeight,
            JCLabelHeight / (float)MAX(totalLineCount, 1)
        );
        float contentHeight = lineHeight * totalLineCount;
        float currentY = MAX((JCLabelHeight - contentHeight) / 2.0f, 0.0f);
        BOOL allDrawsReportedSuccess = YES;

        for (NSInteger index = 0; index < models.count; index++) {
            PrintLabelModel *model = models[index];
            NSInteger lineCount = [model.text
                componentsSeparatedByCharactersInSet:
                    [NSCharacterSet newlineCharacterSet]].count;
            float textBoxHeight = lineHeight * MAX(lineCount, 1);
            BOOL drawn = [JCAPI drawLableText:JCTextHorizontalPadding
                                        withY:currentY
                                    withWidth:JCLabelWidth - (JCTextHorizontalPadding * 2.0f)
                                   withHeight:textBoxHeight
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
                NSLog(@"[Niimbot] drawLableText failed: index=%ld, length=%lu, "
                      @"x=%.2f, y=%.2f, width=%.2f, height=%.2f, font=%@, "
                      @"fontSize=%.2f",
                      (long)index,
                      (unsigned long)model.text.length,
                      JCTextHorizontalPadding,
                      currentY,
                      JCLabelWidth - (JCTextHorizontalPadding * 2.0f),
                      textBoxHeight,
                      defaultFontName,
                      model.fontSize / 4.5);
                allDrawsReportedSuccess = NO;
            }
            currentY += textBoxHeight;
        }
        return allDrawsReportedSuccess;
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
                      fontArray:@[JCDefaultFontFile]];
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
    if (!JCIsPrinterConnected()) {
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

    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            (int64_t)(JCPrintTimeoutSeconds * NSEC_PER_SEC)
        ),
        dispatch_get_main_queue(),
        ^{
            complete(NO, @"Print timed out. Check the printer connection and try again");
        }
    );

    // Follow SDKDemoOC v4.1.1: FONT.json and its font files are copied into
    // the app resources, then image processing is initialized from the main
    // bundle resource directory.
    NSString *resourcePath = [NSBundle mainBundle].resourcePath;
    NSString *fontManifestPath = [[NSBundle mainBundle]
        pathForResource:@"FONT"
                 ofType:@"json"];
    NSString *defaultFontPath = [[NSBundle mainBundle]
        pathForResource:@"ZT001"
                 ofType:@"ttf"];
    if (resourcePath.length == 0 ||
        fontManifestPath.length == 0 ||
        defaultFontPath.length == 0) {
        complete(NO, @"Niimbot font resource is missing");
        return;
    }
    NSError *fontError = nil;
    [JCAPI initImageProcessing:resourcePath error:&fontError];
    if (fontError != nil) {
        complete(NO, fontError.localizedDescription ?: @"Unable to initialize label renderer");
        return;
    }
    [JCAPI setPrintWithCache:YES];

    // SDKDemoOC renders the drawing board and generates its JSON before
    // starting the physical print job. Rendering inside startJob's callback
    // can make drawLableText return NO on iOS even though font setup succeeds.
    NSString *labelJson = nil;
    @try {
        // SDKDemoOC logs individual draw return values but still calls
        // GenerateLableJson. Some JCAPI versions report NO even when the
        // drawing command was accepted, so the generated JSON is the reliable
        // success signal here.
        BOOL drawingReportedSuccess = drawingBlock();
        NSLog(@"[Niimbot] drawing reported success=%@",
              drawingReportedSuccess ? @"YES" : @"NO");
        labelJson = [JCAPI GenerateLableJson];
    } @catch (NSException *exception) {
        complete(NO, exception.reason ?: @"Unable to render label content");
        return;
    }
    if (labelJson.length == 0) {
        complete(NO, @"Unable to generate label data");
        return;
    }

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
        [JCAPI commit:labelJson
          withOnePageNumbers:1
          withComplete:^(BOOL committed) {
            if (!committed) {
                complete(NO, @"Unable to send print data");
            }
        }];
    }];
}

@end
