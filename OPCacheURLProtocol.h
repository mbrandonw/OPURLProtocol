//
//  OPCacheURLProtocol.h
//  Kickstarter
//
//  Created by Brandon Williams on 12/26/13.
//  Copyright (c) 2013 Kickstarter. All rights reserved.
//

#import "OPURLProtocol.h"

@interface OPCacheURLProtocol : OPURLProtocol

/**
 Override to custom which requests will be cached to the disk.
 */
+(BOOL) requestIsCacheable:(NSURLRequest*)request;

@end
