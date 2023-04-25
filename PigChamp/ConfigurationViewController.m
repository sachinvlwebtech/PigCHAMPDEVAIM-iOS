//
//  ConfigurationViewController.m
//  PigChamp
//
//  Created by Venturelabour on 30/04/19.
//  Copyright © 2019 Venturelabour. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "AppDelegate.h"

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
    
   // self.txtURL.text = [NSString stringWithFormat:@"%@", API_BASE_URL];
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
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                             {
                             }];
        [myAlertController addAction: ok];
        [self presentViewController:myAlertController animated:YES completion:nil];
    }
}

- (IBAction)btnCancelClicked:(id)sender {
    // [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnResetClicked:(id)sender {
    self.txtURL.text = @"https://dev-pc-mobile.farmsstaging.com";
    
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
