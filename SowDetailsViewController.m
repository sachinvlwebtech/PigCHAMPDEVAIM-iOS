//
//  SowDetailsViewController.m
//  PigChamp
//
//  Created by Venturelabour on 11/03/16.
//  Copyright © 2016 Venturelabour. All rights reserved.
//

#import "SowDetailsViewController.h"
#import "SimpeNdetailedSowReportViewController.h"
#import "CoreDataHandler.h"
#import <Google/Analytics.h>
#import "ControlSettings.h"

BOOL isOpenSowDetailReport = NO;

@interface SowDetailsViewController ()
{
    NSString* fullDataString;
}
@property(nonatomic, strong) IBOutlet EAAccessory *accessory;
@property(nonatomic) uint32_t totalBytesRead;
@property (nonatomic, strong) EADSessionController *eaSessionController;
@end

@implementation SowDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnAccessoryOnSowDetails.layer.cornerRadius = 15;
    self.btnAccessoryOnSowDetails.clipsToBounds = true;
    
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryConnectedOnSowDetails:)
                                                 name:EAAccessoryDidConnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDisconnectedOnSowDetails:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceivedOnSowDetails:) name:EADSessionDataReceivedOnSowDetailsReportNotification object:nil];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setValue:@"0" forKey:@"reload"];
    [pref synchronize];
    
    tlc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button1 setImage:[UIImage imageNamed:@"Menu"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(updateMenuBarPositions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
    
    SlideNavigationController *sld = [SlideNavigationController sharedInstance];
    sld.delegate = self;

    
    _btnRunReport.layer.shadowColor = [[UIColor grayColor] CGColor];
    _btnRunReport.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    _btnRunReport.layer.shadowOpacity = 1.0f;
    _btnRunReport.layer.shadowRadius = 3.0f;

    _btnCancel.layer.shadowColor = [[UIColor grayColor] CGColor];
    _btnCancel.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    _btnCancel.layer.shadowOpacity = 1.0f;
    _btnCancel.layer.shadowRadius = 3.0f;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Simple and Detailed Sow Report input screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(-20, 0, 22, 22);
    [button setBackgroundImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnBack_tapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    self.navigationItem.leftBarButtonItem=barButton;
    
    self.title = @"Sow Details";

    strRptType = @"1";
    [self.btnSimple setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
    [self.btnDetailed setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
    
    strValidationMsg = @"Please enter Sow Identity.";
    strOK = @"OK";
    strUnauthorised = @"Your session has been expired. Please login again.";
    strServerErr  = @"Server Error.";
    strCancel  = @"Cancel";
    strRunReport = @"RUN REPORT";
    strSimple = @"Simple";
    strDetailed = @"Detailed";
    strIdentity = @"Identity";
    strPlzWait = @"Please Wait...";
    strNoInternet = @"You must be online for the app to function.";
    
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Please enter Sow Identity.",@"OK",@"Sow Details",@"Your session has been expired. Please login again.",@"Server Error.",@"Cancel",@"Run Report",@"Simple",@"Detailed",@"Identity",@"Please Wait...",@"You must be online for the app to function.",nil]];
    
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    
    if (resultArray1.count!=0){
        for (int i=0; i<resultArray1.count; i++){
            [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
        }
        
        for (int i=0; i<12; i++) {
            if (i==0) {
                if ([dictMenu objectForKey:[@"Please enter Sow Identity." uppercaseString]] && ![[dictMenu objectForKey:[@"Please enter Sow Identity." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Please enter Sow Identity." uppercaseString]] length]>0) {
                        strValidationMsg = [dictMenu objectForKey:[@"Please enter Sow Identity." uppercaseString]]?[dictMenu objectForKey:[@"Please enter Sow Identity." uppercaseString]]:@"";
                    }
                }
            }else  if (i==1) {
                if ([dictMenu objectForKey:[@"OK" uppercaseString]] && ![[dictMenu objectForKey:[@"OK" uppercaseString]] isKindOfClass:[NSNull class]]){
                    if ([[dictMenu objectForKey:[@"OK" uppercaseString]] length]>0){
                        strOK = [dictMenu objectForKey:[@"OK" uppercaseString]]?[dictMenu objectForKey:[@"OK" uppercaseString]]:@"";
                    }
                }
            }else  if (i==2) {
                if ([dictMenu objectForKey:[@"Sow Details" uppercaseString]] && ![[dictMenu objectForKey:[@"Sow Details" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Sow Details" uppercaseString]] length]>0) {
                        self.title = [dictMenu objectForKey:[@"Sow Details" uppercaseString]]?[dictMenu objectForKey:[@"Sow Details" uppercaseString]]:@"";
                    }
                }
            }else  if (i==3) {
                if ([dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] && ![[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] length]>0) {
                        strUnauthorised = [dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]?[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]:@"";
                    }
                }
            }else  if (i==4){
                if ([dictMenu objectForKey:[@"Server Error." uppercaseString]] && ![[dictMenu objectForKey:[@"Server Error." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Server Error." uppercaseString]] length]>0) {
                        strServerErr = [dictMenu objectForKey:[@"Server Error." uppercaseString]]?[dictMenu objectForKey:[@"Server Error." uppercaseString]]:@"";
                    }
                }
            }else  if (i==5){
                if ([dictMenu objectForKey:[@"Cancel" uppercaseString]] && ![[dictMenu objectForKey:[@"Cancel" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Cancel" uppercaseString]] length]>0) {
                        strCancel = [dictMenu objectForKey:[@"Cancel" uppercaseString]]?[dictMenu objectForKey:[@"Cancel" uppercaseString]]:@"";
                    }
                }
                [self.btnCancel setTitle:strCancel forState:UIControlStateNormal];
            }
            else  if (i==6){
                if ([dictMenu objectForKey:[@"Run Report" uppercaseString]] && ![[dictMenu objectForKey:[@"Run Report" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Run Report" uppercaseString]] length]>0) {
                        strRunReport = [dictMenu objectForKey:[@"Run Report" uppercaseString]]?[dictMenu objectForKey:[@"Run Report" uppercaseString]]:@"";
                    }
                }
                [self.btnRunReport setTitle:strRunReport forState:UIControlStateNormal];
            }
            else  if (i==7){
                if ([dictMenu objectForKey:[@"Simple" uppercaseString]] && ![[dictMenu objectForKey:[@"Simple" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Simple" uppercaseString]] length]>0) {
                        strSimple = [dictMenu objectForKey:[@"Simple" uppercaseString]]?[dictMenu objectForKey:[@"Simple" uppercaseString]]:@"";
                    }
                }
                self.lblSimple.text = strSimple;
            }
            else  if (i==8){
                if ([dictMenu objectForKey:[@"Detailed" uppercaseString]] && ![[dictMenu objectForKey:[@"Detailed" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Detailed" uppercaseString]] length]>0) {
                        strDetailed = [dictMenu objectForKey:[@"Detailed" uppercaseString]]?[dictMenu objectForKey:[@"Detailed" uppercaseString]]:@"";
                    }
                }
                self.lblDetailed.text = strDetailed;
            }else  if (i==9){
                if ([dictMenu objectForKey:[@"Identity" uppercaseString]] && ![[dictMenu objectForKey:[@"Identity" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Identity" uppercaseString]] length]>0) {
                        strIdentity = [dictMenu objectForKey:[@"Identity" uppercaseString]]?[dictMenu objectForKey:[@"Identity" uppercaseString]]:@"";
                    }
                }
                self.lblIdentityTitle.text = strIdentity;
            }else  if (i==10) {
                if ([dictMenu objectForKey:[@"Please Wait..." uppercaseString]] && ![[dictMenu objectForKey:[@"Please Wait..." uppercaseString]] isKindOfClass:[NSNull class]]){
                    if ([[dictMenu objectForKey:[@"Please Wait..." uppercaseString]] length]>0){
                        strPlzWait = [dictMenu objectForKey:[@"Please Wait..." uppercaseString]]?[dictMenu objectForKey:[@"Please Wait..." uppercaseString]]:@"";
                    }
                }
            }else  if (i==11) {
                if ([dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] && ![[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] isKindOfClass:[NSNull class]]){
                    if ([[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] length]>0){
                        strNoInternet = [dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]?[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]:@"";
                    }
                }
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    @try {
        [super viewWillAppear:animated];
        
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        [pref setValue:@"OnSowDetailsReportScreen" forKey:@"CurrentPage"];
        [pref synchronize];

        isOpenSowDetailReport = NO;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

-(void)viewDidLayoutSubviews {
    @try {
        [super viewDidLayoutSubviews];
        [self.scrSowBg setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    }
    @catch (NSException *exception){
        NSLog(@"Exception in viewDidLayoutSubviews in ViewController=%@",exception.description);
    }
}

-(void)updateMenuBarPositions {
    @try {
        [self.txtIdentity resignFirstResponder];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeView:) name:@"CloseAlert" object:nil];

        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        
        if (!isOpenSowDetailReport) {
            self.vwOverlay.hidden = NO;
            [tlc.view setFrame:CGRectMake(-320, 0, self.view.frame.size.width-64, currentWindow.frame.size.height)];
            [currentWindow addSubview:tlc.view];
            
            [UIView animateWithDuration:0.3 animations:^{
                [tlc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width-64, currentWindow.frame.size.height)];
            }];
        }else {
            self.vwOverlay.hidden = YES;
            [tlc.view removeFromSuperview];
        }
        
        isOpenSowDetailReport = !isOpenSowDetailReport;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception = %@",exception.description);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    @try {
        if([string isEqualToString:@""])
            return YES;
        
        if (textField.text.length>14) {
            return NO;
        }
        
        return YES;
    }
    @catch (NSException *exception){
        NSLog(@"Exception in shouldChangeCharactersInRange- %@",[exception description]);
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
        }else if (responseData.integerValue ==401) {
            
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
        }else if ([responseData isEqualToString:@""]){
            [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        }
//        else{
//            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
//                                                                                       message:strServerErr
//                                                                                preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction* ok = [UIAlertAction
//                                 actionWithTitle:strOK
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
        isOpenSowDetailReport = !isOpenSowDetailReport;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in removeView=%@",exception.description);
    }
}
//- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
//    return YES;
//}

- (IBAction)btnSnner_tapped:(id)sender {
    @try {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        //NSString *strRFID = [pref valueForKey:@"isRFID"];
        NSString *strBar = [pref valueForKey:@"isBarcode"];
        
        if ([strBar isEqualToString:@"1"]){
            barcodeScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"segueBarcode"];
            barcodeScannerViewController.delegate = self;
            [self.navigationController pushViewController:barcodeScannerViewController animated:NO];
        }else{
            
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnSnnerType_tapped=%@",exception.description);
    }
}

-(void)scannedBarcode:(NSString *)barcode{
    @try {
        self.txtIdentity.text =  barcode;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in scannedBarcode=%@",exception.description);
    }
}

- (IBAction)btnRunReport_tapped:(id)sender {
    @try {
        if ([self.txtIdentity.text isEqualToString:@""] || [self.txtIdentity.text isEqual:nil] || self.txtIdentity.text == nil) {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:strValidationMsg
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOK
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     [self.txtIdentity becomeFirstResponder];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }else {
            [self performSegueWithIdentifier:@"segueSowReport" sender:self];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnRunReport_tapped=%@",exception.description);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    @try {
        [textField resignFirstResponder];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in textFieldShouldReturn in ViewController- %@",[exception description]);
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

- (IBAction)btnSimpleNDetailed_tapped:(id)sender {
    @try {
        UIButton *btn = (UIButton*)sender;
        [self.btnSimple setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.btnDetailed setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        
        if (btn.tag==1){
            strRptType = @"1";
            [self.btnSimple setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
        else{
            strRptType = @"2";
            [self.btnDetailed setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnExactNPartialMatch_tapped =%@",exception.description);
    }
}

-(void)btnBack_tapped {
    @try {
        [self.navigationController popViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnBack_tapped=%@",exception.description);
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    @try {
        SimpeNdetailedSowReportViewController *simpeNdetailedSowReportViewController = segue.destinationViewController;
        simpeNdetailedSowReportViewController.strType = strRptType;
            simpeNdetailedSowReportViewController.strIdentity = self.txtIdentity.text;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in prepareForSegue =%@",exception.description);
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
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
- (IBAction)btnAccessoryOnSowDetailsClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = strPlzWait;
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showBTTalbe) userInfo:nil repeats:NO];
}
- (void)accessoryDisconnectedOnSowDetails:(NSNotification *)notification {
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
    //***commented below code by M for showing the alert if the bluetooth device already connected bug-27371
   /* [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"error :%@", error);
        }
        else{
            NSLog(@"You make it! Well done!!!");
        }
    }];*/
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                             connectedAccessories];
    if (accessories)
    {
        for (EAAccessory *obj in accessories){
            EADSessionController *sessionController = [EADSessionController  sharedController];
            [sessionController setupControllerForAccessory:obj
                                        withProtocolString:@""];
            [sessionController openSession];
            
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP" message:[self getTranslatedTextForString:@"Bluetooth device is already connected"] preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                        {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    else{
        [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"error :%@", error);
        }
        else{
            NSLog(@"You make it! Well done!!!");
        }
    }];
    }
}

- (void)accessoryConnectedOnSowDetails:(NSNotification *)notification
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
- (void)_sessionDataReceivedOnSowDetails:(NSNotification *)notification
{
    NSLog(@"Data Received on sow details");

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
            [_customIOS7AlertView showLoaderWithMessage:strPlzWait];
            
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
            transponder = [transponder stringByTrimmingCharactersInSet:characterSet];
            
            NSMutableDictionary *dictHeaders = [[NSMutableDictionary alloc]init];
            //  [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
            //    [dict setValue:transponder forKey:@"transponder"];
            //transponder = @"982000062204796";
           // NSLog(@"The Token is ^^^^^^^^^^^^^^^^^^^^^^%@",dictHeaders);
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
                    NSLog(@"");
                    if (![[dictResponse valueForKey:@"ResultString"] isKindOfClass:[NSNull class]] && ![[dictResponse valueForKey:@"ResultString"] isEqualToString:@"No records"]) {
                        [_customIOS7AlertView close];
                        
                        self.txtIdentity.text = [dictResponse valueForKey:@"ResultString"];
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
        NSLog(@"Exception in getRFID=%@",exception.description);
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
        [_customIOS7AlertView close];
//    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
//    [pref setValue:@"" forKey:@"CurrentPage"];
//    [pref synchronize];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
