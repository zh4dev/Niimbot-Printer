#import <Foundation/Foundation.h>

@interface BlueDeviceInfoModel : NSObject

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *deviceHardwareAddress;
@property (nonatomic, assign) int connectionState;

- (instancetype)initWithDeviceName:(NSString *)deviceName deviceHardwareAddress:(NSString *)deviceHardwareAddress connectionState:(int)connectionState;
- (NSString *)toJson;
- (BlueDeviceInfoModel *)fromJson:(NSString *)json;

@end
