#import "BlueDeviceInfoModel.h"

@implementation BlueDeviceInfoModel

- (instancetype)initWithDeviceName:(NSString *)deviceName deviceHardwareAddress:(NSString *)deviceHardwareAddress connectionState:(int)connectionState {
    self = [super init];
    if (self) {
        _deviceName = deviceName;
        _deviceHardwareAddress = deviceHardwareAddress;
        _connectionState = connectionState;
    }
    return self;
}

- (NSString *)toJson {
    NSError *error = nil;
    NSDictionary *dictionary = @{
        @"deviceName": self.deviceName,
        @"deviceHardwareAddress": self.deviceHardwareAddress,
        @"connectionState": @(self.connectionState)
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

- (BlueDeviceInfoModel *)fromJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    if (error) {
        return nil;
    } else {
        return [[BlueDeviceInfoModel alloc] initWithDeviceName:dictionary[@"deviceName"]
                                     deviceHardwareAddress:dictionary[@"deviceHardwareAddress"]
                                        connectionState:[dictionary[@"connectionState"] intValue]];
    }
}

@end
