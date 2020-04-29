//
//  AppDelegate.h
//  Pusher
//
//  Created by Oleg Shultsev on 28.04.2020.
//  Copyright © 2020 Shultsev Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

