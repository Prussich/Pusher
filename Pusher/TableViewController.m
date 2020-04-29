//
//  TableViewController.m
//  Pusher
//
//  Created by Oleg Shultsev on 29.04.2020.
//  Copyright © 2020 Shultsev Oleg. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize arrData;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(tableUpdate)
                                            name:@"tableUpdate"
                                                 object:nil];
    [self tableUpdate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableCell = @"cellId";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:tableCell];

    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableCell];
    }
    
    NSString *dataText=[[arrData objectAtIndex:indexPath.row] objectForKey:@"date"];
    NSString *detailText=[NSString stringWithFormat:@"%@: %@",[[arrData objectAtIndex:indexPath.row] objectForKey:@"type"],[[arrData objectAtIndex:indexPath.row] objectForKey:@"push"]];
    [cell.textLabel setText:dataText];
    [cell.detailTextLabel setText:detailText];
    return cell;
}

#pragma mark - IBAction functions

- (IBAction)onClearData:(id)sender {
    
    NSUserDefaults *userDefaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.ru.x11.testpush"];
    
    [userDefaults setObject:nil forKey:@"pushes"];
    [userDefaults synchronize];
    
    [self tableUpdate];
}

#pragma mark - Other functions

- (void)tableUpdate{
    NSLog(@"Receive table update");
    //Берем сохраненный массив словарей с пушами
    NSUserDefaults *userDefaults=[[NSUserDefaults alloc] initWithSuiteName:@"group.ru.x11.testpush"];
    
    NSArray *pushesData=[userDefaults objectForKey:@"pushes"];
    
    arrData=[[NSMutableArray alloc] init];
    [arrData addObjectsFromArray:pushesData];
    
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if(token) [_pushTokenField setText:token];
    [self.tableView reloadData];
}

- (void)defaultsChanged:(NSNotification *)notification {
  // Get the user defaults
  NSUserDefaults *defaults = (NSUserDefaults *)[notification object];

  NSLog(@"%@", [defaults objectForKey:@"yourIntrestedObject"]);
}

@end
