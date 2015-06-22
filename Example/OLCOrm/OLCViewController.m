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
    
    isEditingMode = NO;
    [self.tblRecords setDelegate:self];
    [self.tblRecords setDataSource:self];
    
    UIImage *image = [UIImage imageNamed:@"dracula.png"];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [self.tblRecords addGestureRecognizer:lpgr];
    
    records = [[NSArray alloc] init];
    
    records = [TestObject whereColumn:@"link" byOperator:@"=" forValue:@"http://google.com"];
    
    [self makeSampleUser];
    
    //[self getAllRecords];
    
    [TestObject notifyOnChanges:self withMethod:@selector(updateOnInsert:)];
    [UserObject notifyOnChanges:self withMethod:@selector(updateOnInsert:)];
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
        
        NSNumber *index = [user saveAndGetId];
        
        user = nil;
    }
}

- (void) updateOnInsert:(NSNotification *) action
{
    records = [TestObject all];
    
    [self.tblRecords reloadData];
}

- (void) getAllRecords
{
    
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
    
    BOOL isAdded = [self addNewRecord];
    
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
        NSLog(@"long press on table view but not on a row");
    }
    else
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            NSLog(@"long press on table view at row %ld", (long)indexPath.row);
            
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
        
        selection.title     = inputText;
        selection.flag      = [NSNumber numberWithInt:2];
        selection.updateAt  = [NSDate date];
        [selection update];
        
        UserObject *user = [selection hasUser];
        NSLog(@"User : %@", user.name);
        
        NSArray *objs = [user hasTests];
        NSLog(@"Record Count : %lu", (unsigned long)[objs count]);
        
        [self getAllRecords];
        
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
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Change record title"
                                                      message:selection.title
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
    
    [self getAllRecords];
}
@end
