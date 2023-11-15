#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface PrintHelper : NSObject

- (void)isConnected:(FlutterResult)result;
- (void)onDisconnect:(FlutterResult)result;
- (void)onStartScan:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)onStartConnect:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)onStartPrintText:(FlutterMethodCall*)call result:(FlutterResult)result;

@end
