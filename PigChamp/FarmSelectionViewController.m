//
//  FarmSelectionViewController.m
//  PigChamp
//
//  Created by Venturelabour on 21/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import "FarmSelectionViewController.h"
#import "CoreDataHandler.h"
#import "ControlSettings.h"
#import "ServerManager.h"
NSString *strWait;
NSString *strFarms;

@interface FarmSelectionViewController ()
@end

@implementation FarmSelectionViewController

#pragma mark -View life cycle
- (void)viewDidLoad {
    @try {
        _btnSubmit.layer.shadowColor = [[UIColor grayColor] CGColor];
        _btnSubmit.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _btnSubmit.layer.shadowOpacity = 1.0f;
        _btnSubmit.layer.shadowRadius = 3.0f;
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Farm Selection"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
        self.title = @"Farm Selection";
        strNoInternet = @"You must be online for the app to function.";
        strSelectFarm = @"Please select Farm";
        strOK =@"OK";
        strCancel = @"CANCEL";//Cancel
        strWait = @"Updating your farm...";
        strUnauthorised =@"Your session has been expired. Please login again.";
        strServerErr= @"Server Error.";
        strFarms= @"Farms";
        strSignOff = @"Signing off.";
        
        NSMutableArray *arrStringsToTranslate = [[NSMutableArray alloc]init];
        [arrStringsToTranslate addObject:@"Select Farm"];
        [arrStringsToTranslate addObject:@"Farm Selection"];
        [arrStringsToTranslate addObject:@"SUBMIT"];
        [arrStringsToTranslate addObject:@"Updating your farm..."];
        [arrStringsToTranslate addObject:@"You must be online for the app to function."];
        [arrStringsToTranslate addObject:@"Please select Farm"];
        [arrStringsToTranslate addObject:@"OK"];
        [arrStringsToTranslate addObject:@"Cancel"];
        //[arrStringsToTranslate addObject:@"Loading..."];
        [arrStringsToTranslate addObject:@"Your session has been expired. Please login again."];
        [arrStringsToTranslate addObject:@"Server Error."];
        [arrStringsToTranslate addObject:@"Farms"];
        [arrStringsToTranslate addObject:@"Signing off."];
        
        NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrStringsToTranslate];
        
        
        
        //
        NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
        
        if (resultArray1.count!=0){
            for (int i=0; i<resultArray1.count; i++){
                [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
            }
            
            for (int i=0; i<12; i++) {
                
                if (i==0) {
                    if ([dictMenu objectForKey:[@"Select Farm" uppercaseString]] && ![[dictMenu objectForKey:[@"Select Farm" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Select Farm" uppercaseString]] length]>0) {
                            self.lblFarmSelection.text = [dictMenu objectForKey:[@"Select Farm" uppercaseString]]?[dictMenu objectForKey:[@"Select Farm" uppercaseString]]:@"";
                        }else{
                            self.lblFarmSelection.text = @"Select Farm";
                        }
                    }
                    else{
                        self.lblFarmSelection.text = @"Select Farm";
                    }
                }else  if (i==1){
                    if ([dictMenu objectForKey:[@"Farm Selection" uppercaseString]] && ![[dictMenu objectForKey:[@"Farm Selection" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Farm Selection" uppercaseString]] length]>0) {
                            self.title = [dictMenu objectForKey:[@"Farm Selection" uppercaseString]]?[dictMenu objectForKey:[@"Farm Selection" uppercaseString]]:@"";
                        }else{
                            self.title = @"Farm Selection";
                        }
                    }
                    else{
                        self.title = @"Farm Selection";
                    }
                }else  if (i==2){
                    NSString *strSearchTitle;
                    if ([dictMenu objectForKey:[@"SUBMIT" uppercaseString]] && ![[dictMenu objectForKey:[@"SUBMIT" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"SUBMIT" uppercaseString]] length]>0) {
                            strSearchTitle = [dictMenu objectForKey:[@"SUBMIT" uppercaseString]]?[dictMenu objectForKey:[@"SUBMIT" uppercaseString]]:@"";
                        }else{
                            strSearchTitle = @"SUBMIT";
                        }
                    }
                    else{
                        strSearchTitle = @"SUBMIT";
                    }
                    
                    [self.btnSubmit setTitle:strSearchTitle forState:UIControlStateNormal];
                }else  if (i==3){
                    if ([dictMenu objectForKey:[@"Updating your farm..." uppercaseString]] && ![[dictMenu objectForKey:[@"Updating your farm..." uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Updating your farm..." uppercaseString]] length]>0) {
                            strWait = [dictMenu objectForKey:[@"Updating your farm..." uppercaseString]]?[dictMenu objectForKey:[@"Updating your farm..." uppercaseString]]:@"";
                        }
                    }
                    
                }else  if (i==4){
                    if ([dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] && ![[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] length]>0) {
                            strNoInternet = [dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]?[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]:@"";
                        }
                    }
                }else  if (i==5){
                    if ([dictMenu objectForKey:[@"Please select Farm" uppercaseString]] && ![[dictMenu objectForKey:[@"Please select Farm" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Please select Farm" uppercaseString]] length]>0) {
                            strSelectFarm = [dictMenu objectForKey:[@"Please select Farm" uppercaseString]]?[dictMenu objectForKey:[@"Please select Farm" uppercaseString]]:@"";
                        }
                    }
                }else  if (i==6){
                    if ([dictMenu objectForKey:[@"OK" uppercaseString]] && ![[dictMenu objectForKey:[@"OK" uppercaseString]] isKindOfClass:[NSNull class]]){
                        if ([[dictMenu objectForKey:[@"OK" uppercaseString]] length]>0){
                            strOK = [dictMenu objectForKey:[@"OK" uppercaseString]]?[dictMenu objectForKey:[@"OK" uppercaseString]]:@"";
                        }
                    }
                }else  if (i==7){
                    if ([dictMenu objectForKey:[@"Cancel" uppercaseString]] && ![[dictMenu objectForKey:[@"Cancel" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Cancel" uppercaseString]] length]>0) {
                            strCancel = [dictMenu objectForKey:[@"Cancel" uppercaseString]]?[dictMenu objectForKey:[@"Cancel" uppercaseString]]:@"";
                        }
                    }
                }else  if (i==8){
                    if ([dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] && ![[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] length]>0) {
                            strUnauthorised = [dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]?[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]:@"";
                        }
                    }
                }else  if (i==9){
                    if ([dictMenu objectForKey:[@"Server Error." uppercaseString]] && ![[dictMenu objectForKey:[@"Server Error." uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Server Error." uppercaseString]] length]>0) {
                            strServerErr = [dictMenu objectForKey:[@"Server Error." uppercaseString]]?[dictMenu objectForKey:[@"Server Error." uppercaseString]]:@"";
                        }
                    }
                }else  if (i==10){
                    if ([dictMenu objectForKey:[@"Farms" uppercaseString]] && ![[dictMenu objectForKey:[@"Farms" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Farms" uppercaseString]] length]>0) {
                            strFarms = [dictMenu objectForKey:[@"Farms" uppercaseString]]?[dictMenu objectForKey:[@"Farms" uppercaseString]]:@"";
                        }
                    }
                }else  if (i==11){
                    if ([dictMenu objectForKey:[@"Signing off." uppercaseString]] && ![[dictMenu objectForKey:[@"Signing off." uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Signing off." uppercaseString]] length]>0) {
                            strSignOff = [dictMenu objectForKey:[@"Signing off." uppercaseString]]?[dictMenu objectForKey:[@"Signing off." uppercaseString]]:@"";
                        }
                    }
                }
            }
        }
        //
        
        [super viewDidLoad];
        _pref = [NSUserDefaults standardUserDefaults];
        
        self.btnFarmSelection.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
        self.navigationItem.hidesBackButton = YES;
        _arrFarms=[[NSMutableArray alloc]init];
        //***code change for new webservice by M.
        NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:@"farmname"
                                                               ascending:YES];
        //***end By M.
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
        NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Farms" andPredicate:nil andSortDescriptors:sortDescriptors];
        // NSLog(@"resultArray=%@",resultArray);
        
        for (int count=0; count<resultArray.count; count++) {
            @autoreleasepool {
                NSMutableDictionary *dictFarm = [[NSMutableDictionary alloc]init];
                //***code change for new webservice by M.
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"farmcode"] forKey:@"f_No"];
                //[dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"f_nm"] forKey:@"f_nm"];
                ///*** code below changed --key changed from "f_nm" dex for Bug- 27354 By M.
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"des"] forKey:@"f_nm"];
                ///*** end by M.
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"sitekey"] forKey:@"id"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"zerodate"] forKey:@"ZD"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexliveborn"] forKey:@"SSL"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexweaned"] forKey:@"SSW"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                
                //*** end By M.
                //***code added for Splitsex funcationaly Bug-27775 by M @@@@@
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                //@@@@@
                [_arrFarms addObject:dictFarm];
            }
        }
        
        //^^^commented below for Bug-28952 By M.
        if (_arrFarms.count>1) { //^^^^^ uncommented this for Bug-29001 By M.
       // if (_arrFarms.count>=1) { //^^^^^ for single  farm related issuess by M. but this will redirect to Farmsslection though ony one farm is set to the user.
            NSString *strFarm = [[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"]:@"";

            if (strFarm.length==0){
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"f_No"] forKey:@"f_No"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"id"] forKey:@"id"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"f_nm"] forKey:@"f_nm"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"ZD"] forKey:@"ZD"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"SSL"] forKey:@"SSL"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"SSW"] forKey:@"SSW"];
                //*** code added below for new keys as per CoreData Model for New webservice by M.
                
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                 //***end By M.
                //***code added for Splitsex funcationaly Bug-27775 by M @@@@@
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                //@@@@@
                [_pref synchronize];
            }else{
                //code added for Bug-29361 By M.
                for (int count=0; count<_arrFarms.count; count++) {
                    if([[[self.arrFarms objectAtIndex:count] valueForKey:@"f_nm"] isEqualToString: strFarm]){
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"f_No"] forKey:@"f_No"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"id"] forKey:@"id"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"f_nm"] forKey:@"f_nm"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"ZD"] forKey:@"ZD"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"SSL"] forKey:@"SSL"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"SSW"] forKey:@"SSW"];
                        
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                        
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                        [_pref setValue:[[self.arrFarms objectAtIndex:count] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                        
                        [_pref synchronize];
                    }
                }
            }

           [self.btnFarmSelection setTitle:[_pref valueForKey:@"f_nm"] forState:UIControlStateNormal];
            //[self btnSubmit_tapped:nil];
        }
        
//        //Changed by Priyanka on 15thOct for farms conflict btwn staging and production
//        if (_arrFarms.count>1) {
//                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"f_No"] forKey:@"f_No"];
//                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"id"] forKey:@"id"];
//                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"f_nm"] forKey:@"f_nm"];
//                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"ZD"] forKey:@"ZD"];
//                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"SSL"] forKey:@"SSL"];
//                [_pref setValue:[[self.arrFarms objectAtIndex:0] valueForKey:@"SSW"] forKey:@"SSW"];
//                [_pref synchronize];
//
//            [self.btnFarmSelection setTitle:[_pref valueForKey:@"f_nm"] forState:UIControlStateNormal];
//        }
        ///*** code below changed --key changed from "f_nm" des for Bug- 27354 By M.
        // Create a sort descriptor
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"f_No" ascending:YES selector:@selector(localizedStandardCompare:)];

        // Sort the array using the sort descriptor
        NSMutableArray *sortedArray1 = _arrFarms;
        _arrFarms = [sortedArray1 sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        ///*** end By M.
        NSLog(@"_arrFarms = %@",_arrFarms);
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    @try {
        NSLog(@"PrePare for segue");
        // InitialViewController *toDoViewController = segue.destinationViewController;
        //toDoViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"segueDataEntry"];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in prepareForSegue in FarmSelection =%@",exception.description);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------
#pragma mark - picker methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    @try {
        
        return 1;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in numberOfComponentsInPickerView in FArm Selection =%@",exception.description);
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    @try
    {
        if (pickerView==self.pickerDropDown)
        {
            return [_arrFarms count];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in numberOfRowsInComponent- %@",[exception description]);
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    @try
    {
//        [[self.pickerDropDown.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerDropDown.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        if (pickerView==self.pickerDropDown)
        {
            return [_arrFarms objectAtIndex:row];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in titleForRow- %@",[exception description]);
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    @try {
        //
//        [[self.pickerDropDown.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerDropDown.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        NSString *strPrevSelectedValue= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] ?[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] :@""];
        NSInteger prevSelectedIndex=0;
        
        for (int count=0; count<_arrFarms.count; count++) {
            if (strPrevSelectedValue.length>0){
                if ([strPrevSelectedValue integerValue] == [[[_arrFarms objectAtIndex:count] valueForKey:@"id"] integerValue]){
                    prevSelectedIndex = count;
                }
            }
        }
        //
        
        UILabel *lblSortText = (id)view;
        
        if (!lblSortText) {
            lblSortText= [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, [pickerView rowSizeForComponent:component].width-15, [pickerView rowSizeForComponent:component].height)];
        }
        
        lblSortText.font = [UIFont boldSystemFontOfSize:13];
        lblSortText.textAlignment = NSTextAlignmentCenter;
        lblSortText.tintColor = [UIColor clearColor];
        
        if (prevSelectedIndex==row) {
            lblSortText.textColor = [UIColor redColor];
        }else
        {
            lblSortText.textColor = [UIColor darkGrayColor];
        }
        
        if (pickerView==self.pickerDropDown) {
            lblSortText.text = [[_arrFarms objectAtIndex:row] valueForKey:@"f_nm"];
            return lblSortText;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in viewForRow- %@",[exception description]);
    }
    return 0;
}

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#pragma mark - Other methods
- (IBAction)btnSubmit_tapped:(id)sender {
    @try {
        NSString *strTitle= [self.btnFarmSelection titleForState:UIControlStateNormal];
        if (strTitle.length!=0) {
            [self callFarmSelectionWebService:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]isFromSubmit:YES];
        }else{
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:strSelectFarm
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOK
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnSubmit_tapped =%@",exception.description);
    }
}

- (IBAction)btnSelectFarm_tapped:(id)sender {
    @try {
        self.pickerDropDown = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 10, 270, 150.0)];
        [self.pickerDropDown setDelegate:self];
        // self.pickerDropDown.showsSelectionIndicator = YES;
        [self.pickerDropDown setShowsSelectionIndicator:YES];
        
        _alertForFarmSelection = [[CustomIOS7AlertView alloc] init];
        [_alertForFarmSelection setMyDelegate:self];
        [_alertForFarmSelection setUseMotionEffects:true];
        [_alertForFarmSelection setButtonTitles:[NSMutableArray arrayWithObjects:strOK,strCancel, nil]];
        
        __weak typeof(self) weakSelf = self;
        
        [_alertForFarmSelection setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex){
            
            if(buttonIndex == 0) {
                NSInteger row = [weakSelf.pickerDropDown selectedRowInComponent:0];
                
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"id"] forKey:@"id"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"f_nm"] forKey:@"f_nm"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"ZD"] forKey:@"ZD"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"SSL"] forKey:@"SSL"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"SSW"] forKey:@"SSW"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                              
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                //***  added code for other values of farms Bug-27775 By M.@@@@@
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                              
                [weakSelf.pref setValue:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                    //@@@@@
                [weakSelf.btnFarmSelection setTitle:[[weakSelf.arrFarms objectAtIndex:row] valueForKey:@"f_nm"] forState:UIControlStateNormal];
                
                [weakSelf.pref synchronize];
            }
            
            [weakSelf.alertForFarmSelection close];
        }];
        
        NSString *strPrevSelectedValue= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] ?[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] :@""];
        NSInteger prevSelectedIndex=0;
        
        for (int count=0; count<_arrFarms.count; count++) {
            if (strPrevSelectedValue.length>0){
                if ([strPrevSelectedValue integerValue] == [[[_arrFarms objectAtIndex:count] valueForKey:@"id"] integerValue]){
                    prevSelectedIndex = count;
                }
            }
        }
        
        if (_arrFarms.count>=prevSelectedIndex) {
            [self.pickerDropDown selectRow:prevSelectedIndex inComponent:0 animated:NO];
        }
        
        [self.pickerDropDown setShowsSelectionIndicator:YES];
        
        
        [weakSelf.alertForFarmSelection showCustomwithView:self.pickerDropDown title:strFarms];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in btnSelectFarm_tapped=%@",exception.description);
    }
}

-(void)callFarmSelectionWebService:(NSString*)selectedSiteId isFromSubmit:(BOOL)isFromSubmit{
    @try {
        if ([[ControlSettings sharedSettings] isNetConnected ]) {
            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
            [_customIOS7AlertView showLoaderWithMessage:strWait];
            
            [ServerManager sendRequestForFarmSelection:selectedSiteId onSucess:^(NSString *responseData) {
                //
                
                if ([responseData isEqualToString:@"\"Farm is changed\""]){
                    //_customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                    // [_customIOS7AlertView showLoaderWithMessage:strLoading];
                    
                    [ServerManager sendRequestForSysLookup:^(NSString *responseData) {
                        [_customIOS7AlertView close];
                        
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                        {
                            if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                            {
                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                           message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                UIView *controllerView = myAlertController.view;
                                [controllerView addSubview:logoImageView];
                                [controllerView bringSubviewToFront:logoImageView];
                                UIAlertAction* ok = [UIAlertAction
                                                     actionWithTitle:strOK
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                     }];
                                
                                [myAlertController addAction: ok];
                                [self presentViewController:myAlertController animated:YES completion:nil];
                            }
                            else if ([responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                            {
                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                           message:[self getTranslatedTextForString:@"Token not found"]
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                UIView *controllerView = myAlertController.view;
                                [controllerView addSubview:logoImageView];
                                [controllerView bringSubviewToFront:logoImageView];
                                UIAlertAction* ok = [UIAlertAction
                                                     actionWithTitle:strOK
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                     }];
                                
                                [myAlertController addAction: ok];
                                [self presentViewController:myAlertController animated:YES completion:nil];
                            }
                        }else{
                            NSArray *adminRoutes;
                            if (![[dict objectForKey:@"_ADMIN_ROUTES"] isKindOfClass:[NSNull class]])
                            {
                                adminRoutes = [dict objectForKey:@"_ADMIN_ROUTES"];
                            }
                            
                            NSArray *aistuds;
                            if (![[dict objectForKey:@"_AI_STUDS"] isKindOfClass:[NSNull class]])
                            {
                                aistuds= [dict objectForKey:@"_AI_STUDS"]?[dict objectForKey:@"_AI_STUDS"]:@"";
                            }
                            
                            NSArray *halothane;
                            if (![[dict objectForKey:@"_Halothane"] isKindOfClass:[NSNull class]])
                            {
                                halothane = [dict objectForKey:@"_Halothane"];
                            }
                            
                            NSArray *pdResults;
                            if (![[dict objectForKey:@"_PD_RESULTS"] isKindOfClass:[NSNull class]])
                            {
                                pdResults = [dict objectForKey:@"_PD_RESULTS"];
                            }
                            //***code changed below from sex to piglet_sex for Bug-29678 and 29643 By M.
                            NSArray *sex;
                            if (![[dict objectForKey:@"_PIGLET_SEX"] isKindOfClass:[NSNull class]])
                            {
                                sex = [dict objectForKey:@"_PIGLET_SEX"];
                            }
                            //~~~~~ for piglet_identities By M.
                            NSArray *color;
                            if (![[dict objectForKey:@"_PIGLET_COLOR"] isKindOfClass:[NSNull class]])
                            {
                                color = [dict objectForKey:@"_PIGLET_COLOR"];
                            }
                            NSArray *designation;
                            if (![[dict objectForKey:@"_DESIGNATION"] isKindOfClass:[NSNull class]])
                            {
                                designation = [dict objectForKey:@"_DESIGNATION"];
                            }
                            //~~~~~~end of M.
                            NSArray *tod;
                            if (![[dict objectForKey:@"_TOD"] isKindOfClass:[NSNull class]])
                            {
                                tod = [dict objectForKey:@"_TOD"];
                            }
                            
                            NSArray *dataEntryItemsArray;
                            if (![[dict objectForKey:@"_DATA_ENTRY_ITEMS"] isKindOfClass:[NSNull class]])
                            {
                                dataEntryItemsArray = [dict objectForKey:@"_DATA_ENTRY_ITEMS"];
                            }
                            
                            NSMutableArray *arrFilteredDestination = [[NSMutableArray alloc]init];
                            NSArray* destinartionArray;
                            if (![[dict objectForKey:@"_DESTINATION"] isKindOfClass:[NSNull class]])
                            {
                                destinartionArray = [dict objectForKey:@"_DESTINATION"];
                                //
                                @try {
                                    for (NSDictionary *dict in destinartionArray)
                                    {
                                        //***changed below key  got changed in Json response and  casue of crash in Testflight By M.
                                        NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                                        [dt setValue:[dict objectForKey:@"Ds"] forKey:@"Ds"];
                                        //[dt setValue:[dict valueForKey:@"fC"] forKey:@"fC"];
                                        [dt setValue:[dict valueForKey:@"FC"] forKey:@"fC"];
                                        [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                                        //[dt setValue:[dict valueForKey:@"zD"] forKey:@"zD"];
                                        [dt setValue:[dict valueForKey:@"ZD"] forKey:@"zD"];
                                        
                                        [arrFilteredDestination addObject:dt];
                                    }
                                }
                                @catch (NSException *exception) {
                                    NSLog(@"Exception =%@",exception.description);
                                }
                            }
                            
                            //discription
                            NSMutableArray *arrFilteredOrigin = [[NSMutableArray alloc]init];
                            
                            NSArray* originArray;
                            if (![[dict objectForKey:@"_ORIGIN"] isKindOfClass:[NSNull class]])
                            {
                                originArray = [dict objectForKey:@"_ORIGIN"];
                                
                                @try {
                                    for (NSDictionary *dict in originArray)
                                    {
                                       // ***changed below key key got changed in Json response and   casue of crash in Testflight By M.
                                        NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                                        [dt setValue:[dict objectForKey:@"Ds"] forKey:@"Ds"];
                                        //[dt setValue:[dict valueForKey:@"fC"] forKey:@"fC"];
                                        [dt setValue:[dict valueForKey:@"FC"] forKey:@"fC"];
                                        [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                                       // [dt setValue:[dict valueForKey:@"zD"] forKey:@"zD"];
                                        [dt setValue:[dict valueForKey:@"ZD"] forKey:@"zD"];
                                        
                                        [arrFilteredOrigin addObject:dt];
                                    }
                                }
                                @catch (NSException *exception) {
                                    NSLog(@"Exception =%@",exception.description);
                                }
                            }
                            
                            NSArray *geneticsArray;
                            if (![[dict objectForKey:@"_GENETICS"] isKindOfClass:[NSNull class]]) {
                                geneticsArray = [dict objectForKey:@"_GENETICS"];
                            }
                            
                            NSArray* conditionsArray;
                            if (![[dict objectForKey:@"_CONDITIONS"] isKindOfClass:[NSNull class]]){
                                conditionsArray = [dict objectForKey:@"_CONDITIONS"];
                            }
                            
                            NSArray* conditionsScoreArray;
                            if (![[dict objectForKey:@"_ConditionScore"] isKindOfClass:[NSNull class]]){
                                conditionsScoreArray = [dict objectForKey:@"_ConditionScore"];
                            }
                            //***added below for Piglet Defect data entry - Defects-List Bug- 28548 By M.
                            NSArray* pigletDefectsArray;
                            if (![[dict objectForKey:@"_PIGLET_DEFECTS"] isKindOfClass:[NSNull class]]){
                                pigletDefectsArray = [dict objectForKey:@"_PIGLET_DEFECTS"];
                            }
                            NSArray* _herdCategoryArray;
                            if (![[dict objectForKey:@"_HerdCategory"] isKindOfClass:[NSNull class]]){
                                _herdCategoryArray = [dict objectForKey:@"_HerdCategory"];
                            }
                            
                            //
                            NSArray* _LesionScoreArray;
                            if (![[dict objectForKey:@"_LESION_SCORES"] isKindOfClass:[NSNull class]]){
                                _LesionScoreArray = [dict objectForKey:@"_LESION_SCORES"];
                            }
                            
                            NSArray* _LockArray;
                            if (![[dict objectForKey:@"_MATINGLOCK"] isKindOfClass:[NSNull class]]){
                                _LockArray = [dict objectForKey:@"_MATINGLOCK"];
                            }
                            
                            NSArray* _LeakageArray;
                            if (![[dict objectForKey:@"_MATINGLEAK"] isKindOfClass:[NSNull class]]){
                                _LeakageArray = [dict objectForKey:@"_MATINGLEAK"];
                            }
                            
                            NSArray* _QualityArray;
                            if (![[dict objectForKey:@"_MATINGQUALITY"] isKindOfClass:[NSNull class]]){
                                _QualityArray = [dict objectForKey:@"_MATINGQUALITY"];
                            }
                            
                            NSArray* _StandingReflexArray;
                            if (![[dict objectForKey:@"_MATINGSTANDREFLEX"] isKindOfClass:[NSNull class]]){
                                _StandingReflexArray = [dict objectForKey:@"_MATINGSTANDREFLEX"];
                            }
                            
                            NSArray* _TestTypeArray;
                            if (![[dict objectForKey:@"_TESTTYPE"] isKindOfClass:[NSNull class]]){
                                _TestTypeArray = [dict objectForKey:@"_TESTTYPE"];
                            }
                            //
                            
                            NSArray* flagsArray;
                            if (![[dict objectForKey:@"_FLAGS"] isKindOfClass:[NSNull class]]){
                                flagsArray = [dict objectForKey:@"_FLAGS"];
                            }
                            
                            NSArray* transportCompaniesArray;
                            if (![[dict objectForKey:@"_TRANSPORT_COMPANIES"] isKindOfClass:[NSNull class]]){
                                transportCompaniesArray = [dict objectForKey:@"_TRANSPORT_COMPANIES"];
                            }
                            // new additions
                            NSArray* operatorArray;
                            if (![[dict objectForKey:@"_Operators"] isKindOfClass:[NSNull class]]){
                                operatorArray = [dict objectForKey:@"_Operators"];
                            }
                            
                            NSArray *locationsArray;
                            if (![[dict objectForKey:@"_LOCATIONS"] isKindOfClass:[NSNull class]]){
                                locationsArray = [dict objectForKey:@"_LOCATIONS"];
                            }
                            
                            NSArray* treatmentsArray;
                            if (![[dict objectForKey:@"_TREATMENTS"] isKindOfClass:[NSNull class]]){
                                treatmentsArray = [dict objectForKey:@"_TREATMENTS"];
                            }
                            
                            NSArray* packingPlantsArray;
                            
                            if (![[dict objectForKey:@"_PACKING_PLANTS"] isKindOfClass:[NSNull class]]){
                                packingPlantsArray = [dict objectForKey:@"_PACKING_PLANTS"];//Added as sandip told
                            }
                            
                            //[[CoreDataHandler sharedHandler] removeAllmanagedObject];
                            
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Data_Entry_Items"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Admin_Routes"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Halothane"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Pd_Results"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Sex"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Tod"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Origin"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Destination"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"ConditionScore"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Operator"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Locations"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Treatments"];
                            [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Packing_Plants"];//Added as sandip told
                            //***added for logout changes Bug-27775 by M @@@@@
                               [[CoreDataHandler sharedHandler] deleteManagedObjectContexFromDefaultMOC:@"Farms"];
                            //@@@@@
                            if (dataEntryItemsArray.count==0) {
                                
                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                           message:@"Please login again."
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                UIView *controllerView = myAlertController.view;
                                [controllerView addSubview:logoImageView];
                                [controllerView bringSubviewToFront:logoImageView];
                                UIAlertAction* ok = [UIAlertAction
                                                     actionWithTitle:strOK
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //[[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                         {
                                                             if ([[ControlSettings sharedSettings] isNetConnected ]){
                                                                 _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                                                                 [_customIOS7AlertView showLoaderWithMessage:strSignOff];
                                                                 
                                                                 [ServerManager sendRequestForLogout:^(NSString *responseData) {
                                                                     NSLog(@"%@",responseData);
                                                                     [_customIOS7AlertView close];
                                                                     
                                                                     if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])  {
                                                                         //[[NSNotificationCenter defaultCenter]postNotificationName:@"CloseAlert" object:responseData];
                                                                         
                                                                         //                                             UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                         //                                                                                                                        message:responseData
                                                                         //                                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                                                         //                                             UIAlertAction* ok = [UIAlertAction
                                                                         //                                                                  actionWithTitle:strOK
                                                                         //                                                                  style:UIAlertActionStyleDefault
                                                                         //                                                                  handler:^(UIAlertAction * action)                                                              {
                                                                         //
                                                                         //
                                                                         //                                                                      [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                                         //                                                                      //[self.navigationController popToRootViewControllerAnimated:YES];
                                                                         //                                                                      [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                         //                                                                  }];
                                                                         //
                                                                         //                                             [myAlertController addAction: ok];
                                                                         //                                             [self presentViewController:myAlertController animated:YES completion:nil];
                                                                     }else if ([responseData isEqualToString:@"\"Loged out\""] || [responseData isEqualToString:@""]){
                                                                         [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                                     }
                                                                 } onFailure:^(NSString *responseData, NSError *error) {
                                                                     id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                                                     NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                                                                     [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                                     NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                                                                     
                                                                     NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,On log out=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate, self.title];
                                                                     [tracker set:kGAIScreenName value:strErr];
                                                                     [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                                                                     
                                                                     [[NSNotificationCenter defaultCenter]postNotificationName:@"CloseAlert" object:responseData];
                                                                     
                                                                     /*
                                                                      if (responseData.integerValue ==401) {
                                                                      
                                                                      UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                      message:strUnauthorised
                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                                                      UIAlertAction* ok = [UIAlertAction
                                                                      actionWithTitle:strOK
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                      [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                                      [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                      }];
                                                                      
                                                                      [myAlertController addAction: ok];
                                                                      [self presentViewController:myAlertController animated:YES completion:nil];
                                                                      
                                                                      }else {
                                                                      // [self.navigationController popToRootViewControllerAnimated:YES];
                                                                      
                                                                      //                                             UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                      //                                                                                                                        message:strServerErr
                                                                      //                                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                                                      //                                             UIAlertAction* ok = [UIAlertAction
                                                                      //                                                                  actionWithTitle:strOK
                                                                      //                                                                  style:UIAlertActionStyleDefault
                                                                      //                                                                  handler:^(UIAlertAction * action) {
                                                                      //                                                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                                                      //                                                                      [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                      //                                                                  }];
                                                                      //
                                                                      //                                             [myAlertController addAction: ok];
                                                                      //                                             [self presentViewController:myAlertController animated:YES completion:nil];
                                                                      }
                                                                      */
                                                                     
                                                                     [_customIOS7AlertView close];
                                                                 }];
                                                             }
                                                             else {
                                                                 UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                                            message:strNoInternet
                                                                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                                                 UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                                                 logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                                                 UIView *controllerView = myAlertController.view;
                                                                 [controllerView addSubview:logoImageView];
                                                                 [controllerView bringSubviewToFront:logoImageView];
                                                                 UIAlertAction* ok = [UIAlertAction
                                                                                      actionWithTitle:strOK
                                                                                      style:UIAlertActionStyleDefault
                                                                                      handler:^(UIAlertAction * action)
                                                                                      {
                                                                                          [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                                      }];
                                                                 
                                                                 [myAlertController addAction: ok];
                                                                 [self presentViewController:myAlertController animated:YES completion:nil];
                                                             }
                                                             
                                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                         }
                                                     }];
                                
                                [myAlertController addAction: ok];
                                [self presentViewController:myAlertController animated:YES completion:nil];
                            }else{
                                //~~~~added new params for Color and DEsignation for pigletidentities By M.
                                @try {
                                    BOOL isSucess = [[CoreDataHandler sharedHandler] insertBulkValuesWithCommonLookupArray:nil andFarmsArray:nil andDataEntryArray:dataEntryItemsArray andGeneticsArray:geneticsArray andUserParameters:nil andLocations:locationsArray andOperatorArray:operatorArray andBreedingComapniesArray:nil andCondistionsArray:conditionsArray andFlagsArray:flagsArray andTransportArray:transportCompaniesArray andPackingPlantsArray:packingPlantsArray andTreatmentsArray:treatmentsArray andAdminRoutes:adminRoutes andAiStuds:aistuds andHalothane:halothane andPdResults:pdResults andSex:sex andColor:color andDesignation:designation andTod:tod andOrigin:arrFilteredOrigin andDestination:arrFilteredDestination translated:nil conditionScore:conditionsScoreArray pigletDefects:pigletDefectsArray herdCategory:_herdCategoryArray lesionScoreArray:_LesionScoreArray lockArray:_LockArray leakageArray:_LeakageArray qualityArray:_QualityArray standingReflexArray:_StandingReflexArray testTypeArray:_TestTypeArray];
                                    //_LesionScoreArray; _LockArray _LeakageArray _QualityArray _StandingReflexArray _TestTypeArray
                                    
                                    if (isSucess && isFromSubmit){
                                        [self performSegueWithIdentifier:@"segueFarmSelection" sender:self];
                                    }
                                }
                                @catch (NSException *exception) {
                                    
                                    NSLog(@"Exception =%@",exception.description);
                                }
                            }
                        }
                    } onFailure:^(NSString *responseData, NSError *error) {
                        [_customIOS7AlertView close];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        //
                        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                        [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                        
                        NSString *strErr = [NSString stringWithFormat:@"User Name = %@,,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Farm Selection"];
                        [tracker set:kGAIScreenName value:strErr];
                        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                        
                        if (responseData.integerValue ==401) {
                            
                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                       message:strUnauthorised
                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                            UIView *controllerView = myAlertController.view;
                            [controllerView addSubview:logoImageView];
                            [controllerView bringSubviewToFront:logoImageView];
                            UIAlertAction* ok = [UIAlertAction
                                                 actionWithTitle:strOK
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                 }];
                            
                            [myAlertController addAction: ok];
                            [self presentViewController:myAlertController animated:YES completion:nil];
                            
                            // [self.navigationController popToRootViewControllerAnimated:YES];
                        }else{
                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                       message:responseData
                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                            UIView *controllerView = myAlertController.view;
                            [controllerView addSubview:logoImageView];
                            [controllerView bringSubviewToFront:logoImageView];
                            UIAlertAction* ok = [UIAlertAction
                                                 actionWithTitle:strOK
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     //[self.navigationController popToRootViewControllerAnimated:YES];
                                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                 }];
                            
                            [myAlertController addAction: ok];
                            [self presentViewController:myAlertController animated:YES completion:nil];
                        }
                        
                    }];
                }
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                {
                    [_customIOS7AlertView close];
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOK
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
                else if ([responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                {
                    [_customIOS7AlertView close];
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[self getTranslatedTextForString:@"Token not found"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOK
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
            } onFailure:^(NSString *responseData, NSError *error) {
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                //
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,@"Farm Selection SCreen"];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                
                if (responseData.integerValue ==401) {
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strUnauthorised
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOK
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    
                    //[self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strServerErr
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOK
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             //[self.navigationController popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
                
                [_customIOS7AlertView close];
            }];
        }
        else{
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"You must be online for the app to function."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOK
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in callFarmSelectionWebService=%@",exception.description);
    }
}
-(NSString*)getTranslatedTextForString:(NSString*)Checkstring
{
    NSString *strSearchTitle;
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:Checkstring,nil]];
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    if (resultArray1.count!=0){
        for (int i=0; i<resultArray1.count; i++){
            [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
        }
        for (int i=0; i<1; i++) {
            if (i==0)
            {
                if ([dictMenu objectForKey:[Checkstring uppercaseString]] && ![[dictMenu objectForKey:[Checkstring uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[Checkstring uppercaseString]] length]>0) {
                        strSearchTitle = [dictMenu objectForKey:[Checkstring uppercaseString]]?[dictMenu objectForKey:[Checkstring uppercaseString]]:@"";
                    }
                    else
                    {
                        strSearchTitle = Checkstring;
                    }
                }
            }
        }
    }
    else
    {
        strSearchTitle = Checkstring;
    }
    return strSearchTitle;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_customIOS7AlertView close];
    [_alertForFarmSelection close];
    [_pickerDropDown setHidden:YES];
}
@end
