//
//  AppDelegate.m
//  Pusher
//
//  Created by Oleg Shultsev on 28.04.2020.
//  Copyright © 2020 Shultsev Oleg. All rights reserved.
//

#import "AppDelegate.h"
@import UserNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Инициализируем регистрацию центра сообщений
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
         if(!error)
         {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 [[UIApplication sharedApplication] registerForRemoteNotifications];
             });
             NSLog( @"Push registration success." );
         }
         else
         {
             NSLog( @"Push registration FAILED" );
             NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
             NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );
         }
     }];
 
    /*
     Обрабатываем тихий пуш.
     Сценарий: пришел тихий пуш, программа убита.
    */
     if (launchOptions) {
        NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *apsInfo = [userInfo objectForKey:@"data"];

        if (apsInfo) {
            //Берем значение из пуша
            int pushFromCount=[[[userInfo objectForKey:@"data"] objectForKey:@"count"] intValue];
            [self saveNewPushData:pushFromCount];
        }
    }
    //
    
    return YES;
}

#pragma mark - Push device token

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * deviceTokenString = [self stringWithDeviceToken:deviceToken];
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableUpdate" object:nil];
    NSLog(@"The generated device token string is : %@",deviceTokenString);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
     NSLog(@"Error in registration. Error: %@", err);
}

#pragma mark - User Notification Center delegates

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    
    //Игнорим, если пришел alert-push. Он уже обрабатывается в расширении.
    if([[[userInfo objectForKey:@"aps"] objectForKey:@"mutable-content"] intValue]==1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"tableUpdate" object:nil];
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    };
    
    /*
     Обрабатываем тихий пуш.
     Сценарий: пришел тихий пуш, программа в background/foreground.
    */
    
    int pushFromCount=[[[userInfo objectForKey:@"data"] objectForKey:@"count"] intValue];
    [self saveNewPushData:pushFromCount];
    
    //Сообщаем о том, что работу в background выполнили, чтобы не "злить" Apple
    completionHandler(UIBackgroundFetchResultNewData);
}

//Показываем push в открытом приложении
-(void)userNotificationCenter:(UNUserNotificationCenter *)center
      willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionBadge +
                      UNNotificationPresentationOptionSound +
                      UNNotificationPresentationOptionAlert);
};


#pragma mark - Other functions

-(void)saveNewPushData:(int)count{
    //Обявляем NSUserDefaults с SuiteName, чтобы приложение и расширение вместе данные видели в своей группе
    NSUserDefaults *userDefaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.ru.x11.testpush"];
    
    //Небольшая проерочка
    if (0 == count) count=1;
    int newCount=count*2;
    //сохраним число, как сказано в задании
    [userDefaults setInteger:newCount forKey:@"count"];

    //Берем сохраненный массив словарей с пушами
    NSArray *pushesData=[userDefaults objectForKey:@"pushes"];
    
    NSMutableArray *arrData=[[NSMutableArray alloc] init];
    [arrData addObjectsFromArray:pushesData];
    
    //Текущая дата
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    
    //Формируем и сохраняем новый массив
    NSDictionary *currentPush = @{@"date": newDateString,@"push":[@(newCount) stringValue],@"type":@"silent"};
    [arrData addObject:currentPush];
    [userDefaults setObject:arrData forKey:@"pushes"];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableUpdate" object:nil];
    NSLog(@"Hello from App: %@",arrData);
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhx", data[i]];
    }

    return [token copy];
}

@end
