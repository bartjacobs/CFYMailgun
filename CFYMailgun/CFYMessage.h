//
//  CFYMessage.h
//  Mailgun
//
//  Created by Bart Jacobs on 14/01/14.
//  Copyright (c) 2014 Code Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFYMessage : NSObject

@property (copy, nonatomic) NSArray *to;
@property (copy, nonatomic) NSArray *cc;
@property (copy, nonatomic) NSArray *bcc;
@property (copy, nonatomic) NSString *from;
@property (copy, nonatomic) NSString *body;
@property (copy, nonatomic) NSString *subject;

@end
