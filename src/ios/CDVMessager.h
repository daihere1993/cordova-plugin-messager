/*
 * @Author: 玖叁(N.T) 
 * @Date: 2017-11-06 10:17:47 
 * @Last Modified by:   玖叁(N.T) 
 * @Last Modified time: 2017-11-06 10:17:47 
 */
 #import <Cordova/CDV.h>
 #import "MQTTClient.h"
 
 @interface CDVMessager : CDVPlugin <MQTTSessionDelegate>
 
 @property (nonatomic, strong) NSString *callbackId;
 @property (nonatomic, strong) NSString *currentTopic;
 @property (nonatomic, strong) MQTTSession *session;
 
 - (void)subscribe:(CDVInvokedUrlCommand *)command;
 - (void)unsubscribe:(CDVInvokedUrlCommand *)command;
 - (void)init:(CDVInvokedUrlCommand *)command;
 
 @end
 