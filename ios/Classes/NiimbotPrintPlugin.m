#import "NiimbotPrintPlugin.h"
#import "PluginConstant.h"
#import "PrintHelper.h"

@implementation NiimbotPrintPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:niimbotPrint
            binaryMessenger:[registrar messenger]];
  NiimbotPrintPlugin* instance = [[NiimbotPrintPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    PrintHelper *printHelper = [[PrintHelper alloc] init];
  if ([onStartScan isEqualToString:call.method]) {
      [printHelper onStartScan:call result:result];
  } else if ([onStartConnect isEqualToString:call.method]) {
      [printHelper onStartConnect:call result:result];
  } else if ([onStartPrintText isEqualToString:call.method]) {
      [printHelper onStartPrintText:call result:result;
  } else if ([onDisconnect isEqualToString:call.method]) {
      [printHelper onDisconnect:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
