//
//  RKDataDownloader.m
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import "RKDataDownloader.h"


@interface RKDataDownloader()

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSessionDownloadTask *sessionTask;

@property (nonatomic) NSMutableDictionary*taskDataDic;

@property (nonatomic) double taskCount;

@property BOOL isInitWithArray;

@end

@implementation RKDataDownloader

-(id)initWithUrlArray:(NSArray*)urlArray{
    
    dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        if (self==[super init]) {
            
            self.taskDataDic=[[NSMutableDictionary alloc]init];
            
            for (NSString*sorceURL in urlArray) {
                [self.taskDataDic setObject:[NSNumber numberWithDouble:0.0] forKey:sorceURL];
                
                
            }
            
            self.taskCount=(double)self.taskDataDic.count;
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.RKDownloader"];
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
            
            self.session=[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:(id)self delegateQueue:nil];
            
            self.isInitWithArray=YES;
        
        }
        
        dispatch_semaphore_signal(semaphone);
    
    });
    
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    
    return self;
}
-(void)startDownloads{
    
    if (self.isInitWithArray==YES) {
        
        for (int i=0; i<[self.taskDataDic.allKeys count]; i++) {
            
            self.sessionTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.taskDataDic.allKeys[i]]];
            [self.sessionTask resume];
            
        }
    
    }else{
        
        [[NSException exceptionWithName:@"RKDownloader init exception" reason:@"you must use -(void)initWithArray: first. You musu not use -(id)init." userInfo:nil]raise];
        
    }
    
}
#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSError*readingDataError;
    NSData*downloededData=[NSData dataWithContentsOfURL:location options:NSDataReadingUncached error:&readingDataError];
    
    if ([self.delegate respondsToSelector:@selector(didFinishDownloadData:withError:)]) {
        
        [self.delegate didFinishDownloadData:downloededData withError:readingDataError];
    
    }
    
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (error != nil) {
        
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
    
    }else{
        
        NSLog(@"Download finished successfully.");
    
    }

}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        
        NSLog(@"Unknown transfer size");
        
    }else{
        
        __block double progress=0.0;

        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [self.taskDataDic setObject:[NSNumber numberWithDouble:(double)totalBytesWritten / (double)totalBytesExpectedToWrite] forKey:[[downloadTask originalRequest]URL]];
                
                for (NSNumber *progressNum in [self.taskDataDic allValues]) {
                    
                    progress=progress+[progressNum doubleValue];
                    
                }
                
            });
            
            dispatch_semaphore_signal(semaphore);
        
        });
        
        while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        
        if ([self.delegate respondsToSelector:@selector(fileDownloadProgress:)]) {
            
            [self.delegate fileDownloadProgress:[NSNumber numberWithDouble:progress/self.taskCount]];
            
        }

    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    completionHandler();
                    
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"ダウンロードが完了しました。";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                
                }];
            }
        }
    }];

}

@end
