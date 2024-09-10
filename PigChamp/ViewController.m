//
//  ViewController.m
//  PigChamp
//
//  Created by Venturelabour on 20/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreDataHandler.h"
///#import "FarmSelectionViewController.h"
#import "ServerManager.h"
#import <Google/Analytics.h>
#import "ConfigurationViewController.h"

@interface ViewController ()
@end

@implementation ViewController

BOOL isShowMessage = FALSE;
BOOL isActive = FALSE;
BOOL isCriticalUpdate = FALSE;
BOOL isOnetime        = FALSE;
NSString *Message        = @"";
NSString *newVersion     = @"";
NSString *Success        = @"";

#pragma mark - View life cycle
- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        //called below method for V10 By M.
        [self getServerVersion];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationHasBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callNewBaseURLSaved)
                                                     name:@"NewBaseURLSavedNotification"
                                                   object:nil];
        
        [self.txtPasswordtextField addPasswordField]; // call a method
        self.navigationController.navigationBar.translucent = NO;
        
        //contentInsetsScroll = self.scrBackground.contentInset;
        //self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
        
        _btnSubmit.layer.shadowColor = [[UIColor grayColor] CGColor];
        _btnSubmit.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _btnSubmit.layer.shadowOpacity = 1.0f;
        _btnSubmit.layer.shadowRadius = 3.0f;
        
        //To set version
        self.lblVersion.text =  [NSString stringWithFormat:@"Ver %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        _pref = [NSUserDefaults standardUserDefaults];
        [self.btnLanguage setTitle:[_pref valueForKey:@"selectedLanguage"] forState:UIControlStateNormal];
        
        [self callLoadLanguageData];
         
        self.title = @"PigCHAMP";
        self.btnLanguage.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
        _arrLanguage=[[NSMutableArray alloc]init];
        
        
        [self callGetLanguageListAPI];
        
        [self registerForKeyboardNotifications];
        //^^^^^ added below for Bug-29001 By M.
        strOK =@"OK";
        strSignOff = @"Signing off.";
        strNoInternet = @"You must be online for the app to function.";
        strUnauthorised =@"Your session has been expired. Please login again.";
        strServerErr= @"Server Error.";
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in viewDidLoad in ViewController =%@",exception.description);
    }
    
    [self callCheckCurrentVersion]; //Code added by Priyanka July 18//
}
//Added method for Server Issue of V10 By M

-(void)getServerVersion{
    @try{
            if ([[ControlSettings sharedSettings] isNetConnected ]){
               
                [ServerManager getServerVersionDetails:^(NSString *responseData) {
                   
                        NSDictionary *dictreponse = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        NSNumber *majorVersionNumber = dictreponse[@"MajorVersion"];
                                  
                                   if (majorVersionNumber != nil) {
                                       NSInteger majorVersion = [majorVersionNumber integerValue];
                                       [_pref setInteger:majorVersion forKey:@"ServerVersion"];
                                       NSLog(@"Major Version in LoginView: %ld", (long)majorVersion);
                                   } else {
                                       NSLog(@"Major Version is not available in the JSON.");
                                   }
                       
                    
                } onFailure:^(NSString *responseData, NSError *error) {
                    [_customIOS7AlertView close];
                    
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                    [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                    
                    NSString *strErr = [NSString stringWithFormat:@"User Name = %@,,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Server Version"];
                    [tracker set:kGAIScreenName value:strErr];
                    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:responseData
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                        //[self.navigationController popToRootViewControllerAnimated:YES];
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }];
            }
        }@catch (NSException *exception) {
            NSLog(@"Exception in get language list=%@",exception.description);
        }
} 

//>>>trello
-(void)callLoadLanguageData{
    
        @try {
        if ([[ControlSettings sharedSettings] isNetConnected ]){
            
            [ServerManager getAllLanguageTranslation:^(NSString *responseData) {
                
                    NSArray *_arrTransLanguage = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                //Trello
                  _arrayEnglish = [[NSMutableArray alloc]init];                    if(_arrTransLanguage.count > 0){
                        _arrayEnglish = [_arrTransLanguage copy];
                        
                    }
                }
             onFailure:^(NSString *responseData, NSError *error) {
                [_customIOS7AlertView close];
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Simple Report"];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:[@"" valueForKey:@"Error"]
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         //[self.navigationController popToRootViewControllerAnimated:YES];
                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }];
        }
        else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"You must be online for the app to function."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
        }@catch (NSException *exception) {
            NSLog(@"Exception in get language list=%@",exception.description);
        }
    }
/*
-(void)callLoadLanguageData{
    NSString *str = [[[_pref valueForKey:@"baseURL"] stringByAppendingString:@"lngmin/"] stringByAppendingString:[NSString stringWithFormat:@"%@_mob.lng",[_pref valueForKey:@"selectedLanguage"]]];
     NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:str]];
     
     NSString *gameFileContents = [[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding];
     NSLog(@"gameFileContents%@", gameFileContents);
     
     NSMutableArray* allLinedStrings = (NSMutableArray*)[gameFileContents componentsSeparatedByString:@"\r\n"];
     NSMutableArray *newArray = [[NSMutableArray alloc]init];
     _arrayEnglish = [[NSMutableArray alloc]init];
     
     for (NSString *line in allLinedStrings){
         @autoreleasepool {
             NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
             newArray = (NSMutableArray*)[line componentsSeparatedByString:@"="];
             
             if (newArray.count==2){
                 [dict setValue:[newArray objectAtIndex:0] forKey:@"englishText"];
                 [dict setValue:[newArray objectAtIndex:1] forKey:@"translatedText"];
             }
             [_arrayEnglish addObject:dict];
         }
     }
}*/
-(void)callGetLanguageListAPI
{
    @try {
    if ([[ControlSettings sharedSettings] isNetConnected ]){
        //_customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        //[_customIOS7AlertView showLoaderWithMessage:NSLocalizedString(@"Loging in...", "")];
        
        [ServerManager sendRequestForLanguageList:^(NSString *responseData) {
            
            if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""]){
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:responseData
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //[[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                        //[myAlertController dismissViewControllerAnimated:YES completion:nil];
                                     }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }else{
                NSArray *yourArray = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSSortDescriptor * sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                _arrLanguage= (NSMutableArray*)[yourArray sortedArrayUsingDescriptors:@[sortDesc]];
                
                NSLog(@"_arrLanguage=%@",_arrLanguage);
            }
        } onFailure:^(NSString *responseData, NSError *error) {
            [_customIOS7AlertView close];
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
            [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *strDate = [dateformate stringFromDate:[NSDate date]];
            
            NSString *strErr = [NSString stringWithFormat:@"User Name = %@,,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Simple Report"];
            [tracker set:kGAIScreenName value:strErr];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:[responseData valueForKey:@"Error"]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //[self.navigationController popToRootViewControllerAnimated:YES];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }];
    }
    else {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                   message:@"You must be online for the app to function."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
        UIView *controllerView = myAlertController.view;
        [controllerView addSubview:logoImageView];
        [controllerView bringSubviewToFront:logoImageView];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [myAlertController addAction: ok];
        [self presentViewController:myAlertController animated:YES completion:nil];
    }
    }@catch (NSException *exception) {
        NSLog(@"Exception in get language list=%@",exception.description);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    @try {
        [super viewWillAppear:animated];
        
        //Call Session timeout API
        [self callSessionTimeoutValue];
        
        self.txtPasswordtextField.secureTextEntry = TRUE;
         self.txtPasswordtextField.text = @"";
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults valueForKey:@"userName"] != nil)
        {
            NSString * strURL =[defaults objectForKey:@"userName"];
            self.txtLogintextField.text = strURL;
        }
        
        //For displaying previously saved acc number
        if ([defaults valueForKey:@"accountNumber"] != nil)
        {
            NSString * strURL =[defaults objectForKey:@"accountNumber"];
            self.txtAccountNumber.text = strURL;
        }

        [self callGetLanguageListAPI];
      //  [defaults setObject:@"NewURLSaved" forKey:@"BaseURLStatus"];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in viewWillAppear=%@",exception.description);
    }
}

-(void)viewDidLayoutSubviews {
    @try {      [super viewDidLayoutSubviews];
        [self.scrBackground setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 500)];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in viewDidLayoutSubviews in ViewController=%@",exception.description);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    @try {
        if (pickerView==self.pickerLanguage) {
            return [_arrLanguage count];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in numberOfRowsInComponent- %@",[exception description]);
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    @try {
//        [[self.pickerLanguage.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerLanguage.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        if (pickerView==self.pickerLanguage) {
            //Trello
            return [[_arrLanguage objectAtIndex:row] valueForKey:@"description"];
        }
    }
    @catch (NSException *exception){
        NSLog(@"Exception in titleForRow- %@",[exception description]);
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    @try
    {
//        [[self.pickerLanguage.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerLanguage.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        UILabel *lblSortText = (id)view;
        
        if (!lblSortText){
            lblSortText= [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, [pickerView rowSizeForComponent:component].width-15, [pickerView rowSizeForComponent:component].height)];
        }
        
        lblSortText.font = [UIFont boldSystemFontOfSize:16];
        lblSortText.textAlignment = NSTextAlignmentCenter;
        lblSortText.tintColor = [UIColor clearColor];
        
        if (pickerView==self.pickerLanguage)
        {
            //trello
            lblSortText.text = [[_arrLanguage objectAtIndex:row] valueForKey:@"description"];
            return lblSortText;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in viewForRow- %@",[exception description]);
    }
    return 0;
}

#pragma mark - AlertView Delegate
- (IBAction)btnSubmit_tapped:(id)sender
{
    @try {
        [self.scrBackground setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // [self performSegueWithIdentifier:@"SegueLogin" sender:self];
        
        [self.txtPasswordtextField resignFirstResponder];
        [self.txtLogintextField resignFirstResponder];
        [self.txtAccountNumber resignFirstResponder];
        
        if ([self.txtAccountNumber.text isEqualToString:@""] || [self.txtAccountNumber.text isEqual:nil] || self.txtAccountNumber.text == nil){
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"Please enter Account Number."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                     [self.txtAccountNumber becomeFirstResponder];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
        else if ([self.txtLogintextField.text isEqualToString:@""] || [self.txtLogintextField.text isEqual:nil] || self.txtLogintextField.text == nil){
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"Please enter User Name."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                     [self.txtLogintextField becomeFirstResponder];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
        else if ([self.txtPasswordtextField.text isEqualToString:@""] || [self.txtPasswordtextField.text isEqual:nil] || self.txtPasswordtextField.text == nil){
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"Please enter Password."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self.txtPasswordtextField becomeFirstResponder];
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
        else {
            if ([[ControlSettings sharedSettings] isNetConnected ]) {
                _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                [_customIOS7AlertView showLoaderWithMessage:NSLocalizedString(@"Please Wait...", "")];
                
                //Changed by Priyanka for CR141
                [ServerManager sendRequestForLogin:self.txtLogintextField.text password:self.txtPasswordtextField.text accountNumber:self.txtAccountNumber.text language:[_pref valueForKey:@"selectedLanguage"] onSucess:^(NSString *responseData) {
                
              //  [ServerManager sendRequestForLogin:self.txtLogintextField.text password:self.txtPasswordtextField.text language:[_pref valueForKey:@"selectedLanguage"] onSucess:^(NSString *responseData) {
                    
                    NSDictionary *dictreponse = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSString* message = [dictreponse objectForKey:@"error"];
                    if ([message isEqualToString:@"Login Successful."]){
                        NSString *token = [dictreponse valueForKey:@"token"];
                        [_pref setObject:token forKey:@"token"];
                        [_pref setObject:self.txtLogintextField.text forKey:@"userName"];
                        [_pref setObject:self.txtAccountNumber.text forKey:@"accountNumber"];

                        [_pref setObject:@"logged_in" forKey:@"login_state"]; //Code added by priyanka 2nd july//
                        [_pref synchronize];
                        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
                        //** code changed below instead of calling farmsData called userdata  Bug-27742 By M.
                        [self getFarmsData];
                        //[self getUsersData];
                        //*** end by M
                       // [self updateMasterDataBase];
                        
                    }else if ([message isEqualToString:@"Incorrect Password, Please note passwords are case sensitive."]){
                        [_customIOS7AlertView close];
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:message
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 self.txtPasswordtextField.text = @"";
                                                 [self.txtPasswordtextField becomeFirstResponder];
                                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                             }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                    }else if([message rangeOfString:@"Please enter a valid username"].location !=NSNotFound) {
                        [_customIOS7AlertView close];
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:message
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 self.txtPasswordtextField.text = @"";
                                                 self.txtLogintextField.text = @"";
                                                 [self.txtLogintextField becomeFirstResponder];
                                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                             }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                    }
                    else if ([message isEqualToString:@"Your previous session was active and has been closed. A new session has been created."])
                    {
                        [_customIOS7AlertView close];
                        
                        NSString *token = [dictreponse valueForKey:@"token"];
                        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                        [pref setObject:token forKey:@"token"];
                        
                        [pref setObject:@"logged_in" forKey:@"login_state"]; //Code added by priyanka 2nd july//
                        [pref synchronize];
                        
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:message
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                                                 [_customIOS7AlertView showLoaderWithMessage:NSLocalizedString(@"Loading...", "")];
                                                 
                                               //  [self updateMasterDataBase];
                            //** code changed below instead of calling farmsData called userdata  Bug-27742 By M.
                            [self getFarmsData];
                           // [self getUsersData];
                            
                                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                             }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                    }
                    else // to to
                    {
                        [_customIOS7AlertView close];
                        NSString *token = [dictreponse valueForKey:@"token"];
                        
                        NSUserDefaults *pref1 =[NSUserDefaults standardUserDefaults];
                        [pref1 setObject:token forKey:@"token"];
                        [pref1 synchronize];
                        
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:message
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action)
                                             {
                                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                             }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                    }
                } onFailure:^(NSMutableDictionary *responseData, NSError *error) {
                    [_customIOS7AlertView close];
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                    [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                    
                    NSString *strErr = [NSString stringWithFormat:@"User Name = %@,error = %@,DateTime=%@,Event(On Language selection) =%@",self.txtLogintextField.text,error.description.description,strDate, @"Login"];
                    [tracker set:kGAIScreenName value:strErr];
                    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                    
                    if ([responseData.allKeys containsObject:@"code"]) {
                        
                        NSString *path = [[NSBundle mainBundle] pathForResource:@"StatusCodes" ofType:@"plist"];
                        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
                        
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:[dict valueForKey:[responseData valueForKey:@"code"]]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:@"OK"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 [self.navigationController popViewControllerAnimated:YES];
                                             }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
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
                                             actionWithTitle:@"OK"
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
                                     actionWithTitle:@"OK"
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
        NSLog(@"Exception in btnSubmit_tapped =%@",exception.description);
    }
}
///*** added below method for getting User_Params data bug-27742 By M.

-(void)getUsersData{
    
    @try {
        //NSError *error = nil;
        if ([[ControlSettings sharedSettings] isNetConnected ]) {
            [ServerManager sendRequestForUsersData:^(NSString *responseData) {
                [_customIOS7AlertView close];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""]) {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:responseData
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             //[self.navigationController popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else{
                    
                    
                    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
                    [currentDefaults setObject:data forKey:@"user_params"];
                   

//                    [[NSUserDefaults standardUserDefaults] setObject:[dict valueForKey:@"UPF"] forKey:@"user_params"];
                }
            } onFailure:^(NSString *responseData, NSError *error) {
                [_customIOS7AlertView close];
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Simple Report"];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            }];
        }
        else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"You must be online for the app to function."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception in updateMasterDataBase=%@",exception.description);
    }
}
// Added extra function to get Farms Data ...

-(void)getFarmsData{
    
    @try {
        //NSError *error = nil;
        if ([[ControlSettings sharedSettings] isNetConnected ]) {
            [ServerManager sendRequestForFarmsData:^(NSString *responseData) {
                [_customIOS7AlertView close];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""]) {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:responseData
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             //[self.navigationController popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else{
                    
                    
                    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
                    [currentDefaults setObject:data forKey:@"frmsData"];
                    //** call the function of getUsersData for new User_Parameters By M.
                    [self getUsersData];
                    
//                    NSArray *frmArray = [dict valueForKey:@"_farms"];
//
//                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                  //  [prefs setObject:frmArray forKey:@"frmsData"];
//                    [prefs setValue:frmArray forKey:@"frmsData"];
//                    [prefs synchronize];

//                    [[NSUserDefaults standardUserDefaults] setObject:[dict valueForKey:@"_farms"] forKey:@"userParameterData"];

                    [self updateMasterDataBase];
    
                }
            } onFailure:^(NSString *responseData, NSError *error) {
                [_customIOS7AlertView close];
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Simple Report"];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            }];
        }
        else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"You must be online for the app to function."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception in updateMasterDataBase=%@",exception.description);
    }
}







-(void)updateMasterDataBase {
    @try {
        //NSError *error = nil;
        if ([[ControlSettings sharedSettings] isNetConnected ]) {
            [ServerManager sendRequestForSysLookup:^(NSString *responseData) {
                [_customIOS7AlertView close];
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""]) {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:responseData
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             //[self.navigationController popToRootViewControllerAnimated:YES];
                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                         }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else{
                    NSArray *adminRoutes;
                    if (![[dict objectForKey:@"_ADMIN_ROUTES"] isKindOfClass:[NSNull class]]) {
                        adminRoutes = [dict objectForKey:@"_ADMIN_ROUTES"];
                    }
                    
                    NSArray *aistuds;
                    if (![[dict objectForKey:@"_AI_STUDS"] isKindOfClass:[NSNull class]]){
                        aistuds= [dict objectForKey:@"_AI_STUDS"]?[dict objectForKey:@"_AI_STUDS"]:@"";
                    }
                    
                    NSArray *breedingcompanies;
                    if (![[dict objectForKey:@"_BREEDING_COMPANIES"] isKindOfClass:[NSNull class]]){
                        breedingcompanies = [dict objectForKey:@"_BREEDING_COMPANIES"];
                    }
                    
                    NSArray *halothane;
                    if (![[dict objectForKey:@"_Halothane"] isKindOfClass:[NSNull class]]){
                        halothane = [dict objectForKey:@"_Halothane"];
                    }
                    
                    NSArray *pdResults;
                    if (![[dict objectForKey:@"_PD_RESULTS"] isKindOfClass:[NSNull class]]){
                        pdResults = [dict objectForKey:@"_PD_RESULTS"];
                    }
                    //***code changed below from sex to piglet_sex for Bug-29678 and 29643 By M.
                    NSArray *sex;
                    if (![[dict objectForKey:@"_PIGLET_SEX"] isKindOfClass:[NSNull class]]){
                        sex = [dict objectForKey:@"_PIGLET_SEX"];
                    }
                    //~~~~~ for piglet_identities By M.
                    NSArray *color;
                    if (![[dict objectForKey:@"_PIGLET_COLOR"] isKindOfClass:[NSNull class]]){
                        color = [dict objectForKey:@"_PIGLET_COLOR"];
                    }
                    NSArray *designation;
                    if (![[dict objectForKey:@"_DESIGNATION"] isKindOfClass:[NSNull class]])
                    {
                        designation = [dict objectForKey:@"_DESIGNATION"];
                    }//~~~~ end of M.
                    
                    NSArray *tod;
                    if (![[dict objectForKey:@"_TOD"] isKindOfClass:[NSNull class]])
                    {
                        tod = [dict objectForKey:@"_TOD"];
                    }
                    
                    NSArray *commonLookupsArray;
                    if (![[dict objectForKey:@"_COMMON_LOOKUPS"] isKindOfClass:[NSNull class]])
                    {
                        commonLookupsArray = [dict objectForKey:@"_COMMON_LOOKUPS"];
                    }
                    
                    NSArray *dataEntryItemsArray;
                    if (![[dict objectForKey:@"_DATA_ENTRY_ITEMS"] isKindOfClass:[NSNull class]])
                    {
                        dataEntryItemsArray = [dict objectForKey:@"_DATA_ENTRY_ITEMS"];
                    }
                    //$$$$$$$$$$$$$$$$$$$$$#######
                  /*  NSArray *userParametersArray;
                    if (![[dict objectForKey:@"_User_Parameters"] isKindOfClass:[NSNull class]])
                    {
                        userParametersArray = [dict objectForKey:@"_User_Parameters"];
                        
                       / //******Code Change By Priyanka on 11th May 2018******* *
                        NSString *findKey = @"GHSDY4TTYG4123edfgfyi67";
                        NSArray *array = [userParametersArray valueForKey:@"nm"];
                        NSArray *array1 = [userParametersArray valueForKey:@"val"];
                        
                        if ([array containsObject:findKey]) {
                            NSLog(@"%lu", (unsigned long)[array indexOfObject:findKey]);
                            NSLog(@"%@",[array1 objectAtIndex:[array indexOfObject:findKey]]);
                            
                            NSString * strValue = [array1 objectAtIndex:[array indexOfObject:findKey]];
                            [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:@"user_para_fostering_value"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //******Code Change By Priyanka on 11th May 2018********
                        } else {
                            NSLog(@"%@ is not present in the array", findKey);
                        }
                    }*/
                    //$$$$$$$$$$$$$$$$$$$$$#######
                  
                    
        // Adding additional functional call for Getting Farms list ..... Gudipti harikrishna.
                    
                    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"frmsData"];
                    NSDictionary * myDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    
                //    NSDictionary * myDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userParameterData"];
                    
                    //*** code added below to replace description key as per CoreData Model for New webservice by M.
                    
                    NSMutableArray *updatedFarms = [NSMutableArray array];
                    // Iterate through each farm dictionary in the "farms" array
                    for (NSDictionary *farm in myDictionary[@"farms"]) {
                        NSMutableDictionary *updatedFarm = [NSMutableDictionary dictionaryWithDictionary:farm];
                        NSString *originalDescription = farm[@"Description"];
                        
                        // Replace "Description" key with "des"
                        if (originalDescription) {
                            updatedFarm[@"des"] = originalDescription;
                            [updatedFarm removeObjectForKey:@"Description"];
                        }
                        
                        [updatedFarms addObject:updatedFarm];
                    }
                    
                    // Create the final updated dictionary with the replaced key
                    NSDictionary *updatedDictionary = @{@"farms": updatedFarms};

                    //**code end by M.
                    
                    NSArray *farmsArray;
                     //***code key below changed as per new webservice old key = _farms and f_nm newKey = farms and farmname by M.
                    if (![[updatedDictionary objectForKey:@"farms"] isKindOfClass:[NSNull class]]) {     //Commented by harikrishna
                        farmsArray = [updatedDictionary objectForKey:@"farms"];
                    }
                    
                    NSMutableArray *arrFilteredFarms = [[NSMutableArray alloc]init];
                    
                    for (NSDictionary *myDictionary1 in farmsArray){
                        if (![[myDictionary1 valueForKey:@"farmname"] isKindOfClass:[NSNull class]]){
                            [arrFilteredFarms addObject:myDictionary1];
                        }
                    }
                    
                    //*** end By M.
                    
                    
                    
                    
                    
                    
//                    NSArray *farmsArray;
//                    if (![[dict objectForKey:@"_farms"] isKindOfClass:[NSNull class]]) {
//                        farmsArray = [dict objectForKey:@"_farms"];
//                    }
//
//                    NSMutableArray *arrFilteredFarms = [[NSMutableArray alloc]init];
//
//                    for (NSDictionary *dict in farmsArray){
//                        if (![[dict valueForKey:@"f_No"] isKindOfClass:[NSNull class]]){
//                            [arrFilteredFarms addObject:dict];
//                        }
//                    }
                    

                    NSArray *geneticsArray;
                    if (![[dict objectForKey:@"_GENETICS"] isKindOfClass:[NSNull class]])
                    {
                        geneticsArray = [dict objectForKey:@"_GENETICS"];
                    }
                    
                    NSArray *locationsArray;
                    if (![[dict objectForKey:@"_LOCATIONS"] isKindOfClass:[NSNull class]]){
                        locationsArray = [dict objectForKey:@"_LOCATIONS"];
                    }
                    
                    // new additions
                    NSArray* operatorArray;
                    if (![[dict objectForKey:@"_Operators"] isKindOfClass:[NSNull class]]){
                        operatorArray = [dict objectForKey:@"_Operators"];
                    }
                    
                    //
                    NSMutableArray *arrOperatorArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *dict in operatorArray)
                    {
                        NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                        //                            if (![[dict objectForKey:@"fn"] isKindOfClass:[NSNull class]]){
                        //                                [dt setValue:[dict objectForKey:@"fn"] forKey:@"fn"];
                        //                            }
                        if (![[dict objectForKey:@"id"] isKindOfClass:[NSNull class]]){
                            [dt setValue:[dict valueForKey:@"id"] forKey:@"id"];
                        }
                        if (![[dict objectForKey:@"sn"] isKindOfClass:[NSNull class]]){
                            [dt setValue:[dict valueForKey:@"sn"] forKey:@"sn"];
                        }
                        if (![[dict objectForKey:@"ln"] isKindOfClass:[NSNull class]]){
                            [dt setValue:[dict valueForKey:@"ln"] forKey:@"ln"];
                        }
                        
                        //                            if (![[dict objectForKey:@"sid"] isKindOfClass:[NSNull class]]){
                        //                                [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                        //                            }
                        
                        [arrOperatorArray addObject:dt];
                    }
                    //
                    
                    NSArray* breeedingCompaniesArray;
                    if (![[dict objectForKey:@"_BREEDING_COMPANIES"] isKindOfClass:[NSNull class]]){
                        breeedingCompaniesArray = [dict objectForKey:@"_BREEDING_COMPANIES"];
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
                    NSArray* packingPlantsArray;
                    
                    if (![[dict objectForKey:@"_PACKING_PLANTS"] isKindOfClass:[NSNull class]]){
                        packingPlantsArray = [dict objectForKey:@"_PACKING_PLANTS"];
                    }
                    
                    NSArray* treatmentsArray;
                    if (![[dict objectForKey:@"_TREATMENTS"] isKindOfClass:[NSNull class]]){
                        treatmentsArray = [dict objectForKey:@"_TREATMENTS"];
                    }
                    
                    NSMutableArray *arrFilteredDestination = [[NSMutableArray alloc]init];
                    NSArray* destinartionArray;
                    if (![[dict objectForKey:@"_DESTINATION"] isKindOfClass:[NSNull class]]) {
                        destinartionArray = [dict objectForKey:@"_DESTINATION"];
                        //
                        
                        @try {
                            for (NSDictionary *dict in destinartionArray)
                            {
                                //***changed below key casue of crash in Testflight By M.
                                NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                                [dt setValue:[dict objectForKey:@"Ds"] forKey:@"Ds"];
                               // [dt setValue:[dict valueForKey:@"fC"] forKey:@"fC"];
                                [dt setValue:[dict valueForKey:@"FC"] forKey:@"fC"];
                                [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                               // [dt setValue:[dict valueForKey:@"zD"] forKey:@"zD"];
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
                                //***changed below key casue of crash in Testflight By M.
                                NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                                [dt setValue:[dict objectForKey:@"Ds"] forKey:@"Ds"];
                                //[dt setValue:[dict valueForKey:@"fC"] forKey:@"fC"];
                                [dt setValue:[dict valueForKey:@"FC"] forKey:@"fC"];
                                [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                                //[dt setValue:[dict valueForKey:@"zD"] forKey:@"zD"];
                                [dt setValue:[dict valueForKey:@"ZD"] forKey:@"zD"];
                                
                                [arrFilteredOrigin addObject:dt];
                            }
                        }
                        @catch (NSException *exception) {
                            NSLog(@"Exception =%@",exception.description);
                        }
                    }
                    NSArray *userParametersArray;
                    NSData *userdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_params"];
                    NSDictionary *myuserDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:userdata];

                    NSMutableDictionary *originalMutableDictionary = [myuserDictionary mutableCopy];
                    NSMutableDictionary *upfMutableDictionary = [originalMutableDictionary[@"UPF"] mutableCopy];
                    
                    NSMutableDictionary *lowercaseDictionary = [NSMutableDictionary dictionary];
                    for (NSString *key in upfMutableDictionary) {
                        id value = upfMutableDictionary[key];
                        NSString *lowercaseKey = [key lowercaseString];
                       
                            lowercaseDictionary[lowercaseKey] = value;
                        
                    }

                    // Update the UPF dictionary in the original dictionary
                    originalMutableDictionary[@"UPF"] = lowercaseDictionary;

                    // Convert the mutable dictionary to an immutable array of dictionaries
                    userParametersArray = @[lowercaseDictionary];

                    NSLog(@"userParametersArray: %@", userParametersArray);

                    [[CoreDataHandler sharedHandler] removeAllmanagedObject];
                    {
                        BOOL isSucess = [[CoreDataHandler sharedHandler] insertBulkValuesWithCommonLookupArray:commonLookupsArray andFarmsArray:arrFilteredFarms andDataEntryArray:dataEntryItemsArray andGeneticsArray:geneticsArray andUserParameters:userParametersArray andLocations:locationsArray andOperatorArray:arrOperatorArray andBreedingComapniesArray:breeedingCompaniesArray andCondistionsArray:conditionsArray andFlagsArray:flagsArray andTransportArray:transportCompaniesArray andPackingPlantsArray:packingPlantsArray andTreatmentsArray:treatmentsArray andAdminRoutes:adminRoutes andAiStuds:aistuds  andHalothane:halothane andPdResults:pdResults andSex:sex andColor:color andDesignation:designation andTod:tod andOrigin:arrFilteredOrigin andDestination:arrFilteredDestination translated:_arrayEnglish conditionScore:conditionsScoreArray pigletDefects:(NSArray*)pigletDefectsArray herdCategory:_herdCategoryArray lesionScoreArray:_LesionScoreArray lockArray:_LockArray leakageArray:_LeakageArray qualityArray:_QualityArray standingReflexArray:_StandingReflexArray testTypeArray:_TestTypeArray];
                        
                        if (arrFilteredFarms.count==0) {
                            {
                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                           message:@"User does not have access to any farm/Or problem loading data, Please try again."
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                UIView *controllerView = myAlertController.view;
                                [controllerView addSubview:logoImageView];
                                [controllerView bringSubviewToFront:logoImageView];
                                UIAlertAction* ok = [UIAlertAction
                                                     actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         if ([[ControlSettings sharedSettings] isNetConnected ]){
                                                             _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                                                             [_customIOS7AlertView showLoaderWithMessage:@"Signing off."];
                                                             
                                                             [ServerManager sendRequestForLogout:^(NSString *responseData) {
                                                                 NSLog(@"%@",responseData);
                                                                 self.txtPasswordtextField.text = @"";
                                                                 [_customIOS7AlertView close];
                                                                 if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                                                                 {
                                                                     UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                                                message:responseData
                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                                                     UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                                                     logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                                                     UIView *controllerView = myAlertController.view;
                                                                     [controllerView addSubview:logoImageView];
                                                                     [controllerView bringSubviewToFront:logoImageView];
                                                                     UIAlertAction* ok = [UIAlertAction
                                                                                          actionWithTitle:@"OK"
                                                                                          style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action)
                                                                                          {
                                                                                              [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                                          }];
                                                                     
                                                                     [myAlertController addAction: ok];
                                                                     [self presentViewController:myAlertController animated:YES completion:nil];
                                                                 }else if ([responseData isEqualToString:@"\"Loged out\""]){
                                                                     //[self.navigationController popToRootViewControllerAnimated:YES];
                                                                 }
                                                                 
                                                             } onFailure:^(NSString *responseData, NSError *error) {
                                                                 if (responseData.integerValue ==401) {
                                                                     
                                                                     UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                                                message:@"Your session has been expired. Please login again."
                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                                                     UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                                                     logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                                                     UIView *controllerView = myAlertController.view;
                                                                     [controllerView addSubview:logoImageView];
                                                                     [controllerView bringSubviewToFront:logoImageView];
                                                                     UIAlertAction* ok = [UIAlertAction
                                                                                          actionWithTitle:@"OK"
                                                                                          style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action) {
                                                                                              // [self.navigationController popToRootViewControllerAnimated:YES];
                                                                                              [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                                          }];
                                                                     
                                                                     [myAlertController addAction: ok];
                                                                     [self presentViewController:myAlertController animated:YES completion:nil];
                                                                     //[self.navigationController popToRootViewControllerAnimated:YES];
                                                                 }else{
                                                                     UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                                                message:@"Server Error"
                                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                                                     UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                                                     logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                                                     UIView *controllerView = myAlertController.view;
                                                                     [controllerView addSubview:logoImageView];
                                                                     [controllerView bringSubviewToFront:logoImageView];
                                                                     UIAlertAction* ok = [UIAlertAction
                                                                                          actionWithTitle:@"OK"
                                                                                          style:UIAlertActionStyleDefault
                                                                                          handler:^(UIAlertAction * action) {
                                                                                              //[self.navigationController popToRootViewControllerAnimated:YES];
                                                                                              [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                                                                          }];
                                                                     
                                                                     [myAlertController addAction: ok];
                                                                     [self presentViewController:myAlertController animated:YES completion:nil];
                                                                 }
                                                                 
                                                                 id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                                                 NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                                                                 [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                                 NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                                                                 
                                                                 NSString *strErr = [NSString stringWithFormat:@"User Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Simple Report"];
                                                                 [tracker set:kGAIScreenName value:strErr];
                                                                 [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                                                                 
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
                                                                                  actionWithTitle:@"OK"
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
                        }else if (arrFilteredFarms.count==1) {
                            
                            if (dataEntryItemsArray.count==0) {//to do
                                
                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                           message:@"Please login again."
                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                UIView *controllerView = myAlertController.view;
                                [controllerView addSubview:logoImageView];
                                [controllerView bringSubviewToFront:logoImageView];
                                UIAlertAction* ok = [UIAlertAction
                                                     actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         if ([[ControlSettings sharedSettings] isNetConnected ]){
                                                             _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                                                             [_customIOS7AlertView showLoaderWithMessage:@"Signing off."];
                                                             
                                                             [ServerManager sendRequestForLogout:^(NSString *responseData) {
                                                                 NSLog(@"%@",responseData);
                                                                 [_customIOS7AlertView close];
                                                                 
                                                                 if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""]) {
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
                                                                 } else if ([responseData isEqualToString:@"\"Loged out\""] || [responseData isEqualToString:@""]){
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
                                                                                                                                        message:@"You must be online for the app to function."
                                                                                                                                 preferredStyle:UIAlertControllerStyleAlert];
                                                             UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                                             logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                                             UIView *controllerView = myAlertController.view;
                                                             [controllerView addSubview:logoImageView];
                                                             [controllerView bringSubviewToFront:logoImageView];
                                                             UIAlertAction* ok = [UIAlertAction
                                                                                  actionWithTitle:@"OK"
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
                            else{
                                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                                NSLog(@"username=%@",[_pref valueForKey:@"userName"]);
                                
                                //^^^^^^^^^^ commented below code for Single farm issue Bug-28951 By M.
                                /*
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"id"] forKey:@"id"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"f_nm"] forKey:@"f_nm"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"ZD"] forKey:@"ZD"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"SSL"] forKey:@"SSL"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"SSW"] forKey:@"SSW"];
                              //  [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                                
                              //  [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                                //--------------------------
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"farmcode"] forKey:@"f_No"];
                               
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"des"] forKey:@"f_nm"];
                            
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"sitekey"] forKey:@"id"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"zerodate"] forKey:@"ZD"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"splitsexliveborn"] forKey:@"SSL"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"splitsexweaned"] forKey:@"SSW"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                                
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                                [user setValue:[[arrFilteredFarms objectAtIndex:0] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                                
                                [user setValue:self.txtLogintextField.text forKey:@"userName"];
                                NSLog(@"username=%@",self.txtLogintextField.text);
                                [user synchronize];
                                 */
                                NSMutableArray *arrFarms=[[NSMutableArray alloc]init];
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
                                        
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"des"] forKey:@"f_nm"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"sitekey"] forKey:@"id"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"zerodate"] forKey:@"ZD"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexliveborn"] forKey:@"SSL"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexweaned"] forKey:@"SSW"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                                        
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                                        
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                                        [dictFarm setValue:[[resultArray objectAtIndex:count] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                              
                                        [arrFarms addObject:dictFarm];
                                    }
                                }
                                if (arrFarms.count>=1) {
                                  
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"f_No"] forKey:@"f_No"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"id"] forKey:@"id"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"f_nm"] forKey:@"f_nm"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"ZD"] forKey:@"ZD"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"SSL"] forKey:@"SSL"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"SSW"] forKey:@"SSW"];
                                    //*** code added below for new keys as per CoreData Model for New webservice by M.
                                    
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"tattoounique"] forKey:@"tattoounique"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"tattoolength"] forKey:@"tattoolength"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"splitsexlosses"] forKey:@"splitsexlosses"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"splitsexfostered"] forKey:@"splitsexfostered"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"splitsexdefects"] forKey:@"splitsexdefects"];
                                    [user setValue:[[arrFarms objectAtIndex:0] valueForKey:@"splitsextreatments"] forKey:@"splitsextreatments"];
                                    [user synchronize];
                              
                                }
                                
                                if (isSucess){ //^^^^^ commented below for Bug- 28952 and bug-28971 for single farm by M.
                                    //[self performSegueWithIdentifier:@"segueFarmSelection" sender:self];
                                    //^^^^^ added below for navigating to FarmSelection but when single farm is set then need to skip farmSelection view so calling new method updatesinglefarmdatabase
                                   // [_customIOS7AlertView close];
                                   // [self performSegueWithIdentifier:@"SegueLogin" sender:self];
                                    //^^^^ added below method for Bug-29001 By M.
                                    //**added for Version V10  issue By M.
                                    [[NSUserDefaults standardUserDefaults] setObject:self.txtLogintextField.text forKey:@"userName"];
                                    NSLog(@"username=%@",self.txtLogintextField.text);
                                    
                                [self updateSingleFarmDataBase];
                                }
                            }
                        }
                        else {
                            NSLog(@"username=%@",[_pref valueForKey:@"userName"]);
                            if (![[_pref valueForKey:@"userName"] isEqualToString:self.txtLogintextField.text]){
                                [_pref setValue:@"" forKey:@"id"];
                                [_pref setValue:@"" forKey:@"f_nm"];
                                [_pref setValue:@"" forKey:@"ZD"];
                                [_pref setValue:@"" forKey:@"SSL"];
                                [_pref setValue:@"" forKey:@"SSW"];
                               // [_pref setValue:@"" forKey:@"tattoounique"];
                               // [_pref setValue:@"" forKey:@"tattoolength"];
                            }
                            
                            [[NSUserDefaults standardUserDefaults] setObject:self.txtLogintextField.text forKey:@"userName"];
                            NSLog(@"username=%@",self.txtLogintextField.text);
                            
                            if (isSucess) {
                                [_customIOS7AlertView close];
                                [self performSegueWithIdentifier:@"SegueLogin" sender:self];
                            }
                        }
                    }
                }
            } onFailure:^(NSString *responseData, NSError *error) {
                [_customIOS7AlertView close];
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Simple Report"];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            }];
        }
        else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"You must be online for the app to function."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
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
        NSLog(@"Exception in updateMasterDataBase=%@",exception.description);
    }
}
//^^^^^ for Bug 29001 By M.
-(void)updateSingleFarmDataBase{
    @try{
        [ServerManager sendRequestForFarmSelection:[[NSUserDefaults standardUserDefaults] objectForKey:@"id"] onSucess:^(NSString *responseData)  {
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
                        //~~~~~end of M.
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
                                    //***changed below key got changed in Json response and crash in Testflight By M.
                                    NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                                    [dt setValue:[dict objectForKey:@"Ds"] forKey:@"Ds"];
                                   // [dt setValue:[dict valueForKey:@"fC"] forKey:@"fC"];
                                    [dt setValue:[dict valueForKey:@"FC"] forKey:@"fC"];
                                    [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                                   // [dt setValue:[dict valueForKey:@"zD"] forKey:@"zD"];
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
                                    //***changed below key got changed in Json response and  crash in Testflight By M.
                                    NSMutableDictionary *dt  = [[NSMutableDictionary alloc]init];
                                    [dt setValue:[dict objectForKey:@"Ds"] forKey:@"Ds"];
                                   // [dt setValue:[dict valueForKey:@"fC"] forKey:@"fC"];
                                    [dt setValue:[dict valueForKey:@"FC"] forKey:@"fC"];
                                    [dt setValue:[dict valueForKey:@"sid"] forKey:@"sid"];
                                    //[dt setValue:[dict valueForKey:@"zD"] forKey:@"zD"];
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
                                
                                if (isSucess){
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
    @catch(NSException *exception){
        NSLog(@"Exception in UpdateSingleFarm DataBase=%@", exception.description);
    }
    
}
//^^^^^ for bug-29001 By M.
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    @try {
        NSLog(@"PrePare for segue");
        
        if ([segue.identifier isEqualToString:@"segueFarmSelection"])
        {
            // InitialViewController *toDoViewController = //segue.destinationViewController;
            //toDoViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"segueDataEntry"];
        }
        else
        {
            //FarmSelectionViewController *farmSelectionViewController = segue.destinationViewController;
            //farmSelectionViewController.arrlanguage = _arrayEnglish;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in prepareForSegue in FarmSelection =%@",exception.description);
    }
}

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    @try{
        [self.scrBackground setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        if (textField == self.txtLogintextField){
            [textField resignFirstResponder];
            [self.txtPasswordtextField becomeFirstResponder];
        }else{
            [textField resignFirstResponder];
        }
        
        return YES;
    }
    @catch (NSException *exception){
        NSLog(@"Exception in textFieldShouldReturn in ViewController- %@",[exception description]);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.activeTextField = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.txtAccountNumber){
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return resultText.length <= 5;
    }
    //added below code for crash of V10 By M.
    
    if (textField == self.txtLogintextField){
        NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];
       
            [[NSUserDefaults standardUserDefaults] setObject:resultText forKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    else
        return YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//
//    if (textField == self.txtAccountNumber){
//        if(textField.text.length<5)
//        {
//            return YES;
//        }
//        else
//            return NO;
//    }
//    else
//        return YES;
//}

- (void)keyboardWasShown:(NSNotification*)aNotification{
    @try {
        self.automaticallyAdjustsScrollViewInsets = YES;
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.scrBackground.contentInset = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, self.activeTextField.frame.origin))
        {
            [self.scrBackground scrollRectToVisible:self.activeTextField.frame animated:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in keyboardWasShown in ViewController =%@",exception.description);
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    @try {
        [self.scrBackground scrollRectToVisible:CGRectMake(0, 0, self.activeTextField.frame.size.width, self.activeTextField.frame.size.height) animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in keyboardWillHide in ViewController =%@",exception.description);
    }
}

#pragma mark - Other methods
- (IBAction)btnLanguage_tapped:(id)sender{
    @try {
        [self.activeTextField resignFirstResponder];
        self.pickerLanguage = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 10, 270, 150.0)];
        [self.pickerLanguage setDelegate:self];
        // self.pickerLanguage.showsSelectionIndicator = YES;
        [self.pickerLanguage setShowsSelectionIndicator:YES];
        
        _alertForLanguage = [[CustomIOS7AlertView alloc] init];
        [_alertForLanguage setMyDelegate:self];
        [_alertForLanguage setUseMotionEffects:true];
        [_alertForLanguage setButtonTitles:[NSMutableArray arrayWithObjects:@"OK",@"Cancel", nil]];
        
        [self.pickerLanguage reloadAllComponents];
        [self.pickerLanguage selectRow:0 inComponent:0 animated:YES];
        //
        __weak typeof(self) weakSelf = self;
        [_alertForLanguage setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            
            if(buttonIndex == 0) {
                if (weakSelf.arrLanguage.count>0) {
                    NSInteger row = [weakSelf.pickerLanguage selectedRowInComponent:0];
                   // [weakSelf.btnLanguage setTitle:[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"name"] forState:UIControlStateNormal];
                    //>>>>>>>> trello language
                    [weakSelf.btnLanguage setTitle:[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"description"] forState:UIControlStateNormal];
                    //http://192.168.20.40/PigchampWeb/ //http://rdstest.pigchamp.com/
                    
                   /* NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
 
                      NSString *str = [[[defaults valueForKey:@"baseURL"] stringByAppendingString:@"lngmin/"] stringByAppendingString:[NSString stringWithFormat:@"%@_mob.lng",[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"name"]]];
                //    NSString *str = [[NSLocalizedString(@"baseUrl" , @"") stringByAppendingString:@"lngmin/"] stringByAppendingString:[NSString stringWithFormat:@"%@_mob.lng",[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"name"]]];
                    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:str]]; //commented by amit as on dated 19th march 2018
                    /**********added below lines of code by ami as on 19th march 2018*/
                    /* NSString *encodedParam = [[_pref valueForKey:@"selectedLanguage"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];// Amit Added this line of code
                     
                     NSString *strencoded = [[NSLocalizedString(@"baseUrl" , @"") stringByAppendingString:@"lngmin/"] stringByAppendingString:[NSString stringWithFormat:@"%@.lng",encodedParam]];//modified existing parameter
                     
                     NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strencoded]];*/
                    /*********************************************************************/
                   // NSString *gameFileContents = [[NSString alloc] initWithData:data encoding:NSUTF16StringEncoding];
                    //  NSLog(@"gameFileContents%@", gameFileContents);
                  /*
                    NSMutableArray *allLinedStrings = (NSMutableArray*)[gameFileContents componentsSeparatedByString:@"\r\n"];
                    NSMutableArray *newArray;// = [[NSMutableArray alloc]init];
                    _arrayEnglish = [[NSMutableArray alloc]init];
                    
                    for (NSString *line in allLinedStrings) {
                        @autoreleasepool {
                            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                            newArray = (NSMutableArray*)[line componentsSeparatedByString:@"="];
                            
                            if (newArray.count==2) {
                                [dict setValue:[newArray objectAtIndex:0] forKey:@"englishText"];
                                [dict setValue:[newArray objectAtIndex:1] forKey:@"translatedText"];
                            }
                            
                            [weakSelf.arrayEnglish addObject:dict];
                        }
                    }
                    */
                    //[weakSelf.pref setValue:[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"name"] forKey:@"selectedLanguage"];
                    
                    [weakSelf.pref setValue:[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"description"] forKey:@"selectedLanguage"];
                    //<<<< trello for langu
                    [weakSelf.pref setValue:[[weakSelf.arrLanguage objectAtIndex:row] valueForKey:@"code"] forKey:@"selectedLanguageCode"];
                    [weakSelf.pref synchronize];
                    [weakSelf callLoadLanguageData];
                }
                
                [weakSelf.alertForLanguage close];
            }
        }];
        
        NSString *strPrevSelectedValue = [weakSelf.pref valueForKey:@"selectedLanguage"];
        
        for (int count=0;count<weakSelf.arrLanguage.count;count++) {
            if (strPrevSelectedValue.length>0){
                //trello
                if( [strPrevSelectedValue caseInsensitiveCompare:[[weakSelf.arrLanguage objectAtIndex:count] valueForKey:@"description"]] == NSOrderedSame){
                    [self.pickerLanguage selectRow:count inComponent:0 animated:NO];
                    [self.pickerLanguage setShowsSelectionIndicator:YES];
                }
            }
        }
        
        [weakSelf.alertForLanguage showCustomwithView:self.pickerLanguage title:@"Select Language"];
    }
    @catch (NSException *exception) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateformate stringFromDate:[NSDate date]];
        
        NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event(On Language selection) =%@",self.txtLogintextField.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],exception.description,strDate, @"Login"];
        [tracker set:kGAIScreenName value:strErr];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
        NSLog(@"Exception in btnLanguage_tapped =%@",exception.description);
    }
}

-(void)applicationHasBecomeActive
{
    [self callCheckCurrentVersion];
}

-(void)callCheckCurrentVersion
{
    [ServerManager sendRequestForCheckVersion:@"ios" onSucess:^(NSString *responseData)
     {
         NSDictionary *dictDataVersion = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
         
         NSLog(@"check version succes farms selection: %@",dictDataVersion);
         
         //  if ([[dictDataVersion valueForKey:@"IsActive"]intValue]==1)
         isActive = TRUE;
         //  else
         //      isActive = FALSE;
         
         if (isActive == TRUE) {
             if ([[dictDataVersion valueForKey:@"isShowMessage"]intValue]==1)
                 isShowMessage = TRUE;
             else
                 isShowMessage = FALSE;
             
             if ([[dictDataVersion valueForKey:@"isCriticalVersion"]intValue]==1){
                 isCriticalUpdate = TRUE;
                 [[NSUserDefaults standardUserDefaults]setValue:@"TRUE" forKey:@"isCriticalVersion"];
                 
             }else{
                 isCriticalUpdate = FALSE;
                 [[NSUserDefaults standardUserDefaults]setValue:@"FALSE" forKey:@"isCriticalVersion"];
             }
             
             if ([[dictDataVersion valueForKey:@"OneTime"]intValue]==1){
                 //[[NSUserDefaults standardUserDefaults] setValue:@"O" forKey:@"ONE_TIME"];
                 isOnetime = TRUE;
             }else{
                 isOnetime = FALSE;
                 [[NSUserDefaults standardUserDefaults] setValue:@"O" forKey:@"ONE_TIME"];
             }
             Message = [dictDataVersion valueForKey:@"Message"];
             newVersion = [dictDataVersion valueForKey:@"Version"];
             Success = [dictDataVersion valueForKey:@"Success"];
             
             NSString *appVersion = [[[NSBundle mainBundle] infoDictionary]valueForKey:@"CFBundleShortVersionString"];
             
             NSString *v1 = appVersion;
             NSString *v2 = newVersion;
             
             NSComparisonResult r = [v1 compare:v2 options:NSNumericSearch];
             
             if (r == NSOrderedSame || r == NSOrderedDescending) {
                 NSLog(@"true");
             }else {
                 NSLog(@"false");
                 if (isShowMessage) {
                     [self ShowAlert];
                 }
             }
         }else{
         }
         
     } onFailure:^(NSMutableDictionary *responseData, NSError *error)
     {
     }];
}

-(void)ShowAlert
{
    if(isCriticalUpdate) {
        alertForCriticalUpdate = [UIAlertController alertControllerWithTitle:@"Update required" message:Message preferredStyle:UIAlertControllerStyleAlert];
        [alertForCriticalUpdate addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                           {
                                               NSString *iTunesLink = @"https://itunes.apple.com/us/app/pigchamp-mobile/id1375933336?mt=8";
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                           }]];
        [self presentViewController:alertForCriticalUpdate animated:YES completion:nil];
    }
    else
    {
        if (isOnetime == TRUE)
        {
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ONE_TIME"]isEqualToString:newVersion])
            {
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setValue:newVersion forKey:@"ONE_TIME"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                alertForUpdate = [UIAlertController alertControllerWithTitle:@"Update available" message:Message preferredStyle:UIAlertControllerStyleAlert];
                [alertForUpdate addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                           {
                                           }]];
                [alertForUpdate addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                           {
                                               NSString *iTunesLink = @"https://itunes.apple.com/us/app/pigchamp-mobile/id1375933336?mt=8";
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                           }]];
                [self presentViewController:alertForUpdate animated:YES completion:nil];
            }
        }
        else{
            alertForUpdate = [UIAlertController alertControllerWithTitle:@"Update available" message:Message preferredStyle:UIAlertControllerStyleAlert];
            [alertForUpdate addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                       {
                                       }]];
            [alertForUpdate addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                       {
                                           NSString *iTunesLink = @"https://itunes.apple.com/us/app/pigchamp-mobile/id1375933336?mt=8";
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                       }]];
            [self presentViewController:alertForUpdate animated:YES completion:nil];
        }
    }
}

- (IBAction)btnConfigurationClicked:(id)sender {
}

-(void)callNewBaseURLSaved
{
    [self callGetLanguageListAPI];
    [self callSessionTimeoutValue];
    [_pref setValue:@"English (US)" forKey:@"selectedLanguage"];
    //<<<< trello for lang
    [_pref setValue:@"en-US" forKey:@"selectedLanguageCode"];
    [self.btnLanguage setTitle:[_pref valueForKey:@"selectedLanguage"] forState:UIControlStateNormal];
    [_pref synchronize];
    [self callLoadLanguageData];
}

//API call for getting inactivity session timeout value
-(void)callSessionTimeoutValue
{
//    _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
//    [_customIOS7AlertView showLoaderWithMessage:NSLocalizedString(@"Please Wait...", "")];

    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    @try {
        if ([[ControlSettings sharedSettings] isNetConnected ]){
            [ServerManager sendRequestForTimeoutValue:@"" onSucess:^(NSString *responseData){
                
                NSDictionary *dictDataVersion = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSString *strTimeoutValue = [dictDataVersion valueForKey:@"SessionTimeoutValue"];
                NSLog(@"strTimeoutValue---%@",strTimeoutValue);
                
                if ([strTimeoutValue intValue]<1){
                    delegate.delegateTimeoutValue = 1800;
                }
                else{
                    delegate.delegateTimeoutValue = [strTimeoutValue intValue]*60;
                    NSLog(@"value---%d",delegate.delegateTimeoutValue);
                }
                //   [_customIOS7AlertView close];
                
            } onFailure:^(NSMutableDictionary *responseData, NSError *error){
                //  [_customIOS7AlertView close];
                delegate.delegateTimeoutValue = 1800; //Changed for API failure
            }];
        }else {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:@"You must be online for the app to function."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    }@catch (NSException *exception) {
        NSLog(@"Exception in get language list=%@",exception.description);
    }

//    @try {
//        [ServerManager sendRequestForTimeoutValue:@"" onSucess:^(NSString *responseData){
//
//             NSDictionary *dictDataVersion = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//             NSString *strTimeoutValue = [dictDataVersion valueForKey:@"SessionTimeoutValue"];
//             NSLog(@"strTimeoutValue---%@",strTimeoutValue);
//
//             if ([strTimeoutValue intValue]<1){
//                 delegate.delegateTimeoutValue = 1800;
//             }
//             else{
//                 delegate.delegateTimeoutValue = [strTimeoutValue intValue]*60;
//                 NSLog(@"value---%d",delegate.delegateTimeoutValue);
//             }
//           //   [_customIOS7AlertView close];
//
//         } onFailure:^(NSMutableDictionary *responseData, NSError *error){
//           //  [_customIOS7AlertView close];
//             delegate.delegateTimeoutValue = 1800; //Changed for API failure
//         }];
//
//    } @catch (NSException *exception) {
//        NSLog(@"Exception in callSessionTimeoutVale %@",exception.description);
//    }
}
@end
