//
//  FWnetworkWIFI.h
//  FeasyWifiSDK
//
//  Created by wenyewei on 2019/5/30.
//  Copyright © 2019年 Feasycom. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct Dev
{
    __unsafe_unretained NSString * _Nullable macAddress;
    unsigned char type[2];
    unsigned int ip;
    __unsafe_unretained NSString * _Nonnull dev_name;
}Dev_Info;
NS_ASSUME_NONNULL_BEGIN
@protocol WIFIManagerDelegate <NSObject>
-(void)didWIFIContect;
-(void)didFindDeviceList:(NSArray *)arr;

@end
@interface FWnetworkWIFI : NSObject
@property (weak,nonatomic) id <WIFIManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableArray *configDeviceList;
+(instancetype)shareManager;
-(BOOL)isEnableWIFI;
-(void)connectWIFIWithSSID:(NSString *)SSID pass:(NSString *)pass;
-(void)startScan;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
