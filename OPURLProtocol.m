//
//  OPURLProtocol.h
//  OPURLProtocol
//
//  Created by Brandon Williams on 8/23/13.
//  Copyright (c) 2013 Opetopic. All rights reserved.
//

#import "OPURLProtocol.h"

@interface OPURLProtocol ()
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, strong, readwrite) NSMutableData *data;
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *response;
@end

@implementation OPURLProtocol

+(BOOL) canInitWithRequest:(NSURLRequest *)request {
  return NO;
}

+(NSURLRequest*) canonicalRequestForRequest:(NSURLRequest *)request {
  return request;
}

-(id) initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
  return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

-(void) startLoading {
  self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
}

-(void) stopLoading {
  [self.connection cancel];
}

-(void) connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [self.client URLProtocol:self didFailWithError:error];

  self.connection = nil;
  self.response = nil;
  self.data = nil;
}

-(void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
  return [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.client URLProtocol:self didLoadData:data];

  self.data = self.data ?: [NSMutableData new];
  [self.data appendData:data];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
  [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
  self.response = response;
}

-(NSURLRequest*) connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSHTTPURLResponse *)response {
  if (response) {
    [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    return nil;
  }
  return request;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
  [self.client URLProtocolDidFinishLoading:self];

  self.connection = nil;
  self.response = nil;
  self.data = nil;
}

@end
