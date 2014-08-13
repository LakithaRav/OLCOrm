//
//  OLCViewController.m
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 08/10/2014.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import "OLCViewController.h"
#import "TestObject.h"

@interface OLCViewController ()

@end

@implementation OLCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    isEditingMode = NO;
    [self.tblRecords setDelegate:self];
    [self.tblRecords setDataSource:self];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.tblRecords addGestureRecognizer:lpgr];
    
    records = [[NSArray alloc] init];
    
    [self getAllRecords];
}

#pragma OLCOrm Functions

- (void) getAllRecords
{
    TestObject *object = [[TestObject alloc] init];
    
    records = [object whereColumn:@"status" byOperator:@"=" forValue:@"1"];
    
    [self.tblRecords reloadData];
    
}

- (BOOL) addNewRecord
{
    TestObject *test = [[TestObject alloc] init];
    
    test.title = [NSString stringWithFormat:@"Sample Record %d", [records count]];
    test.coordinates = [NSNumber numberWithDouble:234.345345];
    test.currency = [NSNumber numberWithFloat:150.00];
    test.flag = [NSNumber numberWithInt:1];
    test.addAt = [NSDate date];
    test.link = [NSURL URLWithString:@"http://google.com"];
    test.status = [NSNumber numberWithInt:1];

    return [test save];
}

#pragma Controller Events

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAddRecord:(id)sender {
    
    BOOL isAdded = [self addNewRecord];
    
    if(isAdded)
        [self getAllRecords];
}

- (IBAction)btnEditTable:(id)sender {
    
    [self.tblRecords setEditing: !isEditingMode animated: YES];
    
    if (isEditingMode)
    {
        isEditingMode = NO;
        self.btnEdit.title = @"Edit";
    }
    else
    {
        isEditingMode = YES;
        self.btnEdit.title = @"Done";
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tblRecords];
    
    NSIndexPath *indexPath = [self.tblRecords indexPathForRowAtPoint:p];
    if (indexPath == nil)
    {
        NSLog(@"long press on table view but not on a row");
    }
    else
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"long press on table view at row %d", indexPath.row);
            
            [self promptChangeTitleAlert:indexPath.row];
        }
        else
        {
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Press Cancel
    }
    else
    {
        //Press Update
        
        NSInteger selectionIndex = alertView.tag;
        
        TestObject *selection = [records objectAtIndex:selectionIndex];
        
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        
        selection.title = inputText;
        [selection update];
        
        [self getAllRecords];
    }
}

#pragma Controller private methods

- (void) promptChangeTitleAlert:(int) rowIndex
{
    TestObject *selection = [records objectAtIndex:rowIndex];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Change record title"
                                                      message:selection.title
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Update", nil];
    
    [message setTag:(NSInteger) rowIndex];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [message show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    ///#warning Potentially incomplete method implementation.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"recordCell";
    UITableViewCell *cell = [self.tblRecords dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    TestObject *record = [records objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", record.Id, record.title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestObject *record = [records objectAtIndex:indexPath.row];
    
    [record delete];
    
    record = nil;
    
    [self getAllRecords];
}
@end
