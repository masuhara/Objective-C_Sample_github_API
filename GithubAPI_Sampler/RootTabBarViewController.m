//
//  RootTabBarViewController.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/26.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "RootTabBarViewController.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavigationBarTitleImage:[UIImage imageNamed:@"gitmob_title_logo.png"]];
    if (self.tabBarItem.tag == 1) {
        [self tabBarItem].badgeValue = @"ぎ";
    }
}

- (void)setNavigationBarTitleImage:(UIImage *)image
{
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:image];
    // Adjust Image Size
    titleImageView.frame = CGRectMake(0, 0, image.size.width * 0.5, image.size.height * 0.5);
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(-image.size.width*0.5, 0, titleImageView.frame.size.width , titleImageView.frame.size.height)];
    [titleView addSubview:titleImageView];
    self.navigationItem.titleView = titleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    switch (item.tag) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            
            break;
            
        default:
            break;
    }
}

@end
