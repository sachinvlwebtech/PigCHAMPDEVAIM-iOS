//
//  ConfigurationViewController.m
//  PigChamp
//
//  Created by Venturelabour on 30/04/19.
//  Copyright © 2019 Venturelabour. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "AppDelegate.h"
#import "ControlSettings.h"

@interface ConfigurationViewController ()
{
    NSUserDefaults *defaults;
}
@end

@implementation ConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"baseURL"] != nil)
    {
        if([[defaults valueForKey:@"baseURL"] hasSuffix:@"/"])
        {
            NSString * strURL = [NSString stringWithFormat:@"%@",[defaults valueForKey:@"baseURL"]];
            strURL = [strURL substringToIndex:[strURL length] - 1];
            self.txtURL.text = strURL;
        }
        else
        {
            self.txtURL.text = [NSString stringWithFormat:@"%@", API_BASE_URL];
        }
    }
    //*** code for NO autocorrect By M.
    _txtURL.autocorrectionType = UITextAutocorrectionTypeNo;
    _txtURL.autocapitalizationType = UITextAutocapitalizationTypeNone;
   // self.txtURL.text = [NSString stringWithFormat:@"%@", API_BASE_URL];
}
//added for Server Version By M.

-(void)getServerVersion{
    @try{
            if ([[ControlSettings sharedSettings] isNetConnected ]){
               
                [ServerManager getServerVersionDetails:^(NSString *responseData) {
                   
                        NSDictionary *dictreponse = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        NSNumber *majorVersionNumber = dictreponse[@"MajorVersion"];
                                  
                                   if (majorVersionNumber != nil) {
                                       NSInteger majorVersion = [majorVersionNumber integerValue];
                                       [defaults setInteger:majorVersion forKey:@"ServerVersion"];
                                       NSLog(@"Major Version in Config: %ld", (long)majorVersion);
                                   } else {
                                       NSLog(@"Major Version is not available in the JSON.");
                                   }
                       
                    
                } onFailure:^(NSString *responseData, NSError *error) {
                 
                    
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                    [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                    
                    NSString *strErr = [NSString stringWithFormat:@"User Name = %@,,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],error.description,strDate,@"Server Version"];
                    [tracker set:kGAIScreenName value:strErr];
                    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:responseData                                     //message:[responseData valueForKey:@"Error"]
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
- (IBAction)btnSaveClicked:(id)sender
{
    if(![self.txtURL.text isEqualToString:@""])
    {
        if ([self validateUrl:self.txtURL.text])
        {
            if([self.txtURL.text hasSuffix:@"/"])
            {
                [defaults setObject:_txtURL.text forKey:@"baseURL"];
             //   [defaults setObject:@"NewURLSaved" forKey:@"BaseURLStatus"]; //For calling getLanguageList API again after URL change
                [defaults  synchronize];
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"NewBaseURLSavedNotification" object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                NSString * strURL = [NSString stringWithFormat:@"%@/",self.txtURL.text];
                [defaults setObject:strURL forKey:@"baseURL"];
             //   [defaults setObject:@"NewURLSaved" forKey:@"BaseURLStatus"];//For calling getLanguageList API again after URL change
                [defaults  synchronize];
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"NewBaseURLSavedNotification" object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
         }
        else
        {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP" message:[self getTranslatedTextForString:@"Please enter valid URL"] preferredStyle:UIAlertControllerStyleAlert];
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                 {
                                 }];
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    }
    else
    {
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP" message:[self getTranslatedTextForString:@"Please enter valid URL"] preferredStyle:UIAlertControllerStyleAlert];
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
        UIView *controllerView = myAlertController.view;
        [controllerView addSubview:logoImageView];
        [controllerView bringSubviewToFront:logoImageView];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                             }];
        [myAlertController addAction: ok];
        [self presentViewController:myAlertController animated:YES completion:nil];
    }
    //Added below for V10 By M.
    [self getServerVersion];
    
}

- (IBAction)btnCancelClicked:(id)sender {
    // [self.navigationController popViewControllerAnimated:YES];
    //Added below for V10 By M.
    [self getServerVersion];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnResetClicked:(id)sender {
    //*** commented below line for the bug-28795
    self.txtURL.text = @"https://pcmobile.pigchamp.com";
    //@"https://dev-pc-mobile.farmsstaging.com";
//Added below for  V10 issue By M.
    [self getServerVersion];
    //***code added for Bug-28795 By M.
   /* if ([self.txtURL.text isEqualToString:@"https://dev-pc-mobile.farmsstaging.com"]){
        self.txtURL.text = @"https://pcmobile.pigchamp.com"; //-- LIVE
        //http://pcmobile-beta.pigchamp.com--Beta
    }else if([self.txtURL.text isEqualToString:@"https://pcmobile.pigchamp.com"]){
        self.txtURL.text = @"https://dev-pc-mobile.farmsstaging.com";
    }else if([self.txtURL.text isEqualToString:@""] || [self.txtURL.text isEqual:nil] || self.txtURL.text == nil || (![self.txtURL.text isEqualToString:@"https://dev-pc-mobile.farmsstaging.com"] || ![self.txtURL.text isEqualToString:@"https://pcmobile.pigchamp.com"])){
        self.txtURL.text = @"https://pcmobile.pigchamp.com";
    }*/
    //
    
 // self.txtURL.text = @"https://pcmobile.pigchamp.com";
    
//    if ([defaults valueForKey:@"baseURL"] != nil)
//    {
//        self.txtURL.text = [defaults valueForKey:@"baseURL"];
//    }
}

//- (BOOL) validateUrl: (NSString *) candidate {
//    NSString *urlRegEx =
//    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
//    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
//    return [urlTest evaluateWithObject:candidate];
//}

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx =
   //@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([-\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";

    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}
@end
