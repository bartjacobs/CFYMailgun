//
//  CFYMailgun.m
//  Mailgun
//
//  Created by Bart Jacobs on 14/01/14.
//  Copyright (c) 2014 Code Foundry. All rights reserved.
//

#import "CFYMailgun.h"

#import "MF_Base64Additions.h"

NSString * const CFYMailgunBaseURL = @"https://api.mailgun.net/";

@interface CFYMailgun () <NSURLConnectionDataDelegate> {
    NSURL *_baseUrl;
}

@property (copy, nonatomic) NSString *domain;
@property (copy, nonatomic) NSString *apiKey;
@property (copy, nonatomic) NSString *apiVersion;

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation CFYMailgun

#pragma mark -
#pragma mark Shared Instance
+ (CFYMailgun *)sharedInstance {
    static CFYMailgun *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark -
#pragma mark Class Methods
+ (void)setDomain:(NSString *)domain {
    [[CFYMailgun sharedInstance] setDomain:domain];
}

+ (void)setApiKey:(NSString *)apiKey {
    [[CFYMailgun sharedInstance] setApiKey:apiKey];
}

+ (void)setApiVersion:(NSString *)apiVersion {
    [[CFYMailgun sharedInstance] setApiVersion:apiVersion];
}
#pragma mark -
+ (void)sendMessage:(CFYMessage *)message completion:(CFYMailgunCompletionHandler)completion {
    [[CFYMailgun sharedInstance] sendMessage:message completion:completion];
}

#pragma mark -
#pragma mark Instance Methods
- (void)sendMessage:(CFYMessage *)message completion:(CFYMailgunCompletionHandler)completion {
    // Initialize Store
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    // Populate Store
    [info setObject:message forKey:@"message"];
    [info setObject:[completion copy] forKey:@"completion"];
    
    // Initialize Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self baseUrl]];
    
    // Configure Request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self requestBodyForMessage:message]];
    
    // Request Headers
    [request addValue:[self valueForAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    
    // Initialize Connection
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
    
    [info setObject:connection forKey:@"connection"];
    
    if (!self.messages) self.messages = [NSMutableArray array];
    [self.messages addObject:info];
}

#pragma mark -
#pragma mark URL Connection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Deserialization
    NSError *error = nil;
    id response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    // Fetch Store for Connection
    NSMutableDictionary *store = [self storeForConnection:connection];
    
    if (error) {
        [store setObject:error forKey:@"error"];
    } else {
        [store setObject:response forKey:@"response"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Complete Request for Connection
    [self completeRequestForConnection:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (error) {
        // Fetch Store for Connection
        NSMutableDictionary *store = [self storeForConnection:connection];
        
        // Store Response
        [store setObject:error forKey:@"error"];
    }
    
    // Complete Request for Connection
    [self completeRequestForConnection:connection];
}

#pragma mark -
#pragma mark Helper Methods
- (NSURL *)baseUrl {
    if (!_baseUrl) {
        NSString *apiVersion = (self.apiVersion ? self.apiVersion : @"v2");
        NSString *urlString = [CFYMailgunBaseURL stringByAppendingString:apiVersion];
        urlString = [urlString stringByAppendingPathComponent:self.domain];
        urlString = [urlString stringByAppendingPathComponent:@"messages"];
        _baseUrl = [NSURL URLWithString:urlString];
    }
    
    return _baseUrl;
}

- (NSString *)valueForAuthorizationHeader {
    NSString *apiKey = [NSString stringWithFormat:@"api:%@", self.apiKey];
    return [NSString stringWithFormat:@"Basic \"%@\"", [apiKey base64String]];
}

- (NSData *)requestBodyForMessage:(CFYMessage *)message {
    NSMutableDictionary *buffer = [NSMutableDictionary dictionary];
    [buffer setObject:message.from forKey:@"from"];
    [buffer setObject:message.body forKey:@"text"];
    [buffer setObject:message.subject forKey:@"subject"];
    [buffer setObject:[message.to componentsJoinedByString:@","] forKey:@"to"];

    if ( [message.cc count] > 0 ) {
        [buffer setObject:[message.cc componentsJoinedByString:@","] forKey:@"cc"];
    }
    
    if ( [message.bcc count] > 0 ) {
        [buffer setObject:[message.bcc componentsJoinedByString:@","] forKey:@"bcc"];
    }

    NSMutableArray *bufferBody = [NSMutableArray array];
    
    for (NSString *key in buffer) {
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@", key, buffer[key]];
        [bufferBody addObject:keyValue];
    }
    
    NSString *textBody = [bufferBody componentsJoinedByString:@"&"];
    return [textBody dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSMutableDictionary *)storeForConnection:(NSURLConnection *)connection {
    NSMutableDictionary *result = nil;
    
    for (NSMutableDictionary *store in self.messages) {
        if ([[store objectForKey:@"connection"] isEqual:connection]) {
            result = store;
            break;
        }
    }
    
    return result;
}

- (void)completeRequestForConnection:(NSURLConnection *)connection {
    // Fetch Store for Connection
    NSMutableDictionary *store = [self storeForConnection:connection];
    CFYMailgunCompletionHandler completion = [store objectForKey:@"completion"];
    
    if (completion) {
        NSError *error = [store objectForKey:@"error"];
        id response = [store objectForKey:@"response"];
        CFYMessage *message = [store objectForKey:@"message"];
        
        if (error) {
            completion(NO, response, message, error);
        } else {
            completion(YES, response, message, error);
        }
    }
    
    // Cleanup
    [self.messages removeObject:store];
}

@end
