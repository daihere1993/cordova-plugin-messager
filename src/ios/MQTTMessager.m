//
//  MQTTMessager.m
//  MQTTExample
//
//  Created by daihere on 07/07/2017.
//  Copyright © 2017 jmesnil.net. All rights reserved.
//

#import "MQTTMessager.h"

@implementation MQTTMessager

#pragma marg "API"

- (void)connect:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    NSString *clientId = [params objectForKey:@"clientId"];
    NSString *host = [[[params objectForKey:@"host"] componentsSeparatedByString:@":"] objectAtIndex:0];
    int port = [[[[params objectForKey:@"host"] componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    NSString *username = [params objectForKey:@"username"];
    NSString *password = [params objectForKey:@"password"];
    
    // init MQTTClient
    self.client = [[MQTTClient alloc] initWithClientId:clientId];
    [self.client setPort:port];
    [self.client setUsername:username];
    [self.client setPassword:password];
    
    [self.client connectToHost:host completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            // The client is connected when this completion handler is called
            NSLog(@"client is connected with id %@", clientId);
            // Subscribe to the topic
            self.isConnected = YES;
        }
    }];
}

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    
    NSString *topic = [params objectForKey:@"topic"];
    
    // save topic: callbackId
    [self.callbackMap setValue:command.callbackId forKey:topic];
    
    __weak MQTTMessager *weakSelf = self;
    [self.client setMessageHandler:^(MQTTMessage *message) {
        NSString *text = [message payloadString];
        [weakSelf successWithCallbackID:[weakSelf.callbackMap objectForKey:message.topic] withMessage:text];
    }];
    
    if (self.isConnected) {
        [self.client subscribe:topic withCompletionHandler:^(NSArray *grantedQos) {
            // The client is effectively subscribed to the topic when this completion handler is called
            NSLog(@"subscribed to topic %@", topic);
        }];
    } else {
        [self failWithCallbackID:[self.callbackMap objectForKey:topic] withMessage:@"链接失败"];
    }
}

- (void)disconnect:(CDVInvokedUrlCommand *)command {
    [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
        NSLog(@"MQTT is disconnected");
    }];
}

- (void)publish:(CDVInvokedUrlCommand *)command {
    
}

#pragma mark "Private methods"

- (void)successWithCallbackID:(NSString *)callbackID {
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message {
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withError:(NSError *)error {
    [self failWithCallbackID:callbackID withMessage:[error localizedDescription]];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message {
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

@end
