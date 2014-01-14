//
//  CFYAppDelegate.m
//  Mailgun
//
//  Created by Bart Jacobs on 14/01/14.
//  Copyright (c) 2014 Code Foundry. All rights reserved.
//

#import "CFYAppDelegate.h"

#import "CFYMailgun.h"

@implementation CFYAppDelegate

#pragma mark -
#pragma mark Application Life Cycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize Window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Configure Window
    [self.window makeKeyAndVisible];
    
    // Send Message
    [self sendMessage];
    
    return YES;
}

#pragma mark -
#pragma mark Helper Methods
- (void)sendMessage {
    // Initialize Message
    CFYMessage *message = [[CFYMessage alloc] init];
    
    // Configure Message
    message.to = @[@"test1@example.com"];
    message.cc = @[@"test2@example.com"];
    message.bcc = @[@"test3@example.com"];
    message.from = @"test4@example.com";
    message.subject = @"Testing";
    message.body = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac dolor justo, ac tempus leo. Etiam pulvinar eros at lectus sollicitudin scelerisque. Aliquam erat volutpat.";
    
    [CFYMailgun setDomain:@"YOUR-DOMAIN"];
    [CFYMailgun setApiKey:@"YOUR-APIKEY"];
    
    [CFYMailgun sendMessage:message completion:^(BOOL success, id response, CFYMessage *message, NSError *error) {
        if (!error) {
            NSLog(@"%@", response);
        } else {
            NSLog(@"Unable to send message. %@, %@", error, error.userInfo);
        }
    }];
}

@end
