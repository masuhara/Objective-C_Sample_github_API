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


@interface ViewController ()

@end

@implementation ViewController
{
    IBOutlet UIWebView *webView;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    /*
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
     */
    
    // text/htmlエラー対策
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", userName]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             
             [webView loadData:responseObject MIMEType:@"image/svg+xml"  textEncodingName:@"utf-8"  baseURL:nil];
             webView.opaque = NO;
             webView.backgroundColor = [UIColor redColor];
             //[webView reload];
             
             NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             
             //NSLog(@"task=%@, response = %@ %@", operation, [responseObject class], str);
             
             // NSData に変換する
             //NSData *jsonData = [str dataUsingEncoding:NSUnicodeStringEncoding];
            
             NSLog(@"%@", str.description);
             
             // JSON のオブジェクトは NSDictionary に変換されている
             /*
             NSMutableArray *results = [[NSMutableArray alloc] init];
             for (NSDictionary *obj in array)
             {
                 [results addObject:[obj objectForKey:@"fill"]];
                 
             }
              */
             
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             // エラーの場合はエラーの内容をコンソールに出力する
             NSLog(@"Error: %@", error.description);
         }];
    
    
    
    /*
    UAGithubEngine *engine = [[UAGithubEngine alloc] initWithUsername:USER_NAME password:PASSWORD withReachability:YES];
    
    [engine repositoriesWithSuccess:^(id response) {
        NSLog(@"Got an array of repos: %@", response);
    } failure:^(NSError *error) {
        NSLog(@"Oops: %@", error);
    }];
    
    [engine user:@"this_guy" isCollaboratorForRepository:@"UAGithubEngine" success:^(BOOL collaborates) {
        NSLog(@"%d", collaborates);
    } failure:^(NSError *error){
        NSLog(@"D'oh: %@", error);
    }];
     */
}




@end
