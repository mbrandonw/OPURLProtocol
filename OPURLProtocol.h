//
//  OPURLProtocol.h
//  OPURLProtocol
//
//  Created by Brandon Williams on 8/23/13.
//  Copyright (c) 2013 Opetopic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPURLProtocol : NSURLProtocol <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong, readonly) NSURLConnection *connection;
@property (nonatomic, strong, readonly) NSMutableData *data;
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;

@end
