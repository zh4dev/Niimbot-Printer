#import <Flutter/Flutter.h>
#import "PrintHelper.h"
#import "JCAPI.h"
#import "BlueDeviceInfoModel.h"
#import "KeyConstant.h"
#import "PrintLabelModel.h"
#import "PrintQrCodeModel.h"
#import "PrintUtility.h"
#import "LocalDataHelper.h"

static BOOL JCIsPrinterConnected(void) {
    int connectionState = [JCAPI isConnectingState];
    NSString *printerName = [JCAPI connectingPrinterName];
    BOOL isConnected = connectionState != 0 || printerName.length > 0;
    NSLog(@"[Niimbot] connectionState=%d, printerName=%@, connected=%@",
          connectionState,
          printerName ?: @"<nil>",
          isConnected ? @"YES" : @"NO");
    return isConnected;
}

@implementation PrintHelper

- (void)onDisconnect:(FlutterResult)result {
    if (!JCIsPrinterConnected()) {
        result(@(NO));
        return;
    }
    [JCAPI closePrinter];
    result(@(YES));
}

- (void)isConnected:(FlutterResult)result {
    result(@(JCIsPrinterConnected()));
}

- (void)onStartPrintText:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray *values = [call.arguments isKindOfClass:[NSArray class]]
        ? call.arguments
        : @[];
    if (values.count == 0) {
        result([FlutterError errorWithCode:emptyText
                                   message:@"Print data cannot be empty"
                                   details:nil]);
        return;
    }

    NSMutableArray<PrintLabelModel *> *models = [NSMutableArray array];
    for (id value in values) {
        if ([value isKindOfClass:[NSString class]]) {
            [models addObject:[PrintLabelModel fromJson:value]];
        }
    }
    if (models.count == 0) {
        result([FlutterError errorWithCode:emptyText
                                   message:@"Print data cannot be empty"
                                   details:nil]);
        return;
    }
    [[[PrintUtility alloc] init] printLabel:models result:result];
}

- (void)onStartPrintQrCode:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (![call.arguments isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:emptyText
                                   message:@"QR code data cannot be empty"
                                   details:nil]);
        return;
    }
    PrintQrCodeModel *model = [PrintQrCodeModel fromJson:call.arguments];
    if (model.data.length == 0 || model.size <= 0 || model.size > 30) {
        result([FlutterError errorWithCode:emptyText
                                   message:@"Invalid QR code data or size"
                                   details:nil]);
        return;
    }
    [[[PrintUtility alloc] init] printQrCode:model result:result];
}

- (void)onStartConnect:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (![call.arguments isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:connectionFailed
                                   message:@"Invalid printer data"
                                   details:nil]);
        return;
    }
    BlueDeviceInfoModel *model = [[[BlueDeviceInfoModel alloc] init]
        fromJson:call.arguments];
    if (model.deviceName.length == 0) {
        result([FlutterError errorWithCode:failedPairing
                                   message:@"Printer name cannot be empty"
                                   details:nil]);
        return;
    }

    __block BOOL completed = NO;
    [JCAPI openPrinter:model.deviceName completion:^(BOOL isSuccess) {
        if (completed) {
            return;
        }
        completed = YES;
        if (isSuccess) {
            [[[LocalDataHelper alloc] init] setPrinterModel:model.deviceName];
            result(connectionSuccess);
        } else {
            result([FlutterError errorWithCode:failedPairing
                                       message:@"Unable to pair the device"
                                       details:nil]);
        }
    }];
}

- (void)onStartScan:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *durationValue = [call.arguments isKindOfClass:[NSNumber class]]
        ? call.arguments
        : @6000;
    int64_t durationMilliseconds = MAX(durationValue.longLongValue, 1);
    NSMutableDictionary<NSString *, NSString *> *devices =
        [NSMutableDictionary dictionary];
    __block BOOL completed = NO;

    [JCAPI scanBluetoothPrinter:^(NSArray *printerNames) {
        if (completed) {
            return;
        }
        @synchronized (devices) {
            for (id value in printerNames) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                NSString *name = value;
                BlueDeviceInfoModel *model = [[BlueDeviceInfoModel alloc]
                    initWithDeviceName:name
                    deviceHardwareAddress:@""
                    connectionState:0];
                devices[name] = model.toJson;
            }
        }
    }];

    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, durationMilliseconds * NSEC_PER_MSEC),
        dispatch_get_main_queue(),
        ^{
            if (completed) {
                return;
            }
            completed = YES;
            @synchronized (devices) {
                result(devices.allValues);
            }
        }
    );
}

@end
