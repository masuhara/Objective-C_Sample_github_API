//
//  ContributionTableViewCell.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/24.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "ContributionTableViewCell.h"

@implementation ContributionTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setProfileImage:(UIImage *)image
{
    profileImageView.image = image;
}

- (void)setContributionView:(UIWebView *)webView
{
    contributionView = webView;
}

- (void)setName:(NSString *)text
{
    nameLabel.text = text;
}

@end
