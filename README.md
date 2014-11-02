RKDataDownloader
================
#USAGE
It is so simple!

   - (void)viewDidLoad{
   
   RKDataDownloader*dataDownloader=[[RKDataDownloader alloc]initWithUrlArray:urlArray];
   dataDownloader.delegate=self;
   [dataDownloader startDownloads];
   
   }
   #pragma mark - RKDownloader delegate
  -(void)fileDownloadProgress:(NSNumber *)progress{
    
    NSLog(@"%@",progress);
    
  }
  -(void)didFinishDownloadData:(NSData *)data withError:(NSError *)readingDataError dataWithURL:(NSString *)urlStr{
    
    NSLog(@"complete recive data.Data size is %ld byte.",data.length);
    
  }
