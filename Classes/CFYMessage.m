//
//  CFYMessage.m
//  Mailgun
//
//  Created by Bart Jacobs on 14/01/14.
//  Copyright (c) 2014 Code Foundry. All rights reserved.
//

#import "CFYMessage.h"

@implementation CFYMessage

#pragma mark -
#pragma mark Setters & Getters
- (void)setTo:(NSArray *)to {
    if (![to isKindOfClass:[NSArray class]]) {
        [NSException raise:@"Invalid Argument Type" format:@"The value you passed is not of type NSArray."];
        
    } else if (_to != to) {
        _to = to;
    }
}

- (void)setCc:(NSArray *)cc {
    if (![cc isKindOfClass:[NSArray class]]) {
        [NSException raise:@"Invalid Argument Type" format:@"The value you passed is not of type NSArray."];
        
    } else if (_cc != cc) {
        _cc = cc;
    }
}

- (void)setBcc:(NSArray *)bcc {
    if (![bcc isKindOfClass:[NSArray class]]) {
        [NSException raise:@"Invalid Argument Type" format:@"The value you passed is not of type NSArray."];
        
    } else if (_bcc != bcc) {
        _bcc = bcc;
    }
}

@end
