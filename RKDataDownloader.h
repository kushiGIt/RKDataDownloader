//
//  RKDataDownloader.h
//  RKDataDownloader
//
//  Created by RyousukeKushihata on 2014/11/01.
//  Copyright (c) 2014年 RyousukeKushihata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@class RKDataDownloader;

@protocol RKDataDownloaderDelegate;


@interface RKDataDownloader : NSObject<NSURLSessionDelegate>{
    
}

@property id<RKDataDownloaderDelegate>delegate;
/**
 *  data download start. Must use -(id)initWithUrlArray: first.
 */
-(void)startDownloads;
/**
 *  Init and set download url. After use this methods,call -(void)startDownloads.
 *
 *  @param urlArray string url in array.
 *
 *  @return (id)self
 */
-(id)initWithUrlArray:(NSArray*)urlArray;
/**
 *  Do not use this methods.If you use this methods,app is going to clash.
 *
 *  @return (id)self
 */
-(id)init;

@end

@protocol RKDataDownloaderDelegate <NSObject>

@optional

/**
 *  Get download file progress.(optinal)
 *
 *  @param progress nsnumber progress
 */
-(void)fileDownloadProgress:(NSNumber*)progress;
/**
 *  You can get data and error when download file finish.
 *
 *  @param data             get from tmp file
 *  @param readingDataError get error when read from tmp file
 */
-(void)didFinishDownloadData:(NSData*)data withError:(NSError*)readingDataError;

@end
