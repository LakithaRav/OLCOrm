//
//  OLCViewController.m
//  OLCOrm
//
//  Created by Lakitha Samarasinghe on 08/10/2014.
//  Copyright (c) 2014 Lakitha Samarasinghe. All rights reserved.
//

#import "OLCViewController.h"
#import "TestObject.h"
#import "UserObject.h"

@interface OLCViewController ()
{
    NSArray *records;
    BOOL isEditingMode;
}

@end

@implementation OLCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    [TestObject truncateTable];
//    [UþserObject truncateTable];
    
    [TestObject notifyOnChanges:self withMethod:@selector(testNotificationListner:)];
    [UserObject notifyOnChanges:self withMethod:@selector(userNotificationListner:)];
    
    isEditingMode = NO;
    [self.tblRecords setDelegate:self];
    [self.tblRecords setDataSource:self];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [self.tblRecords addGestureRecognizer:lpgr];
    
    records = [[NSArray alloc] init];

    [self makeSampleUser];
    
    [self getAllRecords];
 
}

#pragma OLCOrm Functions

- (void) makeSampleUser
{
    if([UserObject find:[NSNumber numberWithInt:1]] == nil)
    {
        UserObject *user = [[UserObject alloc] init];
        
        user.name = @"Jhon Doe";
        user.desc = @"This is a sample user";
        user.status = [NSNumber numberWithInt:1];
        
        //if you want to get the Id of inserted record
        NSNumber *index = [user saveAndGetId];
        
        [user save];
        
        user = nil;
    }
}

- (void) userNotificationListner:(OLCOrmNotification *) action
{
    records = [TestObject all];
    
    [self.tblRecords reloadData];
}

- (void) testNotificationListner:(OLCOrmNotification *) action
{
    switch (((OLCOrmNotification*) action.object).type)
    {
        case Insert:
            NSLog(@"Insert got called");
            break;
            
        case Update:
            NSLog(@"Update got called");
            break;
            
        case Delete:
            NSLog(@"Delete got called");
            break;
            
        default:
            break;
    }
    
    records = [TestObject all];
    
    [self.tblRecords reloadData];
    
}

- (void) getAllRecords
{
    UserObject *user = (UserObject*)[UserObject find:@1];
    
    records = [user hasTests];
    
    records = [TestObject whereColumn:@"link" byOperator:@"=" forValue:@"http://google.com" accending:YES];
    
    records = [TestObject where:@"flag = 1" sortBy:@"title" accending:NO];
    
    records = [TestObject all];
    
    [self.tblRecords reloadData];
    
}

- (BOOL) addNewRecord
{
    UserObject *user = (UserObject *) [UserObject find:[NSNumber numberWithInt:1]];
    
    TestObject *test = [[TestObject alloc] init];

    test.title = [NSString stringWithFormat:@"Sample's Record %lu", (unsigned long)[records count]];
    test.coordinates = [NSNumber numberWithDouble:234.345345];
    test.currency = [NSNumber numberWithFloat:150.00];
    test.flag = [NSNumber numberWithInt:1];
    test.addAt = [NSDate date];
    test.link = [NSURL URLWithString:@"http://google.com"];
    test.userId = user.Id;
    test.status = [NSNumber numberWithInt:1];
    
    NSMutableSet *stuff = [[NSMutableSet alloc] init];
    [stuff addObject:[NSString stringWithFormat:@"%@", @"SampleStuff1"]];
    
    test.stuff = stuff;
    
    NSMutableArray *sarry = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", nil];
    test.stuffArry = sarry;
    
    test.image = [UIImage imageNamed:@"dracula.png"];
    test.data  = UIImagePNGRepresentation(test.image);

    BOOL isAdded = [test save];
    
    test = nil;
    
    return isAdded;
}

#pragma Controller Events

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAddRecord:(id)sender {
    
    [self addNewRecord];
    
    //if(isAdded)
        //[self getAllRecords];
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

    }
    else
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            [self promptChangeTitleAlert:(int)indexPath.row];
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
        
        selection.title     = inputText;
        selection.flag      = [NSNumber numberWithInt:2];
        selection.updateAt  = [NSDate date];
        
        [selection update];
        
        UserObject *user = [selection hasUser];
        
        NSArray *objs = [user hasTests];
        
//        [self getAllRecords];
        
        selection = nil;
        user = nil;
        objs = nil;
    }
}

#pragma Controller private methods

- (void) promptChangeTitleAlert:(int) rowIndex
{
//    TestObject *selection = [records objectAtIndex:rowIndex];
    TestObject *selection = [records objectAtIndex:rowIndex];
    
    UserObject *user = [selection hasUser];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Change record title"
                                                      message:user.name
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Update", nil];
    
    [message setTag:(NSInteger) rowIndex];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [message show];
    
    selection = nil;
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
    cell.imageView.image = [UIImage imageWithData:record.data];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestObject *record = [records objectAtIndex:indexPath.row];
    
    [record delete];

    
    record = nil;
    
//    [self getAllRecords];
}
@end
