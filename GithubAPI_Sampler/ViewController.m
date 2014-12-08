//
//  ViewController.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/21.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "ViewController.h"
#import "OAuthConstManager.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "ContributionTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "YLGIFImage.h"
#import "DMSVGParser.h"

#import "GithubAPI_Sampler-Swift.h"

#define BGCOLOR [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]

@interface ViewController ()
<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController
{
    IBOutlet UITableView *feedTableView;
    UIActivityIndicatorView *activityIndicator;
    
    NSMutableArray *userNameArray;
    NSMutableArray *profileImageArray;
    NSMutableArray *lastUpdatedArray;
    NSMutableArray *contributionArray;
    
    int numberOfFollowings;
    NSData *contributionData;
    NSOperationQueue *queue;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BGCOLOR;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    feedTableView.delegate = self;
    feedTableView.dataSource = self;
    
    profileImageArray = [NSMutableArray new];
    userNameArray = [NSMutableArray new];
    lastUpdatedArray = [NSMutableArray new];
    contributionArray = [NSMutableArray new];
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 4;
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Load Data

- (IBAction)reloadData
{
    [self loadData];
}

- (void)loadData
{
    // Loading Display
    if (feedTableView.hidden == NO) {
        feedTableView.alpha = 0.0f;
        feedTableView.hidden = YES;
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = self.view.center;
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
    
    // AFNetworking
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *userName = @"masuhara";
    
    // Step of text/html -> SVG
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    numberOfFollowings = [self getFolloingInfo:manager withUserName:userName];
    
}


- (int)getFolloingInfo:(AFHTTPRequestOperationManager *)manager withUserName:(NSString *)userName
{
    
    [manager GET:@"https://api.github.com/users/masuhara/following?page=1&per_page=10"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingAllowFragments
                                                                error:nil];
             numberOfFollowings = (int)array.count;
             
             for (NSDictionary *dic in array) {
                 [userNameArray addObject:[dic valueForKey:@"login"]];
                 [profileImageArray addObject:[dic valueForKey:@"avatar_url"]];
                 // [contributionArray addObject:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", [dic valueForKey:@"login"]]];
             }
             
             [self getContributionGraph:manager];
             //NSLog(@"contributionArray == %@", contributionArray);
             
             // Renew UI on main Thread
             dispatch_async(dispatch_get_main_queue(), ^{
                 [feedTableView reloadData];
             });
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
    return numberOfFollowings;
}



- (void)getContributionGraph:(AFHTTPRequestOperationManager *)manager
{
//    for (int i = 0; i < userNameArray.count; i++) {
//        [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", userNameArray[i]]
//          parameters:nil
//             success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                 
//                 //MARK:ContributionArray
//                 [contributionArray addObject:[DMSVGParser getSVGImage:responseObject]];
//                 
//                 // Renew UI on main Thread
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [feedTableView reloadData];
//                 });
//                 
//             }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                 
//                 NSLog(@"Error: %@", error.description);
//             }];
//    }
    
    for (NSString *name in userNameArray) {
        UIImage *image = [[KNKSVGView alloc] initWithUserName:name].toImage;
        [contributionArray addObject:image];
    }
}


#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"Cell";
    
    ContributionTableViewCell *cell = (ContributionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    
    if (cell == nil)
    {
        cell = [[ContributionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:reuseID];
    }
    
    //MARK:profile Image TAG=1
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:1];
    profileImageView.layer.cornerRadius = 5.0f;
    profileImageView.clipsToBounds = YES;
    
    [profileImageView sd_setImageWithURL:profileImageArray[indexPath.row]
                        placeholderImage:[UIImage imageNamed:@"grabatar@2x.png"]
                                 options:SDWebImageCacheMemoryOnly
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   
                                   UIApplication *application = [UIApplication sharedApplication];
                                   application.networkActivityIndicatorVisible = NO;
                                   // Cache Flag
                                   if (cacheType != SDImageCacheTypeMemory) {
                                       // Fade Animation
                                       [UIView transitionWithView:profileImageView
                                                         duration:0.3f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           profileImageView.image = image;
                                                       } completion:nil];
                                       
                                   }
                               }];
    
    //MARK:User Name TAG=2
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    nameLabel.text = userNameArray[indexPath.row];
    
    //MARK:Updated Date TAG=3
    //UILabel *lastUpdatedLabel = (UILabel *)[cell viewWithTag:3];
    //lastUpdatedLabel.text = lastUpdatedArray[indexPath.row];
    
    //MARK:contribution TAG=5
    UIImageView *contributionView = (UIImageView *)[cell viewWithTag:5];
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    contributionView.image = nil;
    dispatch_async(q_global, ^{
                 // UIImage *image = [DMSVGParser getSVGImage:[NSData dataWithContentsOfURL:[NSURL URLWithString:contributionArray[indexPath.row]]]];
        
        
        UIImage *image = contributionArray[indexPath.row];
        dispatch_async(q_main, ^{
            contributionView.image = image;
            contributionView.transform = CGAffineTransformMakeScale(0.6, 0.6);
            contributionView.alpha = 0.0;
            [UIView animateWithDuration:0.4 animations:^{
                contributionView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                contributionView.alpha = 1.0;
            }];
            // Fade Animation
//            [UIView transitionWithView:profileImageView
//                              duration:0.3f
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:^{
//                                contributionView.image = image;
//                            } completion:nil];
//            [cell layoutSubviews];
        });
    });
    
    return cell;
}

#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        // End of loading
        if (feedTableView.hidden == YES) {
            [UIView animateWithDuration:0.2 animations:^{
                feedTableView.alpha = 1.0f;
            }];
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            
            feedTableView.hidden = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [feedTableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Scroll Control
/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 if(feedTableView.contentOffset.y >= (feedTableView.contentSize.height - feedTableView.bounds.size.height))
 {
 if (totalPages > (pageNumber * ONCE_READ_COUNT)) {
 pageNumber ++;
 [feedTableView reloadData];
 }
 }
 }
 */



@end
