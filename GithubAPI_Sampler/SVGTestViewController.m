//
//  SVGTestViewController.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/27.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "SVGTestViewController.h"
#import "AFNetworking.h"
#import "SHXMLParser.h"
#import "UIColor+Hex.h"


@interface SVGTestViewController ()

@end

@implementation SVGTestViewController
{
    IBOutlet UIImageView *imageView;
    NSMutableArray *dataDateArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!dataDateArray) {
        dataDateArray = [NSMutableArray new];
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *userName = @"masuhara";
    
    // Step of text/html -> SVG
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"https://github.com/users/%@/contributions", userName]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             /*
             NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
              */

             //MARK:XML Parse
             SHXMLParser *parser = [[SHXMLParser alloc] init];
             NSDictionary *resultObject = [parser parseData:responseObject];
             NSArray *dataArray = [SHXMLParser getAsArray:resultObject];
             
             
             for (NSDictionary *dic in dataArray) {
                 int height = [[[dic valueForKey:@"svg"] valueForKey:@"height"] intValue];
                 int width = [[[dic valueForKey:@"svg"] valueForKey:@"width"] intValue];
                 UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
                 bgView.backgroundColor = [UIColor yellowColor];
                 [self.view addSubview:bgView];
                 
                 NSArray *array = [[[[dic valueForKey:@"svg"] valueForKey:@"g"] valueForKey:@"g"] valueForKey:@"rect"];
                 
                 //"g" -> week (54)
                 //"rect" -> 7
                 //NSLog(@"array == %@", [[array[3] valueForKey:@"rect"] valueForKey:@"fill"]);
                 //NSLog(@"%@", array);
                 
                 for (int i = 0; i < array.count; i++) {
                     
                     NSArray *contentArray = array[i];
                     NSLog(@"contentArray = %@", contentArray);
                     for (int j = 0; j < contentArray.count; j++) {
                         
                         int height = [[contentArray valueForKey:@"height"] intValue];
                         int width = [[contentArray valueForKey:@"width"] intValue];
                         
                         UIView *rect = [[UIView alloc] init];
                         rect.frame = CGRectMake(width * i, height * j, width, height);
                         rect.backgroundColor = [UIColor redColor];
                         /*
                          rect.backgroundColor = [UIColor colorWithHex:[[array[i] valueForKey:@"rect"] valueForKey:@"fill"] alpha:1.0];
                          */
                         [self.view addSubview:rect];
                     }
                 }
             }

         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"Error: %@", error.description);
         }];
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"dataDateArray = %@", dataDateArray);
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
