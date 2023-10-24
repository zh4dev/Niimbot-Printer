
#include "FWnetworkWIFI.h"

@implementation FWnetworkWIFI

+(instancetype)shareManager{
    FWnetworkWIFI * manager = [super init];
    return manager;
}

-(BOOL)isEnableWIFI{
    return NO;
}


-(void)connectWIFIWithSSID:(NSString *)SSID pass:(NSString *)pass{
    
}
-(void)startScan{
    
}
-(void)stop{
    
}


@end
