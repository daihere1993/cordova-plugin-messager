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

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    
    NSString *clientID = [params objectForKey:@"clientId"];
    NSString *host = [[[params objectForKey:@"host"] componentsSeparatedByString:@":"] objectAtIndex:0];
    int port = [[[[params objectForKey:@"host"] componentsSeparatedByString:@":"] objectAtIndex:1] intValue];
    NSString *username = [params objectForKey:@"username"];
    NSString *password = [params objectForKey:@"password"];
    NSString *topic = [params objectForKey:@"topic"];
    
    self.currentCallbackId = command.callbackId;
    
    // init MQTTClient
    MQTTClient *client = [[MQTTClient alloc] initWithClientId:clientID];
    [client setPort:port];
    [client setUsername:username];
    [client setPassword:password];
    
    // define the handler that will be called when MQTT messages are received by the client
    [client setMessageHandler:^(MQTTMessage *message) {
        NSString *text = [message payloadString];
        NSLog(@"received message %@", text);
        [self successWithCallbackID:self.currentCallbackId withMessage:text];
    }];
    
    [client connectToHost:host completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            // The client is connected when this completion handler is called
            NSLog(@"client is connected with id %@", clientID);
            // Subscribe to the topic
            [client subscribe:topic withCompletionHandler:^(NSArray *grantedQos) {
                // The client is effectively subscribed to the topic when this completion handler is called
                NSLog(@"subscribed to topic %@", topic);
            }];
        }
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