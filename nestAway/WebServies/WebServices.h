//
//  WebServices.h
//  nestAway
//
//  Created by deepakraj murugesan on 17/10/15.
//  Copyright © 2015 deepakraj murugesan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServices : NSObject
typedef void (^JSONResponseBlock)(NSDictionary* json);
+(WebServices*)sharedInstance;
-(void)apicallForGetMethod:(NSString *)urlPath onCompletion:(JSONResponseBlock)completionBlock;
@end
