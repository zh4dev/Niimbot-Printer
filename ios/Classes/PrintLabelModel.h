#import <Foundation/Foundation.h>

@interface PrintLabelModel : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) double fontSize;

- (instancetype)init;
- (instancetype)initWithText:(NSString *)text fontSize:(double)fontSize;
- (NSString *)toJson;
+ (PrintLabelModel *)fromJson:(NSString *)json;

@end
