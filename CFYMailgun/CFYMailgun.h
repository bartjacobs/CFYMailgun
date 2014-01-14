//
//  CFYMailgun.h
//  Mailgun
//
//  Created by Bart Jacobs on 14/01/14.
//  Copyright (c) 2014 Code Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CFYMessage.h"

extern NSString * const CFYMailgunBaseURL;

typedef void (^CFYMailgunCompletionHandler)(BOOL success, id response, CFYMessage *message, NSError *error);

@interface CFYMailgun : NSObject

#pragma mark -
#pragma mark Class Methods
+ (void)setDomain:(NSString *)domain;
+ (void)setApiKey:(NSString *)apiKey;
+ (void)setApiVersion:(NSString *)apiVersion;

#pragma mark -
+ (void)sendMessage:(CFYMessage *)message completion:(CFYMailgunCompletionHandler)completion;

@end
