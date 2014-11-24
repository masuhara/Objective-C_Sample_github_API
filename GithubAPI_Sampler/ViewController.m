//
//  ViewController.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/21.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "ViewController.h"
#import "OAuthConstManager.h"
#import "UAGithubEngine.h"
#import "AFNetworking.h"
#import "SVGKit.h"
#import "UIImage+SVG.h"
#import "ContributionTableViewCell.h"

@interface ViewController ()
<UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController
{
    IBOutlet UITableView *feedTableView;
    
    NSMutableArray *profileImageArray;
    NSMutableArray *contributionWebViewArray;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    feedTableView.delegate = self;
    feedTableView.dataSource = self;
    
    profileImageArray = [[NSMutableArray alloc] init];
    contributionWebViewArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -

- (IBAction)login
{
    
    // AFHTTPRequestOperationManagerを利用して、http://localhost/test.jsonからJSONデータを取得する
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *userName = @"masuhara";
    
    // text/htmlエラー対策
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", userName]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             [contributionWebViewArray addObject:string];

             
             NSLog(@"contriArray == %@", contributionWebViewArray);

         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // エラーの場合はエラーの内容をコンソールに出力する
             NSLog(@"Error: %@", error.description);
         }];
    
    [feedTableView reloadData];
}


#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contributionWebViewArray.count;
}

#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContributionTableViewCell *cell = (ContributionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //MARK:profile Image
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:1];
    profileImageView.image = 
    
    //MARK:contribution webView
    UIWebView *webView = (UIWebView *)[cell viewWithTag:5];
    [webView loadHTMLString:contributionWebViewArray[indexPath.row] baseURL:nil];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    
    return cell;
}





@end
