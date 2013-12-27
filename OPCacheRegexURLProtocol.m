//
//  OPCacheRegexURLProtocol.m
//  Kickstarter
//
//  Created by Brandon Williams on 12/27/13.
//  Copyright (c) 2013 Kickstarter. All rights reserved.
//

#import "OPCacheRegexURLProtocol.h"

@implementation OPCacheRegexURLProtocol

+(NSArray*) cacheableURLRegexes {
  return @[];
}

+(BOOL) requestIsCacheable:(NSURLRequest *)request {
  for (NSRegularExpression *regex in [[self class] cacheableURLRegexes]) {
    if ([request.URL.absoluteString matches:regex]) {
      DLogSimple(@"%@", request.URL.absoluteString);
      return YES;
    }
  }
  return NO;
}

@end
