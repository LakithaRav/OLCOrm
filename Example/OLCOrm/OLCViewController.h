//
//  OLCViewController.h
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 08/10/2014.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OLCViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblRecords;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;

- (IBAction)btnAddRecord:(id)sender;
- (IBAction)btnEditTable:(id)sender;

@end
