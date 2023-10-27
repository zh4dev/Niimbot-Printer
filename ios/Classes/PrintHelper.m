#import <Flutter/Flutter.h>
#import "PrintHelper.h"
#import "JCAPI.h"
#import "BlueDeviceInfoModel.h"
#import "KeyConstant.h"
#import "PrintLabelModel.h"
#import "PrintUtility.h"
#import "LocalDataHelper.h"

@implementation PrintHelper

- (void)onDisconnect:(FlutterResult)result {
    if ([JCAPI isConnectingState] == 0) {
        result(@(NO));
    } else {
        [JCAPI closePrinter];
        result(@(YES));
    }
}

- (void)onStartPrintText:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSMutableArray *stringList = call.arguments;
    NSMutableArray<PrintLabelModel *> *printLabelModels = [NSMutableArray array];
    if ([stringList count] > 0) {
        for (int i = 0; i < stringList.count; i++) {
            [printLabelModels addObject:[PrintLabelModel fromJson:stringList[i]]];
            if (i == [stringList count] - 1) {
                PrintUtility *printUtility = [[PrintUtility alloc] init];
                [printUtility printLabel:printLabelModels result:result];
            }
        }
    } else {
        result(emptyText);
    }
}

- (void)onStartConnect:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *arguments = call.arguments;
    BlueDeviceInfoModel *model = [[BlueDeviceInfoModel alloc] fromJson:arguments];
    if(model.deviceName == nil || model.deviceName.length == 0) {
        result(failedPairing);
        return;
    }
    [JCAPI openPrinter:model.deviceName completion:^(BOOL isSuccess) {
        LocalDataHelper *localDataHelper = [[LocalDataHelper alloc] init];
        if (isSuccess) {
            [localDataHelper setPrinterModel:model.deviceName];
            result(connectionSuccess);
        } else {
            result(failedPairing);
        }
    }];
}

- (void)onStartScan:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSNumber *scanDuration = call.arguments;
    NSMutableArray *arr = [NSMutableArray array];
    [JCAPI scanPrinterNames:NO completion:^(NSArray *scanedPrinterNames) {
        for(NSString *name in scanedPrinterNames){
            BlueDeviceInfoModel *model = [[BlueDeviceInfoModel alloc] initWithDeviceName:name deviceHardwareAddress:@("") connectionState:0];
            [arr addObject:model.toJson];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) scanDuration), dispatch_get_main_queue(), ^{
            result(arr);
        });
    }];
}

@end
