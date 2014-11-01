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

@property (nonatomic, strong) NSMutableArray *arrFileDownloadData;

@property (nonatomic, strong) NSURL *docDirectoryURL;


-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier;

@end

@implementation RKDataDownloader

-(id)initWithUrlArray:(NSArray*)urlArray{
    
    dispatch_semaphore_t semaphone =dispatch_semaphore_create(0);
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        
        if (self==[super init]) {
            
            self.arrFileDownloadData = [[NSMutableArray alloc] init];
            
            for (NSString*sorceURL in urlArray) {
                
                [self.arrFileDownloadData addObject:[[RKFileDownloadInfo alloc]initWithDownloadSource:sorceURL]];
                
            }
            
            NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
            self.docDirectoryURL=[URLs objectAtIndex:0];
            
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.BGTransferDemo"];
            sessionConfiguration.HTTPMaximumConnectionsPerHost = 5;
            
            self.session=[NSURLSession sessionWithConfiguration:sessionConfiguration delegate:(id)self delegateQueue:nil];
        
        }
        
        dispatch_semaphore_signal(semaphone);
    
    });
    
    dispatch_semaphore_wait(semaphone, DISPATCH_TIME_FOREVER);
    
    return self;
}
-(void)startDownloads{
    
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        
        RKFileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        
        if (!fdi.isDownloading) {
            
            if (fdi.taskIdentifier == -1) {
                
                fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:fdi.downloadSource]];
            
            }else{
                
                fdi.downloadTask = [self.session downloadTaskWithResumeData:fdi.taskResumeData];
            
            }
            
            fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
            [fdi.downloadTask resume];
            fdi.isDownloading = YES;
        }
    }
}
-(int)getFileDownloadInfoIndexWithTaskIdentifier:(unsigned long)taskIdentifier{
    int index = 0;
    
    for (int i=0; i<[self.arrFileDownloadData count]; i++) {
        
        RKFileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:i];
        if (fdi.taskIdentifier == taskIdentifier) {
            
            index = i;
            break;
        
        }
    }
    
    return index;
}
#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:destinationFilename];
    
    if ([fileManager fileExistsAtPath:[destinationURL path]]) {
        
        [fileManager removeItemAtURL:destinationURL error:nil];
    
    }
    
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&error];
    
    if (success) {
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        RKFileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        fdi.isDownloading = NO;
        fdi.downloadComplete = YES;
        
        fdi.taskIdentifier = -1;
        
        fdi.taskResumeData = nil;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.tblFiles reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationNone];
            
        }];
        
    }else{
        
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
    
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
        
        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
        RKFileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            
            if ([self.delegate respondsToSelector:@selector(fileDownloadProgress:)]) {
                
                [self.delegate fileDownloadProgress:[NSNumber numberWithDouble:fdi.downloadProgress]];
                
            }
            
        }];
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
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"ダウンロードが完了しました。";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}

@end
