#import <Foundation/Foundation.h>

@interface PrintQrCodeModel : NSObject

@property(nonatomic, copy) NSString *data;
@property(nonatomic, assign) double size;

+ (PrintQrCodeModel *)fromJson:(NSString *)json;

@end
