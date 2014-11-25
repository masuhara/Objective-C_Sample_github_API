//
//  ContributionTableViewCell.h
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/24.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContributionTableViewCell : UITableViewCell
{
    __weak IBOutlet UIImageView *profileImageView;
    __weak IBOutlet UILabel *nameLabel;
    //__weak IBOutlet UIImageView *contributionView;
    __weak IBOutlet UIWebView *contributionView;
}

- (void)setProfileImage:(UIImage *)image;
//- (void)setContributionView:(UIImageView *)contributionView;
- (void)setContributionView:(UIWebView *)contributionView;
- (void)setName:(NSString *)text;


@end
