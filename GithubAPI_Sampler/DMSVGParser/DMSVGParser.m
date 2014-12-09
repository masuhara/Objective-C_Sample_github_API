//
//  DMSVGParser.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/08.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "DMSVGParser.h"
#import "SHXMLParser.h"
#import "UIColor+Hex.h"


#define CELL_HEIGHT 721/54
#define CELL_WIDTH 721/54
#define BORDER_WIDTH 1.0f


@implementation DMSVGParser


+ (UIImage *)getSVGImage:(NSData *)svgData{
    
    //MARK:Base View
    UIView *bgView = [[UIView alloc] init];
    //MARK:BGCOLOR
    bgView.backgroundColor = [UIColor clearColor];
    
    //MARK:XML Parse
    SHXMLParser *parser = [[SHXMLParser alloc] init];
    NSDictionary *resultObject = [parser parseData:svgData];
    NSArray *dataArray = [SHXMLParser getAsArray:resultObject];
    
    
    for (NSDictionary *dic in dataArray) {
        int height = [[[dic valueForKey:@"svg"] valueForKey:@"height"] intValue];
        int width = [[[dic valueForKey:@"svg"] valueForKey:@"width"] intValue];
        bgView.frame = CGRectMake(0, 0, width, height);
        
        NSArray *array = [[[[dic valueForKey:@"svg"] valueForKey:@"g"] valueForKey:@"g"] valueForKey:@"rect"];
        
        for (int i = 0; i < array.count; i++) {
            
            NSArray *contentArray = array[i];

            for (int j = 0; j < contentArray.count; j++) {
                
                UIView *rect = [[UIView alloc] init];
                rect.frame = CGRectMake(CELL_WIDTH * i, CELL_HEIGHT * j, CELL_WIDTH, CELL_HEIGHT);
                rect.layer.borderWidth = BORDER_WIDTH;
                rect.layer.borderColor = [[UIColor whiteColor] CGColor];
                
                //MARK:Class Judgement
                if ([[contentArray valueForKey:@"fill"] isKindOfClass:[NSArray class]]) {
                    NSArray *colorArray = [contentArray valueForKey:@"fill"];
                    rect.backgroundColor = [UIColor colorWithHex:colorArray[j]];
                }else{
                    NSString *color = [contentArray valueForKey:@"fill"];
                    rect.backgroundColor = [UIColor colorWithHex:color];
                }
                [bgView addSubview:rect];
            }
        }
    }
    
    UIImage *image = [self imageFromView:bgView];
    return image;
}

+ (UIImage *)imageFromView:(UIView *)view
{
    // if paramater "YES", bgColor become black
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -view.frame.origin.x, -view.frame.origin.y);
    [view.layer renderInContext:context];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

@end
