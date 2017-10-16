/*
 * @Author: 玖叁(N.T) 
 * @Date: 2017-10-13 09:51:05 
 * @Last Modified by:   玖叁(N.T) 
 * @Last Modified time: 2017-10-13 09:51:05 
 */

#import <Cordova/CDV.h>
#import "MQTTClient.h"

@interface CDVMessager : CDVPlugin <MQTTSessionDelegate>

@property (nonatomic, strong) NSString *callbackId;
@property (nonatomic, strong) MQTTSession *session;
@property (nonatomic) BOOL isLaunch;
@property (nonatomic, strong) NSDictionary *notificationMessage;

- (void)subscribe:(CDVInvokedUrlCommand *)command;
- (void)init:(CDVInvokedUrlCommand *)command;

@end
