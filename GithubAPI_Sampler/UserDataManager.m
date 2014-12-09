//
//  UserDataManager.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/09.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "UserDataManager.h"

@implementation UserDataManager

static UserDataManager *sharedData = nil;

+ (UserDataManager *)sharedManager{
    if (!sharedData) {
        sharedData = [UserDataManager new];
    }
    return sharedData;
}

- (id)init
{
    self = [super init];
    if (self) {
        //Initialization
        _profileImageArray = [NSMutableArray new];
        _userNameArray = [NSMutableArray new];
        _lastUpdatedArray = [NSMutableArray new];
        _contributionArray = [NSMutableArray new];
    }
    return self;
}

//+ (void)releaseData{
//    sharedData = nil;
//}



@end
