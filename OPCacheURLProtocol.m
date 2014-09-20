//
//  OPCacheURLProtocol.m
//  Kickstarter
//
//  Created by Brandon Williams on 12/26/13.
//  Copyright (c) 2013 Kickstarter. All rights reserved.
//

#import "OPCacheURLProtocol.h"

NSString* const OPCachingURLHeader = @"X-OPCache";
NSString* const OPCachingForceURLHeader = @"X-OPCache-Force";

@interface OPCachedData : NSObject <NSCoding>
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@end

@interface OPCacheURLProtocol (/**/)
+(NSString*) cacheDirectoryPath;
+(void) ensureCacheDirectory;
+(NSString*) cachePathForRequest:(NSURLRequest*)request;
@end

@implementation OPCacheURLProtocol

+(NSUInteger) diskCacheSize {
  return 1024 * 1024 * 30;
}

+(void) initialize {
  [[self class] ensureCacheDirectory];

  NSFileManager *manager = NSFileManager.defaultManager;

  [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil usingBlock:^(NSNotification *note) {

    // clean up the old files, and let the OS know this may take some time.
    UIBackgroundTaskIdentifier taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    [(NSBlockOperation*)[NSBlockOperation blockOperationWithBlock:^{

      NSArray *files = [manager
                        contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[[self class] cacheDirectoryPath]]
                        includingPropertiesForKeys:@[NSURLAttributeModificationDateKey]
                        options:NSDirectoryEnumerationSkipsHiddenFiles
                        error:NULL];

      NSUInteger totalSize = 0;
      for (NSURL *url in files) {
        @autoreleasepool {
          NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:NULL];
          totalSize += [attributes[NSFileSize] unsignedIntegerValue];
        }
      }

      NSArray *sortedFiles = [files sortedArrayUsingComparator:^NSComparisonResult(NSURL *url1, NSURL *url2) {
        NSDate *date1 = nil, *date2 = nil;
        NSError *error1 = nil, *error2 = nil;
        if ([url1 getResourceValue:&date1 forKey:NSURLAttributeModificationDateKey error:&error1] &&
            [url2 getResourceValue:&date2 forKey:NSURLAttributeModificationDateKey error:&error2]) {
          return [date1 compare:date2];
        }
        return NSOrderedSame;
      }];

      // remove old files until we get under our cache size limit
      for (NSURL *url in sortedFiles) {
        @autoreleasepool {
          if (totalSize >= self.class.diskCacheSize) {
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url.path error:NULL];
            NSUInteger size = [attributes[NSFileSize] unsignedIntegerValue];
            totalSize -= size;
            [[NSFileManager defaultManager] removeItemAtPath:url.path error:NULL];
          } else {
            break ;
          }
        }
      }

      [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
    }] start];
  }];
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

  NSString *cachePath = [[self class] cachePathForRequest:self.request];
  OPCachedData *cachedData = nil;
  if (! self.request.allHTTPHeaderFields[OPCachingForceURLHeader]) {
    cachedData = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
  }

  if (cachedData) {
    [[NSFileManager defaultManager] setAttributes:@{ NSFileModificationDate: [NSDate date] }
                                     ofItemAtPath:cachePath
                                            error:NULL];

    [self.client URLProtocol:self didReceiveResponse:cachedData.response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:cachedData.data];
    [self.client URLProtocolDidFinishLoading:self];
  } else {
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

+(void) clearCache {
  [[NSFileManager defaultManager] removeItemAtPath:[[self class] cacheDirectoryPath] error:NULL];
  [self ensureCacheDirectory];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

+(NSString*) cacheDirectoryPath {
  return [[NSFileManager cachesDirectoryPath]
          stringByAppendingPathComponent:[NSString stringWithFormat:@"OPCacheURLProtocol/%@", NSStringFromClass([self class])]];
}

+(void) ensureCacheDirectory {
  [[NSFileManager defaultManager]
   createDirectoryAtPath:[[self class] cacheDirectoryPath]
   withIntermediateDirectories:YES attributes:nil error:NULL];
}

+(NSString*) cachePathForRequest:(NSURLRequest*)request {
  return [[[self class] cacheDirectoryPath]
          stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", (unsigned long)request.URL.absoluteString.hash]];
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
