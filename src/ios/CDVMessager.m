//
//  MQTTMessager.m
//  MQTTExample
//
//  Created by daihere on 07/07/2017.
//  Copyright © 2017 jmesnil.net. All rights reserved.
//

#import "CDVMessager.h"

#define D_ISHight(K) [[UIDevice currentDevice].systemVersion floatValue]>=K

@implementation CDVMessager

- (void)init:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    NSDictionary *para = [command.arguments objectAtIndex:0];
    // 注册远程推送
    if (D_ISHight(8.0)) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeNewsstandContentAvailability | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
    
    // 连接MQTT消息服务器
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = [para objectForKey:@"host"];
    transport.port = [[para objectForKey:@"port"] intValue];
    
    self.session = [[MQTTSession alloc] init];
    self.session.transport = transport;
    self.session.userName = [para objectForKey:@"username"];
    self.session.password = [para objectForKey:@"password"];
    self.session.clientId = [para objectForKey:@"clientId"];
    self.session.delegate = self;
    __weak CDVMessager *mySelf = self;
    self.session.connectionHandler = ^(MQTTSessionEvent event) {
        if (event == MQTTSessionEventConnected) {
            NSLog(@"Connect successful!");
            [mySelf successWithCallbackID:command.callbackId withMessage:[NSString stringWithFormat:@"%li",event]];
        }
    };
    [self.session connectAndWaitTimeout:5];
    
}

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    NSString *topic = [command.arguments objectAtIndex:0];
    
    if (self.session != nil) {
        [self.session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
            if (error) {
                NSLog(@"Subscription failed %@", error.localizedDescription);
                [self failWithCallbackID:self.callbackId withError:error];
            } else {
                NSLog(@"Subscription successfull! Granted Qos: %@", gQoss);
            }
        }];
    }
}

- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Get message <%@>", message);
    NSDictionary *result = @{
                             @"type": [@"receivedMqttMsg_" stringByAppendingString:topic],
                             @"value": message
                             };
    [self successWithCallbackID:self.callbackId withDic:result];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSString *)deviceToken {
    NSDictionary *result = @{
                             @"type": @"registedNotification",
                             @"value": deviceToken
                             };
    [self successWithCallbackID:self.callbackId withDic:result];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self failWithCallbackID:self.callbackId withError:error];
}

- (void)notificationReceived:(NSDictionary *)info isLaunch:(BOOL)isLaunch {
    NSLog(@"Notification received");
    
    if (self.callbackId != nil) {
        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithCapacity:4];
        NSMutableDictionary *additionalData = [NSMutableDictionary dictionaryWithCapacity:4];
        
        for (id key in info) {
            if ([key isEqualToString:@"aps"]) {
                id aps = [info objectForKey:@"aps"];
                
                for (id key in aps) {
                    NSLog(@"Push Plugin key: %@", key);
                    id value = [aps objectForKey:key];
                    
                    if ([key isEqualToString:@"alert"]) {
                        if ([value isKindOfClass:[NSDictionary class]]) {
                            for (id messageKey in value) {
                                id messageValue = [value objectForKey:messageKey];
                                if ([messageKey isEqualToString:@"body"]) {
                                    [message setObject:messageValue forKey:@"message"];
                                } else if ([messageKey isEqualToString:@"title"]) {
                                    [message setObject:messageValue forKey:@"title"];
                                } else {
                                    [additionalData setObject:messageValue forKey:messageKey];
                                }
                            }
                        } else {
                            [message setObject:value forKey:@"message"];
                        }
                    } else if ([key isEqualToString:@"title"]) {
                        [message setObject:value forKey:@"title"];
                    } else if ([key isEqualToString:@"badge"]) {
                        [message setObject:value forKey:@"count"];
                    } else if ([key isEqualToString:@"sound"]) {
                        [message setObject:value forKey:@"sound"];
                    } else if ([key isEqualToString:@"image"]) {
                        [message setObject:value forKey:@"image"];
                    } else {
                        [additionalData setObject:value forKey:key];
                    }
                }
            } else {
                [additionalData setObject:[info objectForKey:key] forKey:key];
            }
        }
        
        
        if (isLaunch) {
            [additionalData setObject:[NSNumber numberWithBool:YES] forKey:@"isLaunch"];
        } else {
            [additionalData setObject:[NSNumber numberWithBool:NO] forKey:@"isLaunch"];
        }
        
        [message setObject:additionalData forKey:@"additionalData"];
        
        NSDictionary *result = @{
                                 @"type": @"receivedNotification",
                                 @"value": message
                                 };
        
        // send notification message
        [self successWithCallbackID:self.callbackId withDic:result];
    }
}


#pragma mark "Private methods"

- (void)successWithCallbackID:(NSString *)callbackID {
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)successWithCallbackID:(NSString *)callbackID withDic:(NSDictionary *)result {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withError:(NSError *)error {
    [self failWithCallbackID:callbackID withMessage:[error localizedDescription]];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

@end
