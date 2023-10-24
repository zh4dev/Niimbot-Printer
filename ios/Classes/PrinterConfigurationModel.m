#import "PrinterConfigurationModel.h"

@implementation PrinterConfigurationModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _printModel = 0;
        _printDensity = 0;
        _printMultiple = 0.0;
    }
    return self;
}

- (instancetype)initWithPrintModel:(int)printModel printDensity:(int)printDensity printMultiple:(float)printMultiple {
    self = [super init];
    if (self) {
        _printModel = printModel;
        _printDensity = printDensity;
        _printMultiple = printMultiple;
    }
    return self;
}

- (NSString *)toJson {
    NSError *error = nil;
    NSDictionary *dictionary = @{
        @"printModel": @(self.printModel),
        @"printDensity": @(self.printDensity),
        @"printMultiple": @(self.printMultiple)
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (PrinterConfigurationModel *)fromJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    if (error) {
        return [[PrinterConfigurationModel alloc] init];
    } else {
        return [[PrinterConfigurationModel alloc] initWithPrintModel:[dictionary[@"printModel"] intValue]
                                                       printDensity:[dictionary[@"printDensity"] intValue]
                                                     printMultiple:[dictionary[@"printMultiple"] floatValue]];
    }
}

@end
