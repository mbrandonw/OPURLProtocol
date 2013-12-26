//
//  OPCacheURLProtocol.m
//  Kickstarter
//
//  Created by Brandon Williams on 12/26/13.
//  Copyright (c) 2013 Kickstarter. All rights reserved.
//

#import "OPCacheURLProtocol.h"

static NSString *OPCachingURLHeader = @"X-OPCache";
static NSString *cachesSubdirectory = @"OPCacheURLProtocol";

@interface OPCachedData : NSObject <NSCoding>
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@end

@interface OPCacheURLProtocol (/**/)
+(NSString*) cachePathForRequest:(NSURLRequest*)request;
@end

@implementation OPCacheURLProtocol

+(void) initialize {
  if (self == [OPCacheURLProtocol class]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:[[NSFileManager cachesDirectoryPath] stringByAppendingPathComponent:cachesSubdirectory]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
  }
}

+(BOOL) requestIsCacheable:(NSURLRequest*)request {
  return NO;
}

+(BOOL) canInitWithRequest:(NSURLRequest *)request {
  return !request.allHTTPHeaderFields[OPCachingURLHeader] && [[self class] requestIsCacheable:request];
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
  NSMutableURLRequest *newRequest = [request mutableCopy];
  [newRequest setValue:@"" forHTTPHeaderField:OPCachingURLHeader];

  if (! (self = [super initWithRequest:newRequest cachedResponse:cachedResponse client:client])) {
    return nil;
  }

  return self;
}

-(void) startLoading {

  OPCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] cachePathForRequest:self.request]];
  if (cache) {
    NSData *data = [cache data];
    NSURLResponse *response = [cache response];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
  }
  else
  {
    [super startLoading];
  }
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {

  NSString *cachePath = [[self class] cachePathForRequest:self.request];
  OPCachedData *cache = [OPCachedData new];
  [cache setResponse:self.response];
  [cache setData:self.data];
  [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];

  [super connectionDidFinishLoading:connection];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

+(NSString*) cachePathForRequest:(NSURLRequest*)request {
  return [[[NSFileManager cachesDirectoryPath]
           stringByAppendingPathComponent:cachesSubdirectory]
          stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", request.URL.absoluteString.hash]];
}

@end


#pragma mark -
#pragma mark OPCachedData
#pragma mark -

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";

@implementation OPCachedData

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.data forKey:kDataKey];
  [aCoder encodeObject:self.response forKey:kResponseKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (! (self = [super init])) {
    return nil;
  }

  [self setData:[aDecoder decodeObjectForKey:kDataKey]];
  [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];

  return self;
}

@end
