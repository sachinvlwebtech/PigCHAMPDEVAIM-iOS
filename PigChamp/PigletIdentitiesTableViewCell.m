//
//  PigletIdentitiesTableViewCell.m
//  PigChamp
//
//  Created by Nikhil Nandre on 12/3/20.
//  Copyright © 2020 Venturelabour. All rights reserved.
//

#import "PigletIdentitiesTableViewCell.h"
#import "PigletIdTableViewCell.h"

@implementation PigletIdentitiesTableViewCell 
NSInteger prev;
BOOL chkMarkEdit = FALSE;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.pigletIdenListArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReloadNotification:) name:@"ReloadNestedTableNotification" object:nil];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)btnAdd_tapped:(id)sender {
    if ([_txtpiglet_den.text isEqualToString: @""] ||
        [_txtpiglet_Tattoo.text isEqualToString: @""] ||
        [_txtpiglet_Weight.text isEqualToString: @""] ||
        [_txtpiglet_Teats.text isEqualToString: @""] ||
        [_txtpiglet_TeatsLeft.text isEqualToString: @""] ||
        [_txtpiglet_TeatsBBL.text isEqualToString: @""] ||
        [_txtpiglet_TeatsBBR.text isEqualToString: @""] ||
        [_txtpiglet_transp.text isEqualToString: @""] ||
        [_btnSex.currentTitle isEqualToString:@""] ||
        [_btnColor.currentTitle isEqualToString:@""] ||
        [_btnDestination.currentTitle isEqualToString:@""]) {
        NSLog(@"No allowed to add to list");
        
        [self.delegate showAlertFromCell:self];
        
    }
    else{
        //NSLog(@"I am in add row tapped");
        NSMutableDictionary *txtdata = [NSMutableDictionary dictionary];
        NSString *identxt = [NSString stringWithString:_txtpiglet_den.text];
        NSString *tattootxt = [NSString stringWithString:_txtpiglet_Tattoo.text];
        NSString *transtxt = [NSString stringWithString:_txtpiglet_transp.text];
        if (identxt.length > 0) {
            [txtdata setValue:_txtpiglet_den.text forKey:@"Identity"];
            
        } if (tattootxt.length > 0) {
            [txtdata setValue:tattootxt forKey:@"Tattoo"];
            
        } if (transtxt.length > 0) {
            [txtdata setValue:transtxt forKey:@"Transponder"];
            
        }
        [self.pigletIdenListArray insertObject:txtdata atIndex:0];
        //NSLog(@"%@",_pigletIdenListArray);
      
        //added for Bug-29596 By M.
        chkMarkEdit = TRUE;
        [self.delegate AddPigletIdentityToArray];
        
        [_identitiestblView reloadData];
      
        _txtpiglet_den.text = @"";
        _txtpiglet_Tattoo.text = @"";
        _txtpiglet_Weight.text = @"";
        _txtpiglet_Teats.text = @"";
        _txtpiglet_transp.text = @"";
        _txtpiglet_TeatsBBL.text = @"";
        _txtpiglet_TeatsBBR.text = @"";
        _txtpiglet_TeatsLeft.text = @"";
        [_btnSex setTitle:@"" forState:UIControlStateNormal];
        [_btnColor setTitle:@"" forState:UIControlStateNormal];
        [_btnDestination setTitle:@"" forState:UIControlStateNormal];
        [self.delegate clearAlldicts];
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        NSInteger retrievedCounter = [pref integerForKey:@"CounterKey"];
        retrievedCounter = retrievedCounter + 1;
        [pref setInteger:retrievedCounter forKey:@"CounterKey"];
        [pref synchronize];
    }
}
- (IBAction)btnRemove_tapped:(id)sender {
    
    NSLog(@"I am in remove row tapped");
    if (self.pigletIdenListArray.count > 0) {
       
        NSDictionary *objRemove = [self.pigletIdenListArray lastObject];
       
        NSString *tmpIden = objRemove[@"Identity"];
        
        [self.delegate PigletIdentitiesRemoveObject:tmpIden];
        [self.pigletIdenListArray removeLastObject];
        
        // Update the table view
        [self.identitiestblView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pigletIdenListArray.count inSection:0];
        [self.identitiestblView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.identitiestblView endUpdates];
        
    } else {
        // Handle the case where there are no rows to remove
        NSLog(@"No rows to remove");
    }
    
}
#pragma mark - Table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfSectionsInTableView:(NSInteger)section{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _pigletIdenListArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        return 70;
    }
    @catch (NSException *exception){
        
        NSLog(@"Exception in heightForRowAtIndexPath = %@",exception.description);
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Identity    Tattoo     Transponder";
    }
   
    return nil; // Return nil if you don't want a header for a particular section
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width - 20, 20)];
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [headerView addSubview:titleLabel];
    
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        PigletIdTableViewCell *cell = (PigletIdTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"identitiesList" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
       
       
        NSDictionary *item = self.pigletIdenListArray[indexPath.row];
        
        // Extract the "Identity" value
        NSString *identity = item[@"Identity"];
        NSString *tattoo = item[@"Tattoo"];
        NSString *transponder = item[@"Transponder"];
        cell.lblPigletIdenty.text = identity;
        cell.lblPigletTattoo.text = tattoo;
        cell.lblPigletTrans.text = transponder;
        if (!chkMarkEdit){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
           
        }
        
        return cell;
    }
    
    @catch (NSException *exception) {
        
        NSLog(@"Exception in cellForRowAtIndexPath =%@",exception.description);
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView cellForRowAtIndexPath:indexPath];

       if (cell.accessoryType==UITableViewCellAccessoryNone)
       {
          cell.accessoryType=UITableViewCellAccessoryCheckmark;

           NSDictionary *item = self.pigletIdenListArray[indexPath.row];
           
           // Extract the "Identity" value
           NSString *identity = item[@"Identity"];
           [self.delegate PigletIdentitiesListUpdate:identity];
           if (prev!=indexPath.row) {
           
             prev=indexPath.row;
         }

     }
     else{
         cell.accessoryType=UITableViewCellAccessoryNone;
         NSDictionary *item = self.pigletIdenListArray[indexPath.row];
         
         // Extract the "Identity" value
         NSString *identity = item[@"Identity"];
         [self.delegate PigletIdentitiesListUpdateUnchk:identity];
     }
    return  cell;
}
-(void)ClearPigletIdentitiesList{
    @try {
        [_pigletIdenListArray removeAllObjects];
        [self.identitiestblView reloadData];
       
    } @catch (NSException *exception) {
        NSLog(@"Exception in PigletIdentities=%@",exception.description);
        
    }
}
- (void)handleReloadNotification:(NSNotification *)notification {
    NSString *data = notification.userInfo[@"data"];
    [self showPigletIdentityList:data];
}
-(void)showPigletIdentityList:(NSString *)pigletStrigEdit{
    //NSLog(@"I am in Show list of Piglet Identities");
    NSData *jsonData = [pigletStrigEdit dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    NSMutableDictionary *editdata = [[NSMutableDictionary alloc]init];
    if (!error) {
        for (NSDictionary *dict in jsonArray) {
            NSMutableDictionary *editdata = [[NSMutableDictionary alloc]init];
            NSString *identityE = dict[@"Identity"];
            NSString *tattooE = dict[@"Tattoo"];
            NSString *transE = dict[@"Transponder"];
            [editdata setValue:identityE forKey:@"Identity"];
            
            [editdata setValue:tattooE forKey:@"Tattoo"];
            
            [editdata setValue:transE forKey:@"Transponder"];
            
            [self.pigletIdenListArray addObject:editdata];
            NSLog(@"Piglet list Array%@",_pigletIdenListArray);
        }
        
    }
    //added for Bug-29596
    chkMarkEdit = TRUE;
    [self.identitiestblView reloadData];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
    @end
