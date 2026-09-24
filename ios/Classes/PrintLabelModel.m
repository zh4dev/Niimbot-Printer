#import "PrintLabelModel.h"

@implementation PrintLabelModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _text = @"";
        _fontSize = 0.0;
        _fontFamily = @"宋体";
        _fontStyle = @"normal";
        _sizingMode = @"fixed";
        _minFontSize = 0.0;
        _maxFontSize = 0.0;
        _maxLines = 1;
        _fontSizeOffset = 0.0;
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
        @"fontSize": @(self.fontSize),
        @"fontFamily": self.fontFamily ?: @"宋体",
        @"fontStyle": self.fontStyle ?: @"normal"
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
        PrintLabelModel *model = [[PrintLabelModel alloc]
            initWithText:dictionary[@"text"]
                fontSize:[dictionary[@"fontSize"] doubleValue]];
        NSString *fontFamily = dictionary[@"fontFamily"];
        model.fontFamily = ([fontFamily isKindOfClass:[NSString class]] && fontFamily.length > 0)
            ? fontFamily
            : @"宋体";
        NSString *fontStyle = dictionary[@"fontStyle"];
        model.fontStyle = ([fontStyle isKindOfClass:[NSString class]] && fontStyle.length > 0)
            ? fontStyle
            : @"normal";
        NSDictionary *sizing = [dictionary[@"sizing"] isKindOfClass:[NSDictionary class]]
            ? dictionary[@"sizing"]
            : nil;
        if (sizing != nil) {
            model.sizingMode = sizing[@"mode"] ?: @"fixed";
            model.minFontSize = [sizing[@"minFontSize"] doubleValue];
            model.maxFontSize = [sizing[@"maxFontSize"] doubleValue];
            model.maxLines = MAX([sizing[@"maxLines"] integerValue], 1);
            model.fontSizeOffset = [sizing[@"fontSizeOffset"] doubleValue];
        } else {
            model.sizingMode = @"fixed";
            model.minFontSize = model.fontSize;
            model.maxFontSize = model.fontSize;
            model.maxLines = 1;
            model.fontSizeOffset = 0.0;
        }
        return model;
    }
}

- (NSArray<NSNumber *> *)fontStyles {
    BOOL italic = [self.fontStyle isEqualToString:@"italic"] ||
        [self.fontStyle isEqualToString:@"boldItalic"];
    BOOL bold = [self.fontStyle isEqualToString:@"bold"] ||
        [self.fontStyle isEqualToString:@"boldItalic"];
    BOOL underline = [self.fontStyle isEqualToString:@"underline"];
    BOOL strikethrough = [self.fontStyle isEqualToString:@"strikethrough"];
    // JCAPI 3.2.8 reads the first flag as bold and the second as italic,
    // despite the order documented in the public header.
    return @[@(bold), @(italic), @(underline), @(strikethrough)];
}

@end
