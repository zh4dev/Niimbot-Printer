#import "PrintLabelModel.h"

@implementation PrintLabelModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _text = @"";
        _fontSize = 0.0;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text fontSize:(double)fontSize {
    self = [super init];
    if (self) {
        _text = text;
        _fontSize = fontSize;
    }
    return self;
}

- (NSString *)toJson {
    NSError *error = nil;
    NSDictionary *dictionary = @{
        @"text": self.text,
        @"fontSize": @(self.fontSize)
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (PrintLabelModel *)fromJson:(NSString *)json {
    NSError *error = nil;
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];

    if (error) {
        return [[PrintLabelModel alloc] init];
    } else {
        return [[PrintLabelModel alloc] initWithText:dictionary[@"text"] fontSize:[dictionary[@"fontSize"] doubleValue]];
    }
}

@end
