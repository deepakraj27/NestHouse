//
//  WebServices.m
//  nestAway
//
//  Created by deepakraj murugesan on 17/10/15.
//  Copyright © 2015 deepakraj murugesan. All rights reserved.
//

#import "WebServices.h"
#define kAPIHost @"http://a88a4240."   //live


@implementation WebServices

+(WebServices*)sharedInstance {
    static WebServices *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)apicallForGetMethod:(NSString *)urlPath onCompletion:(JSONResponseBlock)completionBlock{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *pathString=[kAPIHost stringByAppendingString:urlPath];
    NSURL *url=[NSURL URLWithString:pathString];
    [request setURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:request
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           //NSLog(@"Response:%@ \n error:%@\n ", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding], error);
                                                           if(error == nil)
                                                           {
                                                               
                                                               if (data != nil) {
                                                                   NSError *errorPaserJSON = nil;
                                                                   NSDictionary *jsonContents = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorPaserJSON];
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       completionBlock(jsonContents);
                                                                   });
                                                                   
                                                               }
                                                               
                                                           }
                                                           else{
                                                               
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   completionBlock([NSDictionary dictionaryWithObject:[error localizedDescription] forKey:@"error"]);
                                                               });
                                                               
                                                           }
                                                           
                                                       }];
    [dataTask resume];
}

@end
