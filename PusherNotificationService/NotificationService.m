//
//  NotificationService.m
//  PusherNotificationService
//
//  Created by Oleg Shultsev on 28.04.2020.
//  Copyright © 2020 Shultsev Oleg. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSRange range = NSMakeRange(6,1);
    NSString *newText = [[NSString stringWithFormat:@"%@",request.content.body] stringByReplacingCharactersInRange:range withString:[self getMessCount]];
    
    self.bestAttemptContent.body = newText;
      
    /*
     Обрабатываем alert-пуш.
     Сценарий: пришел alert пуш, программа killed.
    */

    [self saveNewPushData:newText];
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}


#pragma mark - Other functions

-(void)saveNewPushData:(NSString *)text{
    //Обявляем NSUserDefaults с SuiteName, чтобы приложение и расширение вместе данные видели в своей группе
    NSUserDefaults *userDefaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.ru.x11.testpush"];
    
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
    NSDictionary *currentPush = @{@"date": newDateString,@"push":text,@"type":@"message"};
    [arrData addObject:currentPush];
    [userDefaults setObject:arrData forKey:@"pushes"];
    [userDefaults synchronize];
    NSLog(@"Hello from Notification Service: %@",arrData);
}

-(NSString *)getMessCount{
    NSUserDefaults *userDefaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.ru.x11.testpush"];
    
    //Берем сохраненный массив словарей с пушами
    NSArray *pushesData=[userDefaults objectForKey:@"pushes"];
    int messCount=1;
    for (int i = 0; i < pushesData.count; i++)
    {
        if([[[pushesData objectAtIndex:i] objectForKey:@"type"] isEqualToString:@"message"]){
            messCount++;
        }
    }
    
    return [@(messCount) stringValue];
}

@end
