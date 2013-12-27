//
//  OPCacheRegexURLProtocol.h
//  Kickstarter
//
//  Created by Brandon Williams on 12/27/13.
//  Copyright (c) 2013 Kickstarter. All rights reserved.
//

#import "OPCacheURLProtocol.h"

@interface OPCacheRegexURLProtocol : OPCacheURLProtocol

+(NSArray*) cacheableURLRegexes;

@end
