//
//  ViewController.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/21.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "ViewController.h"
#import "OAuthConstManager.h"
#import "UserDataManager.h"
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "ContributionTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "YLGIFImage.h"
#import "DMSVGParser.h"
#import "SVPullToRefresh.h"


#define BGCOLOR [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f]

@interface ViewController ()
<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController
{
    IBOutlet UITableView *feedTableView;
    UIActivityIndicatorView *activityIndicator;
    
    int pageNumber;
    int numberOfFollowings;
    NSData *contributionData;
    NSOperationQueue *queue;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageNumber = 1;
    
    self.view.backgroundColor = BGCOLOR;
    //self.edgesForExtendedLayout = UIRectEdgeAll;
    
    feedTableView.delegate = self;
    feedTableView.dataSource = self;
    
    __weak ViewController *weakSelf = self;
    [feedTableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    [feedTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    // iOS7でRefresh後にNavigationBarに隠れる問題の対処
    
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //feedTableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    
    [self loadData:NO];
    [self setLongPressGesture];
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
    [self loadData:YES];
}

- (void)loadData:(BOOL)isPull
{
    // Loading Display
    if (isPull == NO) {
        if (feedTableView.hidden == NO) {
            feedTableView.alpha = 0.0f;
            feedTableView.hidden = YES;
            
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = feedTableView.center;
            [self.view addSubview:activityIndicator];
            [activityIndicator startAnimating];
        }
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
    // 20 pages per Page
    [manager GET:[NSString stringWithFormat:@"https://api.github.com/users/masuhara/following?page=%d&per_page=20", pageNumber]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingAllowFragments
                                                                error:nil];
             numberOfFollowings = (int)array.count;
             
             for (NSDictionary *dic in array) {
                 [[UserDataManager sharedManager].userNameArray addObject:[dic valueForKey:@"login"]];
                 [[UserDataManager sharedManager].profileImageArray addObject:[dic valueForKey:@"avatar_url"]];
                 [[UserDataManager sharedManager].contributionArray addObject:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", [dic valueForKey:@"login"]]];
             }
             
             
             [self getContributionGraph:manager];
             //NSLog(@"contributionArray == %@", contributionArray);
             
             // Renew UI on main Thread
             /*
              dispatch_async(dispatch_get_main_queue(), ^{
              [feedTableView reloadData];
              });
              */
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
    return numberOfFollowings;
}



- (void)getContributionGraph:(AFHTTPRequestOperationManager *)manager
{
    for (int i = 0; i < [UserDataManager sharedManager].userNameArray.count; i++) {
        [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", [UserDataManager sharedManager].userNameArray[i]]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 //MARK:ContributionArray
                 [[UserDataManager sharedManager].contributionArray addObject:[DMSVGParser getSVGImage:responseObject]];
                 
                 // Renew UI on main Thread
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [feedTableView reloadData];
                 });
                 
             }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 NSLog(@"Error: %@", error.description);
             }];
    }
}


#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [UserDataManager sharedManager].userNameArray.count;
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
    
    [profileImageView sd_setImageWithURL:[UserDataManager sharedManager].profileImageArray[indexPath.row]
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
    nameLabel.text = [UserDataManager sharedManager].userNameArray[indexPath.row];
    
    //MARK:Updated Date TAG=3
    //UILabel *lastUpdatedLabel = (UILabel *)[cell viewWithTag:3];
    //lastUpdatedLabel.text = lastUpdatedArray[indexPath.row];
    
    //MARK:contribution TAG=5
    UIImageView *contributionView = (UIImageView *)[cell viewWithTag:5];
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    contributionView.image = nil;
    dispatch_async(q_global, ^{
        
         UIImage *image = [DMSVGParser getSVGImage:[NSData dataWithContentsOfURL:[NSURL URLWithString:[UserDataManager sharedManager].contributionArray[indexPath.row]]]];
         /*
        
        __block UIImage *image = nil;
        
        if ([[UserDataManager sharedManager].contributionArray isKindOfClass:[UIImage class]]) {
            image = [UserDataManager sharedManager].contributionArray[indexPath.row];
            NSLog(@"image = %@", image);
        }
          */
        
        dispatch_async(q_main, ^{
            // Fade Animation
            [UIView transitionWithView:profileImageView
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                contributionView.image = image;
                                //NSLog(@"contributionImage = %@", contributionView.image);
                            } completion:nil];
            [cell layoutSubviews];
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


- (void)setLongPressGesture
{
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rowButtonAction:)];
    longPressRecognizer.allowableMovement = 15;
    longPressRecognizer.minimumPressDuration = 0.6f;
    [feedTableView addGestureRecognizer: longPressRecognizer];
}


-(void)rowButtonAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint p = [gestureRecognizer locationInView:feedTableView];
    NSIndexPath *indexPath = [feedTableView indexPathForRowAtPoint:p];
    if (indexPath == nil){
        
        NSLog(@"long press on table view");
        
    }else if (((UILongPressGestureRecognizer *)gestureRecognizer).state == UIGestureRecognizerStateBegan){
        
        NSLog(@"long Press on Cell");
    }
}

#pragma mark - Refresh Control

- (void)insertRowAtTop {
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData:YES];
        [feedTableView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {
    
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //UpDate
        pageNumber++;
        [self loadData:YES];
        [feedTableView reloadData];
        [feedTableView.infiniteScrollingView stopAnimating];
    });
}



@end
