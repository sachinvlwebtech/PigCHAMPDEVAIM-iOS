//
//  ReportsInput.m
//  PigChamp
//
//  Created by Venturelabour on 05/02/16.
//  Copyright © 2016 Venturelabour. All rights reserved.
//

#import "ReportsInput.h"
#import "CoreDataHandler.h"
#import "ActiveAnimalListViewController.h"
#import "ProductionsummaryViewController.h"
#import <Google/Analytics.h>

BOOL isOpenReportInput = NO;
BOOL isThousandFormatReport = NO;

@interface ReportsInput ()
{
    NSMutableArray *arrTemp;
    UITextField *txtDynamic;
    NSMutableDictionary * dictDynamicCopyToSend;
    NSString* fullDataString;
}
@property(nonatomic, strong) IBOutlet EAAccessory *accessory;
@property(nonatomic) uint32_t totalBytesRead;
@property (nonatomic, strong) EADSessionController *eaSessionController;

@end

@implementation ReportsInput

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnAccessory.layer.cornerRadius = 15;
    self.btnAccessory.clipsToBounds = true;
    
    self.btnAccessory.hidden = YES;
    
    if ([self.strEvent isEqualToString:@"3"])
    {
        self.btnAccessory.hidden = NO;
    }
    
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryConnectedOnReports:)
                                                 name:EAAccessoryDidConnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDisconnectedOnReports:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceivedOnReports:) name:EADSessionDataReceivedOnReportsNotification object:nil];
    
    arrTemp =[[NSMutableArray alloc]init];//3,5
    dictDynamicCopyToSend = [[NSMutableDictionary alloc]init];
    
    NSArray *arrUserParameter = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"User_Parameters" andPredicate:nil andSortDescriptors:nil];
    
    for (int count=0; count<arrUserParameter.count; count++){
        if ([[[arrUserParameter objectAtIndex:count] valueForKey:@"nm"]  isEqualToString:@"DateUsageFormat"]){
            _strDateFormat = [[arrUserParameter objectAtIndex:count] valueForKey:@"val"];
        }
    }
    
    if ([self.strDateFormat isEqualToString:@"1"]) {
        isThousandFormatReport = YES;
    }else {
        isThousandFormatReport = NO;
    }
    
    NSLog(@"_strDateFormat=%@",_strDateFormat);
    //
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setValue:@"0" forKey:@"reload"];
    [pref synchronize];
    self.navigationController.navigationBar.translucent = NO;
    
    _btnRunReport.layer.shadowColor = [[UIColor grayColor] CGColor];
    _btnRunReport.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    _btnRunReport.layer.shadowOpacity = 1.0f;
    _btnRunReport.layer.shadowRadius = 3.0f;
    
    _btnCancel.layer.shadowColor = [[UIColor grayColor] CGColor];
    _btnCancel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    _btnCancel.layer.shadowOpacity = 1.0f;
    _btnCancel.layer.shadowRadius = 3.0f;
    
    
    _arrDynamicReport = [[NSMutableArray alloc]init];
    _arrDropDownReport = [[NSMutableArray alloc]init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(-20, 0, 22, 22);
    [button setBackgroundImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnBack_tapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    self.navigationItem.leftBarButtonItem=barButton;
    
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"CLEAr",@"SaVE",@"Yes",@"No",@"Ok",@"Cancel",@"Please Wait...",@"Your session has been expired. Please login again.",@"Server Error.",@"Run Report",@"You must enter a value for animal Identity.",@"Status",@"Date From should be smaller than To Date.",@"Date range should be within 6 months.",@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date.",@"Please select Start Date less than or equal to current date.",@"Please select End Date greater than or equal Start Date.",nil]];
    
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    
    strYes = @"Yes";
    strNo = @"No";
    strOk = @"OK";
    strCancel = @"CANCEL";
    strWait = @"Please Wait...";
    strNoInternet = @"You must be online for the app to function.";
    strIdentity = @"You must enter a value for animal Identity.";
    strUnauthorised = @"Your session has been expired. Please login again.";
    strServerErr  = @"Server Error.";
    strRunReport = @"RUN REPORT";
    strStatus = @"Status";
    strDateRangeMessage = @"Date From should be smaller than To Date.";
    strDateRange6Months = @"Date range should be within 6 months.";
    strDateCompareMsg =@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date.";
    strDateLessThanCurrentMsg = @"Please select Start Date less than or equal to current date.";
    strDateGreaterMsg = @"Please select End Date greater than or equal Start Date.";
    if (resultArray1.count!=0){
        for (int i=0; i<resultArray1.count; i++){
            [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
        }
        
        for (int i=0; i<18; i++) {
            if (i==0) {
                NSString *strSearchTitle;
                if ([dictMenu objectForKey:@"CLEAR"] && ![[dictMenu objectForKey:@"CLEAR"] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:@"CLEAR"] length]>0) {
                        strSearchTitle = [dictMenu objectForKey:@"CLEAR"]?[dictMenu objectForKey:@"CLEAR"]:@"";
                    }else{
                        strSearchTitle = @"CLEAR";
                    }
                }
                else{
                    strSearchTitle = @"CLEAR";
                }
                
                [self.btnClear setTitle:strSearchTitle forState:UIControlStateNormal];
            }else  if (i==1){
                NSString *strSearchTitle;
                if ([dictMenu objectForKey:@"SAVE"] && ![[dictMenu objectForKey:@"SAVE"] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:@"SAVE"] length]>0) {
                        strSearchTitle = [dictMenu objectForKey:@"SAVE"]?[dictMenu objectForKey:@"SAVE"]:@"";
                    }else{
                        strSearchTitle = @"SAVE";
                    }
                }
                else{
                    strSearchTitle = @"SAVE";
                }
                
                [self.btnSave setTitle:strSearchTitle forState:UIControlStateNormal];
            }else  if (i==2){
                if ([dictMenu objectForKey:[@"Yes" uppercaseString]] && ![[dictMenu objectForKey:[@"Yes" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Yes" uppercaseString]] length]>0) {
                        strYes = [dictMenu objectForKey:[@"Yes" uppercaseString]]?[dictMenu objectForKey:[@"Yes" uppercaseString]]:@"";
                    }
                }
            }else  if (i==3){
                if ([dictMenu objectForKey:[@"No" uppercaseString]] && ![[dictMenu objectForKey:[@"No" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"No" uppercaseString]] length]>0) {
                        strNo = [dictMenu objectForKey:[@"No" uppercaseString]]?[dictMenu objectForKey:[@"No" uppercaseString]]:@"";
                    }
                }
            }else  if (i==4){
                if ([dictMenu objectForKey:[@"Ok" uppercaseString]] && ![[dictMenu objectForKey:[@"Ok" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Ok" uppercaseString]] length]>0) {
                        strOk = [dictMenu objectForKey:[@"Ok" uppercaseString]]?[dictMenu objectForKey:[@"Ok" uppercaseString]]:@"";
                    }
                }
            }else  if (i==5){
                if ([dictMenu objectForKey:[@"Cancel" uppercaseString]] && ![[dictMenu objectForKey:[@"Cancel" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Cancel" uppercaseString]] length]>0) {
                        strCancel = [dictMenu objectForKey:[@"Cancel" uppercaseString]]?[dictMenu objectForKey:[@"Cancel" uppercaseString]]:@"";
                    }
                }
                [self.btnCancel setTitle:strCancel forState:UIControlStateNormal];
            }else  if (i==6){
                if ([dictMenu objectForKey:[@"Please Wait..." uppercaseString]] && ![[dictMenu objectForKey:[@"Please Wait..." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Please Wait..." uppercaseString]] length]>0) {
                        strWait = [dictMenu objectForKey:[@"Please Wait..." uppercaseString]]?[dictMenu objectForKey:[@"Please Wait..." uppercaseString]]:@"";
                    }
                }
            }else  if (i==7){
                if ([dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] && ![[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] length]>0) {
                        strNoInternet = [dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]?[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]:@"";
                    }
                }
            }else  if (i==8){
                if ([dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]] && ![[dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]] length]>0) {
                        strIdentity = [dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]]?[dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]]:@"";
                    }
                }
            }else  if (i==9){
                if ([dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] && ![[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] length]>0) {
                        strUnauthorised = [dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]?[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]:@"";
                    }
                }
            }else  if (i==10){
                if ([dictMenu objectForKey:[@"Server Error." uppercaseString]] && ![[dictMenu objectForKey:[@"Server Error." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Server Error." uppercaseString]] length]>0) {
                        strServerErr = [dictMenu objectForKey:[@"Server Error." uppercaseString]]?[dictMenu objectForKey:[@"Server Error." uppercaseString]]:@"";
                    }
                }
            }
            else  if (i==11){
                if ([dictMenu objectForKey:[@"Run Report" uppercaseString]] && ![[dictMenu objectForKey:[@"Run Report" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Run Report" uppercaseString]] length]>0) {
                        strRunReport = [dictMenu objectForKey:[@"Run Report" uppercaseString]]?[dictMenu objectForKey:[@"Run Report" uppercaseString]]:@"";
                    }
                }
                [self.btnRunReport setTitle:strRunReport forState:UIControlStateNormal];
            }
            else  if (i==12){
                if ([dictMenu objectForKey:[@"Status" uppercaseString]] && ![[dictMenu objectForKey:[@"Status" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Status" uppercaseString]] length]>0) {
                        strStatus = [dictMenu objectForKey:[@"Status" uppercaseString]]?[dictMenu objectForKey:[@"Status" uppercaseString]]:@"";
                    }
                }
            }else  if (i==13){
                if ([dictMenu objectForKey:[@"Date From should be smaller than To Date." uppercaseString]] && ![[dictMenu objectForKey:[@"Date From should be smaller than To Date." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Date From should be smaller than To Date." uppercaseString]] length]>0) {
                        strDateRangeMessage = [dictMenu objectForKey:[@"Date From should be smaller than To Date." uppercaseString]]?[dictMenu objectForKey:[@"Date From should be smaller than To Date." uppercaseString]]:@"";
                    }
                }
            }else  if (i==14){
                if ([dictMenu objectForKey:[@"Date range should be within 6 months." uppercaseString]] && ![[dictMenu objectForKey:[@"Date range should be within 6 months." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Date range should be within 6 months." uppercaseString]] length]>0) {
                        strDateRange6Months = [dictMenu objectForKey:[@"Date range should be within 6 months." uppercaseString]]?[dictMenu objectForKey:[@"Date range should be within 6 months." uppercaseString]]:@"";
                    }
                }
            }else  if (i==15){
                if ([dictMenu objectForKey:[@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date." uppercaseString]] && ![[dictMenu objectForKey:[@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date." uppercaseString]] length]>0) {
                        strDateCompareMsg = [dictMenu objectForKey:[@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date." uppercaseString]]?[dictMenu objectForKey:[@"Please select Due to Farrow End Date greater than or equal to Due to Farrow Start Date." uppercaseString]]:@"";
                    }
                }
            }else  if (i==16){
                if ([dictMenu objectForKey:[@"Please select Start Date less than or equal to current date." uppercaseString]] && ![[dictMenu objectForKey:[@"Please select Start Date less than or equal to current date." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Please select Start Date less than or equal to current date." uppercaseString]] length]>0) {
                        strDateLessThanCurrentMsg = [dictMenu objectForKey:[@"Please select Start Date less than or equal to current date." uppercaseString]]?[dictMenu objectForKey:[@"Please select Start Date less than or equal to current date." uppercaseString]]:@"";
                    }
                }
            }else  if (i==17){
                if ([dictMenu objectForKey:[@"Please select End Date greater than or equal Start Date." uppercaseString]] && ![[dictMenu objectForKey:[@"Please select End Date greater than or equal Start Date." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Please select End Date greater than or equal Start Date." uppercaseString]] length]>0) {
                        strDateGreaterMsg = [dictMenu objectForKey:[@"Please select End Date greater than or equal Start Date." uppercaseString]]?[dictMenu objectForKey:[@"Please select End Date greater than or equal Start Date." uppercaseString]]:@"";
                    }
                }
            }
        }
    }
    
    [self createDynamicGUIWithDefaultValues];
    
    tlc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button1 setImage:[UIImage imageNamed:@"Menu"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(updateMenuBarPositions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
}

-(void)addObject:(NSString*)object englishVersion:(NSString*)englishVersion dataType:(NSString*)dataType defaultVal:(NSString*)defaultVal{
    @try {
        NSDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:dataType?dataType:@"" forKey:@"dataType"];
        
        if (object.length!=0){
            [dict setValue:object?object:@"" forKey:@"visible"];
            [_arrDynamicReport addObject:dict];
        }
        else{
            [dict setValue:englishVersion?englishVersion:@"" forKey:@"visible"];
            [_arrDynamicReport addObject:dict];
            //[_dictDynamicReport setValue:defaultVal forKey:[dict valueForKey:@"visible"]];
        }
        
        [_dictDynamicReport setValue:defaultVal forKey:[dict valueForKey:@"visible"]];
        
        if ([dataType isEqualToString:@"Date"])
        {
            [_dictJsonReport setValue:[self set1000Date:defaultVal] forKey:[dict valueForKey:@"visible"]];
        }
    }
    @catch (NSException *exception){
        
        NSLog(@"Exception ion addObject=%@",exception.description);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
    [pref setValue:@"OnReportsScreen" forKey:@"CurrentPage"];
    [pref synchronize];

    @try {
        [super viewWillAppear:animated];
        SlideNavigationController *sld = [SlideNavigationController sharedInstance];
        sld.delegate = self;
        isOpenReportInput = NO;
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        if ([_strEvent isEqualToString:@"5"]) {
            [tracker set:kGAIScreenName value:@"Active Animals List Input Screen"];
        }else if ([_strEvent isEqualToString:@"7"]) {
            [tracker set:kGAIScreenName value:@"Open Sow List Input Screen"];
        }else if ([_strEvent isEqualToString:@"8"]) {
            [tracker set:kGAIScreenName value:@"Gilt Pool Input Screen"];
        }else if ([_strEvent isEqualToString:@"10"]) {
            [tracker set:kGAIScreenName value:@"Warning List-Not Serrved Input Screen"];
        }else if ([_strEvent isEqualToString:@"11"]) {
            [tracker set:kGAIScreenName value:@"Warning List-Not Weaned Input Screen"];
        }else if ([_strEvent isEqualToString:@"9"]) {
            [tracker set:kGAIScreenName value:@"Sows Due to Farrow Input Screen"];
        }else if ([_strEvent isEqualToString:@"6"]) {
            [tracker set:kGAIScreenName value:@"Sows Due for Attention Input Screen"];
        }
        
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    }
    @catch (NSException *exception){
        NSLog(@"Exception in viewWillAppear in sub data menu data entry  = %@",exception.description);
    }
}

-(void)updateMenuBarPositions {
    @try {
        [self.activeTextField resignFirstResponder];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeView:) name:@"CloseAlert" object:nil];
        
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        
        if (!isOpenReportInput) {
            self.vwOverlay.hidden = NO;
            [tlc.view setFrame:CGRectMake(-320, 0, self.view.frame.size.width-64, currentWindow.frame.size.height)];
            [currentWindow addSubview:tlc.view];
            
            [UIView animateWithDuration:0.3 animations:^{
                [tlc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width-64, currentWindow.frame.size.height)];
            }];
        }else{
            self.vwOverlay.hidden = YES;
            [tlc.view removeFromSuperview];
        }
        
        isOpenReportInput = !isOpenReportInput;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
}

-(void)removeView:(NSNotification *) notification {
    @try {
        NSDictionary *userInfo = notification.object;
        NSString *responseData =(NSString*) userInfo;
        
        if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
        {
            if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
            {
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
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
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }
        }else if (responseData.integerValue ==401) {
            
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:strUnauthorised
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOk
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }else if ([responseData isEqualToString:@""]){
            [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        }
        //        else{
        //            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                       message:strServerErr
        //                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //            UIAlertAction* ok = [UIAlertAction
        //                                 actionWithTitle:strOk
        //                                 style:UIAlertActionStyleDefault
        //                                 handler:^(UIAlertAction * action) {
        //                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                 }];
        //
        //            [myAlertController addAction: ok];
        //            [self presentViewController:myAlertController animated:YES completion:nil];
        //        }
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        self.vwOverlay.hidden = YES;
        isOpenReportInput = !isOpenReportInput;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in removeView=%@",exception.description);
    }
}

//- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
//    return YES;
//}

#pragma mark - Table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrDynamicReport.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    @try {
        return 45;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in heightForFooterInSection=%@",exception.description);
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    @try {
        return _vwFooter;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in viewForFooterInSection = %@",exception.description);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        //NSLog(@"indexPath.row=%d",indexPath.row);
        
        UITableViewCell *cell;
        NSMutableDictionary *dict = [_arrDynamicReport objectAtIndex:indexPath.row];
        NSString *strDataType = [dict valueForKey:@"dataType"];
        
        if ([strDataType isEqualToString:@"IR"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TextWihScanner" forIndexPath:indexPath];
            
            if (cell ==nil){
                cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextWihScanner"];
            }
            
            cell.backgroundColor = [UIColor clearColor];
            UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            lblDetails.text = [dict valueForKey:@"visible"]?[dict valueForKey:@"visible"]:@"";
            
            if ([_strEvent isEqualToString:@"3"] || [_strEvent isEqualToString:@"5"]){
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lblDetails.font = [UIFont boldSystemFontOfSize:17];
                }else{
                    lblDetails.font = [UIFont boldSystemFontOfSize:13];
                }
            }else{
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lblDetails.font = [UIFont systemFontOfSize:17];
                }else{
                    lblDetails.font = [UIFont systemFontOfSize:13];
                }
            }
            
            txtDynamic = (UITextField*)[cell viewWithTag:2];
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, txtDynamic.frame.size.height)];
            leftView.backgroundColor = [UIColor clearColor];
            txtDynamic.rightViewMode = UITextFieldViewModeAlways;
            txtDynamic.rightView = leftView;
            
            txtDynamic.text = [_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]];
            //[txtDynamic setKeyboardType:UIKeyboardTypeNumberPad];
        }
        else if ([strDataType isEqualToString:@"Date"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DateReport" forIndexPath:indexPath];
            
            if (cell ==nil){
                cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DateReport"];
            }
            
            UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            lblDetails.text = [dict valueForKey:@"visible"];
            
            if ([_strEvent isEqualToString:@"3"] || [_strEvent isEqualToString:@"5"]){
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lblDetails.font = [UIFont boldSystemFontOfSize:17];
                }else{
                    lblDetails.font = [UIFont boldSystemFontOfSize:13];
                }
            }else{
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lblDetails.font = [UIFont systemFontOfSize:17];
                }else{
                    lblDetails.font = [UIFont systemFontOfSize:13];
                }
            }
            
            UIButton *btn = (UIButton*)[cell viewWithTag:2];
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;//UITextAlignmentCenter
            btn.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
            [btn setTitle:[_dictJsonReport valueForKey:[dict valueForKey:@"visible"]] forState:UIControlStateNormal];
            
            //
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init];
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];//
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init] ;
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'00:00:00"];
            NSString *currentDate;
            
            if(currentDate == nil){
                currentDate = [dateFormatter stringFromDate:[NSDate date]];
            }
            
            NSDate *todayDate;
            todayDate =[dateFormatter dateFromString:currentDate];
            
            NSDateFormatter *dateFormatterr1 = [[NSDateFormatter alloc]init] ;
            [dateFormatterr1 setDateFormat:@"MM/dd/yyyy"];//
            NSDate *dtCheckIn = [dateFormatterr1 dateFromString:[_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]]];
            
            int days = [dtCheckIn timeIntervalSinceDate:todayDate]/24/60/60;
            
            if (days==0){
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }else if (days==1){
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }else{
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }
        }
        else if ([strDataType isEqualToString:@"DropDown"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DropDownReport"];
            
            if (cell ==nil) {
                cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DropDownReport"];
            }
            
            UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            lblDetails.text = [dict valueForKey:@"visible"];
            
            if ([_strEvent isEqualToString:@"3"] || [_strEvent isEqualToString:@"5"]) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    lblDetails.font = [UIFont boldSystemFontOfSize:17];
                }else {
                    lblDetails.font = [UIFont boldSystemFontOfSize:13];
                }
            }else{
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    lblDetails.font = [UIFont systemFontOfSize:17];
                }else {
                    lblDetails.font = [UIFont systemFontOfSize:13];
                }
            }
            
            UIButton *btn = (UIButton*)[cell viewWithTag:2];
            btn.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
            [btn setTitle:[_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]] forState:UIControlStateNormal];
        }else if ([strDataType isEqualToString:@"Text"]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"TextReport"];
            
            if (cell ==nil){
                cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextReport"];
            }
            
            UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            lblDetails.text = [dict valueForKey:@"visible"];
            
            if ([_strEvent isEqualToString:@"3"] || [_strEvent isEqualToString:@"5"]){
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lblDetails.font = [UIFont boldSystemFontOfSize:17];
                }else{
                    lblDetails.font = [UIFont boldSystemFontOfSize:13];
                }
            }else{
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lblDetails.font = [UIFont systemFontOfSize:17];
                }else{
                    lblDetails.font = [UIFont systemFontOfSize:13];
                }
            }
            
            txtDynamic = (UITextField*)[cell viewWithTag:2];
            txtDynamic.text = [_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]];
            [txtDynamic setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        }
        
        return cell;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in cellForRowAtIndexPath =%@",exception.description);
    }
}

/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//----------------------------------------------------------------------------------------------------------------------------------

#pragma mark - picker methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    @try {
        return  1;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in numberOfRowsInComponent=%@",exception.description);
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;{
    @try{
        if (pickerView==self.pickerDropDownReport){
            return [_arrDropDownReport count];
        }
    }
    @catch (NSException *exception){
        NSLog(@"Exception in numberOfRowsInComponent- %@",[exception description]);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    @try{
//        [[self.pickerDropDownReport.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerDropDownReport.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        if (pickerView==self.pickerDropDownReport){
            return [[_arrDropDownReport objectAtIndex:row] valueForKey:@"visible"];
        }
    }
    @catch (NSException *exception){
        NSLog(@"Exception in titleForRow- %@",[exception description]);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    @try
    {
//        [[self.pickerDropDownReport.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerDropDownReport.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        UILabel *lblSortText = (id)view;
        
        if (!lblSortText)
        {
            lblSortText= [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, [pickerView rowSizeForComponent:component].width-15, [pickerView rowSizeForComponent:component].height)];
        }
        
        lblSortText.font = [UIFont systemFontOfSize:13];
        lblSortText.textColor = [UIColor blackColor];
        lblSortText.textAlignment = NSTextAlignmentCenter;
        lblSortText.tintColor = [UIColor clearColor];
        
        if (pickerView==self.pickerDropDownReport) {
            lblSortText.text = [[_arrDropDownReport objectAtIndex:row] valueForKey:@"visible"];
            return lblSortText;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in viewForRow- %@",[exception description]);
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    @try
    {
        [textField resignFirstResponder];
        
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in textFieldShouldReturn in ViewController- %@",[exception description]);
    }
}

#pragma mark - Textfield methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.activeTextField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    @try {
        UITableViewCell* cell = (UITableViewCell*)[[textField superview] superview];
        
        if (textField.tag==12){
            cell = [(UITableViewCell*)[[textField superview] superview] superview];
        }
        else if (textField.tag==13 || (textField.tag==14)){
            cell = [[(UITableViewCell*)[[textField superview] superview] superview] superview];
        }
        
        NSIndexPath *indexPath = [self.tblReportsDynamic indexPathForCell:cell];
        NSDictionary *dict = [self.arrDynamicReport objectAtIndex:indexPath.row];
        NSString *newString = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
        
        if([string isEqualToString:@""]) {
            [self.dictDynamicReport setValue:newString forKey:[dict valueForKey:@"visible"]];
            return YES;
        }
        
        if ([_strEvent isEqualToString:@"10"] || [_strEvent isEqualToString:@"11"]) {
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            if ((location.location != NSNotFound) && (newString.length < 3)){
                [self.dictDynamicReport setValue:newString forKey:[dict valueForKey:@"visible"]];
                return ((location.location != NSNotFound) && (newString.length < 4));
            }
            else {
                return NO;
            }
        }else if ([_strEvent isEqualToString:@"9"] || [_strEvent isEqualToString:@"8"] || [_strEvent isEqualToString:@"6"]) {
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            if ((location.location != NSNotFound) && (newString.length < 4)){
                [self.dictDynamicReport setValue:newString forKey:[dict valueForKey:@"visible"]];
                return ((location.location != NSNotFound) && (newString.length < 4));
            }
            else {
                return NO;
            }
        }else if ([_strEvent isEqualToString:@"3"]){
            @try{
                if (textField.text.length>14) {
                    return NO;
                }
                else{
                    [_dictDynamicReport setValue:newString forKey:[dict valueForKey:@"visible"]];
                    return YES;
                }
            }
            @catch (NSException *exception){
                NSLog(@"Exception in shouldChangeCharactersInRange- %@",[exception description]);
            }
        }
        else {
            [self.dictDynamicReport setValue:newString forKey:[dict valueForKey:@"visible"]];
        }
        
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in shouldChangeCharactersInRange- %@",[exception description]);
    }
}

#pragma mark - other methods
-(void)btnBack_tapped {
    @try {
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnBack_tapped=%@",exception.description);
    }
}

- (IBAction)btnDate_tapped:(id)sender {
    @try {
        [self.activeTextField resignFirstResponder];
        UITableViewCell* cell = (UITableViewCell*)[[sender superview] superview];
        NSIndexPath* indexPath = [self.tblReportsDynamic indexPathForCell:cell];
        NSDictionary *dict = [_arrDynamicReport objectAtIndex:indexPath.row];
        NSString *strPrevSelectedValue = [_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]];
        __block NSString *strTitle=[dict valueForKey:@"visible"]?[dict valueForKey:@"visible"]:@"";
        
        NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
        [dateFormatterr setDateFormat:@"MM/dd/yyyy"]; //MMMM dd
        
        NSDate *dt2 = [dateFormatterr dateFromString:strPrevSelectedValue];
        
        self.dtPickerReport= [[UIDatePicker alloc] init];
        self.dtPickerReport.frame=CGRectMake(15, 14, 260, 150.0);
        self.dtPickerReport.datePickerMode = UIDatePickerModeDate;
        
        if (@available(iOS 13.4, *)) {
            self.dtPickerReport.preferredDatePickerStyle = UIDatePickerStyleWheels;
        } else {
            // Fallback on earlier versions
        }
        
        if (strPrevSelectedValue.length>0) {
            [self.dtPickerReport setDate:dt2];
        }
        else{
            [self.dtPickerReport setDate:[NSDate date]];
        }
        
        
        NSDateFormatter *dateFormatterrr = [[NSDateFormatter alloc]init];
        [dateFormatterrr setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [dateFormatterrr dateFromString:@"1/1/1900"];
        self.dtPickerReport.minimumDate=date;
                 

    //   [self.view addSubview:self.dtPickerReport];
        
        _alertForPickUpDateReport = [[CustomIOS7AlertView alloc] init];
        [_alertForPickUpDateReport setMyDelegate:self];
        [_alertForPickUpDateReport setButtonTitles:[NSMutableArray arrayWithObjects:strOk,strCancel, nil]];
        _alertForPickUpDateReport.fromDynamic = @"Dynamic";

        [_alertForPickUpDateReport showCustomwithView:self.dtPickerReport title:strTitle];
        
        
        __weak typeof(self) weakSelf = self;
        
        [_alertForPickUpDateReport setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            if(buttonIndex == 0) {
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                
                NSString *strSelectedDate = [formatter stringFromDate:weakSelf.dtPickerReport.date];
                [weakSelf.dictDynamicReport setValue:strSelectedDate forKey:[dict valueForKey:@"visible"]];
                
                //
                NSString *strBaseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZD"];
                if (isThousandFormatReport) {
                    [formatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *dtselectedDate = [formatter dateFromString:strSelectedDate];
                    [formatter setDateFormat:@"yyyyMMdd"];
                    NSDate *BaseDate = [formatter dateFromString:strBaseDate];
                    int days = [dtselectedDate timeIntervalSinceDate:BaseDate]/24/60/60;
                    
                    NSString *strDate = [NSString stringWithFormat:@"%05d",days];
                    NSString *calFormat,*strFromString;
                    
                    if (strDate.length>=2) {
                        calFormat = [strDate substringToIndex:2];
                    }else {
                        calFormat = strDate;
                    }
                    
                    if (strDate.length>=3) {
                        strFromString = [strDate substringFromIndex:2];
                    }
                    
                    calFormat = [[calFormat stringByAppendingString:@"-"] stringByAppendingString:strFromString?strFromString:@""];
                    [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                    
                    NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
                    
                    [weakSelf.dictJsonReport setValue:strSelectedDate100 forKey:[dict valueForKey:@"visible"]];
                    
                    [formatter setDateFormat:@"MM/dd/yyyy"];//Added by Priyanka
                    NSString *strSelectedDateDayOfyear1 = [formatter stringFromDate:dtselectedDate];//Added by Priyanka
                    [dictDynamicCopyToSend setValue:strSelectedDateDayOfyear1 forKey:[dict valueForKey:@"visible"]];//Added by Priyanka
                }else if([weakSelf.strDateFormat isEqualToString:@"6"]){
                    [formatter setDateFormat:@"MM/dd/yyyy"];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                    NSDate *dtselectedDate = [formatter dateFromString:strSelectedDate];
                    NSDate *Firstdate= [weakSelf getFirstDateOfCurrentYear:dtselectedDate];
                    
                    NSInteger days=[weakSelf daysBetweenDate:Firstdate andDate:dtselectedDate];
                    NSLog(@"days:%ld",days);
                    
                    NSString *strDate = [NSString stringWithFormat:@"%03li",days];
                    [formatter setDateFormat:@"yy"];
                    
                    NSString *strSelectedDateyearformat = [[[formatter stringFromDate:dtselectedDate] stringByAppendingString:@"-"] stringByAppendingString:strDate];
                    
                    //[weakSelf.dictJsonReport setValue:strSelectedDateyearformat forKey:[dict valueForKey:@"visible"]];
                    
                    /**********below code added by amit*********************************************/
                    [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                    NSString *strSelectedDateDayOfyear = [[strSelectedDateyearformat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
                    
                    [weakSelf.dictJsonReport setValue:strSelectedDateDayOfyear forKey:[dict valueForKey:@"visible"]];
                    /********************************************************************************/
                    
                    [formatter setDateFormat:@"MM/dd/yyyy"];//Added by Priyanka
                    NSString *strSelectedDateDayOfyear1 = [formatter stringFromDate:dtselectedDate];//Added by Priyanka
                    [dictDynamicCopyToSend setValue:strSelectedDateDayOfyear1 forKey:[dict valueForKey:@"visible"]];//Added by Priyanka
                } else {
                    [dictDynamicCopyToSend setValue:strSelectedDate forKey:[dict valueForKey:@"visible"]];//Added by Priyanka
                    [weakSelf.dictJsonReport setValue:strSelectedDate forKey:[dict valueForKey:@"visible"]];
                }
            }
            
            NSLog(@"date selected:%@",weakSelf.dictJsonReport);
            NSLog(@"date selected dictDynamicCopyToSend:%@",dictDynamicCopyToSend);

            [weakSelf.tblReportsDynamic reloadData];
            [alertView close];
        }];
        
        [weakSelf.alertForPickUpDateReport setUseMotionEffects:true];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in btnDate_tapped =%@",exception.description);
    }
}

- (IBAction)btnCancel_tapped:(id)sender {
    @try {
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnCancel_tapped=%@",exception.description);
    }
}

- (IBAction)btnRunReport_tapped:(id)sender
{
    @try {
        NSLog(@"event id=%@",_strEvent);
        if ([_strEvent isEqualToString:@"3"])
        {
            if (txtDynamic.text.length == 0) //Changed by priyanka
            {
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strIdentity
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action){
                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                
                [myAlertController addAction:ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }
            else
            {
                ActiveAnimalListViewController *activeAnimalListViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"ActiveReport"];
                // activeAnimalListViewController.strIdentity = [_dictDynamicReport valueForKey:@"Identity"];  //Changed by priyanka
                activeAnimalListViewController.strIdentity = txtDynamic.text;
                [self.navigationController pushViewController:activeAnimalListViewController animated:YES];
            }
            
            
            //            if ([[_dictDynamicReport valueForKey:@"Identity"] length]==0) {
            //                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
            //                                                                                           message:strIdentity
            //                                                                                    preferredStyle:UIAlertControllerStyleAlert];
            //                UIAlertAction* ok = [UIAlertAction
            //                                     actionWithTitle:strOk
            //                                     style:UIAlertActionStyleDefault
            //                                     handler:^(UIAlertAction * action){
            //                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
            //                                     }];
            //
            //                [myAlertController addAction:ok];
            //                [self presentViewController:myAlertController animated:YES completion:nil];
            //            }else {
            //                ActiveAnimalListViewController *activeAnimalListViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"ActiveReport"];
            //                activeAnimalListViewController.strIdentity = [_dictDynamicReport valueForKey:@"Identity"];
            //                [self.navigationController pushViewController:activeAnimalListViewController animated:YES];
            //            }
        }else if([_strEvent isEqualToString:@"2"]) {
            ProductionsummaryViewController *productionsummaryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductSummary"];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *dt2 = [formatter dateFromString:[_dictDynamicReport valueForKey:@"Date From"]];
            NSDate *dt3 = [formatter dateFromString:[_dictDynamicReport valueForKey:@"Date To"]];
            
            [formatter setDateFormat:@"yyyyMMdd"];
            NSString *strStart = [formatter stringFromDate:dt2];
            NSString *strEnd = [formatter stringFromDate:dt3];
            
            [dict setValue:strStart forKey:@"Date From"];
            [dict setValue:strEnd forKey:@"Date To"];
            
            //
            NSCalendar *gregorian = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSGregorianCalendar];
            
            NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
            
            NSDateComponents *components = [gregorian components:unitFlags
                                                        fromDate:dt2
                                                          toDate:dt3 options:0];
            NSInteger months = [components month];
            
            NSComparisonResult result = [dt2 compare:dt3];
            
            if (result== NSOrderedDescending) {
                
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strDateRangeMessage
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                
                [myAlertController addAction:ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
                return;
            } else if (months<6) {
                [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
                productionsummaryViewController.dictHeaders = dict;
                [self.navigationController pushViewController:productionsummaryViewController animated:YES];
            } else {
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strDateRange6Months
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                
                [myAlertController addAction:ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
                return;
            }
        }
        else {
            FirstReportViewController *firstReportViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"Report"];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
            [dict setValue:@"1" forKey:@"FromRec"];
            [dict setValue:@"20" forKey:@"ToRec"];
            [dict setValue:@"" forKey:@"sortFld"];
            [dict setValue:@"0" forKey:@"sortOrd"];
            
            if ([_strEvent isEqualToString:@"5"])
            {
                //[dict setValue:_strActiveAnimalReportType forKey:@"reportType"];
                
                if(_strActiveAnimalReportType!=NULL)
                {
                    // NSString * str = [self getTranslatedTextForString:@"Any Active Status"];
                    if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Any Active Status"]])
                    {
                        [dict setValue:@"" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Retained Gilt"]])
                    {
                        [dict setValue:@"stRetainedGilt" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Gilt Made Available"]])
                    {
                        [dict setValue:@"stAvailableGilt" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Maiden Gilt"]])
                    {
                        [dict setValue:@"stMaidenGilt" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Served (In-Pig)"]])
                    {
                        [dict setValue:@"stInPig" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Pregnancy Check Negative/Open"]])
                    {
                        [dict setValue:@"stPregCheckNeg" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Aborted"]])
                    {
                        [dict setValue:@"stAborted" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Lactating"]])
                    {
                        [dict setValue:@"stLactating" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Lactating (Nurse)"]])
                    {
                        [dict setValue:@"stLactatingNurse" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Weaned/Dry"]])
                    {
                        [dict setValue:@"stDry" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Working Boar"]])
                    {
                        [dict setValue:@"stWorkingBoar" forKey:@"reportType"];
                    }
                    else if([_strActiveAnimalReportType isEqualToString:[self getTranslatedTextForString:@"Unworked Boar"]])
                    {
                        [dict setValue:@"stUnworkedBoar" forKey:@"reportType"];
                    }
                    else
                    {
                        [dict setValue:@"" forKey:@"reportType"];
                    }
                }
                else
                {
                    [dict setValue:@"" forKey:@"reportType"];
                }
            }
            else if ([_strEvent isEqualToString:@"7"])
            {
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Gilts"]] forKey:@"gilts"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Weaned Sows"]] forKey:@"Weaned"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Aborted Sows"]] forKey:@"aborted"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Pregnancy Check Negative/Open"]] forKey:@"prcCheck"];
            }
            //            else if ([_strEvent isEqualToString:@"7"])
            //            {
            //                NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Gilts",@"Weaned Sows",@"Aborted Sows",@"Pregnancy Check Negative/Open",nil]];
            //                NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
            //
            ////                if (resultArray1.count!=0){
            ////                    for (int i=0; i<resultArray1.count; i++){
            ////                        [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
            ////                    }
            ////                }
            //
            //                for (int i=0; i<resultArray1.count; i++){
            //                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
            //                }
            //
            //                for (int i=0; i<5; i++) {
            //
            //                    dict = [[NSMutableDictionary alloc]init];
            //                    if (i==0) {
            //                        if ([dictMenu objectForKey:[@"Gilts" uppercaseString]] && ![[dictMenu objectForKey:[@"Gilts" uppercaseString]] isKindOfClass:[NSNull class]]) {
            //                                [dict setValue:[_dictDynamicReport valueForKey:@"Gilts"] forKey:@"gilts"];
            //                        }
            //                        else{
            //                            [dict setValue:@"DropDown" forKey:@"dataType"];
            //                            [dict setValue:@"Gilts" forKey:@"visible"];
            //                            [_arrDynamicReport addObject:dict];
            //                            [_dictDynamicReport setValue:@"Yes" forKey:@"Gilts"];
            //                        }
            //                    }else  if (i==1){
            //                        if ([dictMenu objectForKey:[@"Weaned Sows" uppercaseString]] && ![[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]] isKindOfClass:[NSNull class]]) {
            //                            [self addObject:[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]?[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]:@"" englishVersion:@"Weaned Sows" dataType:@"DropDown" defaultVal:@"Yes"];
            //                        }
            //                        else{
            //                            [dict setValue:@"DropDown" forKey:@"dataType"];
            //                            [dict setValue:@"Weaned Sows" forKey:@"visible"];
            //                            [_arrDynamicReport addObject:dict];
            //                            [_dictDynamicReport setValue:@"Yes" forKey:@"Weaned Sows"];
            //                        }
            //                    }else  if (i==2){
            //                        if ([dictMenu objectForKey:[@"Aborted Sows" uppercaseString]] && ![[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]] isKindOfClass:[NSNull class]]) {
            //                            [self addObject:[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]?[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]:@"" englishVersion:@"Aborted Sows" dataType:@"DropDown" defaultVal:@"Yes"];
            //                        }
            //                        else{
            //                            [dict setValue:@"DropDown" forKey:@"dataType"];
            //                            [dict setValue:@"Aborted Sows" forKey:@"visible"];
            //                            [_arrDynamicReport addObject:dict];
            //                            [_dictDynamicReport setValue:@"Yes" forKey:@"Aborted Sows"];
            //                        }
            //                    }else  if (i==3) {
            //                        if ([dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]] && ![[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]] isKindOfClass:[NSNull class]]) {
            //                            [self addObject:[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]?[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]:@"" englishVersion:@"Pregnancy Check Negative/Open" dataType:@"DropDown" defaultVal:@"Yes"];
            //                        }
            //                        else{
            //                            [dict setValue:@"DropDown" forKey:@"dataType"];
            //                            [dict setValue:@"Pregnancy Check Negative/Open" forKey:@"visible"];
            //                            [_arrDynamicReport addObject:dict];
            //                            [_dictDynamicReport setValue:@"Yes" forKey:@"Pregnancy Check Negative/Open"];
            //                        }
            //                    }
            //                }
            //
            //
            //                [dict setValue:[_dictDynamicReport valueForKey:[dictMenu objectForKey:[@"Gilts" uppercaseString]]?[dictMenu objectForKey:[@"Gilts" uppercaseString]]:@""] forKey:@"gilts"];
            //                [dict setValue:[_dictDynamicReport valueForKey:[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]?[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]:@""] forKey:@"Weaned"];
            //                [dict setValue:[_dictDynamicReport valueForKey:[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]?[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]:@""] forKey:@"aborted"];
            //                [dict setValue:[_dictDynamicReport valueForKey:[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]?[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]:@""] forKey:@"prcCheck"];
            //            }
            else if ([_strEvent isEqualToString:@"8"]) {
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Include Retained Gilts"]] forKey:@"IncludeRetainedGilts"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Acclimatization Period"]] forKey:@"AcclimPeriod"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Overdue for Service"]] forKey:@"OverdueForService"];
            }else if ([_strEvent isEqualToString:@"10"]) {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                NSDate *dt2 = [formatter dateFromString:[_dictDynamicReport valueForKey:[self getTranslatedTextForString:@"Due to be Served"]]];
                [formatter setDateFormat:@"yyyyMMdd"];
                NSString *strDate = [formatter stringFromDate:dt2];
                
                NSString *strDays =[_dictDynamicReport valueForKey:[self getTranslatedTextForString:@"Days since Weaned"]];
                
                if (strDays.length==0) {
                    strDays = @"0";
                }
                
                [dict setValue:strDays forKey:@"DaysSinceWean"];
                [dict setValue:strDate forKey:@"DueToBeServed"];
            }else if ([_strEvent isEqualToString:@"11"]) {
                NSString *strDays =[_dictDynamicReport valueForKey:[self getTranslatedTextForString:@"Days since Farrowed"]];
                
                if (strDays.length==0) {
                    strDays = @"0";
                }
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                NSDate *dt2 = [formatter dateFromString:[_dictDynamicReport valueForKey:[self getTranslatedTextForString:@"Due to be Weaned"]]];
                [formatter setDateFormat:@"yyyyMMdd"];
                NSString *strDate = [formatter stringFromDate:dt2];
                [dict setValue:strDays forKey:@"DaysSinceFarrow"];
                [dict setValue:strDate forKey:@"DueToBeWeaned"];
            }else if ([_strEvent isEqualToString:@"9"]) {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                NSDate *dt2 = [formatter dateFromString:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Due to Farrow Start"]]];
                NSDate *dt3 = [formatter dateFromString:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Due to Farrow End"]]];
                
                //
                NSComparisonResult result = [dt2 compare:dt3];
                
                if (result!= NSOrderedAscending && result!= NSOrderedSame) {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strDateCompareMsg
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction:ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    return;
                }
                
                [formatter setDateFormat:@"yyyyMMdd"];
                NSString *strStart = [formatter stringFromDate:dt2];
                NSString *strEnd = [formatter stringFromDate:dt3];
                
                [dict setValue:strStart forKey:@"DueToStartDate"];
                [dict setValue:strEnd forKey:@"DueToEndDate"];
                
                NSString *strDaysSinceServed = [dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Days Since Served"]];
                if ([strDaysSinceServed length]==0) {
                    [dict setValue:@"0" forKey:@"DaysSinceServed"];
                }else{
                    [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Days Since Served"]] forKey:@"DaysSinceServed"];
                }
                
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Incl. Aborted"]] forKey:@"IncAborted"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Incl. Preg Test Neg/Open"]] forKey:@"IncPregTest"];
            }else if ([_strEvent isEqualToString:@"6"]) {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yyyy"];
                NSDate *dt2 = [formatter dateFromString:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Start Date"]]];
                NSDate *dt3 =[NSDate date];
                
                NSDate *dt4 = [formatter dateFromString:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"End Date"]]];
                
                //6 month validation as sandip told
                NSCalendar *gregorian = [[NSCalendar alloc]
                                         initWithCalendarIdentifier:NSGregorianCalendar];
                
                NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
                
                NSDateComponents *components = [gregorian components:unitFlags
                                                            fromDate:dt2
                                                              toDate:dt4 options:0];
                NSInteger months = [components month];
                //
                
                //
                NSComparisonResult result = [dt2 compare:dt3];
                NSComparisonResult result2 = [dt2 compare:dt4];
                
                if (result!= NSOrderedAscending) {
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strDateLessThanCurrentMsg
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action){
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction:ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    return;
                }
                
                if (result2!= NSOrderedAscending && result2!= NSOrderedSame) {
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strDateGreaterMsg
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action){
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction:ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    return;
                }
                
                if (months>5)
                {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strDateRange6Months
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction:ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    return;
                }
                //
                
                [formatter setDateFormat:@"yyyyMMdd"];
                NSString *strStart = [formatter stringFromDate:dt2];
                NSString *strEnd = [formatter stringFromDate:dt4];
                
                [dict setValue:strStart forKey:@"StartDate"];
                [dict setValue:strEnd forKey:@"EndDate"];
                [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Days After"]] forKey:@"DaysAfter"];
               // [dict setValue:[dictDynamicCopyToSend valueForKey:@""] forKey:@"evtType"];
                
                if ([[dictDynamicCopyToSend valueForKey:@""] isEqualToString:[self getTranslatedTextForString:@"Arrived"]]) {
                    [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Still Un-Served"]] forKey:@"stillLact"];
                    [dict setValue:@"Arrived" forKey:@"evtType"];

                }else if ([[dictDynamicCopyToSend valueForKey:@""] isEqualToString:[self getTranslatedTextForString:@"Served"]]) {
                    [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Still In-Pig"]] forKey:@"stillLact"];
                    [dict setValue:@"Served" forKey:@"evtType"];

                }else if ([[dictDynamicCopyToSend valueForKey:@""] isEqualToString:[self getTranslatedTextForString:@"Farrowed"]]) {
                    [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Still Lactating"]] forKey:@"stillLact"];
                    [dict setValue:@"Farrowed" forKey:@"evtType"];

                }else if ([[dictDynamicCopyToSend valueForKey:@""] isEqualToString:[self getTranslatedTextForString:@"Weaned"]]) {
                    [dict setValue:[dictDynamicCopyToSend valueForKey:[self getTranslatedTextForString:@"Still Un-Served"]] forKey:@"stillLact"];
                    [dict setValue:@"Weaned" forKey:@"evtType"];

                }
                //
                
                // [dict setValue:[_dictDynamicReport valueForKey:@"Still Lactating"] forKey:@"stillLact"];
            }
            
            //FirstReportViewController *firstReportViewController = [segue destinationViewController];
            firstReportViewController.dictHeaders = dict;
            firstReportViewController.strEvnt = _strEvent;
            firstReportViewController.strTitle = self.title;
            /******added by amit*******/
            firstReportViewController.strDateFormat=self.strDateFormat;
            /***************************/
            // firstReportViewController.strActiveAnimalreportType = [_dictDynamicReport valueForKey:@"Status"];//Changed by Priyanka
            firstReportViewController.strActiveAnimalreportType = [_dictDynamicReport valueForKey:strStatus];
            [self.navigationController pushViewController:firstReportViewController animated:YES];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnRunReport_tapped=%@",exception.description);
    }
}

- (IBAction)btnDropDown_tapped:(id)sender
{
    @try {
        [self.activeTextField resignFirstResponder];
        NSInteger prevSelectedIndex = 0;
        
        UITableViewCell* cell = (UITableViewCell*)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tblReportsDynamic indexPathForCell:cell];
        NSDictionary *dict = [_arrDynamicReport objectAtIndex:indexPath.row];
        [_arrDropDownReport removeAllObjects];
        
        NSString *strPrevSelectedValue= [NSString stringWithFormat:@"%@",[_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]]?[_dictDynamicReport valueForKey:[dict valueForKey:@"visible"]]:@""];
        
        if ([_strEvent isEqualToString:@"5"]) {
            
            _arrActiveAnimalList =[[NSMutableArray alloc]init];
               NSArray *resultArray = [[NSArray alloc]initWithObjects:@"Any Active Status",@"Retained Gilt",@"Gilt Made Available",@"Maiden Gilt",@"Served (In-Pig)",@"Pregnancy Check Negative/Open",@"Aborted",@"Lactating",@"Lactating (Nurse)",@"Weaned/Dry",@"Working Boar",@"Unworked Boar", nil];
            
//            NSArray* resultArray = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Any Active Status",@"Retained Gilt",@"Gilt Made Available",@"Maiden Gilt",@"Served (In-Pig)",@"Pregnancy Check Negative/Open",@"Aborted",@"Lactating",@"Lactating (Nurse)",@"Weaned/Dry",@"Working Boar",@"Unworked Boar",nil]];
//
            if (resultArray!=0) {
                for (int i=0; i<resultArray.count; i++)
                {
                    [_arrActiveAnimalList addObject:[self getTranslatedTextForString:[resultArray objectAtIndex:i]]];
                }
            }
            
            for (int i =0; i<_arrActiveAnimalList.count; i++) {
                NSDictionary *dict11 = [[NSMutableDictionary alloc]init];
                [dict11 setValue:[_arrActiveAnimalList objectAtIndex:i] forKey:@"visible"];
                [_arrDropDownReport addObject:dict11];
                
                if (strPrevSelectedValue.length>0) {
                    if ([strPrevSelectedValue isEqualToString:[_arrActiveAnimalList objectAtIndex:i]]){
                        prevSelectedIndex = i;
                    }
                }
            }
        }else if ([_strEvent isEqualToString:@"6"] && indexPath.row==3)
        {
            NSArray *arr = [[NSArray alloc]initWithObjects:[self getTranslatedTextForString:@"Arrived"],[self getTranslatedTextForString:@"Served"],[self getTranslatedTextForString:@"Farrowed"],[self getTranslatedTextForString:@"Weaned"], nil];
            for (int i =0; i<arr.count; i++) {
                NSDictionary *dict11 = [[NSMutableDictionary alloc]init];
                [dict11 setValue:[arr objectAtIndex:i] forKey:@"visible"];
                [_arrDropDownReport addObject:dict11];
                
                if (strPrevSelectedValue.length>0){
                    if ([strPrevSelectedValue isEqualToString:[arr objectAtIndex:i]]){
                        prevSelectedIndex = i;
                    }
                }
            }
        }
        else
        {
            NSDictionary *dict1 = [[NSMutableDictionary alloc]init];
            [dict1 setValue:strNo forKey:@"visible"];
            [_arrDropDownReport addObject:dict1];
            
            if (strPrevSelectedValue.length>0){
                if ([strPrevSelectedValue isEqualToString:strNo]){
                    prevSelectedIndex = 0;
                }
            }
            
            NSDictionary *dict11 = [[NSMutableDictionary alloc]init];
            [dict11 setValue:strYes forKey:@"visible"];
            [_arrDropDownReport addObject:dict11];
            if (strPrevSelectedValue.length>0){
                if ([strPrevSelectedValue isEqualToString:strYes]){
                    prevSelectedIndex = 1;
                }
            }
        }
        
        NSLog(@"_arrDropDownReport=%@",_arrDropDownReport);
        
        self.pickerDropDownReport = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 10, 270, 150.0)];
        [self.pickerDropDownReport setDelegate:self];
        // self.pickerDropDownReport.showsSelectionIndicator = YES;
        [self.pickerDropDownReport setShowsSelectionIndicator:YES];
        
        _alertForDropDown = [[CustomIOS7AlertView alloc] init];
        [_alertForDropDown setMyDelegate:self];
        [_alertForDropDown setUseMotionEffects:true];
        [_alertForDropDown setButtonTitles:[NSMutableArray arrayWithObjects:strOk,strCancel, nil]];
        
        __weak typeof(self) weakSelf = self;
        //__unsafe_unretained typeof(self) weakSelf = self;
        [_alertForDropDown setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex)
         {
             if(buttonIndex == 0 && weakSelf.pickerDropDownReport>0){
                 NSInteger row = [weakSelf.pickerDropDownReport selectedRowInComponent:0];
                 NSDictionary *dict = [weakSelf.arrDynamicReport objectAtIndex:indexPath.row];
                 [weakSelf.dictDynamicReport setValue:[[weakSelf.arrDropDownReport objectAtIndex:row] valueForKey:@"visible"] forKey:[dict valueForKey:@"visible"]];
                 
                 if ([_strEvent isEqualToString:@"7"])//Added by priyanka on 17th aug
                 {
                     if(row == 0)
                     {
                         [dictDynamicCopyToSend setValue:@"0" forKey:[dict valueForKey:@"visible"]]; //Added by priyanka on 17th aug
                     }
                     else
                     {
                         [dictDynamicCopyToSend setValue:@"1" forKey:[dict valueForKey:@"visible"]]; //Added by priyanka on 17th aug
                     }
                 }else  if ([_strEvent isEqualToString:@"9"])
                 {
                     if(row == 0)
                     {
                         [dictDynamicCopyToSend setValue:@"0" forKey:[dict valueForKey:@"visible"]];
                     }
                     else
                     {
                         [dictDynamicCopyToSend setValue:@"1" forKey:[dict valueForKey:@"visible"]];
                     }
                     NSLog(@"dictTempSowAttention=%@",dictDynamicCopyToSend);
                 }else  if ([_strEvent isEqualToString:@"8"])
                 {
                     if(row == 0)
                     {
                         [dictDynamicCopyToSend setValue:@"0" forKey:[dict valueForKey:@"visible"]];
                     }
                     else
                     {
                         [dictDynamicCopyToSend setValue:@"1" forKey:[dict valueForKey:@"visible"]];
                     }
                     NSLog(@"dictTempSowAttention=%@",dictDynamicCopyToSend);
                 }else  if ([_strEvent isEqualToString:@"6"] && indexPath.row==4)
                 {
                     if(row == 0)
                     {
                         [dictDynamicCopyToSend setValue:@"0" forKey:[dict valueForKey:@"visible"]];
                     }
                     else
                     {
                         [dictDynamicCopyToSend setValue:@"1" forKey:[dict valueForKey:@"visible"]];
                     }
                     NSLog(@"dictTempSowAttention=%@",dictDynamicCopyToSend);
                 }else if ([_strEvent isEqualToString:@"6"] && indexPath.row==3)
                 {
                     NSDictionary *dict = [weakSelf.arrDynamicReport objectAtIndex:indexPath.row+1];
                     NSString *pre = [weakSelf.dictDynamicReport valueForKey:[dict valueForKey:@"visible"]];
                     
                     if (row==0) {
                         [dict setValue:[self getTranslatedTextForString:@"Still Un-Served"] forKey:@"visible"]; //For sending stillLact 0 & 1 after changing farrowed drop down
                         [dictDynamicCopyToSend setValue:[self getTranslatedTextForString:@"Arrived"] forKey:@""];
                         if ([[self getTranslatedTextForString:@"Yes"] isEqualToString:pre])
                         {
                             [dictDynamicCopyToSend setValue:@"1" forKey:[self getTranslatedTextForString:@"Still Un-Served"]];
                         }
                         else
                         {
                             [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still Un-Served"]];
                         }
                     }else if (row==1) {
                         [dict setValue:[self getTranslatedTextForString:@"Still In-Pig"] forKey:@"visible"];
                         [dictDynamicCopyToSend setValue:[self getTranslatedTextForString:@"Served"] forKey:@""];
                       //  [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still In-Pig"]];
                         if ([[self getTranslatedTextForString:@"Yes"] isEqualToString:pre])
                         {
                             [dictDynamicCopyToSend setValue:@"1" forKey:[self getTranslatedTextForString:@"Still In-Pig"]];
                         }
                         else
                         {
                             [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still In-Pig"]];
                         }
                     }else if (row==2) {
                         [dict setValue:[self getTranslatedTextForString:@"Still Lactating"] forKey:@"visible"];
                         [dictDynamicCopyToSend setValue:[self getTranslatedTextForString:@"Farrowed"] forKey:@""];
                        // [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still Lactating"]];
                         if ([[self getTranslatedTextForString:@"Yes"] isEqualToString:pre])
                         {
                             [dictDynamicCopyToSend setValue:@"1" forKey:[self getTranslatedTextForString:@"Still Lactating"]];
                         }
                         else
                         {
                             [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still Lactating"]];
                         }
                     }else if (row==3) {
                         [dict setValue:[self getTranslatedTextForString:@"Still Un-Served"] forKey:@"visible"];
                         [dictDynamicCopyToSend setValue:[self getTranslatedTextForString:@"Weaned"] forKey:@""];
                       //  [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still Un-Served"]];
                         if ([[self getTranslatedTextForString:@"Yes"] isEqualToString:pre])
                         {
                             [dictDynamicCopyToSend setValue:@"1" forKey:[self getTranslatedTextForString:@"Still Un-Served"]];
                         }
                         else
                         {
                             [dictDynamicCopyToSend setValue:@"0" forKey:[self getTranslatedTextForString:@"Still Un-Served"]];
                         }
                     }
                     [weakSelf.dictDynamicReport setValue:pre forKey:[dict valueForKey:@"visible"]];
                     NSLog(@"dictTempSowAttention=%@",_dictDynamicReport);
                     NSLog(@"dictTempSowAttention=%@",_arrDynamicReport);
                 }else if ([_strEvent isEqualToString:@"5"] ) {
                     //  NSArray *arrConstant = [[NSArray alloc]initWithObjects:@"",@"stRetainedGilt",@"stAvailableGilt",@"stMaidenGilt",@"stInPig",@"stPregCheckNeg",@"stAborted",@"stLactating",@"stLactatingNurse",@"stDry",@"stWorkingBoar",@"stUnworkedBoar", nil];
                     // _strActiveAnimalReportType = [arrConstant objectAtIndex:row];
                     _strActiveAnimalReportType = [_arrActiveAnimalList objectAtIndex:row];
                 }
                 [weakSelf.tblReportsDynamic reloadData];
             }
             [weakSelf.alertForPickUpDateReport close];
         }];
        
        if (_arrDropDownReport.count>0) {
            [weakSelf.alertForDropDown showCustomwithView:self.pickerDropDownReport title:[dict valueForKey:@"visible"]?[dict valueForKey:@"visible"]:@""];
        }
        else {
            NSLog(@"no data");
        }
        
        [weakSelf.pickerDropDownReport selectRow:prevSelectedIndex inComponent:0 animated:NO];
        [self.pickerDropDownReport setShowsSelectionIndicator:YES];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnDropDown_tapped =%@",exception.description);
    }
}

#pragma mark -Textfield custom methods
- (void)registerForKeyboardNotifications
{
    @try {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in registerForKeyboardNotifications = %@",exception.description);
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification{
    @try {
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.tblReportsDynamic.contentInset = contentInsets;
        _tblReportsDynamic.scrollIndicatorInsets = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        
        if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin) ) {
            [self.tblReportsDynamic scrollRectToVisible:CGRectMake(self.activeTextField.frame.origin.x, self.activeTextField.frame.origin.y, self.activeTextField.frame.size.width, self.activeTextField.frame.size.height) animated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in keyboardWasShown in ViewController =%@",exception.description);
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    @try {
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.tblReportsDynamic.contentInset = contentInsets;
        self.tblReportsDynamic.scrollIndicatorInsets = contentInsets;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception  in keyboardWillHide in ViewController =%@",exception.description);
    }
}

-(void)createDynamicGUIWithDefaultValues {
    @try {
        _dictDynamicReport = [[NSMutableDictionary alloc]init];
        _dictJsonReport= [[NSMutableDictionary alloc]init];
        
        NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
        NSDictionary *dict;// = [[NSMutableDictionary alloc]init];
        
        //  NSMutableArray *arrTemp =[[NSMutableArray alloc]init];//3,5
        self.title = _strSubMenu;
        
        if ([_strEvent isEqualToString:@"2"]) {
            
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
            NSString *strSelectedDate = [dateFormatterr stringFromDate:[NSDate date]];
            
            [arrTemp addObject:@"Date From"];
            [arrTemp addObject:@"Date To"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<2; i++){
                    dict = [[NSMutableDictionary alloc]init];
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Date From" uppercaseString]] && ![[dictMenu objectForKey:[@"Date From" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Date From" uppercaseString]]?[dictMenu objectForKey:[@"Date From" uppercaseString]]:@"" englishVersion:@"Date From" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else{
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Date From" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"Date From"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"Date From"];
                        }
                    }else  if (i==1){
                        if ([dictMenu objectForKey:[@"Date To" uppercaseString]] && ![[dictMenu objectForKey:[@"Date To" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Date To" uppercaseString]]?[dictMenu objectForKey:[@"Date To"uppercaseString]]:@"" englishVersion:@"Date To" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else {
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Date To" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"Date To"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"Date To"];
                        }
                    }
                }
            }
        }else if ([_strEvent isEqualToString:@"3"]) {
            [arrTemp addObject:@"Identity"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<1; i++){
                    dict = [[NSMutableDictionary alloc]init];
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Identity" uppercaseString]] && ![[dictMenu objectForKey:[@"Identity" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Identity" uppercaseString]]?[dictMenu objectForKey:[@"Identity" uppercaseString]]:@"" englishVersion:@"Identity"  dataType:@"IR" defaultVal:@""];
                        }
                        else{
                            [dict setValue:@"IR" forKey:@"dataType"];
                            [dict setValue:@"Identity" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"" forKey:@"Identity"];
                        }
                    }
                }
            }
        }else if ([_strEvent isEqualToString:@"5"]){
            [arrTemp addObject:@"Status"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<1; i++){
                    dict = [[NSMutableDictionary alloc]init];
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Status" uppercaseString]] && ![[dictMenu objectForKey:[@"Status" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Status" uppercaseString]]?[dictMenu objectForKey:[@"Status" uppercaseString]]:@"" englishVersion:@"Status" dataType:@"DropDown" defaultVal:[self getTranslatedTextForString:@"Any Active Status"]];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Status" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Any Active Status" forKey:@"Status"];
                        }
                    }
                }
            }
        }else if ([_strEvent isEqualToString:@"6"]){
            //
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
            NSString *strSelectedDate = [dateFormatterr stringFromDate:[NSDate date]];
            
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Start Date"];
            [arrTemp addObject:@"End Date"];
            [arrTemp addObject:@"Days After"];
            [arrTemp addObject:@""];
            [arrTemp addObject:@"Still Lactating"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<5; i++) {
                    dict = [[NSMutableDictionary alloc]init];
                    
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Start Date" uppercaseString]] && ![[dictMenu objectForKey:[@"Start Date" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Start Date" uppercaseString]]?[dictMenu objectForKey:[@"Start Date" uppercaseString]]:@"" englishVersion:@"Start Date" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else{
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Start Date" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"Start Date"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"Start Date"];
                        }
                    }else  if (i==1){
                        if ([dictMenu objectForKey:[@"End Date" uppercaseString]] && ![[dictMenu objectForKey:[@"End Date" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"End Date" uppercaseString]]?[dictMenu objectForKey:[@"End Date" uppercaseString]]:@"" englishVersion:@"End Date" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else{
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"End Date" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"End Date"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"End Date"];
                        }
                    }else  if (i==2){
                        if ([dictMenu objectForKey:[@"Days After" uppercaseString]] && ![[dictMenu objectForKey:[@"Days After" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Days After" uppercaseString]]?[dictMenu objectForKey:[@"Days After" uppercaseString]]:@"" englishVersion:@"Days After" dataType:@"Text" defaultVal:@"7"];
                        }
                        else{
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Days After" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"7" forKey:@"Days After"];
                        }
                    }else  if (i==3){
                        if ([dictMenu objectForKey:[@"" uppercaseString]] && ![[dictMenu objectForKey:[@"" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"" uppercaseString]] englishVersion:@"" dataType:@"DropDown" defaultVal:[self getTranslatedTextForString:@"Farrowed"]];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:[self getTranslatedTextForString:@"Farrowed"] forKey:@""];
                            
                        }
                    }else  if (i==4){
                        if ([dictMenu objectForKey:[@"Still Lactating" uppercaseString]] && ![[dictMenu objectForKey:[@"Still Lactating" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Still Lactating" uppercaseString]]?[dictMenu objectForKey:[@"Still Lactating" uppercaseString]]:@"" englishVersion:@"Still Lactating" dataType:@"DropDown" defaultVal:strNo];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Still Lactating" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strNo forKey:@"Still Lactating"];
                        }
                    }
                }
            }
            dictDynamicCopyToSend = [_dictDynamicReport mutableCopy]; //For sending 0 & 1 to API holding dict in dictDynamicCopyToSend
           // [dictDynamicCopyToSend setObject:@"0" forKey:[dictMenu objectForKey:[@"Still Lactating" uppercaseString]]];
             [dictDynamicCopyToSend setObject:@"0" forKey:[self getTranslatedTextForString:@"Still Lactating"]];//Changed by priyanka
        }else if ([_strEvent isEqualToString:@"7"]){
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Gilts"];
            [arrTemp addObject:@"Weaned Sows"];
            [arrTemp addObject:@"Aborted Sows"];
            [arrTemp addObject:@"Pregnancy Check Negative/Open"];
            
            //
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<5; i++) {
                    
                    dict = [[NSMutableDictionary alloc]init];
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Gilts" uppercaseString]] && ![[dictMenu objectForKey:[@"Gilts" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Gilts" uppercaseString]]?[dictMenu objectForKey:[@"Gilts" uppercaseString]]:@"" englishVersion:@"Gilts" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Gilts" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Gilts"];
                        }
                    }else  if (i==1){
                        if ([dictMenu objectForKey:[@"Weaned Sows" uppercaseString]] && ![[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]?[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]:@"" englishVersion:@"Weaned Sows" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Weaned Sows" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Weaned Sows"];
                        }
                    }else  if (i==2){
                        if ([dictMenu objectForKey:[@"Aborted Sows" uppercaseString]] && ![[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]?[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]:@"" englishVersion:@"Aborted Sows" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Aborted Sows" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Aborted Sows"];
                        }
                    }else  if (i==3) {
                        if ([dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]] && ![[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]?[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]:@"" englishVersion:@"Pregnancy Check Negative/Open" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Pregnancy Check Negative/Open" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Pregnancy Check Negative/Open"];
                        }
                    }
                }
            }
            dictDynamicCopyToSend = [_dictDynamicReport mutableCopy];
//            [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Gilts" uppercaseString]]];
//            [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Weaned Sows" uppercaseString]]];
//            [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Aborted Sows" uppercaseString]]];
//            [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Pregnancy Check Negative/Open" uppercaseString]]];
                        [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Gilts"]];
                        [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Weaned Sows"]];
                        [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Aborted Sows"]];
                        [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Pregnancy Check Negative/Open"]];
            
        }else if ([_strEvent isEqualToString:@"8"]){
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Include Retained Gilts"];
            [arrTemp addObject:@"Acclimatization Period"];
            [arrTemp addObject:@"Overdue for Service"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            //if (resultArray1.count!=0)
            {
                
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<3; i++) {
                    dict = [[NSMutableDictionary alloc]init];
                    
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Include Retained Gilts" uppercaseString]] && ![[dictMenu objectForKey:[@"Include Retained Gilts" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Include Retained Gilts" uppercaseString]]?[dictMenu objectForKey:[@"Include Retained Gilts" uppercaseString]]:@"" englishVersion:@"Include Retained Gilts" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else{
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Include Retained Gilts" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Include Retained Gilts"];
                        }
                    }else  if (i==1){
                        if ([dictMenu objectForKey:[@"Acclimatization Period" uppercaseString]] && ![[dictMenu objectForKey:[@"Acclimatization Period" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Acclimatization Period" uppercaseString]]?[dictMenu objectForKey:[@"Acclimatization Period" uppercaseString]]:@"" englishVersion:@"Acclimatization Period" dataType:@"Text" defaultVal:@"21"];
                        }
                        else {
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Acclimatization Period" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"21" forKey:@"Acclimatization Period"];
                        }
                    }else  if (i==2) {
                        if ([dictMenu objectForKey:[@"Overdue for Service" uppercaseString]] && ![[dictMenu objectForKey:[@"Overdue for Service" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Overdue for Service" uppercaseString]]?[dictMenu objectForKey:[@"Overdue for Service" uppercaseString]]:@"" englishVersion:@"Overdue for Service" dataType:@"Text" defaultVal:@"60"];
                        }
                        else {
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Overdue for Service" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"60" forKey:@"Overdue for Service"];
                        }
                    }
                }
            }
            dictDynamicCopyToSend = [_dictDynamicReport mutableCopy];
           // [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Include Retained Gilts" uppercaseString]]];
            [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Include Retained Gilts"]];
        }else if ([_strEvent isEqualToString:@"9"]){
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
            NSString *strSelectedDate = [dateFormatterr stringFromDate:[NSDate date]];
            
            NSDate *now = [NSDate date];
            int daysToAdd = 6;
            NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
            NSString *strEndDate = [dateFormatterr stringFromDate:newDate1];
            
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Due to Farrow Start"];
            [arrTemp addObject:@"Due to Farrow End"];
            [arrTemp addObject:@"Days Since Served"];
            [arrTemp addObject:@"Incl. Aborted"];
            [arrTemp addObject:@"Incl. Preg Test Neg/Open"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++) {
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<5; i++) {
                    dict = [[NSMutableDictionary alloc]init];
                    
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Due to Farrow Start" uppercaseString]] && ![[dictMenu objectForKey:[@"Due to Farrow Start" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Due to Farrow Start" uppercaseString]]?[dictMenu objectForKey:[@"Due to Farrow Start" uppercaseString]]:@"" englishVersion:@"Due to Farrow Start" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else {
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Due to Farrow Start" forKey:@"visible"];
                            
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"Due to Farrow Start"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"Due to Farrow Start"];
                        }
                    }else  if (i==1) {
                        if ([dictMenu objectForKey:[@"Due to Farrow End" uppercaseString]] && ![[dictMenu objectForKey:[@"Due to Farrow End" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Due to Farrow End" uppercaseString]]?[dictMenu objectForKey:[@"Due to Farrow End" uppercaseString]]:@"" englishVersion:@"Due to Farrow End"dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else {
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Due to Farrow End" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strEndDate forKey:@"Due to Farrow End"];
                            [_dictJsonReport setValue:[self set1000Date:strEndDate] forKey:@"Due to Farrow End"];
                        }
                    }else  if (i==2) {
                        if ([dictMenu objectForKey:[@"Days Since Served" uppercaseString]] && ![[dictMenu objectForKey:[@"Days Since Served" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Days Since Served" uppercaseString]]?[dictMenu objectForKey:[@"Days Since Served" uppercaseString]]:@"" englishVersion:@"Days Since Served" dataType:@"Text" defaultVal:@"115"];
                        }
                        else {
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Days Since Served" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"115" forKey:@"Days Since Served"];
                        }
                    }else  if (i==3) {
                        if ([dictMenu objectForKey:[@"Incl. Aborted" uppercaseString]] && ![[dictMenu objectForKey:[@"Incl. Aborted" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Incl. Aborted" uppercaseString]]?[dictMenu objectForKey:[@"Incl. Aborted" uppercaseString]]:@"" englishVersion:@"Incl. Aborted" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else {
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Incl. Aborted" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Incl. Aborted"];
                        }
                    }else  if (i==4){
                        if ([dictMenu objectForKey:[@"Incl. Preg Test Neg/Open" uppercaseString]] && ![[dictMenu objectForKey:[@"Incl. Preg Test Neg/Open" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Incl. Preg Test Neg/Open" uppercaseString]]?[dictMenu objectForKey:[@"Incl. Preg Test Neg/Open" uppercaseString]]:@"" englishVersion:@"Incl. Preg Test Neg/Open" dataType:@"DropDown" defaultVal:strYes];
                        }
                        else {
                            [dict setValue:@"DropDown" forKey:@"dataType"];
                            [dict setValue:@"Incl. Preg Test Neg/Open" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"Yes" forKey:@"Incl. Preg Test Neg/Open"];
                        }
                    }
                }
            }
            dictDynamicCopyToSend = [_dictDynamicReport mutableCopy];
//            [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Incl. Aborted" uppercaseString]]];
//            [dictDynamicCopyToSend setObject:@"1" forKey:[dictMenu objectForKey:[@"Incl. Preg Test Neg/Open" uppercaseString]]];
            [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Incl. Aborted"]];
            [dictDynamicCopyToSend setObject:@"1" forKey:[self getTranslatedTextForString:@"Incl. Preg Test Neg/Open"]];
        }else if ([_strEvent isEqualToString:@"10"]) {
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
            NSString *strSelectedDate = [dateFormatterr stringFromDate:[NSDate date]];
            
            dict = [[NSMutableDictionary alloc]init];
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Due to be Served"];
            [arrTemp addObject:@"Days since Weaned"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            //if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++) {
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<2; i++) {
                    dict = [[NSMutableDictionary alloc]init];
                    
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Due to be Served" uppercaseString]] && ![[dictMenu objectForKey:[@"Due to be Served" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Due to be Served" uppercaseString]]?[dictMenu objectForKey:[@"Due to be Served" uppercaseString]]:@"" englishVersion:@"Due to be Served" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else {
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Due to be Served" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"Due to be Served"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"Due to be Served"];
                        }
                    }else  if (i==1) {
                        if ([dictMenu objectForKey:[@"Days since Weaned" uppercaseString]] && ![[dictMenu objectForKey:[@"Days since Weaned" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Days since Weaned" uppercaseString]]?[dictMenu objectForKey:[@"Days since Weaned" uppercaseString]]:@"" englishVersion:@"Days since Weaned" dataType:@"Text" defaultVal:@"5"];
                        }
                        else {
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Days since Weaned" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"5" forKey:@"Days since Weaned"];
                        }
                    }
                }
            }
        }else if ([_strEvent isEqualToString:@"11"]) {
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
            NSString *strSelectedDate = [dateFormatterr stringFromDate:[NSDate date]];
            
            //
            //            {
            //                [dateFormatterr setDateFormat:@"YYYYMMdd"];
            //                NSString *strSelectedDatee = [dateFormatterr stringFromDate:[NSDate date]];
            //                [dictJson setValue:strSelectedDatee forKey:[dict valueForKey:@"data_item_key"]];
            //            }
            //
            
            
            dict = [[NSMutableDictionary alloc]init];
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Due to be Weaned"];
            [arrTemp addObject:@"Days since Farrowed"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            // if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<2; i++) {
                    dict = [[NSMutableDictionary alloc]init];
                    
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Due to be Weaned" uppercaseString]] && ![[dictMenu objectForKey:[@"Due to be Weaned" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Due to be Weaned" uppercaseString]]?[dictMenu objectForKey:[@"Due to be Weaned" uppercaseString]]:@"" englishVersion:@"Due to be Weaned" dataType:@"Date" defaultVal:strSelectedDate];
                        }
                        else{
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Due to be Weaned" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:strSelectedDate forKey:@"Due to be Weaned"];
                            [_dictJsonReport setValue:[self set1000Date:strSelectedDate] forKey:@"Due to be Weaned"];
                        }
                    }else  if (i==1){
                        if ([dictMenu objectForKey:[@"Days since Farrowed" uppercaseString]] && ![[dictMenu objectForKey:[@"Days since Farrowed" uppercaseString]] isKindOfClass:[NSNull class]]) {
                            [self addObject:[dictMenu objectForKey:[@"Days since Farrowed" uppercaseString]]?[dictMenu objectForKey:[@"Days since Farrowed" uppercaseString]]:@"" englishVersion:@"Days since Farrowed" dataType:@"Text" defaultVal:@"21"];
                        }
                        else{
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Days since Farrowed" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                            [_dictDynamicReport setValue:@"21" forKey:@"Days since Farrowed"];
                        }
                    }
                }
            }
        }else if ([_strEvent isEqualToString:@"12"]) {
            dict = [[NSMutableDictionary alloc]init];
            [arrTemp removeAllObjects];
            [arrTemp addObject:@"Due to Farrow"];
            [arrTemp addObject:@"Days Since Served"];
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:arrTemp];
            // if (resultArray1.count!=0)
            {
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
                }
                
                [_arrDynamicReport removeAllObjects];
                
                for (int i=0; i<2; i++) {
                    dict = [[NSMutableDictionary alloc]init];
                    
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Due to Farrow" uppercaseString]] && ![[dictMenu objectForKey:[@"Due to Farrow" uppercaseString]] isKindOfClass:[NSNull class]]){
                            [self addObject:[dictMenu objectForKey:[@"Due to Farrow" uppercaseString]]?[dictMenu objectForKey:[@"Due to Farrow" uppercaseString]]:@"" englishVersion:@"Due to Farrow" dataType:@"Date" defaultVal:@""];
                        }
                        else{
                            [dict setValue:@"Date" forKey:@"dataType"];
                            [dict setValue:@"Due to Farrow" forKey:@"visible"];
                            
                            [_arrDynamicReport addObject:dict];
                        }
                    }else  if (i==1){
                        if ([dictMenu objectForKey:[@"Days Since Served" uppercaseString]] && ![[dictMenu objectForKey:[@"Days Since Served" uppercaseString]] isKindOfClass:[NSNull class]]){
                            [self addObject:[dictMenu objectForKey:[@"Days Since Served" uppercaseString]]?[dictMenu objectForKey:[@"Days Since Served" uppercaseString]]:@"" englishVersion:@"Days Since Served" dataType:@"Text" defaultVal:@""];
                        }
                        else{
                            [dict setValue:@"Text" forKey:@"dataType"];
                            [dict setValue:@"Days Since Served" forKey:@"visible"];
                            [_arrDynamicReport addObject:dict];
                        }
                    }
                }
            }
        }
        
        //
        //        for (NSMutableDictionary *dict  in _arrDynamicReport){
        //            [_dictDynamicReport setValue:@"" forKey:[dict valueForKey:@"visible"]];
        //        }
        NSLog(@"_dictDynamicReport=%@",_dictDynamicReport);
        
        [self.tblReportsDynamic reloadData];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in createDynamicGUIWithDefaultValues=%@",exception.description);
    }
}

- (IBAction)btnSnner_tapped:(id)sender {
    @try {
        barcodeScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"segueBarcode"];
        barcodeScannerViewController.delegate = self;
        [self.navigationController pushViewController:barcodeScannerViewController animated:NO];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnSnnerType_tapped=%@",exception.description);
    }
}

-(void)scannedBarcode:(NSString *)barcode{
    @try {
        //self.txtIdentity.text =  barcode;
        [self.dictDynamicReport setValue:barcode forKey:@"Identity"];
        [self.tblReportsDynamic reloadData];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in scannedBarcode=%@",exception.description);
    }
}

-(NSDate *)getFirstDateOfCurrentYear:(NSDate*)selecteddate
{
    //Get current year
    //NSDate *currentYear=[[NSDate alloc]init];
    // currentYear=selecteddate
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    [formatter1 setDateFormat:@"yyyy"];
    NSString *currentYearString = [formatter1 stringFromDate:selecteddate];
    [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
    //Get first date of current year
    NSString *firstDateString=[NSString stringWithFormat:@"10 01-01-%@",currentYearString];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"hh dd-MM-yyyy"];
    
    NSDate *firstDate = [[NSDate alloc]init];
    firstDate = [formatter2 dateFromString:firstDateString];
    
    NSLog(@"firstDate=%@",firstDate);
    
    return firstDate;
}

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    @try{
        NSDate *fromDate;
        NSDate *toDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];

        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                     interval:NULL forDate:fromDateTime];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                     interval:NULL forDate:toDateTime];
        
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:fromDate toDate:toDate options:0];
        
        return [difference day]+1;
    } @catch (NSException *exception) {
        NSLog(@"Exception in fillDefaultValuesForMandatoryFields=%@",exception.description);
    }
}


-(NSString*)set1000Date:(NSString*)strSelectedDate{
    @try {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        
        NSString *strBaseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZD"];
        if (isThousandFormatReport) {
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *dtselectedDate = [formatter dateFromString:strSelectedDate];
            [formatter setDateFormat:@"yyyyMMdd"];
            NSDate *BaseDate = [formatter dateFromString:strBaseDate];
            int days = [dtselectedDate timeIntervalSinceDate:BaseDate]/24/60/60;
            
            NSString *strDate = [NSString stringWithFormat:@"%05d",days];
            NSString *calFormat,*strFromString;
            
            if (strDate.length>=2) {
                calFormat = [strDate substringToIndex:2];
            }else {
                calFormat = strDate;
            }
            
            if (strDate.length>=3) {
                strFromString = [strDate substringFromIndex:2];
            }
            
            calFormat = [[calFormat stringByAppendingString:@"-"] stringByAppendingString:strFromString?strFromString:@""];
            [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
            
            NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
            
            return strSelectedDate100;
        }else if([self.strDateFormat isEqualToString:@"6"]){
            [formatter setDateFormat:@"MM/dd/yyyy"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSDate *dtselectedDate = [formatter dateFromString:strSelectedDate];
            NSDate *Firstdate= [self getFirstDateOfCurrentYear:dtselectedDate];
            
            // NSDate *BaseDate = [formatter dateFromString:strBaseDate];
            //int days = [dtselectedDate timeIntervalSinceDate:Firstdate]/24/60/60;
            // NSLog(@"days:%d",days);
            NSInteger days=[self daysBetweenDate:Firstdate andDate:dtselectedDate];
            NSLog(@"days:%ld",days);
            
            NSString *strDate = [NSString stringWithFormat:@"%03li",days];
            [formatter setDateFormat:@"yy"];
            
            NSString *strSelectedDateyearformat = [[[formatter stringFromDate:dtselectedDate] stringByAppendingString:@"-"] stringByAppendingString:strDate];
            
            /**********below code added by amit*********************************************/
            [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
            NSString *strSelectedDateDayOfyear = [[strSelectedDateyearformat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
            
            return strSelectedDateDayOfyear;
            
            /********************************************************************************/
            // return strSelectedDateyearformat;
            
        }
        else {
            return strSelectedDate;
        }
        //
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
}
-(NSString*)getTranslatedTextForString:(NSString*)Checkstring
{
    NSString *strSearchTitle;
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:Checkstring,nil]];
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    if (resultArray1.count!=0){
        for (int i=0; i<resultArray1.count; i++){
            [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
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

- (IBAction)btnAccessoryClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = strWait;
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showBTTalbe) userInfo:nil repeats:NO];
}

- (void)accessoryDisconnectedOnReports:(NSNotification *)notification {
    //  EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    NSLog(@"Disconnected");
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP" message:[self getTranslatedTextForString:@"Disconnected Successfully"] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                {
                                }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showBTTalbe
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"error :%@", error);
        }
        else{
            NSLog(@"You make it! Well done!!!");
        }
    }];
}

- (void)accessoryConnectedOnReports:(NSNotification *)notification
{
    NSLog(@"EAController::accessoryConnected");
    //self.session = nil;
    EAAccessory *accessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    if (accessory)
    {
        EADSessionController *sessionController = [EADSessionController  sharedController];
        [sessionController setupControllerForAccessory:accessory
                                    withProtocolString:@""];
        
        [sessionController openSession];
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP" message:[self getTranslatedTextForString:@"Connected Successfully"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                    {
                                    }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//Session data received method
- (void)_sessionDataReceivedOnReports:(NSNotification *)notification
{
    NSLog(@"Data received on Reports");
    
    NSData *data;
    EADSessionController *sessionController = (EADSessionController *)[notification object];
    uint32_t bytesAvailable = 0;
    
    while ((bytesAvailable = (uint32_t)[sessionController readBytesAvailable]) > 0) {
        data = [sessionController readData:bytesAvailable];
        if (data) {
            _totalBytesRead = _totalBytesRead + bytesAvailable;
        }
    }
    
    fullDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",fullDataString);
    
    if (!([fullDataString length]<17))
    {
        if ([fullDataString length]>17)
        {
            fullDataString = [fullDataString substringFromIndex:[fullDataString length] - 17];//For trimming suffix 100000//
            [self getRFID:fullDataString index:0]; //API Call
        }
        else if(fullDataString.length==17)
        {
            [self getRFID:fullDataString index:0]; //API Call
        }
    }
}
-(void)getRFID:(NSString*)transponder index:(NSInteger)index{
    @try {
        if ([[ControlSettings sharedSettings] isNetConnected ]) {
            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
            [_customIOS7AlertView showLoaderWithMessage:strWait];
            
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
            transponder = [transponder stringByTrimmingCharactersInSet:characterSet];
            
            NSMutableDictionary *dictHeaders = [[NSMutableDictionary alloc]init];
            //  [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
            //    [dict setValue:transponder forKey:@"transponder"];
            
            
            [ServerManager sendRequest:[NSString stringWithFormat:@"token=%@&transponder=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],transponder] idOfServiceUrl:15 headers:dictHeaders methodType:@"GET" onSucess:^(NSString *responseData) {
                [_customIOS7AlertView close];
                
                NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                {
                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                    {
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
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
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                             }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                    }
                }else{
                    NSLog(@"");
                    if (![[dictResponse valueForKey:@"ResultString"] isKindOfClass:[NSNull class]] && ![[dictResponse valueForKey:@"ResultString"] isEqualToString:@"No records"]) {
                        [_customIOS7AlertView close];
                        
                       txtDynamic.text = [dictResponse valueForKey:@"ResultString"];
                    }
                }
                NSLog(@"responseData=%@",responseData);
            } onFailure:^(NSMutableDictionary *responseData, NSError *error){
                [_customIOS7AlertView close];
            }];
        } else{
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:strNoInternet
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOk
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
        NSLog(@"Exception in getRFID=%@",exception.description);
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_alertForPickUpDateReport close];
    [_dtPickerReport setHidden:YES];
    [_pickerDropDownReport setHidden:YES];
    [_customIOS7AlertView close];
    [_alertForPickUpDateReport close];
    [_alertForDropDown setHidden:YES];
}
@end
