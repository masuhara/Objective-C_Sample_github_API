//
//  UserDataManager.h
//  GithubAPI_Sampler
//
//  Created by Master on 2014/12/09.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataManager : NSObject


@property (nonatomic)NSMutableArray *userNameArray;
@property (nonatomic)NSMutableArray *profileImageArray;
@property (nonatomic)NSMutableArray *lastUpdatedArray;
@property (nonatomic)NSMutableArray *contributionArray;


+ (UserDataManager *)sharedManager;
//+ (void)releaseData;

@end
