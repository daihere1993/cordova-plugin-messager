//
//  AppDelegate+notification.m
//  捷行卡
//
//  Created by daihere on 11/08/2017.
//
//

#import "AppDelegate+notification.h"
#import "CDVMessager.h"

@implementation AppDelegate (notification)

- (id)getCommandInstance:(NSString *)className {
    return [self.viewController getCommandInstance:className];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@",token);
    CDVMessager *messagerHandler = [self getCommandInstance:@"CDVMessager"];
    [messagerHandler didRegisterForRemoteNotificationsWithDeviceToken:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Register fail %@", error);
    CDVMessager *messagerHandler = [self getCommandInstance:@"CDVMessager"];
    [messagerHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"clicked on the shade");
    CDVMessager *messagerHandler = [self getCommandInstance:@"CDVMessager"];
    [messagerHandler notificationReceived:userInfo isLaunch:NO];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveNotification with fetchCompletionHandler");
    
    if (application.applicationState == UIApplicationStateActive) {
        CDVMessager *messagerHandler = [self getCommandInstance:@"CDVMessager"];
        [messagerHandler notificationReceived:userInfo isLaunch:YES];
    } else {
        long silent = 0;
        id aps = [userInfo objectForKey:@"aps"];
        id contentAvailable = [aps objectForKey:@"content-available"];
        
        if ([contentAvailable isKindOfClass:[NSString class]] && [contentAvailable isEqualToString:@"1"]) {
            silent = 1;
        } else if ([contentAvailable isKindOfClass:[NSNumber class]]) {
            silent = [contentAvailable integerValue];
        }
        
        if (silent == 1) {
            NSLog(@"This should silent push");
            CDVMessager *messagerHandler = [self getCommandInstance:@"CDVMessager"];
            [messagerHandler notificationReceived:userInfo isLaunch:NO];
            
        } else {
            NSLog(@"just put it in the shade");
            
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }
}

@end