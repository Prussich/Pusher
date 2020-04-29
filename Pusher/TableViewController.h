//
//  TableViewController.h
//  Pusher
//
//  Created by Oleg Shultsev on 29.04.2020.
//  Copyright © 2020 Shultsev Oleg. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource>

- (IBAction)onClearData:(id)sender;

@property (nonatomic, retain) NSMutableArray *arrData;
@property (weak, nonatomic) IBOutlet UITextField *pushTokenField;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;

@end

NS_ASSUME_NONNULL_END
