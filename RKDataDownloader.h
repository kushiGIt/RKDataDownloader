//
//  RKDataDownloader.h
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RKFileDownloadInfo.h"
#import "AppDelegate.h"

@class RKDataDownloader;

@protocol RKDataDownloaderDelegate;


@interface RKDataDownloader : NSObject<NSURLSessionDelegate>{
    
}

@property id<RKDataDownloaderDelegate>delegate;

@property (weak, nonatomic) IBOutlet UITableView *tblFiles;

-(void)startDownloads;

-(id)initWithUrlArray:(NSArray*)urlArray;

@end

@protocol RKDataDownloaderDelegate <NSObject>

@optional

-(void)fileDownloadProgress:(NSNumber*)progress;

@end
