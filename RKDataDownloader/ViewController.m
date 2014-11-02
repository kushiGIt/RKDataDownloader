//
//  ViewController.m
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    IBOutlet UIProgressView *progressView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray*array = [[NSMutableArray alloc] init];
    [array addObject:@"https://developer.apple.com/library/ios/documentation/iphone/conceptual/iphoneosprogrammingguide/iphoneappprogrammingguide.pdf"];
    [array addObject:@"https://developer.apple.com/library/ios/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/NetworkingOverview.pdf"];
    [array addObject:@"https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/AVFoundationPG.pdf"];
    [array addObject:@"http://manuals.info.apple.com/MANUALS/1000/MA1565/en_US/iphone_user_guide.pdf"];
    
    RKDataDownloader*test1=[[RKDataDownloader alloc]initWithUrlArray:array];
    [test1 startDownloads];
    
    test1.delegate=self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fileDownloadProgress:(NSNumber *)progress{
    
    NSLog(@"%f",[progress floatValue]);
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        
        [progressView setProgress:[progress floatValue] animated:YES];
        
    });
    
}
-(void)didFinishDownloadData:(NSData *)data withError:(NSError *)readingDataError dataWithUrl:(NSString *)urlStr{
    
    NSLog(@"%ld",(unsigned long)data.length);
    NSLog(@"%@",readingDataError);
    
}
@end
