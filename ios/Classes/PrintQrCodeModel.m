#import "PrintQrCodeModel.h"

@implementation PrintQrCodeModel

+ (PrintQrCodeModel *)fromJson:(NSString *)json {
    PrintQrCodeModel *model = [[PrintQrCodeModel alloc] init];
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                               options:0
                                                                 error:&error];
    if (error != nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
        model.data = @"";
        model.size = 0;
        return model;
    }
    model.data = [dictionary[@"data"] isKindOfClass:[NSString class]]
        ? dictionary[@"data"]
        : @"";
    model.size = [dictionary[@"size"] doubleValue];
    return model;
}

@end
