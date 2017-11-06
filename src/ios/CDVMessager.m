/*
 * @Author: 玖叁(N.T) 
 * @Date: 2017-10-13 09:50:45 
 * @Last Modified by: 玖叁(N.T)
 * @Last Modified time: 2017-11-06 10:18:05
 */

#import "CDVMessager.h"

@implementation CDVMessager

- (void)init:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
    NSDictionary *para = [command.arguments objectAtIndex:0];
    
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
        NSDictionary *result;
        if (event == MQTTSessionEventConnected) {
            NSLog(@"Connect successful!");
            result = @{
                       @"type": @"connectSuccess",
                       @"value": @"Connect success."
                       };
            if (mySelf.currentTopic != nil) {
                [mySelf _subscribe:mySelf.currentTopic];
            }
            [mySelf successWithCallbackID:mySelf.callbackId withDic:result];
        } else {
            result = @{
                       @"type": @"connectFail",
                       @"value": @"Connect fail."
                       };
            [mySelf successWithCallbackID:mySelf.callbackId withDic:result];
            if (event == MQTTSessionEventConnectionError) {
                [mySelf.session connectAndWaitTimeout:5];
            }
        }
    };
    [self.session connectAndWaitTimeout:5];
}

- (void)subscribe:(CDVInvokedUrlCommand *)command {
    NSString *topic = [command.arguments objectAtIndex:0];
    
    self.currentTopic = topic;
    [self _subscribe:topic];
}

- (void)_subscribe:(NSString *)topic {
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

- (void)unsubscribe:(CDVInvokedUrlCommand *)command {
    NSString *topic = [command.arguments objectAtIndex:0];
    
    if (self.session != nil) {
        [self.session unsubscribeTopic:topic];
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
