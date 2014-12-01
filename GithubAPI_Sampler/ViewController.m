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
#import "ContributionTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "YLGIFImage.h"
#import "SvgToBezier.h"


@interface ViewController ()
<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController
{
    IBOutlet UITableView *feedTableView;
    NSMutableArray *userNameArray;
    NSMutableArray *profileImageArray;
    NSMutableArray *lastUpdatedArray;
    NSMutableArray *contributionWebViewArray;
    NSString *svgStrings[9999];
    
    int numberOfFollowings;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    feedTableView.delegate = self;
    feedTableView.dataSource = self;
    
    profileImageArray = [NSMutableArray new];
    userNameArray = [NSMutableArray new];
    lastUpdatedArray = [NSMutableArray new];
    contributionWebViewArray = [NSMutableArray new];
    
    
    self.navigationItem.title = @"hoge";
    
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
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



#pragma mark -

- (IBAction)reloadData
{
    [self loadData];
}

- (void)loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *userName = @"masuhara";
    
    // Step of text/html -> SVG
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    numberOfFollowings = [self getFolloingInfo:manager withUserName:userName];
    
}


- (int)getFolloingInfo:(AFHTTPRequestOperationManager *)manager withUserName:(NSString *)userName
{
    
    [manager GET:@"https://api.github.com/users/masuhara/following?page=1&per_page=100"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSArray *array = [NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingAllowFragments
                                                                error:nil];
             numberOfFollowings = (int)array.count;
             
             for (NSDictionary *dic in array) {
                 [userNameArray addObject:[dic valueForKey:@"login"]];
                 [profileImageArray addObject:[dic valueForKey:@"avatar_url"]];
             }
             
             [self getContributionGraph:manager];
             NSLog(@"userNameArray == %@", userNameArray);
             
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
    return numberOfFollowings;
}



- (void)getContributionGraph:(AFHTTPRequestOperationManager *)manager
{
    for (int i = 0; i < userNameArray.count; i++) {
        [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", userNameArray[i]]
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                 
                 //contributionWebViewArray[i] = string;
                 svgStrings[i] = string;
                 
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
    

    //MARK:fix reuse cell Problem
    //MARK:contribution webView
    UIWebView *webView = (UIWebView *)[cell viewWithTag:5];
    
    // not clear without these 2 lines
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [webView loadHTMLString:svgStrings[indexPath.row] baseURL:nil];
    
    
    
    //MARK:ContributionView
    /*
     UIImageView *contributionView = (UIImageView *)[cell viewWithTag:5];
     
     [contributionView sd_setImageWithURL:[NSURL URLWithString:svgStrings[indexPath.row]]
     placeholderImage:nil
     options:SDWebImageCacheMemoryOnly
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
     NSLog(@"読み込み完了");
     [activityIndicator removeFromSuperview];
     }];
     [contributionView addSubview:activityIndicator];
     [activityIndicator startAnimating];
     */
    
    //[YLGIFImage imageNamed:@"loading.gif"]
    /*
     dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_queue_t q_main = dispatch_get_main_queue();
     dispatch_async(q_global, ^{
     UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
     dispatch_async(q_main, ^{
     profileImageView.image = image;
     [cell layoutSubviews];
     });
     });
     */
    
    return cell;
}




#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
    {
//        UIWebView *webView = (UIWebView *)[cell viewWithTag:5];
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
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
