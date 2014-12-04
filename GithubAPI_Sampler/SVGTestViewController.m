//
//  SVGTestViewController.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/27.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "SVGTestViewController.h"
#import "PocketSVG.h"
#import "AFNetworking.h"
#import "SHXMLParser.h"

@interface SVGTestViewController ()

@end

@implementation SVGTestViewController
{
    IBOutlet UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *userName = @"masuhara";
    
    // Step of text/html -> SVG
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", userName]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             //MARK:XML Parse
             SHXMLParser *parser = [[SHXMLParser alloc] init];
             NSDictionary *resultObject = [parser parseData:responseObject];
             NSArray *dataArray = [SHXMLParser getAsArray:resultObject];
             NSLog(@"dataArray == %@", dataArray);
             /*
             NSMutableData *data = [NSMutableData dataWithContentsOfURL:[NSURL URLWithString:@"https://github.com/users/masuhara/contributions"]];
             UIImage *resImage = [[UIImage alloc] initWithData:data];
             
             imageView.image = resImage;
              */
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error.description);
         }];
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

@end
