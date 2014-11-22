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
  NSString *urlString = request.URL.absoluteString;
  if (! urlString) {
    return NO;
  }

  for (NSRegularExpression *regex in [[self class] cacheableURLRegexes]) {
    if ([regex matchesInString:urlString options:0 range:NSMakeRange(0, urlString.length)].count > 0) {
      return YES;
    }
  }
  return NO;
}

@end
