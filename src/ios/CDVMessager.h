//
//  MQTTMessager.h
//  MQTTExample
//
//  Created by daihere on 07/07/2017.
//  Copyright © 2017 jmesnil.net. All rights reserved.
//
#import <Cordova/CDV.h>
#import "MQTTClient.h"

@interface CDVMessager : CDVPlugin <MQTTSessionDelegate>

@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) MQTTSession *session;
@property (nonatomic) BOOL isLaunch;
@property (nonatomic, strong) NSDictionary *notificationMessage;

- (void)subscribe:(CDVInvokedUrlCommand *)command;
- (void)init:(CDVInvokedUrlCommand *)command;
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSString *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)notificationReceived:(NSDictionary *)info isLaunch:(BOOL)isLaunch;

@end
