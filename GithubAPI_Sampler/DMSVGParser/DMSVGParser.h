//
//  DMSVGParser.h
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/08.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DMSVGParser : NSObject



@property(nonatomic)UIImageView *backgroundImageView;
@property(nonatomic)NSMutableArray *contributions;
@property(nonatomic)UIColor *contributionsColor;


+ (DMSVGParser *)sharedManager;
+ (UIImage *)getSVGImage:(NSData *)svgData;

@end


