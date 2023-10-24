#import <Foundation/Foundation.h>

@interface PrinterConfigurationModel : NSObject

@property (nonatomic, assign) int printModel;
@property (nonatomic, assign) int printDensity;
@property (nonatomic, assign) float printMultiple;

- (instancetype)init;
- (instancetype)initWithPrintModel:(int)printModel printDensity:(int)printDensity printMultiple:(float)printMultiple;
- (NSString *)toJson;
+ (PrinterConfigurationModel *)fromJson:(NSString *)json;

@end
