//
//  PathView.h
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/07.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PathView : UIView
{
    NSString* _svgString;
    CGFloat _scale;
    UIColor* _color;
}

- (id)initWithFrame:(CGRect)frame
       andSVGString:(NSString*)svgString
              scale:(CGFloat)scale
          fillColor:(UIColor*)color;

@end
