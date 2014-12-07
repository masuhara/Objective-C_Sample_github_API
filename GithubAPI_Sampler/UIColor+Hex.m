//
//  UIColor+Hex.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/08.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString *)colorCode
{
    return [UIColor colorWithHex:colorCode alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSString *)colorCode alpha:(CGFloat)alpha
{
    if ([[colorCode substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"#"]) {
        colorCode = [colorCode substringWithRange:NSMakeRange(1, colorCode.length - 1)];
    }
    
    if ([colorCode length] == 3) {
        NSMutableString *_colorCode = [[NSMutableString alloc] init];
        
        for (NSInteger i = 0; i < colorCode.length; i++) {
            [_colorCode appendString:[colorCode substringWithRange:NSMakeRange(i, 1)]];
            [_colorCode appendString:[colorCode substringWithRange:NSMakeRange(i, 1)]];
        }
        
        colorCode = [_colorCode copy];
    }
    
    NSString *hexCodeStr;
    const char *hexCode;
    char *endptr;
    CGFloat red, green, blue;
    red = 0;
    green = 0;
    blue = 0;
    
    for (NSInteger i = 0; i < 3; i++) {
        hexCodeStr = [NSString stringWithFormat:@"+0x%@", [colorCode substringWithRange:NSMakeRange(i * 2, 2)]];
        hexCode    = [hexCodeStr cStringUsingEncoding:NSASCIIStringEncoding];
        
        switch (i) {
            case 0:
                red   = strtol(hexCode, &endptr, 16);
                break;
                
            case 1:
                green = strtol(hexCode, &endptr, 16);
                break;
                
            case 2:
                blue  = strtol(hexCode, &endptr, 16);
                
            default:
                break;
        }
    }
    
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:alpha];
}

@end
