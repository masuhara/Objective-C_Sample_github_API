//
//  PathView.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/07.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "PathView.h"
#import "SKUBezierPath+SVG.h"

@implementation PathView

- (id)initWithFrame:(CGRect)frame
       andSVGString:(NSString*)svgString
              scale:(CGFloat)scale
          fillColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        _svgString = svgString;
        _scale = scale;
        _color = color;
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    UIBezierPath* aPath = [UIBezierPath bezierPathWithSVGString:_svgString];
    [_color setFill];
    
    CGContextRef aRef = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(aRef, _scale, _scale);
    
    [aPath fill];
}

@end
