//
//  SearchViewController.m
//  PigChamp
//
//  Created by Venturelabour on 30/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchListViewController.h"
#import "CoreDataHandler.h"
#import "ServerManager.h"
#import "ControlSettings.h"

BOOL isExact = NO;
BOOL isPartial = NO;
int recordsSearch = 0;
NSInteger maxCountSearch = 20;
BOOL canCallSearch= NO;
BOOL isOpenSearch = NO;

@interface SearchViewController ()
{
    NSString* fullDataString;
}
@property(nonatomic, strong) IBOutlet EAAccessory *accessory;
@property(nonatomic) uint32_t totalBytesRead;
@property (nonatomic, strong) EADSessionController *eaSessionController;

@end

#pragma mark - view life cycle
@implementation SearchViewController

- (void)viewDidLoad
{
    self.btnAccessory.layer.cornerRadius = 15;
    self.btnAccessory.clipsToBounds = true;
    
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryConnectedOnSearch:)
                                                 name:EAAccessoryDidConnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDisconnectedOnSearch:)
                                                 name:EAAccessoryDidDisconnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceivedOnSearch:) name:EADSessionDataReceivedOnSearchNotification object:nil];

    @try {
        [super viewDidLoad];
        [self.scrSearchBg setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 600)];
        self.navigationController.navigationBar.translucent = NO;

        _btnSearch.layer.shadowColor = [[UIColor grayColor] CGColor];
        _btnSearch.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _btnSearch.layer.shadowOpacity = 1.0f;
        _btnSearch.layer.shadowRadius = 3.0f;
        
        [self registerForKeyboardNotifications];

        strMatchFilter = @"1";
        strSowBoarFilter =@"S";
        
        [self.btnExactMatch setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        [self.btnPartialMatch setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.btnSow setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        [self.btnBoar setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        // disable autocorrect By M.
        _txtIdentity.autocorrectionType = UITextAutocorrectionTypeNo;
       
        _txtIdentity.smartQuotesType = UITextSmartQuotesTypeNo;
        _txtIdentity.smartDashesType = UITextSmartDashesTypeNo;
        _txtIdentity.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in viewDidLoad=%@",exception.description);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
    [pref setValue:@"OnSearchScreen" forKey:@"CurrentPage"];
    [pref synchronize];

    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"FromSetting"];

    //
    isOpenSearch = NO;
    self.navigationItem.hidesBackButton = YES;
    tlc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    SlideNavigationController *sld = [SlideNavigationController sharedInstance];
    sld.delegate = self;
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button1 setImage:[UIImage imageNamed:@"Menu"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(updateMenuBarPositions) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button1];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.txtIdentity.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    self.txtIdentity.rightViewMode = UITextFieldViewModeAlways;
    self.txtIdentity.rightView = leftView;
    //
    
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:@"Search"];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
   // self.slidingViewController.title = @"Search";
    strIdentityMsg = @"You must enter a value for animal Identity.";
    strOK =@"OK";
    strPlzWait = @"Please Wait...";
    strNoInternet = @"You must be online for the app to function.";
    strUnauthorised =@"Your session has been expired. Please login again.";
    strServerErr= @"Server Error.";
    strSignOff = @"Signing off.";

    self.lblSow.text =@"Sow/Gilt";
    self.lblBoar.text =@"Boar";
    self.lblBoarGroup.text = @"Boar Group";
    self.lblSemenBatch.text =@"Semen Batch";
    self.lblExactMatch.text = @"Exact Match";
    self.lblPartialMatch.text = @"Partial match at beginning";
    
    self.title = @"Search";
    
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Exact match",@"Partial match at beginning",@"Search",@"IDentity",@"You must enter a value for animal Identity.",@"OK",@"Please Wait...",@"You must be online for the app to function.",@"Sow/Gilt",@"Boar",@"Your session has been expired. Please login again.",@"Server Error.",@"Signing off.",@"Signing off.",@"Semen Batch",nil]];
    
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    
    if (resultArray1.count!=0){
        for (int i=0; i<resultArray1.count; i++){
            [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
        }
        
        for (int i=0; i<14; i++) {
            if (i==0) {
                if ([dictMenu objectForKey:[@"Exact Match" uppercaseString]] && ![[dictMenu objectForKey:[@"Exact Match" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Exact Match" uppercaseString]] length]>0) {
                        self.lblExactMatch.text = [dictMenu objectForKey:[@"Exact Match" uppercaseString]]?[dictMenu objectForKey:[@"Exact Match" uppercaseString]]:@"";
                    }
//                    else{
//                        self.lblExactMatch.text = @"Exact Match";
//                    }
                }
//                else{
//                    self.lblExactMatch.text = @"Exact Match";
//                }
            }else  if (i==1){
                if ([dictMenu objectForKey:[@"Partial match at beginning" uppercaseString]] && ![[dictMenu objectForKey:[@"Partial match at beginning" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Partial match at beginning" uppercaseString]] length]>0) {
                        self.lblPartialMatch.text = [dictMenu objectForKey:[@"Partial match at beginning" uppercaseString]]?[dictMenu objectForKey:[@"Partial match at beginning" uppercaseString]]:@"";
                    }
//                    else{
//                        self.lblPartialMatch.text = @"Partial match at beginning";
//                    }
                }
//                else{
//                    self.lblPartialMatch.text = @"Partial match at beginning";
//                }
            }else  if (i==2){
                NSString *strSearchTitle;
                if ([dictMenu objectForKey:[@"Search" uppercaseString]] && ![[dictMenu objectForKey:[@"Search" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Search" uppercaseString]] length]>0) {
                        self.title = [dictMenu objectForKey:[@"Search" uppercaseString]]?[dictMenu objectForKey:[@"Search" uppercaseString]]:@"";
                        strSearchTitle = [dictMenu objectForKey:[@"Search" uppercaseString]]?[dictMenu objectForKey:[@"Search" uppercaseString]]:@""; //Changed by Priyanka on 3rdaug18
                    }else{
                        self.title = @"Search";
                    }
                }
                else{
                    self.title = @"Search";
                }
                
                [self.btnSearch setTitle:strSearchTitle forState:UIControlStateNormal];
               // self.slidingViewController.title = strSearchTitle;
            }else  if (i==3){
                if ([dictMenu objectForKey:[@"Identity" uppercaseString]] && ![[dictMenu objectForKey:[@"Identity" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Identity" uppercaseString]] length]>0) {
                        self.lblIdentityTitle.text = [dictMenu objectForKey:[@"Identity" uppercaseString]]?[dictMenu objectForKey:[@"Identity" uppercaseString]]:@"";
                    }else{
                        self.lblIdentityTitle.text = @"Identity";
                    }
                }
                else{
                    self.lblIdentityTitle.text = @"Identity";
                }
            }else  if (i==4){
                if ([dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]] && ![[dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]] length]>0) {
                        strIdentityMsg = [dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]]?[dictMenu objectForKey:[@"You must enter a value for animal Identity." uppercaseString]]:@"";
                    }
                }
            }else  if (i==5){
                if ([dictMenu objectForKey:[@"OK" uppercaseString]] && ![[dictMenu objectForKey:[@"OK" uppercaseString]] isKindOfClass:[NSNull class]]){
                    if ([[dictMenu objectForKey:[@"OK" uppercaseString]] length]>0){
                        strOK = [dictMenu objectForKey:[@"OK" uppercaseString]]?[dictMenu objectForKey:[@"OK" uppercaseString]]:@"";
                    }
                }
            }else  if (i==6){
                if ([dictMenu objectForKey:[@"Please Wait..." uppercaseString]] && ![[dictMenu objectForKey:[@"Please Wait..." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Please Wait..." uppercaseString]] length]>0) {
                        strPlzWait = [dictMenu objectForKey:[@"Please Wait..." uppercaseString]]?[dictMenu objectForKey:[@"Please Wait..." uppercaseString]]:@"";
                    }
                }
            }else  if (i==7){
                if ([dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] && ![[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]] length]>0) {
                        strNoInternet = [dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]?[dictMenu objectForKey:[@"You must be online for the app to function." uppercaseString]]:@"";
                    }
                }
            }else if (i==8) {
                if ([dictMenu objectForKey:[@"Sow/Gilt" uppercaseString]] && ![[dictMenu objectForKey:[@"Sow/Gilt" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Sow/Gilt" uppercaseString]] length]>0) {
                        self.lblSow.text = [dictMenu objectForKey:[@"Sow/Gilt" uppercaseString]]?[dictMenu objectForKey:[@"Sow/Gilt" uppercaseString]]:@"";
                    }
                    //                    else{
                    //                        self.lblExactMatch.text = @"Exact Match";
                    //                    }
                }
                //                else{
                //                    self.lblExactMatch.text = @"Exact Match";
                //                }
            }else if (i==9) {
                if ([dictMenu objectForKey:[@"Boar/Boar Group" uppercaseString]] && ![[dictMenu objectForKey:[@"Boar/Boar Group" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Boar/Boar Group" uppercaseString]] length]>0) {
                        self.lblBoar.text = [dictMenu objectForKey:[@"Boar/Boar Group" uppercaseString]]?[dictMenu objectForKey:[@"Boar/Boar Group" uppercaseString]]:@"";
                    }
                    //                    else{
                    //                        self.lblExactMatch.text = @"Exact Match";
                    //                    }
                }
                //                else{
                //                    self.lblExactMatch.text = @"Exact Match";
                //                }
            }else  if (i==10){
                if ([dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] && ![[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]] length]>0) {
                        strUnauthorised = [dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]?[dictMenu objectForKey:[@"Your session has been expired. Please login again." uppercaseString]]:@"";
                    }
                }
            }else  if (i==11){
                if ([dictMenu objectForKey:[@"Server Error." uppercaseString]] && ![[dictMenu objectForKey:[@"Server Error." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Server Error." uppercaseString]] length]>0) {
                        strServerErr = [dictMenu objectForKey:[@"Server Error." uppercaseString]]?[dictMenu objectForKey:[@"Server Error." uppercaseString]]:@"";
                    }
                }
            }else  if (i==12){
                if ([dictMenu objectForKey:[@"Signing off." uppercaseString]] && ![[dictMenu objectForKey:[@"Signing off." uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Signing off." uppercaseString]] length]>0) {
                        strSignOff = [dictMenu objectForKey:[@"Signing off." uppercaseString]]?[dictMenu objectForKey:[@"Signing off." uppercaseString]]:@"";
                    }
                }
            }else if (i==13) {
                if ([dictMenu objectForKey:[@"Semen Batch" uppercaseString]] && ![[dictMenu objectForKey:[@"Semen Batch" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Semen Batch" uppercaseString]] length]>0) {
                        self.lblBoar.text = [dictMenu objectForKey:[@"Semen Batch" uppercaseString]]?[dictMenu objectForKey:[@"Semen Batch" uppercaseString]]:@"";
                    }
                    //                    else{
                    //                        self.lblExactMatch.text = @"Exact Match";
                    //                    }
                }
                //                else{
                //                    self.lblExactMatch.text = @"Exact Match";
                //                }
            }
        }
    }
}

-(void)viewDidLayoutSubviews {
    @try {
        [super viewDidLayoutSubviews];
       // [self.scrSearchBg setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
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
        
        if (!isOpenSearch) {
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
        
        isOpenSearch = !isOpenSearch;
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

        [[NSNotificationCenter defaultCenter]removeObserver:self];
        self.vwOverlay.hidden = YES;
        isOpenSearch = !isOpenSearch;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in removeView=%@",exception.description);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    @try{
        if([string isEqualToString:@""])
             return YES;
        
        //NSLog(@"lenght=%d",textField.text.length);
            if (textField.text.length>30) {
                return NO;
            }
        
        return YES;
    }
    @catch (NSException *exception){
        NSLog(@"Exception in shouldChangeCharactersInRange- %@",[exception description]);
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
#pragma mark -Textfield related  methods
- (void)registerForKeyboardNotifications{
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
        NSLog(@"Exception in registerForKeyboardNotifications =%@",exception.description);
    }
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    @try {
        }
       @catch (NSException *exception) {
        NSLog(@"Exception in keyboardWasShown in ViewController =%@",exception.description);
    }
}
- (void) keyboardWillHide:(NSNotification *)notification {
    @try {
        // UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        // self.scrBackground.contentInset = contentInsets;
        //self.scrBackground.scrollIndicatorInsets = contentInsets;
        //[self.scrBackground setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 600)];
        //[self.scrSearchBg scrollRectToVisible:CGRectMake(0, 0, self.scrSearchBg.frame.size.width, self.scrSearchBg.frame.size.height) animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception  in keyboardWillHide in ViewController =%@",exception.description);
    }
}

- (IBAction)btnSearch_tapped:(id)sender {
    @try {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"FromHistory"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"deletedIndetity"];

        [self.txtIdentity resignFirstResponder];
        
        NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
        
        if ([self.txtIdentity.text isEqualToString:@""] || [self.txtIdentity.text isEqual:nil] || self.txtIdentity.text == nil || [[self.txtIdentity.text stringByTrimmingCharactersInSet: set] length] == 0){
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:strIdentityMsg
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
                                     [self.txtIdentity becomeFirstResponder];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
        else {
            //[self performSegueWithIdentifier:@"segueSearchList" sender:self];
           
            if ([[ControlSettings sharedSettings] isNetConnected ]) {
                _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                [_customIOS7AlertView showLoaderWithMessage:strPlzWait];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
                [dict setValue:self.txtIdentity.text forKey:@"Identity"];
                [dict setValue:strMatchFilter forKey:@"match"];
                [dict setValue:strSowBoarFilter forKey:@"SexType"];
                [dict setValue:@"1" forKey:@"FromRec"];
                [dict setValue:@"20" forKey:@"ToRec"];
                [dict setValue:@"" forKey:@"sortFld"];
                [dict setValue:@"0" forKey:@"sortOrd"];
                
                [self callService:dict];
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
           
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnSearch_tapped=%@",exception.description);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    @try {
        NSLog(@"self.txtIdentity.text=%@",self.txtIdentity.text);
        if ([segue.identifier isEqualToString:@"segueSearchList"]) {
            SearchListViewController *searchListViewController = segue.destinationViewController;
            searchListViewController.strIdentity = self.txtIdentity.text;
            searchListViewController.strMatchfilter = strMatchFilter;
            searchListViewController.arrSearchList = arrSearch;
            searchListViewController.strIdentityText = self.txtIdentity.text;
            searchListViewController.strMatchfilterBoarSow = strSowBoarFilter;
           // [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",51] forKey:@"FromRec"];
           // [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",100] forKey:@"ToRec"];
        }else {
           HistorySummaryViewController *historySummaryViewController = [segue destinationViewController];
           historySummaryViewController.strIdentityId = [[arrSearch objectAtIndex:0] valueForKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"FromDataEntry"];
            historySummaryViewController.strTitle = [[arrSearch objectAtIndex:0] valueForKey:@"Identity"];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in prepareForSegue in FarmSelection =%@",exception.description);
    }
}

- (IBAction)btnExactNPartialMatch_tapped:(id)sender {
    @try {
        UIButton *btn = (UIButton*)sender;
        [self.btnExactMatch setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.btnPartialMatch setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        
        if (btn.tag==1){
            strMatchFilter = @"1";
           [self.btnExactMatch setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
        else{
            strMatchFilter = @"2";
            [self.btnPartialMatch setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnExactNPartialMatch_tapped =%@",exception.description);
    }
}

- (IBAction)btnSowBoar_tapped:(id)sender {
    @try {
        UIButton *btn = (UIButton*)sender;
        [self.btnSow setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.btnBoar setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.btnSemenBatch setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.btnBoarGroup setBackgroundImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];


        if (btn.tag==1){
            strSowBoarFilter = @"S";
             [self.btnSow setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
        else if(btn.tag==2) {
                strSowBoarFilter = @"B";
                [self.btnBoar setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
          }
        else if(btn.tag==3) {
              strSowBoarFilter = @"A";
              [self.btnSemenBatch setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
        else{
            strSowBoarFilter = @"G";
            [self.btnBoarGroup setBackgroundImage:[UIImage imageNamed:@"tickmark"] forState:UIControlStateNormal];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnExactNPartialMatch_tapped =%@",exception.description);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    @try{
        [textField resignFirstResponder];
        
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in textFieldShouldReturn in ViewController- %@",[exception description]);
    }
}

- (IBAction)btnSnnerType_tapped:(id)sender {
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

-(void)callService:(NSMutableDictionary*)dict {
    @try {
       canCallSearch = YES;
       
        [ServerManager sendRequest:[NSString stringWithFormat:@"token=%@&Identity=%@&match=%@&SexType=%@&FromRec=%@&ToRec=%@&sortFld=%@&sortOrd=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],self.txtIdentity.text,strMatchFilter,strSowBoarFilter,[NSString stringWithFormat:@"%d",recordsSearch+1],[NSString stringWithFormat:@"%d",recordsSearch+20],@"",@"0"] idOfServiceUrl:10 headers:dict methodType:@"GET" onSucess:^(NSString *responseData) {
            canCallSearch = NO;
             arrSearch = [[NSMutableArray alloc]init];
            [_customIOS7AlertView close];
            
            id response = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
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
            }else if ([[response objectForKey:@"_Pig"] isKindOfClass:[NSArray class]]) {
                [arrSearch addObjectsFromArray:[response objectForKey:@"_Pig"]];
                
                NSString *strRec = [[response objectForKey:@"_RecCount"] objectForKey:@"totRecs"];
                if ([strRec localizedCaseInsensitiveContainsString:@"Not connected"])
                {//to do too
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:NSLocalizedString(@"connection_lost", @"")
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
                                             if ([[ControlSettings sharedSettings] isNetConnected ]){
                                                 _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                                                 [_customIOS7AlertView showLoaderWithMessage:strSignOff];
                                                 
                                                 [ServerManager sendRequestForLogout:^(NSString *responseData) {
                                                     NSLog(@"%@",responseData);
                                                     [_customIOS7AlertView close];
                                                     
                                                     if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])  {
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
                                                     
                                                     // [[NSNotificationCenter defaultCenter]postNotificationName:@"CloseAlert" object:responseData];
                                                     
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
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
                
               // maxCountSearchList = [strRec integerValue];
                [[NSUserDefaults standardUserDefaults] setObject:strRec forKey:@"maxCount"];
                [[NSUserDefaults standardUserDefaults] setObject:strRec forKey:@"totRec"];

                if (arrSearch.count==1) {
                    [self performSegueWithIdentifier:@"segueHistorySummary" sender:self];
                }else {
                    [self performSegueWithIdentifier:@"segueSearchList" sender:self];
                }
            }
            else {
                
            }
        } onFailure:^(NSMutableDictionary *responseData, NSError *error) {
            [_customIOS7AlertView close];

            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
            [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *strDate = [dateformate stringFromDate:[NSDate date]];
            
            NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event(on Edit)=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate, self.title];
            [tracker set:kGAIScreenName value:strErr];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

            if ([responseData.allKeys containsObject:@"code"]) {
                if ([[responseData valueForKey:@"code"]integerValue] ==401) {
                    
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
                }else if ([[responseData valueForKey:@"code"]integerValue] ==408) {
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[responseData valueForKey:@"Error"]
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
                                             //[self.navigationController popViewControllerAnimated:YES];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    
                    // [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            else{
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:[responseData valueForKey:@"Error"]
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
            }        }];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in callService = %@",exception.description);
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

- (IBAction)btnAccessoryOnSearchClicked:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = strPlzWait;
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showBTTalbe) userInfo:nil repeats:NO];
}
- (void)accessoryDisconnectedOnSearch:(NSNotification *)notification {
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

- (void)accessoryConnectedOnSearch:(NSNotification *)notification
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
- (void)_sessionDataReceivedOnSearch:(NSNotification *)notification
{
    NSLog(@"Data Received on search");

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
//    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
//    [pref setValue:@"" forKey:@"CurrentPage"];
//    [pref synchronize];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
          [_customIOS7AlertView close];
}
@end
