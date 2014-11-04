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
    [array addObject:@"http://upload.wikimedia.org/wikipedia/ja/1/17/日本猫_2008-1.jpg"];
    [array addObject:@"http://amenama.on.arena.ne.jp/wordpress/wp-content/uploads/2014/08/cat.png"];
    [array addObject:@"http://www.kgw-sense.com/homare/blog/udata/猫.jpg"];
    [array addObject:@"http://bluemark.info/wp-content/uploads/2013/02/3a4465fcdc9a8bb92e40ac1456d52d6f.jpg"];
    
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
    
//    NSLog(@"%ld",(unsigned long)data.length);
    NSLog(@"%@",readingDataError);
    
}
-(void)didFinishAllDownloadsWithDataDictinary:(NSDictionary *)dataDic withErrorDic:(NSDictionary *)errorDic{
    
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        
        NSLog(@"errordic=%@",errorDic);
        NSLog(@"data=%@",dataDic);
    });
}
@end
