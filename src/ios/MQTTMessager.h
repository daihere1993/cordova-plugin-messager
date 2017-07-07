//
//  MQTTMessager.h
//  MQTTExample
//
//  Created by daihere on 07/07/2017.
//  Copyright © 2017 jmesnil.net. All rights reserved.
//
#import <Cordova/CDV.h>
#import "MQTTKit.h"

@interface MQTTMessager:CDVPlugin

@property (nonatomic, strong) NSString *currentCallbackId;

- (void)subscribe:(CDVInvokedUrlCommand *)command;
- (void)publish:(CDVInvokedUrlCommand *)command;

@end
