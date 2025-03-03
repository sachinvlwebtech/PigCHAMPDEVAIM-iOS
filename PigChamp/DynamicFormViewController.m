//
//  DynamicFormViewController.m
//  PigChamp
//
//  Created by Venturelabour on 26/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import "DynamicFormViewController.h"
#import "CoreDataHandler.h"
#import "ControlSettings.h"
#import "ServerManager.h"
#import "SettingsViewController.h"
#import "BarcodeScannerViewController.h"
#import "DropDown.h"
#import "dateCustomCell.h"
#import "textCustomCell.h"
#import "iRCustomCell.h"
#import "twoTextCustomCell.h"
#import "sptwoTextCustomCell.h"
#import "threeTextCustomCell.h"
#import "Note.h"
#import "EADSessionController.h"
#import "MBProgressHUD.h"
#import "DropDownSearchViewController.h"
#import "PigletIdentitiesTableViewCell.h"


BOOL isFromKeybord = NO;
BOOL isRFIDCalled = NO;
BOOL isOpenDynamic = NO;
BOOL isThousandFormat = NO;
BOOL isGestationWarnLengthflg = 0;
BOOL dateDelFlg = FALSE;
BOOL isDateSelected = FALSE;
NSString* dateDeliveredValue;
NSString* strSelectedDateMMM;
NSString* strSelectedDateOTH;
//***code added for SplitSex Functionality Bug-27775 By M @@@@@
BOOL strSplitSex=NO;
BOOL strSplitWex = NO;
BOOL strSplitLosses = NO;
BOOL strSplitFostered = NO;
BOOL strSplitDefects = NO;
BOOL strSplitTreatments = NO;
int tattooScanflg = 0;
//~~~~~ for Piglet Identities By M.
int tagScanflg = 0;
NSInteger btnTag;
BOOL addnewPigFlg = NO;
//***added for Bug0-29063 by M.
NSString* reqStringfulltmp;
NSString* strServiceName1;
//~~~~~ Added for piglet identities By M.
NSString* strpigletIdentitiesEdit;
@interface DynamicFormViewController ()
{
    NSString* fullDataString,*strFromDropDownView;
    NSInteger txtFieldTag;
    NSDictionary * dictCurrentTextFieldClicked;
    NSMutableArray * arrMultipleIdentities, *arrMultipleSowIdentities;
    BOOL flag;
    NSUserDefaults *pref;
    NSInteger TapedDropDownTag;
    NSString *detectedDateFormat;
    //***added for Bug0-29063 by M.
    NSString *value;
    NSArray *reqStringArray;
    //~~~~~ Added for piglet identities By M.
    NSMutableDictionary *pigletIdentityDict, *pigletIdentityJsonDict;
    NSArray *array169_1;
    NSMutableDictionary *dictDataToSend_1;
    NSString *tattooScannedValue;
}
@property(nonatomic, strong) IBOutlet EAAccessory *accessory;
@property(nonatomic) uint32_t totalBytesRead;
@property (nonatomic, strong) EADSessionController *eaSessionController;
//***added for Bug0-29063 by M.
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation DynamicFormViewController

@synthesize strEventCode;
@synthesize dictJson;

#pragma mark - View life cycle
- (void)viewDidLoad {
    @try {
        [super viewDidLoad];
        
        flag = 0;
        pref =[NSUserDefaults standardUserDefaults];
        //~~~added for Piglet Identities Bug-29596 By M.
        addnewPigFlg = NO;
        
        arrMultipleIdentities = [[NSMutableArray alloc]init];
        arrMultipleSowIdentities = [[NSMutableArray alloc]init];
        //~~~~~ added for Piglet Identities By M.
        _pigletIdentitiesArray = [[NSMutableArray alloc]init];
        _pigletIdentitiesJsonArray = [[NSMutableArray alloc]init];
        _pigletIdentitiesArray1= [[NSMutableArray alloc]init];
        _pigletIdentitiesJsonArray1= [[NSMutableArray alloc]init];
        _tmparray = [[NSMutableArray alloc]init];
        //~~~~~added for piglet Identities  Bug-29596 By M.
        _pigletidentitiesArryinUnchk= [[NSMutableArray alloc]init];
        _pigletidentitiesJsonArryinUnchk= [[NSMutableArray alloc]init];
        //added for bug-29661 By M.
        strSelectedDateMMM = nil;
        strpigletIdentitiesEdit = nil;
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accessoryConnected:)
                                                     name:EAAccessoryDidConnectNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accessoryDisconnected:)
                                                     name:EAAccessoryDidDisconnectNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:EADSessionDataReceivedNotification object:nil];
        
        self.btnConnectAccessory.layer.cornerRadius = 15;
        self.btnConnectAccessory.clipsToBounds = true;
        
        tlc = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
        SlideNavigationController *sld = [SlideNavigationController sharedInstance];
        sld.delegate = self;
        
        self.navigationController.navigationBar.translucent = NO;
        
        _btnSave.layer.shadowColor = [[UIColor grayColor] CGColor];
        _btnSave.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _btnSave.layer.shadowOpacity = 1.0f;
        _btnSave.layer.shadowRadius = 3.0f;
        
        _btnClear.layer.shadowColor = [[UIColor grayColor] CGColor];
        _btnClear.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
        _btnClear.layer.shadowOpacity = 1.0f;
        _btnClear.layer.shadowRadius = 3.0f;
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Dynamic form"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
        _arrDynamic = [[NSMutableArray alloc]init];
        _arrDropDown = [[NSMutableArray alloc]init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(-20, 0, 22, 22);
        [button setBackgroundImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnBack_tapped) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
        [barButton setCustomView:button];
        self.navigationItem.leftBarButtonItem=barButton;
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button1 setImage:[UIImage imageNamed:@"Menu"] forState:UIControlStateNormal];
        [button1 addTarget:self action:@selector(updateMenuBarPositions) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button1];
        self.navigationItem.rightBarButtonItem=rightBarButtonItem;
        
        [self registerForKeyboardNotifications];
        
        NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"CLEAr",@"SaVE",@"Yes",@"No",@"Ok",@"Cancel",@"Please Wait...",@"Clear",@"Your session has been expired. Please login again.",@"Server Error.",@"Signing off.",@"You must be online for the app to function.",@"Are you sure you want to continue without trasponder?",nil]];
        
        NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
        
        strYes = @"Yes";
        strNo = @"No";
        strOk = @"OK";
        strCancel = @"CANCEL";//Cancel
        strWait = @"Please Wait...";
        strNoInternet = @"You must be online for the app to function.";
        strClear = @"CLEAR";
        strUnauthorised =@"Your session has been expired. Please login again.";
        strServerErr= @"Server Error.";
        strSignOff = @"Signing off.";
        strMsgTranspoder = @"Are you sure you want to continue without trasponder?";
        if (resultArray1.count!=0){
            for (int i=0; i<resultArray1.count; i++){
                [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
                //NSLog(@"dictMenu=%@",dictMenu);
            }
            
            for (int i=0; i<13; i++) {
                if (i==0){
                    NSString *strSearchTitle;
                    if ([dictMenu objectForKey:@"CLEAR"] && ![[dictMenu objectForKey:@"CLEAR"] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:@"CLEAR"] length]>0) {
                            strSearchTitle = [dictMenu objectForKey:@"CLEAR"]?[dictMenu objectForKey:@"CLEAR"]:@"";
                        }
                        //                        else{
                        //                            strSearchTitle = @"CLEAR";
                        //                        }
                    }
                    //                    else{
                    //                            strSearchTitle = @"CLEAR";
                    //                    }
                    
                    [self.btnClear setTitle:strSearchTitle forState:UIControlStateNormal];
                }else  if (i==1){
                    NSString *strSearchTitle;
                    if ([dictMenu objectForKey:@"SAVE"] && ![[dictMenu objectForKey:@"SAVE"] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:@"SAVE"] length]>0) {
                            strSearchTitle = [dictMenu objectForKey:@"SAVE"]?[dictMenu objectForKey:@"SAVE"]:@"";
                        }
                        //                        else{
                        //                            strSearchTitle = @"SAVE";
                        //                        }
                    }
                    //                    else{
                    //                        strSearchTitle = @"SAVE";
                    //                    }
                    
                    [self.btnSave setTitle:strSearchTitle forState:UIControlStateNormal];
                }else  if (i==2){
                    if ([dictMenu objectForKey:[@"Yes" uppercaseString]] && ![[dictMenu objectForKey:[@"Yes" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Yes" uppercaseString]] length]>0) {
                            strYes = [dictMenu objectForKey:[@"Yes" uppercaseString]]?[dictMenu objectForKey:[@"Yes" uppercaseString]]:@"";
                        }
                        //                        else{
                        //                            strYes = @"Yes";
                        //                        }
                    }
                    //                    else{
                    //                        strYes = @"Yes";
                    //                    }
                }else  if (i==3){
                    if ([dictMenu objectForKey:[@"No" uppercaseString]] && ![[dictMenu objectForKey:[@"No" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"No" uppercaseString]] length]>0) {
                            strNo = [dictMenu objectForKey:[@"No" uppercaseString]]?[dictMenu objectForKey:[@"No" uppercaseString]]:@"";
                        }
                        //                        else{
                        //                            strNo = @"No";
                        //                        }
                    }
                    //                    else{
                    //                        strNo = @"No";
                    //                    }
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
                    if ([dictMenu objectForKey:[@"CLEAR" uppercaseString]] && ![[dictMenu objectForKey:[@"CLEAR" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"CLEAR" uppercaseString]] length]>0) {
                            strClear = [dictMenu objectForKey:[@"CLEAR" uppercaseString]]?[dictMenu objectForKey:[@"CLEAR" uppercaseString]]:@"";
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
                }else  if (i==11) {
                    if ([dictMenu objectForKey:[@"Signing off." uppercaseString]] && ![[dictMenu objectForKey:[@"Signing off." uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Signing off." uppercaseString]] length]>0) {
                            strSignOff = [dictMenu objectForKey:[@"Signing off." uppercaseString]]?[dictMenu objectForKey:[@"Signing off." uppercaseString]]:@"";
                        }
                    }
                }else  if (i==12) {
                    if ([dictMenu objectForKey:[@"Are you sure you want to continue without trasponder?" uppercaseString]] && ![[dictMenu objectForKey:[@"Are you sure you want to continue without trasponder?" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"Are you sure you want to continue without trasponder?" uppercaseString]] length]>0) {
                            strMsgTranspoder = [dictMenu objectForKey:[@"Are you sure you want to continue without trasponder?" uppercaseString]]?[dictMenu objectForKey:[@"Are you sure you want to continue without trasponder?" uppercaseString]]:@"";
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in viewDidLoad=%@",exception.description);
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self registerForKeyboardNotifications];
    
    if (![strFromDropDownView  isEqual: @"fromDropDownView"]) {
        @try {
            [super viewWillAppear:animated];
            
            NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
            [pref setValue:@"OnDataEntryScreen" forKey:@"CurrentPage"];
            [pref synchronize];
            
            if ([_strFromEditPage isEqualToString:@"fromEditPage"])
            {
                _strFromEditPage = @"FromEdit";
            }
            else
            {
                _strFromEditPage = @"FromDataEntry";
            }
            
            isOpenDynamic = NO;
            
            NSString * strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
            NSString *strFromSetting = [pref valueForKey:@"FromSetting"];
            //~~~~~ Added for piglet identities By M.
            pigletIdentityDict = [NSMutableDictionary dictionaryWithDictionary:@{
                @"Identity": @"",
                @"Tattoo": @"",
                @"Transponder": @"",
                @"Sex": @"",
                @"Weight": @0,
                @"Teats": @0,
                @"TeatsLeft": @0,
                @"TeatsBBL": @0,
                @"TeatsBBR": @0,
                @"Color": @"",
                @"Designation": @""
            }];
            pigletIdentityJsonDict = [NSMutableDictionary dictionaryWithDictionary:@{
                @"34": @"", //Identity
                @"35": @"", //Tattoo
                @"36": @"", //Transponder
                @"37": @"", //Sex
                @"38": @0,//Weight
                @"39": @0, //Teats
                @"40": @0,//TeatsLeft
                @"41": @0, //TeatsBBL
                @"42": @0, //TeatsBBR
                @"43": @"", //Color
                @"44": @"" //Designation
            }];
            /*strSplitSex = [pref valueForKey:@"SSL"];
             strSplitWex = [pref valueForKey:@"SSW"];*/
            //***code added for SplitSex Functionality Bug-27775 By M  @@@@@
            strSplitSex = [[pref valueForKey:@"SSL"] boolValue];
            strSplitWex = [[pref valueForKey:@"SSW"] boolValue];
            strSplitLosses = [[pref valueForKey:@"splitsexlosses"] boolValue];
            strSplitFostered = [[pref valueForKey:@"splitsexfostered"] boolValue];
            strSplitDefects = [[pref valueForKey:@"splitsexdefects"] boolValue];
            strSplitTreatments = [[pref valueForKey:@"splitsextreatments"] boolValue];
            NSLog(@"strSplitSex=%d",strSplitSex);
            NSLog(@"strSplitWex=%d",strSplitWex);
            
            if ([strFromSetting isEqualToString:@"0"]) {
                NSArray *arrUserParameter = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"User_Parameters" andPredicate:nil andSortDescriptors:nil];
                //***commented below code for User_Parameters api changes By M.
                
                //for (int count=0; count<arrUserParameter.count; count++) {
                //if ([[[arrUserParameter objectAtIndex:count] valueForKey:@"up_date_settings_input_format"]  isEqualToString:@"DateUsageFormat"]) {
                //_strDateFormat = [arrUserParameter valueForKey:@"up_date_settings_input_format"];
                //}
                // }
                
                for (NSInteger i = 0; i < arrUserParameter.count; i++) {
                    NSManagedObject *managedObject = arrUserParameter[i];
                    
                    NSNumber *dateFormatNumber = [managedObject valueForKey:@"up_date_settings_input_format"];
                    //*** code added for Bug-28561 By M.
                    isGestationWarnLengthflg = [[managedObject valueForKey:@"up_date_settings_input_format"] boolValue];
                    // Convert the numerical value to a string
                    _strDateFormat = [dateFormatNumber stringValue];
                    //***added for bug-29662 By M.
                    _strOutputDateFormat = [managedObject valueForKey:@"up_date_settings_output_format"];
                    NSLog(@"_strDateFormat: %@", _strDateFormat);
                }
                
                //*** codition changed as per the User_Params API response for date for Bug-27782 By M.
                
                //if ([_strDateFormat isEqualToString:@"7"]) {
                if ([_strDateFormat isEqualToString:@"1"]) {
                    isThousandFormat = YES;
                }else {
                    isThousandFormat = NO;
                }
                
                NSLog(@"_strDateFormat=%@",_strDateFormat);
                
                self.title = self.strTitle;
                self.lblSelectedValue.text = self.lblTitle;
                [_arrDynamic removeAllObjects];
                //~~~~~ added for Piglet Identities By M.
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Data_Entry_Items"];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"cd == %@", strEventCode];
                fetchRequest.sortDescriptors = nil;
                fetchRequest.relationshipKeyPathsForPrefetching = @[@"dkaItems"];
                NSArray *resultArray = [[CoreDataHandler sharedHandler]getValuesToListWithFetchRequest:fetchRequest];

                for (NSManagedObject *dataEntryItem in resultArray){
                    _dictDynamic = [[NSMutableDictionary alloc]init];
                    
                    // NSString *strData = [[resultArray objectAtIndex:count] valueForKey:@""];
                    //if (![strData isEqualToString:@"7"])//Yogs commnetes bcz of bug NUMBER 24 IN DEFECT SHEET
                    {
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"co"] ?: @"" forKey:@"co"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"dk"] ?: @"" forKey:@"dk"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"dt"] ?: @"" forKey:@"dt"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"dft"] ?: @"" forKey:@"dfT"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"dfv"] ?: @"" forKey:@"dfv"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"mxv"] ?: @"" forKey:@"mxV"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"mnv"] ?: @"" forKey:@"mnV"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"lb"] ?: @"" forKey:@"Lb"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"nc"] ?: @"" forKey:@"nC"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"op"] ?: @"" forKey:@"op"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"nd"] ?: @"" forKey:@"nD"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"ps"] ?: @"" forKey:@"ps"];
                        [_dictDynamic setValue:[dataEntryItem valueForKey:@"ac"] ?: @"" forKey:@"ac"];
                        
                       
                        [_arrDynamic addObject:_dictDynamic];
                    
                        // suppose to comment for Bug-27856 and Bug-27788 by M.
                        //For removing 169 and piglet identities -------------------
                        /*for (NSMutableDictionary *dict  in _arrDynamic){
                         if ([[dict valueForKey:@"dk"] integerValue] == 169 && [[dict valueForKey:@"Lb"]   isEqual: @"Piglet Identities"]){
                         [_arrDynamic removeObject:dict];
                         }
                         //For removing 169 and piglet identities -------------------
                         } */
                        //***added code for checking the Fostering flag and removing dk=63 for  Bug-27742 By M.
                        if (strEventCode.integerValue == 27){
                            BOOL doubleIdentity=TRUE;
                            for (NSInteger i = 0; i < arrUserParameter.count; i++) {
                                NSManagedObject *managedObject = arrUserParameter[i];
                                NSNumber *doubleIdentityNumber = [managedObject valueForKey:@"up_fosterings_double_identity"];
                                doubleIdentity = [doubleIdentityNumber boolValue];
                            }
                            if (!doubleIdentity){
                                for (NSMutableDictionary *dict  in _arrDynamic){
                                    if ([[dict valueForKey:@"dk"] integerValue] == 63 && [[dict valueForKey:@"Lb"]   isEqual: @"Destination Sow (+)"]){
                                        [_arrDynamic removeObject:dict];
                                    }
                                }
                            }
                        }
                        //***end of  By M.
                    }
                }
                //~~~~~ Piglet identities by M.
                NSMutableArray *uniqueArray = [NSMutableArray array];
                NSMutableArray *uniqueArrayNew = [NSMutableArray array];
                NSArray *arrPigleyIdentityies = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Piglet_Identities" andPredicate:nil andSortDescriptors:nil];
                NSMutableArray *nestedDataArray = [NSMutableArray array];
                for (NSInteger i = 0; i < arrPigleyIdentityies.count; i++){
                    NSManagedObject *managedObject = arrPigleyIdentityies[i];
                    NSMutableDictionary *nestedDict = [NSMutableDictionary dictionary];
                   
                    //NSNumber *pigCD = [managedObject valueForKey:@"cd"];
                 
                    [nestedDict setValue:[managedObject valueForKey:@"lb"] forKey:@"lb"];
                    [nestedDict setValue:[managedObject valueForKey:@"ac"] forKey:@"ac"];
                    [nestedDict setValue:[managedObject valueForKey:@"cd"] forKey:@"cd"];
                    [nestedDict setValue:[managedObject valueForKey:@"co"] forKey:@"co"];
                    [nestedDict setValue:[managedObject valueForKey:@"coe"] forKey:@"coe"];
                    [nestedDict setValue:[managedObject valueForKey:@"dft"] forKey:@"dft"];
                    [nestedDict setValue:[managedObject valueForKey:@"dfv"] forKey:@"dfv"];
                    [nestedDict setValue:[managedObject valueForKey:@"dk"] forKey:@"dk"];
                    [nestedDict setValue:[managedObject valueForKey:@"dt"] forKey:@"dt"];
                    [nestedDict setValue:[managedObject valueForKey:@"lc"] forKey:@"lc"];
                    [nestedDict setValue:[managedObject valueForKey:@"mnv"] forKey:@"mnv"];
                    [nestedDict setValue:[managedObject valueForKey:@"mxv"] forKey:@"mxv"];
                    [nestedDict setValue:[managedObject valueForKey:@"nc"] forKey:@"nc"];
                    [nestedDict setValue:[managedObject valueForKey:@"nd"] forKey:@"nd"];
                    [nestedDict setValue:[managedObject valueForKey:@"op"] forKey:@"op"];
                    [nestedDict setValue:[managedObject valueForKey:@"ps"] forKey:@"ps"];
                    [nestedDict setValue:[managedObject valueForKey:@"dka"] forKey:@"dka"];
                    // Add the nested dictionary to the array*/
                    [nestedDataArray addObject:nestedDict];
                  
                }
                NSMutableDictionary *seen = [NSMutableDictionary dictionary];
                

                for (NSDictionary *item in nestedDataArray) {
                    NSString *itemLb = item[@"lb"];
                    if (![seen objectForKey:itemLb]) {
                        [seen setObject:@(1) forKey:itemLb];
                        [uniqueArray addObject:item];
                    }
                }

                for (NSMutableDictionary *item in uniqueArray) {
                    NSString *label = item[@"lb"];
                    NSInteger dkValue = 0;
                            
                            if ([label isEqualToString:@"Tag"]) {
                                dkValue = 34;
                            } else if ([label isEqualToString:@"Tattoo"]) {
                                dkValue = 35;
                            } else if ([label isEqualToString:@"Transponder"]) {
                                dkValue = 36;
                            } else if ([label isEqualToString:@"Sex"]) {
                                dkValue = 37;
                            } else if ([label isEqualToString:@"Weight"]) {
                                dkValue = 38;
                            } else if ([label isEqualToString:@"Teats"]) {
                                dkValue = 39;
                            } else if ([label isEqualToString:@"Teats Left"]) {
                                dkValue = 40;
                            } else if ([label isEqualToString:@"Teats BBL"]) {
                                dkValue = 41;
                            } else if ([label isEqualToString:@"Teats BBR"]) {
                                dkValue = 42;
                            } else if ([label isEqualToString:@"Color"]) {
                                dkValue = 43;
                            } else if ([label isEqualToString:@"Designation"]) {
                                dkValue = 44;
                            }
                    
                    [item setObject:@(dkValue) forKey:@"dk"];
                }
                NSLog(@"%@", uniqueArray);
                    for (NSMutableDictionary *dict  in _arrDynamic){
                        if  ([[dict valueForKey:@"dk"] integerValue] == 169 && [[dict valueForKey:@"Lb"]  isEqual: @"Piglet Identities"]){
                            
                            [dict setValue:uniqueArray forKey:@"dka"];
                            //[_arrDynamic addObject:_dictDynamic];
                            NSLog(@">>>>>>>>>>>>>>>>>>>%@",_arrDynamic);
                        }
                        
                    }
                //~~~~~end of  By M.
                    // Add the array of nested data to the main dictionary under the key "dka"
                
                    //[_dictDynamic setValue:nestedDataArray forKey:@"dka"];

                    // Add the main dictionary to the array
                    ///[_arrDynamic addObject:_dictDynamic];
                
                /*
                 //***added code for checking the Fostering flag and removing dk=63 for  Bug-27742 By M.
                 if (strEventCode.integerValue == 27){
                 BOOL doubleIdentity=TRUE;
                 for (NSInteger i = 0; i < arrUserParameter.count; i++) {
                 NSManagedObject *managedObject = arrUserParameter[i];
                 NSNumber *doubleIdentityNumber = [managedObject valueForKey:@"up_fosterings_double_identity"];
                 doubleIdentity = [doubleIdentityNumber boolValue];
                 }
                 if (!doubleIdentity){
                 for (NSMutableDictionary *dict  in _arrDynamic){
                 if ([[dict valueForKey:@"dk"] integerValue] == 63 && [[dict valueForKey:@"Lb"]   isEqual: @"Destination Sow (+)"]){
                 [_arrDynamic removeObject:dict];
                 }
                 }
                 }
                 }
                 //***end of  By M.
                 */
                
              
                NSArray *arrsorted = [_arrDynamic sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                    
                    NSInteger position1 = [[obj1 valueForKey:@"ps"] integerValue];
                    NSInteger position2 = [[obj2 valueForKey:@"ps"] integerValue];
                    
                    if (position1 <position2)
                    {
                        return  NSOrderedAscending;
                    }
                    else if (position1 >position2)
                    {
                        return NSOrderedDescending;
                    }
                    else {
                        return NSOrderedSame;
                    }
                }];
                
                [_arrDynamic removeAllObjects];
                _arrDynamic = [NSMutableArray arrayWithArray:arrsorted];
                
                _dictDynamic = [[NSMutableDictionary alloc]init];
                dictJson = [[NSMutableDictionary alloc]init];
                
                for (NSMutableDictionary *dict  in _arrDynamic) {
                    
                    if ([[dict valueForKey:@"dk"] integerValue] != 7){
                        if ([[dict valueForKey:@"dk"] integerValue] == 92){
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"" forKey:@"first"];
                            [dictText setValue:@"" forKey:@"second"];
                            [dictText setValue:@"" forKey:@"third"];
                            
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }// |||| added for fostered 57 for Bug-29732 By M.
                        else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue] == 3 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue] == 57 && [self isTwoText])){
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"" forKey:@"Male"];
                            [dictText setValue:@"" forKey:@"Female"];
                            
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }
                        else if([[dict valueForKey:@"dk"] integerValue] == 6){
                            
                            NSMutableDictionary *dictData = [[NSMutableDictionary alloc]init];
                            [dictData setValue:@"" forKey:@"br"];
                            [dictData setValue:@"" forKey:@"rm"];
                            [dictData setValue:@"" forKey:@"pn"];
                            
                            [dictJson setObject:dictData forKey:[dict valueForKey:@"dk"]];
                        }
                        //~~~~~for piglet identities by M
                        else if([[dict valueForKey:@"dk"] integerValue] == 169){
                           // [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:pigletIdentityJsonDict forKey:[dict valueForKey:@"dk"]];
                           
                        }else if([[dict valueForKey:@"dk"] integerValue] != 6){
                            [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:@"" forKey:[dict valueForKey:@"dk"]];
                        }
                    }
                }
                
                [self fillDefaultValuesForMandatoryFields];
                
                if ([strFromDataEntry isEqualToString:@"1"]) {
                    [self callEdit];
                    //added for bug-29661 By M.
                    strSelectedDateMMM = nil;
                }
                //***code added for Bug-28565 By M.
                isDateSelected = FALSE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblDynamic reloadData];
                });
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in viewWillAppear=%@",exception.description);
        }
    }
}
/*
-(void)viewWillAppear:(BOOL)animated {
    
    [self registerForKeyboardNotifications];
    
    if (![strFromDropDownView  isEqual: @"fromDropDownView"]) {
        @try {
            [super viewWillAppear:animated];
            
            NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
            [pref setValue:@"OnDataEntryScreen" forKey:@"CurrentPage"];
            [pref synchronize];
            
            if ([_strFromEditPage isEqualToString:@"fromEditPage"])
            {
                _strFromEditPage = @"FromEdit";
            }
            else
            {
                _strFromEditPage = @"FromDataEntry";
            }
            
            isOpenDynamic = NO;
            
            NSString * strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
            NSString *strFromSetting = [pref valueForKey:@"FromSetting"];
            
            /*strSplitSex = [pref valueForKey:@"SSL"];
            strSplitWex = [pref valueForKey:@"SSW"];*/
            //***code added for SplitSex Functionality Bug-27775 By M  @@@@@
    /*~~~~      strSplitSex = [[pref valueForKey:@"SSL"] boolValue];
            strSplitWex = [[pref valueForKey:@"SSW"] boolValue];
            strSplitLosses = [[pref valueForKey:@"splitsexlosses"] boolValue];
            strSplitFostered = [[pref valueForKey:@"splitsexfostered"] boolValue];
            strSplitDefects = [[pref valueForKey:@"splitsexdefects"] boolValue];
            strSplitTreatments = [[pref valueForKey:@"splitsextreatments"] boolValue];
            NSLog(@"strSplitSex=%d",strSplitSex);
            NSLog(@"strSplitWex=%d",strSplitWex);
            
            if ([strFromSetting isEqualToString:@"0"]) {
                NSArray *arrUserParameter = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"User_Parameters" andPredicate:nil andSortDescriptors:nil];
                //***commented below code for User_Parameters api changes By M.
                
                //for (int count=0; count<arrUserParameter.count; count++) {
                    //if ([[[arrUserParameter objectAtIndex:count] valueForKey:@"up_date_settings_input_format"]  isEqualToString:@"DateUsageFormat"]) {
                //_strDateFormat = [arrUserParameter valueForKey:@"up_date_settings_input_format"];
                    //}
               // }
              
                for (NSInteger i = 0; i < arrUserParameter.count; i++) {
                    NSManagedObject *managedObject = arrUserParameter[i];
                
                       NSNumber *dateFormatNumber = [managedObject valueForKey:@"up_date_settings_input_format"];
                    //*** code added for Bug-28561 By M.
                      isGestationWarnLengthflg = [[managedObject valueForKey:@"up_date_settings_input_format"] boolValue];
                       // Convert the numerical value to a string
                       _strDateFormat = [dateFormatNumber stringValue];
                       
                       NSLog(@"_strDateFormat: %@", _strDateFormat);
                }
               
               //*** codition changed as per the User_Params API response for date for Bug-27782 By M.
                //if ([_strDateFormat isEqualToString:@"7"]) {
                if ([_strDateFormat isEqualToString:@"1"]) {
                    isThousandFormat = YES;
                }else {
                    isThousandFormat = NO;
                }
                
                NSLog(@"_strDateFormat=%@",_strDateFormat);
                
                self.title = self.strTitle;
                self.lblSelectedValue.text = self.lblTitle;
                [_arrDynamic removeAllObjects];
                
                NSArray *resultArray = [[CoreDataHandler sharedHandler]getValuesToListWithEntityName:@"Data_Entry_Items" andPredicate:[NSPredicate predicateWithFormat:@"cd == %@", strEventCode] andSortDescriptors:nil];
                
                for (int count=0; count<resultArray.count; count++){
                    _dictDynamic = [[NSMutableDictionary alloc]init];
                    
                    // NSString *strData = [[resultArray objectAtIndex:count] valueForKey:@""];
                    //if (![strData isEqualToString:@"7"])//Yogs commnetes bcz of bug NUMBER 24 IN DEFECT SHEET
                    {
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"co"]?[[resultArray objectAtIndex:count] valueForKey:@"co"]:@"" forKey:@"co"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"]?[[resultArray objectAtIndex:count] valueForKey:@"dk"]:@"" forKey:@"dk"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"]?[[resultArray objectAtIndex:count] valueForKey:@"dt"]:@"" forKey:@"dt"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"dft"]?[[resultArray objectAtIndex:count] valueForKey:@"dft"]:@"" forKey:@"dfT"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"dfv"]?[[resultArray objectAtIndex:count] valueForKey:@"dfv"]:@"" forKey:@"dfv"];
                    //    [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"ic"]?[[resultArray objectAtIndex:count] valueForKey:@"ic"]:@"" forKey:@"lC"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"mxv"]?[[resultArray objectAtIndex:count] valueForKey:@"mxv"]:@"" forKey:@"mxV"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"mnv"]?[[resultArray objectAtIndex:count] valueForKey:@"mnv"]:@"" forKey:@"mnV"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"lb"]?[[resultArray objectAtIndex:count] valueForKey:@"lb"]:@"" forKey:@"Lb"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"nc"]?[[resultArray objectAtIndex:count] valueForKey:@"nc"]:@"" forKey:@"nC"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"op"]?[[resultArray objectAtIndex:count] valueForKey:@"op"]:@"" forKey:@"op"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"nd"]?[[resultArray objectAtIndex:count] valueForKey:@"nd"]:@"" forKey:@"nD"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"ps"]?[[resultArray objectAtIndex:count] valueForKey:@"ps"]:@"" forKey:@"ps"];
                        [_dictDynamic setValue:[[resultArray objectAtIndex:count] valueForKey:@"ac"]?[[resultArray objectAtIndex:count] valueForKey:@"ac"]:@"" forKey:@"ac"];
                        
                        [_arrDynamic addObject:_dictDynamic];
                        
                        // suppose to comment for Bug-27856 and Bug-27788 by M.
                        //For removing 169 and piglet identities -------------------
                        /*for (NSMutableDictionary *dict  in _arrDynamic){
                            if ([[dict valueForKey:@"dk"] integerValue] == 169 && [[dict valueForKey:@"Lb"]   isEqual: @"Piglet Identities"]){
                                [_arrDynamic removeObject:dict];
                            }
                            //For removing 169 and piglet identities -------------------
                        } */
                        //***added code for checking the Fostering flag and removing dk=63 for  Bug-27742 By M.
               /*~~~~~~         if (strEventCode.integerValue == 27){
                        BOOL doubleIdentity=TRUE;
                        for (NSInteger i = 0; i < arrUserParameter.count; i++) {
                            NSManagedObject *managedObject = arrUserParameter[i];
                            NSNumber *doubleIdentityNumber = [managedObject valueForKey:@"up_fosterings_double_identity"];
                                doubleIdentity = [doubleIdentityNumber boolValue];
                        }
                        if (!doubleIdentity){
                                for (NSMutableDictionary *dict  in _arrDynamic){
                                    if ([[dict valueForKey:@"dk"] integerValue] == 63 && [[dict valueForKey:@"Lb"]   isEqual: @"Destination Sow (+)"]){
                                        [_arrDynamic removeObject:dict];
                                    }
                                }
                            }
                        }
                        //***end of  By M.
                    }
                }
               /*
                //***added code for checking the Fostering flag and removing dk=63 for  Bug-27742 By M.
                if (strEventCode.integerValue == 27){
                BOOL doubleIdentity=TRUE;
                for (NSInteger i = 0; i < arrUserParameter.count; i++) {
                    NSManagedObject *managedObject = arrUserParameter[i];
                    NSNumber *doubleIdentityNumber = [managedObject valueForKey:@"up_fosterings_double_identity"];
                        doubleIdentity = [doubleIdentityNumber boolValue];
                }
                if (!doubleIdentity){
                        for (NSMutableDictionary *dict  in _arrDynamic){
                            if ([[dict valueForKey:@"dk"] integerValue] == 63 && [[dict valueForKey:@"Lb"]   isEqual: @"Destination Sow (+)"]){
                                [_arrDynamic removeObject:dict];
                            }
                        }
                    }
                }
                //***end of  By M.
                */
           /*~~~~~     NSArray *arrsorted = [_arrDynamic sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
                    
                    NSInteger position1 = [[obj1 valueForKey:@"ps"] integerValue];
                    NSInteger position2 = [[obj2 valueForKey:@"ps"] integerValue];
                    
                    if (position1 <position2)
                    {
                        return  NSOrderedAscending;
                    }
                    else if (position1 >position2)
                    {
                        return NSOrderedDescending;
                    }
                    else {
                        return NSOrderedSame;
                    }
                }];
                
                [_arrDynamic removeAllObjects];
                _arrDynamic = [NSMutableArray arrayWithArray:arrsorted];
                
                _dictDynamic = [[NSMutableDictionary alloc]init];
                dictJson = [[NSMutableDictionary alloc]init];
                
                for (NSMutableDictionary *dict  in _arrDynamic) {
                    
                    if ([[dict valueForKey:@"dk"] integerValue] != 7){
                        if ([[dict valueForKey:@"dk"] integerValue] == 92){
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"" forKey:@"first"];
                            [dictText setValue:@"" forKey:@"second"];
                            [dictText setValue:@"" forKey:@"third"];
                            
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue] == 3 && [self isTwoText])){
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"" forKey:@"Male"];
                            [dictText setValue:@"" forKey:@"Female"];
                            
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }
                        else if([[dict valueForKey:@"dk"] integerValue] == 6){
                            
                            NSMutableDictionary *dictData = [[NSMutableDictionary alloc]init];
                            [dictData setValue:@"" forKey:@"br"];
                            [dictData setValue:@"" forKey:@"rm"];
                            [dictData setValue:@"" forKey:@"pn"];
                            
                            [dictJson setObject:dictData forKey:[dict valueForKey:@"dk"]];
                        }
                        else if([[dict valueForKey:@"dk"] integerValue] != 6){
                            [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:@"" forKey:[dict valueForKey:@"dk"]];
                        }
                    }
                }
                
                [self fillDefaultValuesForMandatoryFields];
                
                if ([strFromDataEntry isEqualToString:@"1"]) {
                    [self callEdit];
                }
                //***code added for Bug-28565 By M.
                isDateSelected = FALSE;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblDynamic reloadData];
                });
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in viewWillAppear=%@",exception.description);
        }
    }
}*/

-(void)updateMenuBarPositions {
    @try {
        
        [self.activeTextField resignFirstResponder];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeView:) name:@"CloseAlert" object:nil];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        
        if (!isOpenDynamic) {
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
        
        isOpenDynamic = !isOpenDynamic;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    @try {
        [self.tblDynamic reloadData];
    }
    @catch (NSException *exception){
        NSLog(@"Exception in willRotateToInterfaceOrientation:%@",exception.description);
    }
}

-(void)removeView:(NSNotification *) notification{
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
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
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
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
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
            //** added Pigchamp logo on alert Bug-27920 by M.
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            
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
        isOpenDynamic = !isOpenDynamic;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in removeView=%@",exception.description);
    }
}

//- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
//    return YES;
//}

#pragma mark - Table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrDynamic.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        NSMutableDictionary *dict = [_arrDynamic objectAtIndex:indexPath.row];
        if ([[dict valueForKey:@"dk"] integerValue] == 92){
            return 110;
        }//~~~~~ added for new piglet identities By M.
        else if ([[dict valueForKey:@"dk"] integerValue] == 169){
            return 510;//478;
        }
        //        else if ([[dict valueForKey:@"dk"] integerValue] == 7){
        //            return 250;
        //        }
        else if ([[dict valueForKey:@"dk"] integerValue] != 6){
            return 60;
        }
        else
            return  180;
    }
    @catch (NSException *exception){
        
        NSLog(@"Exception in heightForRowAtIndexPath = %@",exception.description);
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    @try {
//        return 60;
//    }
//    @catch (NSException *exception) {
//
//        NSLog(@"Exception in heightForFooterInSection=%@",exception.description);
//    }
//}
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    @try {
//        return _vwFooter;
//    }
//    @catch (NSException *exception) {
//
//        NSLog(@"Exception in viewForFooterInSection = %@",exception.description);
//    }
//}

//
//#pragma UIScrollView Method:
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    BOOL loading = '\0';
//    if (!loading) {
//        float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
//        if (endScrolling >= scrollView.contentSize.height)
//        [self.tblDynamic reloadData];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        UITableViewCell *cell;
        NSMutableDictionary *dict = [_arrDynamic objectAtIndex:indexPath.row];
        NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]?[dict valueForKey:@"dt"]:@""];
        
        
        //*************Code change on 18th May by Priyanka - Destaination sow purpose**************//
        ///***code condition added for Litter Identity below 21 for Bug- 28110 By M.
        //////***added for condition of 7 for Boar/Female Batch Identities Bug-28918 By M.
        if ([[dict valueForKey:@"dk"] integerValue]==1 || [[dict valueForKey:@"dk"] integerValue]==63 || [[dict valueForKey:@"dk"] integerValue]==12 || [[dict valueForKey:@"dk"] integerValue]==29 || [[dict valueForKey:@"dk"] integerValue]==69 || [[dict valueForKey:@"dk"] integerValue]==38 || [[dict valueForKey:@"dk"] integerValue]==39 || [[dict valueForKey:@"dk"] integerValue]==32 || [[dict valueForKey:@"dk"] integerValue]==27 || [[dict valueForKey:@"dk"] integerValue]==59 || [[dict valueForKey:@"dk"] integerValue]==68 || [[dict valueForKey:@"dk"] integerValue]==60 || [[dict valueForKey:@"dk"] integerValue]==21 || [[dict valueForKey:@"dk"] integerValue]==7){
            //*************Code change on 18th May by Priyanka - Destaination sow purpose**************//
            
            iRCustomCell *cell;
            //            cell = [tableView dequeueReusableCellWithIdentifier:@"TextWihScanner" forIndexPath:indexPath];
            //
            //            if (cell ==nil){
            //                cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextWihScanner"];
            //            }
            
            cell = (iRCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"TextWihScanner" forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor clearColor];
            // UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else {
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }
            else {
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else {
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            //UITextField *txtDynamic = (UITextField*)[cell viewWithTag:2];
            UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, cell.txtDetail.frame.size.height)];
            leftView.backgroundColor = [UIColor clearColor];
            cell.txtDetail.rightViewMode = UITextFieldViewModeAlways;
            cell.txtDetail.rightView = leftView;
            
            //Added for Bug-29659 By M.
            cell.txtDetail.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.txtDetail.spellCheckingType = UITextSpellCheckingTypeNo;
            if (@available(iOS 11.0, *)) {
                cell.txtDetail.smartQuotesType = UITextSmartQuotesTypeNo;
            } else {
                // Fallback on earlier versions
            }
            if (@available(iOS 11.0, *)) {
                cell.txtDetail.smartDashesType = UITextSmartDashesTypeNo;
            } else {
                // Fallback on earlier versions
            }
            if (@available(iOS 11.0, *)) {
                cell.txtDetail.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
            } else {
                // Fallback on earlier versions
            }
           
            //*** end of M.
            cell.txtDetail.text = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
           // strScan = [dict valueForKey:@"Lb"];
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            if((strMinVal.length >0 && strMaxVal.length>0)||[[dict valueForKey:@"dk"]integerValue]==24 || [self getTextType:[dict valueForKey:@"dt"]]){
                [cell.txtDetail setKeyboardType:UIKeyboardTypeNumberPad];
            }
            else{
                [cell.txtDetail setKeyboardType:UIKeyboardTypeDefault];
            }
            
            cell.txtDetail.tag = indexPath.row;
            
            [cell.btnDetail bringSubviewToFront:cell.txtDetail];
            
            
            NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
            NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
            
            
            NSLog(@"dictionary in cell for row: %@",dict);
            //***added below condition for dk=12 Bug-27966 By M.
            if ([strFromDataEntry isEqualToString:@"1"] && ([[dict valueForKey:@"dk"] integerValue]==1 || [[dict valueForKey:@"dk"] integerValue]==27 || [[dict valueForKey:@"dk"] integerValue]==63 || [[dict valueForKey:@"dk"] integerValue]==12 || [[dict valueForKey:@"dk"] integerValue]==60)){
                cell.userInteractionEnabled = NO;
            }
            else
            {
                cell.userInteractionEnabled = YES;
            }
            
            return cell;
            
        }//added below 57 for bug-29360 By M.
        else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText])  || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])) {
            
            twoTextCustomCell *cell = (twoTextCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"TwoText" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor clearColor];
            //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else {
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }
            else{
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            //
            __block NSDictionary *dictText;//= [_dictDynamic valueForKey:@"Lb"];
            
            [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                //***removed condition for bug-27735 by M.
                //*** uncommented below condition for Bug-27775 By M @@@@@
                if ([key integerValue]==51 || [key integerValue]==15 || [key integerValue]==3){
                //if ([key integerValue]==51  || [key integerValue]==3){
                    dictText = obj;
                }
            }];
            
            // UITextField *txt = (UITextField*)[cell viewWithTag:100];
            cell.txtFirst.text = [dictText valueForKey:@"Male"];
            cell.txtFirst.tag =indexPath.row;
            
            //UITextField *txtSecond = (UITextField*)[cell viewWithTag:101];
            cell.txtSecond.text = [dictText valueForKey:@"Female"];
            cell.txtSecond.tag =indexPath.row;
            
            [cell.txtFirst setKeyboardType:UIKeyboardTypeNumberPad];
            [cell.txtSecond setKeyboardType:UIKeyboardTypeNumberPad];
            
            return cell;
        }// |||| added for fostered 57 for Bug-29732 By M.
        else if (([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])) {
            
            sptwoTextCustomCell *cell = (sptwoTextCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"SPTwoText" forIndexPath:indexPath];
           cell.backgroundColor = [UIColor clearColor];
           //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
           cell.lblDetail.text = [dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
           
           if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
               if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                   cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
               }
               else {
                   cell.lblDetail.font = [UIFont systemFontOfSize:17];
               }
           }
           else{
               if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                   cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
               }
               else{
                   cell.lblDetail.font = [UIFont systemFontOfSize:13];
               }
           }
           
           //
           __block NSDictionary *dictText;//= [_dictDynamic valueForKey:@"Lb"];
           
           [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
             
               if ([key integerValue]==57){
              
                   dictText = obj;
                   *stop = YES;
               }
           }];
           // Safely set txtFirst and txtSecond text
           cell.txtFirst.text = [dictText valueForKey:@"Male"];
           cell.txtFirst.tag =indexPath.row;
           
           //UITextField *txtSecond = (UITextField*)[cell viewWithTag:101];
           cell.txtSecond.text = [dictText valueForKey:@"Female"];
           cell.txtSecond.tag =indexPath.row;
           
           [cell.txtFirst setKeyboardType:UIKeyboardTypeNumberPad];
           [cell.txtSecond setKeyboardType:UIKeyboardTypeNumberPad];
             
           
           return cell;
       }
        else if ([[dict valueForKey:@"dk"] integerValue] == 48) {
            
            
            Note *cell = (Note*)[tableView dequeueReusableCellWithIdentifier:@"Note" forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor clearColor];
            //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }
            else{
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            //UITextView *txtDynamic = (UITextView*)[cell viewWithTag:2];
            cell.txtDetail.text = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
            cell.txtDetail.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
            [cell.txtDetail setKeyboardType:UIKeyboardTypeDefault];
            cell.txtDetail.tag = indexPath.row;
            
            return cell;
            
        }
        
        //        else if ([[dict valueForKey:@"dk"] integerValue]==7){
        //            PigletIdentitiesTableViewCell *cell = (PigletIdentitiesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PigletIdentitiesTableViewCell" forIndexPath:indexPath];
        //            cell.backgroundColor = [UIColor clearColor];
        //            //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
        //            cell.lblDetail.text = [dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
        //
        //            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
        //                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
        //                }
        //                else {
        //                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
        //                }
        //            }
        //            else{
        //                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
        //                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
        //                }
        //                else{
        //                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
        //                }
        //            }
        //
        //            //                       //
        //            //                       __block NSDictionary *dictText;//= [_dictDynamic valueForKey:@"Lb"];
        //            //
        //            //                       [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        //            //                           if ([key integerValue]==51 || [key integerValue]==15){
        //            //                               dictText = obj;
        //            //                           }
        //            //                       }];
        //            //
        //            //                       // UITextField *txt = (UITextField*)[cell viewWithTag:100];
        //            //                       cell.txtFirst.text = [dictText valueForKey:@"first"];
        //            //                       cell.txtFirst.tag =indexPath.row;
        //            //
        //            //                       //UITextField *txtSecond = (UITextField*)[cell viewWithTag:101];
        //            //                       cell.txtSecond.text = [dictText valueForKey:@"second"];
        //            //                       cell.txtSecond.tag =indexPath.row;
        //            //
        //            //                       [cell.txtFirst setKeyboardType:UIKeyboardTypeNumberPad];
        //            //                       [cell.txtSecond setKeyboardType:UIKeyboardTypeNumberPad];
        //
        //            return cell;
        //        }
        //~~~~~ added for new piglet identities By M.
        else if ([[dict valueForKey:@"dk"] integerValue]==169){
            PigletIdentitiesTableViewCell *cell = (PigletIdentitiesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PigletIdentitiesTableViewCell" forIndexPath:indexPath];
            cell.delegate = self;
            cell.backgroundColor = [UIColor clearColor];
            //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else {
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }
            else{
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            [cell.txtpiglet_den setKeyboardType:UIKeyboardTypeDefault];
            [cell.txtpiglet_Tattoo setKeyboardType:UIKeyboardTypeDefault];
            [cell.txtpiglet_transp setKeyboardType:UIKeyboardTypeDefault];
            //***added decimal for Bug-29689 By M.
            [cell.txtpiglet_Weight setKeyboardType:UIKeyboardTypeDecimalPad];
            cell.txtpiglet_den.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            cell.txtpiglet_Tattoo.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            cell.txtpiglet_transp.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            
            if(![_strFromEditPage isEqualToString:@"FromEdit"]){
                cell.txtpiglet_den.tag = indexPath.row;
                cell.txtpiglet_Tattoo.tag = indexPath.row;
                cell.txtpiglet_Weight.tag = indexPath.row;
                cell.txtpiglet_transp.tag = indexPath.row;
                cell.txtpiglet_Teats.tag = indexPath.row;
                cell.txtpiglet_TeatsLeft.tag = indexPath.row;
                cell.txtpiglet_TeatsBBL.tag = indexPath.row;
                cell.txtpiglet_TeatsBBR.tag = indexPath.row;
                
                
                /* __block NSDictionary *dict;
                 
                 [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                 if ([key integerValue]==169){
                 dict = obj;
                 }
                 }];*/
                
                NSDictionary *dictDataToSend;
                NSArray *array169 = dictJson[@"169"];
                if (array169 && [array169 isKindOfClass:[NSArray class]]) {
                    if (array169.count == 1){
                        dictDataToSend = array169[0];
                        // added for Bug-29637 By M.
                        if (tagScanflg > 0 || tattooScanflg >0){
                            cell.txtpiglet_den.text = [dictDataToSend valueForKey:@"34"];
                            cell.txtpiglet_Tattoo.text = dictDataToSend[@"35"];
                            tagScanflg = 0;
                            tattooScanflg = 0;
                        }
                        [cell.btnSex setTitle:[dictDataToSend valueForKey:@"37"] forState:UIControlStateNormal];
                        [cell.btnColor setTitle:[dictDataToSend valueForKey:@"43"] forState:UIControlStateNormal];
                        [cell.btnDestination setTitle:[dictDataToSend valueForKey:@"44"] forState:UIControlStateNormal];
                    } else if(array169.count > 1) {
                        dictDataToSend = [array169 lastObject];
                        // added for Bug-29637 By M.
                        if (tagScanflg > 0 || tattooScanflg >0){
                            cell.txtpiglet_den.text = [dictDataToSend  valueForKey: @"34"];
                            cell.txtpiglet_Tattoo.text = dictDataToSend[@"35"];
                            tagScanflg = 0;
                            tattooScanflg = 0;
                        }
                        [cell.btnSex setTitle:[dictDataToSend valueForKey:@"37"] forState:UIControlStateNormal];
                        [cell.btnColor setTitle:[dictDataToSend valueForKey:@"43"] forState:UIControlStateNormal];
                        [cell.btnDestination setTitle:[dictDataToSend valueForKey:@"44"] forState:UIControlStateNormal];
                    }
                }
                else{
                    __block NSDictionary *dict;
                    
                    [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key integerValue]==169){
                            dict = obj;
                        }
                    }];
                    [cell.btnSex setTitle:[dict valueForKey:@"37"] forState:UIControlStateNormal];
                    [cell.btnColor setTitle:[dict valueForKey:@"43"] forState:UIControlStateNormal];
                    [cell.btnDestination setTitle:[dict valueForKey:@"44"] forState:UIControlStateNormal];
                }
            } if([_strFromEditPage isEqualToString:@"FromEdit"] && (!addnewPigFlg)){
                cell.txtpiglet_den.text = @"";
                cell.txtpiglet_Tattoo.text = @"";
                cell.txtpiglet_Weight.text = @"";
                cell.txtpiglet_transp.text = @"";
                cell.txtpiglet_Teats.text = @"";
                cell.txtpiglet_TeatsLeft.text = @"";
                cell.txtpiglet_TeatsBBL.text = @"";
                cell.txtpiglet_TeatsBBR.text = @"";
                [cell.btnSex setTitle:@"" forState:UIControlStateNormal];
                [cell.btnColor setTitle:@"" forState:UIControlStateNormal];
                [cell.btnDestination setTitle:@"" forState:UIControlStateNormal];
                //if ([self.delegate respondsToSelector:@selector(showPigletIdentityList:)]) {
                //   [self.delegate showPigletIdentityList:dictJson[@"169"]];
                // }
                //[self.delegate showPigletIdentityList:dictJson[@"169"]];
            }else if([_strFromEditPage isEqualToString:@"FromEdit"] && addnewPigFlg){
                cell.txtpiglet_den.tag = indexPath.row;
                cell.txtpiglet_Tattoo.tag = indexPath.row;
                cell.txtpiglet_Weight.tag = indexPath.row;
                cell.txtpiglet_transp.tag = indexPath.row;
                cell.txtpiglet_Teats.tag = indexPath.row;
                cell.txtpiglet_TeatsLeft.tag = indexPath.row;
                cell.txtpiglet_TeatsBBL.tag = indexPath.row;
                cell.txtpiglet_TeatsBBR.tag = indexPath.row;
                //~~~~~ code added for Piglet Identities By M. Bug-29595
               /* if(tagScanflg == 1){
                    cell.txtpiglet_den.text = dictJson[@"169"][@"34"];
                    tagScanflg = 0;
                }
                else if (tagScanflg == 2){
                    NSDictionary *dict = dictJson[@"169"];
                    
                    cell.txtpiglet_den.text = [dict valueForKey:@"34"];
                    tagScanflg = 0;
                }
                
                if(tattooScanflg == 1){
                    cell.txtpiglet_Tattoo.text = dictJson[@"169"][@"35"];
                    tattooScanflg = 0;
                }
                else if (tattooScanflg == 2){
                    NSDictionary *dict = dictJson[@"169"];
                    
                    cell.txtpiglet_Tattoo.text = [dict valueForKey:@"35"];
                    tattooScanflg = 0;
                }*/
                
                /* __block NSDictionary *dict;
                 
                 [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                 if ([key integerValue]==169){
                 dict = obj;
                 }
                 }];*/
                
                NSDictionary *dictDataToSend;
                NSArray *array169 = dictJson[@"169"];
                if (array169 && [array169 isKindOfClass:[NSArray class]]) {
                    if (array169.count == 1){
                        dictDataToSend = array169[0];
                        // added for Bug-29637 By M.
                        if (tagScanflg > 0 || tattooScanflg >0){
                            cell.txtpiglet_den.text = [dictDataToSend valueForKey:@"34"];
                            cell.txtpiglet_Tattoo.text = dictDataToSend[@"35"];
                            tagScanflg = 0;
                            tattooScanflg = 0;
                        }
                        [cell.btnSex setTitle:[dictDataToSend valueForKey:@"37"] forState:UIControlStateNormal];
                        [cell.btnColor setTitle:[dictDataToSend valueForKey:@"43"] forState:UIControlStateNormal];
                        [cell.btnDestination setTitle:[dictDataToSend valueForKey:@"44"] forState:UIControlStateNormal];
                    } else if(array169.count > 1) {
                        dictDataToSend = [array169 lastObject];
                        // added for Bug-29637 By M.
                        if (tagScanflg > 0 || tattooScanflg > 0){
                            cell.txtpiglet_den.text = [dictDataToSend valueForKey:@"34"];
                            cell.txtpiglet_Tattoo.text = dictDataToSend[@"35"];
                            tagScanflg = 0;
                            tattooScanflg = 0;
                        }
                        [cell.btnSex setTitle:[dictDataToSend valueForKey:@"37"] forState:UIControlStateNormal];
                        [cell.btnColor setTitle:[dictDataToSend valueForKey:@"43"] forState:UIControlStateNormal];
                        [cell.btnDestination setTitle:[dictDataToSend valueForKey:@"44"] forState:UIControlStateNormal];
                    }
                }
                else{
                    __block NSDictionary *dict;
                    
                    [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key integerValue]==169){
                            dict = obj;
                        }
                    }];
                    [cell.btnSex setTitle:[dict valueForKey:@"37"] forState:UIControlStateNormal];
                    [cell.btnColor setTitle:[dict valueForKey:@"43"] forState:UIControlStateNormal];
                    [cell.btnDestination setTitle:[dict valueForKey:@"44"] forState:UIControlStateNormal];
                }
            }
          
            return cell;
        }
        else if ([strDataType isEqualToString:@"Date"]) {
            dateCustomCell *cell= (dateCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"dateCustomCell" forIndexPath:indexPath];
            // cell = [[dateCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCustomCell"];
            
            if (cell ==nil){
                cell  = (dateCustomCell*)[[dateCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCustomCell"];
            }
            
            // YourTableViewCellClass *cell = (YourTableViewCellClass*)[tableView dequeueReusableCellWithIdentifier:@"YourCellIdentifierStringDefinedInStoryBoard"];
            //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }else{
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else {
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            //UIButton *btn = (UIButton*)[cell viewWithTag:2];
            cell.btnDetail.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;//UILineBreakModeWordWrap
            cell.btnDetail.titleLabel.textAlignment = NSTextAlignmentCenter;//UITextAlignmentCenter
            cell.btnDetail.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
            [cell.btnDetail setTitle:[_dictDynamic valueForKey:[dict valueForKey:@"Lb"]] forState:UIControlStateNormal];
            //***code added for getting value for date for bug -28145
            if ([[dict valueForKey:@"dk"] integerValue] == 2) {
                dateDeliveredValue = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
            }//
            /*
            NSString *newDateString = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
            
            NSString *formattedDateString11 = [self convertDateToStringWithDetectedFormat:newDateString];
             
            [cell.btnDetail setTitle:formattedDateString11 forState:UIControlStateNormal];*/
            
            NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init];
            [dateFormatterr setDateFormat:@"dd/MM/yyyy"];//
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init] ;
            [dateFormatter setDateFormat:@"dd-MM-yyyy'T'00:00:00"];
            NSString *currentDate;
            
            if(currentDate == nil) {
                currentDate = [dateFormatter stringFromDate:[NSDate date]];
            }
            
            NSDate *todayDate;
            todayDate =[dateFormatter dateFromString:currentDate];
            
            NSDateFormatter *dateFormatterr1 = [[NSDateFormatter alloc]init] ;
            [dateFormatterr1 setDateFormat:@"ddMMyyyy"];//
            NSDate *dtCheckIn = [dateFormatterr1 dateFromString:[dictJson valueForKey:[dict valueForKey:@"dk"]]];
            
            int days = [dtCheckIn timeIntervalSinceDate:todayDate]/24/60/60;
            //***code added for Bug-28565 By M.
            if (isDateSelected){
                [cell.btnDetail setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
               // isDateSelected = FALSE;
            }
            else{
                if (days==0){
                    [cell.btnDetail setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                }else if (days==1) {
                    [cell.btnDetail setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                }else {
                    [cell.btnDetail setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
            }
            return cell;
        }else if ([strDataType isEqualToString:@"DropDown"]) {
            if ([[dict valueForKey:@"dk"] integerValue] == 6){
                cell = [tableView dequeueReusableCellWithIdentifier:@"BarnPen" forIndexPath:indexPath];
                
                if (cell ==nil) {
                    cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BarnPen"];
                }
                
                __block NSDictionary *dictBarn;
                
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key integerValue]==6){
                        dictBarn = obj;
                    }
                }];
                
                //[dict setValue:@"1" forKey:@"co"];
                UILabel *lblBarn = (UILabel*)[cell viewWithTag:11];
                UILabel *lblRoom = (UILabel*)[cell viewWithTag:12];
                UILabel *lblPen = (UILabel*)[cell viewWithTag:13];
                
                //
                lblBarn.text = @"Barn";
                lblRoom.text = @"Room";
                lblPen.text = @"Pen";
                
                NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Barn",@"Room",@"Pen",nil]];
                NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
                
                if (resultArray1.count!=0){
                    for (int i=0; i<resultArray1.count; i++){
                        [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
                    }
                    
                    for (int i=0; i<3; i++) {
                        if (i==0) {
                            if ([dictMenu objectForKey:[@"Barn" uppercaseString]] && ![[dictMenu objectForKey:[@"Barn" uppercaseString]] isKindOfClass:[NSNull class]]) {
                                if ([[dictMenu objectForKey:[@"Barn" uppercaseString]] length]>0) {
                                    lblBarn.text = [dictMenu objectForKey:[@"Barn" uppercaseString]]?[dictMenu objectForKey:[@"Barn" uppercaseString]]:@"";
                                }
                            }
                        }else if(i==1){
                            if([dictMenu objectForKey:[@"Room" uppercaseString]] && ![[dictMenu objectForKey:[@"Room" uppercaseString]] isKindOfClass:[NSNull class]]){
                                if ([[dictMenu objectForKey:[@"Room" uppercaseString]] length]>0) {
                                    lblRoom.text = [dictMenu objectForKey:[@"Room" uppercaseString]]?[dictMenu objectForKey:[@"Room" uppercaseString]]:@"";
                                }
                            }
                        }else if(i==2)
                        {
                            if([dictMenu objectForKey:[@"Pen" uppercaseString]] && ![[dictMenu objectForKey:[@"Pen" uppercaseString]] isKindOfClass:[NSNull class]]){
                                if ([[dictMenu objectForKey:[@"Pen" uppercaseString]] length]>0) {
                                    lblPen.text = [dictMenu objectForKey:[@"Pen" uppercaseString]]?[dictMenu objectForKey:[@"Pen" uppercaseString]]:@"";
                                }
                            }
                        }
                    }
                }
                //
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                        lblBarn.font = [UIFont boldSystemFontOfSize:17];
                        lblRoom.font = [UIFont boldSystemFontOfSize:17];
                        lblPen.font = [UIFont boldSystemFontOfSize:17];
                    }
                    else{
                        lblBarn.font = [UIFont systemFontOfSize:17];
                        lblRoom.font = [UIFont systemFontOfSize:17];
                        lblPen.font = [UIFont systemFontOfSize:17];
                    }
                    
                }else{
                    if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                        lblBarn.font = [UIFont boldSystemFontOfSize:13];
                        lblRoom.font = [UIFont boldSystemFontOfSize:13];
                        lblPen.font = [UIFont boldSystemFontOfSize:13];
                    }
                    else{
                        lblBarn.font = [UIFont systemFontOfSize:13];
                        lblRoom.font = [UIFont systemFontOfSize:13];
                        lblPen.font = [UIFont systemFontOfSize:13];
                    }
                }
                
                UIButton *btn = (UIButton*)[cell viewWithTag:2];
                // btn.tag=indexPath.row;
                btn.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
                [btn setTitle:[dictBarn valueForKey:@"br"] forState:UIControlStateNormal];
                
                UIButton *btnRoom = (UIButton*)[cell viewWithTag:3];
                // btnRoom.tag=indexPath.row;
                btnRoom.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
                [btnRoom setTitle:[dictBarn valueForKey:@"rm"] forState:UIControlStateNormal];
                
                UIButton *btnPen = (UIButton*)[cell viewWithTag:4];
                //btnPen.tag=indexPath.row;
                btnPen.layer.borderColor =[[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
                [btnPen setTitle:[dictBarn valueForKey:@"pn"] forState:UIControlStateNormal];
            }
            else{
                cell = [tableView dequeueReusableCellWithIdentifier:@"DropDown" forIndexPath:indexPath];
                
                if (cell ==nil){
                    cell  = (DropDown*)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DropDown"];
                }
                
                UILabel *lbldetail = (UILabel*)[cell viewWithTag:201];
                lbldetail.text = [dict valueForKey:@"Lb"];
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                        lbldetail.font = [UIFont boldSystemFontOfSize:17];
                    }
                    else{
                        lbldetail.font = [UIFont systemFontOfSize:17];
                    }
                }else{
                    if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                        lbldetail.font = [UIFont boldSystemFontOfSize:13];
                    }
                    else {
                        lbldetail.font = [UIFont systemFontOfSize:13];
                    }
                }
                
                UIButton *btnDeatail = (UIButton*)[cell viewWithTag:2];
                //btnDeatail.tag=indexPath.row;
                //[btnDeatail addTarget:self action:@selector(btnDropdown_tapped:) forControlEvents:UIControlEventTouchUpInside];
                btnDeatail.layer.borderColor = [[UIColor colorWithRed:206.0/255.0 green:208.0/255.0 blue:206.0/255.0 alpha:1] CGColor];
                [btnDeatail setTitle:[_dictDynamic valueForKey:[dict valueForKey:@"Lb"]] forState:UIControlStateNormal];
            }
        }
        else if ([strDataType isEqualToString:@"TextField"]) {
            textCustomCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"Text" forIndexPath:indexPath];
            
            //                if (cell ==nil){
            //                }
            
            //cell  = [[textCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Text"];
            cell = (textCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"Text" forIndexPath:indexPath];
            
            //UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }else{
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            //               if (indexPath.row%2==0){
            //                   lblDetails.font = [UIFont boldSystemFontOfSize:13];
            //               }
            //               else {
            //                   lblDetails.font = [UIFont systemFontOfSize:13];
            //               }
            
            //UITextField *txtDynamic = (UITextField*)[cell viewWithTag:2];
            cell.txtDetail.text = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
            cell.txtDetail.tag = indexPath.row;
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            if((strMinVal.length >0 && strMaxVal.length>0)||[[dict valueForKey:@"dk"]integerValue]==24 || [self getTextType:[dict valueForKey:@"dt"]] || [[dict valueForKey:@"dk"]integerValue]==32){
                [cell.txtDetail setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            }
            else{
                [cell.txtDetail setKeyboardType:UIKeyboardTypeDefault];
            }
            
            return cell;
        }
        else if ([strDataType isEqualToString:@"IR"]) {
            //                cell = [tableView dequeueReusableCellWithIdentifier:@"ThreeText" forIndexPath:indexPath];
            //
            //                if (cell == nil){
            //                    cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ThreeText"];
            //                }
            
            threeTextCustomCell *cell = (threeTextCustomCell*)[tableView dequeueReusableCellWithIdentifier:@"ThreeText" forIndexPath:indexPath];
            
            // UILabel *lblDetails = (UILabel*)[cell viewWithTag:1];
            cell.lblDetail.text = [dict valueForKey:@"Lb"];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:17];
                }
                else{
                    cell.lblDetail.font = [UIFont systemFontOfSize:17];
                }
            }else{
                if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                    cell.lblDetail.font = [UIFont boldSystemFontOfSize:13];
                }
                else {
                    cell.lblDetail.font = [UIFont systemFontOfSize:13];
                }
            }
            
            //               if (indexPath.row%2==0){
            //                   lblDetails.font = [UIFont boldSystemFontOfSize:13];
            //               }
            //               else {
            //
            //                   lblDetails.font = [UIFont systemFontOfSize:13];
            //               }
            
            __block NSDictionary *dictText;//= [_dictDynamic valueForKey:@"Lb"];
            
            [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if ([key integerValue]==92) {
                    dictText = obj;
                }
            }];
            
            //UITextField *txt = (UITextField*)[cell viewWithTag:12];
            cell.txtFirst.text = [dictText valueForKey:@"first"];
            cell.txtFirst.tag = indexPath.row;
            //UITextField *txtSecond = (UITextField*)[cell viewWithTag:13];
            cell.txtSecond.text = [dictText valueForKey:@"second"];
            cell.txtSecond.tag = indexPath.row;
            
            //UITextField *txtThrid = (UITextField*)[cell viewWithTag:14];
            cell.txtThird.text = [dictText valueForKey:@"third"];
            cell.txtThird.tag = indexPath.row;
            
            return cell;
        }
        
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        
        if ([strFromDataEntry isEqualToString:@"1"] && ([[dict valueForKey:@"dk"] integerValue]==1 || [[dict valueForKey:@"dk"] integerValue]==27 || [[dict valueForKey:@"dk"] integerValue]==63 || [[dict valueForKey:@"dk"] integerValue]==60 ||[[dict valueForKey:@"dk"] integerValue]==12)){
            cell.userInteractionEnabled = NO;
        }
        else{
            cell.userInteractionEnabled = YES;
        }
        
        //cell.tag = indexPath.row;
        
        return cell;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in cellForRowAtIndexPath =%@",exception.description);
    }
}

-(BOOL)isTwoText {
    @try {
        //***below is changed cause of CSH Bug-28164 By M.
       // if ([strSplitWex isEqualToString:@"-1"] && [strSplitWex isEqualToString:@"-1"]){
       /*  if (strSplitWex == 0 && strSplitWex == 0){
            return YES;
        }else if (strSplitSex == 0) {//if ([strSplitSex isEqualToString:@"-1"]) {
            return YES;
        }else if (strSplitWex == 0){ //if ([strSplitWex isEqualToString:@"-1"]){
            return YES;
        }*/
        //***code added for SplitSex Functionality Bug-27775 By M  @@@@@
        if ((strSplitSex) && strEventCode.integerValue == 26){
            return YES;
            
        }else if(((strSplitWex)) && (strEventCode.integerValue == 29 || strEventCode.integerValue == 31 || strEventCode.integerValue == 28)){
            return YES;
            
        }else if((strSplitLosses) && strEventCode.integerValue == 32){
            return YES;
            
        }//added eventcode 31 for bug-29360 By M.
        else if((strSplitFostered) && (strEventCode.integerValue == 27 || strEventCode.integerValue == 93 || strEventCode.integerValue == 31)){
            return YES;
            
        }else if((strSplitDefects) && strEventCode.integerValue == 47){
            return YES;
            
        } else if((strSplitTreatments) && strEventCode.integerValue == 35){
            return YES;
            
        }
        return NO;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception =%@",exception.description);
    }
}

-(NSString*)getViewType:(NSString*)datatype{
    @try {
        NSArray *arrDate =[[NSArray alloc]initWithObjects:@"DT",@"DD",@"DF",nil];
        NSArray *arrDropDown =[[NSArray alloc]initWithObjects:@"CO",@"LC",@"TP",@"BL",@"SO",@"FR",@"BF",nil];
        //NSArray *arrTextField =[[NSArray alloc]initWithObjects:@"BI",@"SI", @"IN",@"AI",@"BL",@"EN",@"WT",@"C$",@"PG",@"TX",@"SI",@"ID",@"MM",@"IP",@"GI",@"MI",@"TT",@"US",nil];
        NSArray *arrTextField =[[NSArray alloc]initWithObjects:@"BI",@"SI", @"IN",@"AI",@"BL",@"EN",@"WT",@"C$",@"PG",@"TX",@"SI",@"ID",@"MM",@"IP",@"GI",@"MI",@"TT",@"US",@"LD",@"AR",@"BR",@"TR",@"SR",@"GR",nil];
        
        // Added AR,SR,GR,BR,TR on 25thApril2023
        
        if ([arrDate containsObject:datatype]){
            return @"Date";
        }
        else if ([arrDropDown containsObject:datatype])
        {
            return @"DropDown";
        }
        else if ([arrTextField containsObject:datatype]){
            return @"TextField";
        }
        else if ([datatype isEqualToString:@"IR"])
        {
            return @"IR";
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in getViewType = %@",exception.description);
    }
    return 0;
}

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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    @try
    {
        if (pickerView==self.pickerDropDown) {
            return [_arrDropDown count];
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
        
        if (pickerView==self.pickerDropDown) {
            return [[_arrDropDown objectAtIndex:row] valueForKey:@"visible"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in titleForRow- %@",[exception description]);
    }
    return 0;
}

//----------------------------------------------------------------------------------------------------------------------------------

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    @try {
//        [[self.pickerDropDown.subviews objectAtIndex:1] setBackgroundColor:[UIColor darkGrayColor]];
//        [[self.pickerDropDown.subviews objectAtIndex:2] setBackgroundColor:[UIColor darkGrayColor]];
        
        UILabel *lblSortText = (id)view;
        
        if (!lblSortText) {
            lblSortText= [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, [pickerView rowSizeForComponent:component].width-15, [pickerView rowSizeForComponent:component].height)];
        }
        
        lblSortText.font = [UIFont systemFontOfSize:13];
        lblSortText.textColor = [UIColor blackColor];
        lblSortText.textAlignment = NSTextAlignmentCenter;
        lblSortText.tintColor = [UIColor clearColor];
        
        if (pickerView==self.pickerDropDown) {
            lblSortText.text = [[_arrDropDown objectAtIndex:row] valueForKey:@"visible"];
            return lblSortText;
        }
    }
    @catch (NSException *exception)  {
        NSLog(@"Exception in viewForRow- %@",[exception description]);
    }
    return 0;
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
        NSLog(@"Exception in registerForKeyboardNotifications = %@",exception.description);
    }
}

-(BOOL)getTextType:(NSString*)dataType {
    @try {
        NSArray *arrTextField =[[NSArray alloc]initWithObjects:@"IN",@"EN",@"WT",@"C$",@"PG",nil];
        return [arrTextField containsObject:dataType]?YES:NO;
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in getTextType=%@",exception.description);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    @try {
        self.activeTextField = textView;
        
        if (!isFromKeybord && text.length>0) {
            return  NO;
        }
        
        NSLog(@"textView.text.length=%lu",(unsigned long)textView.text.length);
        
        if (textView.text.length>240) {
            return  NO;
        }
        
        NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        UITableViewCell *cell = (UITableViewCell*)[[textView superview] superview];
        NSIndexPath* indexPath = [self.tblDynamic indexPathForCell:cell];
        
        if([text isEqualToString:@"\n"]){
            NSLog(@"text=%@",text);
        }
        
        NSLog(@"indexPath.row=%ld",(long)indexPath.row);
        // NSDictionary *dict = [self.arrDynamic objectAtIndex:indexPath.row];
        NSDictionary *dict = [self.arrDynamic objectAtIndex:textView.tag];
        
        NSCharacterSet *characterSet = nil;
        characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\","];
        NSRange location = [text rangeOfCharacterFromSet:[characterSet invertedSet]];
        if ((location.location != NSNotFound) || [text isEqualToString:@""]) {
            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
            return (location.location != NSNotFound || [text isEqualToString:@""]);
        }
        else {
            return NO;
        }
        
        if([text isEqualToString:@""])
            return YES;
        
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception =%@",exception.description);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    @try {
        //~~~added for piglet identities By M.
       /* NSDictionary *dict = [[NSDictionary alloc]init];
        if([_strFromEditPage isEqualToString:@"FromEdit"]){
            NSInteger index = NSNotFound;
            // Iterate through the array of dictionaries
            for (NSInteger i = 0; i < self.arrDynamic.count; i++) {
                NSDictionary *dict = self.arrDynamic[i];
                
                // Check if the value of the "dk" key is equal to 169
                if ([dict[@"dk"] integerValue] == 169) {
                    index = i;
                    break; // Exit the loop since we found the index
                }
            }
            dict = [self.arrDynamic objectAtIndex:index];
        }else{
            dict = [self.arrDynamic objectAtIndex:textField.tag];
        }*/
        //added @@@@@  for Piglet Identities Edit issue
        NSDictionary *dict = [[NSDictionary alloc] init];

        if ([_strFromEditPage isEqualToString:@"FromEdit"]) {
            NSInteger index = NSNotFound;
            for (NSInteger i = 0; i < self.arrDynamic.count; i++) {
                NSDictionary *dict1 = self.arrDynamic[i];
                
                // Check if the value of the "dk" key is equal to 169
                if ([dict1[@"dk"] integerValue] == 169) {
                    index = i;
                    break; // Exit the loop since we found the index
                }
            }
            //added @@@@@
            if (index != NSNotFound) {
                PigletIdentitiesTableViewCell *cell = [self findCellForTextField:textField];
                if (cell){
                    dict = [self.arrDynamic objectAtIndex:index];
                }
                else {
                    
                    dict = [self.arrDynamic objectAtIndex:textField.tag];
                }
            } else {
               
                dict = [self.arrDynamic objectAtIndex:textField.tag];
            }
        } else {
            dict = [self.arrDynamic objectAtIndex:textField.tag];
        }
        //commented below for Piglet Identities
        //NSDictionary *dict = [self.arrDynamic objectAtIndex:textField.tag];
        //  NSLog(@"In shouldChangeCharactersInRange- %@",self.arrDynamic);
        string = [string uppercaseString];
        
        if(!isFromKeybord && string.length>0 && [[textField.text stringByAppendingString:string] length]==15 && strEventCode.integerValue == 37 && [[dict valueForKey:@"dk"] integerValue]==68) {
            
            if (!isRFIDCalled) {
                isRFIDCalled = YES;
                // [self getRFID:[textField.text stringByAppendingString:string] index:textField.tag];
            }
            return NO;
        }else if(!isFromKeybord && string.length>0 && [[textField.text stringByAppendingString:string] length]==15 && strEventCode.integerValue == 36 && [[dict valueForKey:@"dk"] integerValue]==68){
            
            if (!isRFIDCalled){
                isRFIDCalled = YES;
                //  [self getRFID:[textField.text stringByAppendingString:string] index:textField.tag];
            }
            return NO;
        }
        else if((strEventCode.integerValue == 2 || strEventCode.integerValue == 4 || strEventCode.integerValue == 5 || strEventCode.integerValue == 6) && ([[dict valueForKey:@"dk"] integerValue]!=32) && !isFromKeybord){
            return NO;
        }else if((strEventCode.integerValue != 2 || strEventCode.integerValue != 4 || strEventCode.integerValue != 5 || strEventCode.integerValue != 6|| strEventCode.integerValue != 36 || strEventCode.integerValue != 37) && ([[dict valueForKey:@"dk"] integerValue]==1) && !isFromKeybord && string.length>0 && [[textField.text stringByAppendingString:string] length]==15){
            
            if (!isRFIDCalled){
                isRFIDCalled = YES;
                // [self getRFID:[textField.text stringByAppendingString:string] index:textField.tag];
            }
            
            return NO;
        }else if((strEventCode.integerValue != 2 || strEventCode.integerValue != 4 || strEventCode.integerValue != 5 || strEventCode.integerValue != 6|| strEventCode.integerValue != 36 || strEventCode.integerValue != 37)  && !isFromKeybord && ([[dict valueForKey:@"dk"] integerValue]!=1) && ([[dict valueForKey:@"dk"] integerValue]!=68)){
            
            if((strEventCode.integerValue == 2 || strEventCode.integerValue == 4 || strEventCode.integerValue == 5 || strEventCode.integerValue == 6) && ([[dict valueForKey:@"dk"] integerValue]==32) && !isFromKeybord){
            }else{
                NSString *newString = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
                NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //***condition added for Liveborn bug- 27735 by M.
                if([[dict valueForKey:@"dk"] integerValue]==18 || [[dict valueForKey:@"dk"] integerValue]==15){
                    if ((location.location != NSNotFound) && ([newString length]<=2)) {
                        [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                        
                        return YES;
                    }else{
                        return NO;
                    }
                }
                return NO;
            }
        }
        
        NSUInteger decimalPlacesLimit = [[dict valueForKey:@"nD"] integerValue] ? [[dict valueForKey:@"nD"] integerValue]:0;
        NSRange rangeDot = [textField.text rangeOfString:@"." options:NSCaseInsensitiveSearch];
        
        if (rangeDot.length > 0 && decimalPlacesLimit>0){
            
            if([string isEqualToString:@"."]) {
                return NO;
            } else {
                NSArray *explodedString = [textField.text componentsSeparatedByString:@"."];
                NSString *decimalPart = explodedString[1];
                
                if (decimalPart.length >= decimalPlacesLimit && ![string isEqualToString:@""]) {
                    return NO;
                }
            }
        }
        
        NSString *newString = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
        NSString *stnumberofchars = [dict valueForKey:@"nC"]?[dict valueForKey:@"nC"]:@"";
        
        if ([[dict valueForKey:@"dk"]integerValue]==1){
            NSString *stnumberofchars = [dict valueForKey:@"nC"]?[dict valueForKey:@"nC"]:@"";
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }else if([string isEqualToString:@" "]){
                return NO;
            }
            else if ([stnumberofchars length]>0) {
                if (newString.length <=[[dict valueForKey:@"nC"] integerValue]) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return (newString.length <=[[dict valueForKey:@"nC"] integerValue]);
                }else {
                    return NO;
                }
            }
        }
        //*** commeneted above code for Identity removing last number in all entry By M.
       /* if ([[dict valueForKey:@"dk"]integerValue]==1) {
            if([string isEqualToString:@""]){
                return NO;
            }else{
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
        }*/
        //**added below condition Bugnet - 27946 by M.
        //***commented for 89 to 91 below condition for bug-28847 By M.
        else if (([[dict valueForKey:@"dk"]integerValue]==88)){ //|| ([[dict valueForKey:@"dk"]integerValue]==89) || ([[dict valueForKey:@"dk"]integerValue]==90) || ([[dict valueForKey:@"dk"]integerValue]==91)){
            if([string isEqualToString:@" "]){
                return NO;
            } //end of code by M.
           // NSArray *compWhiteSpace = [string componentsSeparatedByString:@" "];
           // if(compWhiteSpace.count > 1) {
            //    [string stringByReplacingOccurrencesOfString:@" "  withString:@""];
           //     return YES;
           // }
        }else if ([[dict valueForKey:@"dk"]integerValue]==27) {
            ///*** condition added for Bug-28148 by M.
              
            //if([string isEqualToString:@" "]){
              //  return NO;
            //}
            NSString *stnumberofchars = [dict valueForKey:@"nC"]?[dict valueForKey:@"nC"]:@"";
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }else if([string isEqualToString:@" "]){
                return NO;
            }
            else if ([stnumberofchars length]>0) {
                if (newString.length <=[[dict valueForKey:@"nC"] integerValue]) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return (newString.length <=[[dict valueForKey:@"nC"] integerValue]);
                }else {
                    return NO;
                }
            }
        
        }else if ([[dict valueForKey:@"dk"]integerValue]==38) {
            if([string isEqualToString:@" "]){
                return NO;
            }
        }//code added for Bug-29064 By M.
        else if ([[dict valueForKey:@"dk"]integerValue]==31) {
            if([string isEqualToString:@" "]){
                return NO;
            }
        }/*else if ([[dict valueForKey:@"dk"]integerValue]==69) {
            if([string isEqualToString:@" "]){
                return NO;
            }
        }*/ //**code added for New Identity bug-28619 by M.
        if ([[dict valueForKey:@"dk"] integerValue]==69) {
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            
            if (((location.location != NSNotFound) && (newString.length <=15)) || [string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                
                return (((location.location != NSNotFound) && (newString.length <=15)) || [string isEqualToString:@""]);
            }
            else
                return NO;
        }
         else if ([[dict valueForKey:@"dk"]integerValue]==68) {
            if([string isEqualToString:@" "]){
                return NO;
            }
        }
        else if ([[dict valueForKey:@"dk"]integerValue]==39) {
            if([string isEqualToString:@" "]){
                return NO;
            }
        }
        //***code added for Bug-28575 By M.
        else if ([[dict valueForKey:@"dk"]integerValue]==58) {
            if([string isEqualToString:@""]){
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            if (([strMinVal integerValue]>=0) && ([strMaxVal integerValue]>0)&&([newString length]<=2)) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]));
                }
                else
                    return NO;
            }
            else
                return NO;
            }//**code added for Identity bug-28802 by M.
        if ([[dict valueForKey:@"dk"] integerValue]==60) {
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            
            if (((location.location != NSNotFound) && (newString.length <=15)) || [string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                
                return (((location.location != NSNotFound) && (newString.length <=15)) || [string isEqualToString:@""]);
            }
            else
                return NO;
        }
        
        //******************************** code addded for Bug 28781 By M.
        else if ([[dict valueForKey:@"dk"]integerValue]==3 && (![self isTwoText])) { //added twotext condition for Bug-27775  by M @@@@@
            if ([string isEqualToString:@""]) {
                   [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                   [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                   return YES;
               }
               
               NSString *strMinVal = [dict valueForKey:@"mnV"] ? [dict valueForKey:@"mnV"] : @"";
               NSString *strMaxVal = [dict valueForKey:@"mxV"] ? [dict valueForKey:@"mxV"] : @"";
               
               // Convert newString to integer value to compare
               NSInteger intNewValue = [newString integerValue];
               
               // Adjusting the character set to include negative sign
               NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-"];
               
               // Check if the replacement string contains only valid characters
               NSRange location = [string rangeOfCharacterFromSet:characterSet];
               if (location.location != NSNotFound &&
                   [newString rangeOfCharacterFromSet:[characterSet invertedSet]].location == NSNotFound &&
                   intNewValue >= [strMinVal integerValue] &&
                   intNewValue <= [strMaxVal integerValue]) {
                   
                   [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                   [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                   return YES;
               } else {
                   return NO;
               }}//***code added for Number of Piglet for Bug-28773 By M.
     /*   else if ([[dict valueForKey:@"dk"]integerValue]==3) {
            //*** added spacing for backspace key was not working Bug-28773 and added validation for length bug-28791 By M.
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            if (([strMinVal integerValue]>=0) && ([strMaxVal integerValue]>0)&&([newString length]<= [strMaxVal length])) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890-"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if([newString  isEqual: @"-"]){
                    if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) || [newString  isEqual: @"-"]) {
                        [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                        return ((((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) || [newString  isEqual: @"-"]));
                    }
                }else{
                    NSArray *components = [newString componentsSeparatedByString:@"-"];
                    if (components.count == 2) {
                        NSString *firstPart = components[0];
                        NSString *secondPart = components[1];
                        
                        NSLog(@"First part: %@", firstPart);   // Output: (empty string if not present)
                        NSLog(@"Second part: %@", secondPart); // Output: 1
                        if ([firstPart isEqual:@""]){
                            if ((location.location != NSNotFound) && ([secondPart integerValue] >= [strMinVal integerValue] && [secondPart integerValue] <= [strMaxVal integerValue])) {
                                [self.dictDynamic setValue:secondPart forKey:[dict valueForKey:@"Lb"]];
                                [dictJson setValue:secondPart forKey:[dict valueForKey:@"dk"]];
                                
                                return ((location.location != NSNotFound) && ([secondPart integerValue] >= [strMinVal integerValue] && [secondPart integerValue] <= [strMaxVal integerValue]));
                            }
                        } else if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) || [newString  isEqual: @"-"]) {
                            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                            if([newString  isEqual: @"-"]){
                                return ((((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) || [newString  isEqual: @"-"]));
                            }
                        }
                        else
                            return NO;
                            // return ((((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) || [newString  isEqual: @"-"]));
                        }
                    }
                   
                }
            else
                return NO;
            }
        */
        
        //***code added for Bug-28584 By M.
        /*else if ([[dict valueForKey:@"dk"]integerValue]==57) {
            if([string isEqualToString:@""]){
                return NO;
            }else{
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
        }*/
        /*else if ([[dict valueForKey:@"dk"]integerValue]==57) {
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            
            if ((location.location != NSNotFound) && (newString.length < 3)){
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return ((location.location != NSNotFound) && (newString.length < 3));
            }
            else {
                return NO;
            }
        }*/
        //***commented by M. for Bug-28773
            /*else if ([[dict valueForKey:@"dk"]integerValue]==51) {
                if([string isEqualToString:@""]){
                    return NO;
                }
            }*/
        //***end of by M.
        /*else if ([[dict valueForKey:@"dk"]integerValue]==20) {
            if([newString intValue] > 999){
                return NO;
            }else {
                return YES;
            }
        }*/
        ///***code added below for litter weight was taking special character Bug- 28165 By M.
        else if ([[dict valueForKey:@"dk"]integerValue]==20) {
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            if (([strMinVal integerValue]>=0) && ([strMaxVal integerValue]>0)&&([newString length]<11)) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]));
                }
                else
                    return NO;
            }
            else
                return NO;
        }///*** end By M.
    
        ///***code added below for litter weight was taking special character Bug- 28184 and 27951 By M.
        else if ([[dict valueForKey:@"dk"]integerValue]==40) {
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            if (([strMinVal integerValue]>=0) && ([strMaxVal integerValue]>0)&&([newString length]<11)) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]));
                }
                else
                    return NO;
            }
            else
                return NO;
        }
        //*** commented below code and added above modified code
        /*else if ([[dict valueForKey:@"dk"]integerValue]==40) {
            if([newString intValue] > 999){
                return NO;
            }else {
                ///**added below code for saving total weight- Bugnet No- 27951 by M. start
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                //by M End
                return YES;
            }
        }*/
        //***commented below code for bug- 28930 By M.
        /*else if ([[dict valueForKey:@"dk"]integerValue]==29) {
           ////**** changed below length based for Bug 28054 By M.
            NSInteger maxtattolenghth = 0;
            maxtattolenghth = [[pref valueForKey:@"tattoolength"] integerValue];
           // //if(newString.length > 8){
            //**code condition below added by M.
            //if(newString.length > maxtattolenghth){
            if(newString.length > maxtattolenghth){
                return NO;
            }else {
                //** added code for bug 27924 by M.
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                //end of by M.
                return YES;
            }
        } */
        //***code added below for Bug-28930 By M.
        else if ([[dict valueForKey:@"dk"]integerValue]==29) {
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            NSInteger maxtattolenghth = 0;
            maxtattolenghth = [[pref valueForKey:@"tattoolength"] integerValue];
            if (((location.location != NSNotFound) && (newString.length <= maxtattolenghth)) || [string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                
                return (((location.location != NSNotFound) && (newString.length <= maxtattolenghth)) || [string isEqualToString:@""]);
            }
            else
                return NO;
        }
        else if ([[dict valueForKey:@"dk"]integerValue]==24) {
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            
            if ((location.location != NSNotFound) && (newString.length < 4)){
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return ((location.location != NSNotFound) && (newString.length < 4));
            }
            else {
                return NO;
            }
        }//commented below code cause of duplication for tattoo By M Bug-28930
         /* else if ([[dict valueForKey:@"dk"]integerValue]==29) {
            
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            if ((location.location != NSNotFound) && (newString.length <= [stnumberofchars integerValue])) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return (location.location != NSNotFound);
            }
            else{
                return YES;
            }
        }*/
          //***added below code for bug-28847 by M.
        else if ([[dict valueForKey:@"dk"]integerValue]==30 || [[dict valueForKey:@"dk"]integerValue]==89 || [[dict valueForKey:@"dk"]integerValue]==90 || [[dict valueForKey:@"dk"]integerValue]==91) {
            
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            if ((location.location != NSNotFound) && (newString.length <= 15)) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return (location.location != NSNotFound);
            }
            else{
                return NO;
            }
        }
        
        //***commented below code for checking max value as per Bug-27823
       /* else if (([[dict valueForKey:@"dk"]integerValue]==10)) {//as per android bug : 17759
            if([string isEqualToString:@""]){
               NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *updatednewString = [formatter numberFromString:newString];
                
                if ([updatednewString floatValue] < 9999.9902){
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
                }
            }
           
            if (([newString integerValue]>=0)&&([newString length]<8)) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if ((location.location != NSNotFound) && (([newString integerValue]>=0)&&([newString length]<8))) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    
                    return ((location.location != NSNotFound) && (([newString integerValue]>=0)&&([newString length]<8)));
                }
                else {
                    return NO;
                }
            }
            else
                return NO;
        }*/
        //***added below condition for Bug-27823 by M.
        else if ([[dict valueForKey:@"dk"]integerValue]==10) {
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            if (([strMinVal integerValue]>=0) && ([strMaxVal integerValue]>0)&&([newString length]<8)) {
                NSCharacterSet *characterSet = nil;
                ///***added below code for Bug-28121 By M.
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]));
                }
                else
                    return NO;
            }
            else
                return NO;
        }
        else if ([[dict valueForKey:@"dk"]integerValue]==151) {
            if([string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            if (([strMinVal integerValue]>=0) && ([strMaxVal integerValue]>0)&&([newString length]<11)) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]));
                }
                else
                    return NO;
            }
            else
                return NO;
        }//~~~~~~~added by M Piglet_identities
        else if ([[dict valueForKey:@"dk"] integerValue]==169) {
            
            PigletIdentitiesTableViewCell *cell = [self findCellForTextField:textField];
            if (cell) {
                    cell.btnSex.userInteractionEnabled = YES;
                    cell.btnColor.userInteractionEnabled = YES;
                    cell.btnDestination.userInteractionEnabled = YES;
                    }
            NSArray *dka = [dict valueForKey:@"dka"]?[dict valueForKey:@"dka"]:@"";
            NSString *strMinVal,*strMaxVal;
            if ([textField.placeholder isEqualToString:@"Tag"]) {
               // addnewPigFlg = YES;
                if ([_strFromEditPage isEqualToString:@"FromEdit"]){
                    addnewPigFlg = YES;
                }else{
                    addnewPigFlg = NO;
                }
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //@@@@@ by M
              
                if([string isEqualToString:@""]) {
                    
                    NSMutableString *tmp = [newString mutableCopy];
            
                    [pigletIdentityDict setObject:newString forKey:@"Identity"];
                  
                    [pigletIdentityJsonDict setObject:tmp forKey:@"34"];
                
                    return YES;
                }
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    
                    NSMutableString *tmp = [newString mutableCopy];
            
                    [pigletIdentityDict setObject:newString forKey:@"Identity"];
                  
                    [pigletIdentityJsonDict setObject:tmp forKey:@"34"];
                    NSMutableArray *existingArray = [[NSMutableArray alloc]init];
                  
                  /*  if (pigdrop){
                        NSDictionary *tmp = [dictJson valueForKey:@"169"];
                        NSString *sex,*color,*desig;
                        sex = [tmp valueForKey:@"37"];
                        color = [tmp valueForKey:@"43"];
                        desig = [tmp valueForKey:@"44"];
                        [pigletIdentityJsonDict setValue:sex forKey:@"37"];
                        [pigletIdentityJsonDict setValue:color forKey:@"43"];
                        [pigletIdentityJsonDict setValue:desig forKey:@"44"];
                        
                        if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                            [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                        }
                        [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];
                        pigdrop = NO;
                    }*/
                  
                    return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
                }
                else{
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"Tattoo"]){
                //***code added for Bug-28839 By M.
                NSInteger maxtattolenghth = 0;
                maxtattolenghth = [[pref valueForKey:@"tattoolength"] integerValue];
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    NSMutableString *tmp = [newString mutableCopy];
                  
                    [pigletIdentityDict setObject:newString forKey:@"Tattoo"];
                                 
                    [pigletIdentityJsonDict setObject:tmp forKey:@"35"];
                    
                    
                    return YES;
                }
                //if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                //***code added for Bug-28839 By M.
                if ((location.location != NSNotFound)&& (newString.length <= maxtattolenghth)) {
                    NSMutableString *tmp = [newString mutableCopy];
                  
                    [pigletIdentityDict setObject:newString forKey:@"Tattoo"];
                                 
                    [pigletIdentityJsonDict setObject:tmp forKey:@"35"];
                     // return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
                    return (((location.location != NSNotFound) && (newString.length <= maxtattolenghth)));;
                }
                else{
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"Weight"]) {
                
                NSCharacterSet *characterSet = nil;
                //***added decimal for Bug-29689 By M.
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
               
                for (NSDictionary *entry in dka) {
                    if ([entry[@"dk"] intValue] == 38) {
                        strMinVal = entry[@"mnv"];
                        strMaxVal = entry[@"mxv"];
                        break; // Exit the loop once the desired entry is found
                    }
                }
               
                if([string isEqualToString:@""]) {
                    NSMutableString *tmp = [newString mutableCopy];
                                         
                    [pigletIdentityDict setObject:newString forKey:@"Weight"];
                    [pigletIdentityJsonDict setObject:tmp forKey:@"38"];
                   
                    return YES;
                }
                if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])) {
                    NSMutableString *tmp = [newString mutableCopy];
                    
                    [pigletIdentityDict setObject:newString forKey:@"Weight"];
                    [pigletIdentityJsonDict setObject:tmp forKey:@"38"];
                    
                    return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
                }
                else{
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for Weight is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                message:custMsg
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil];
                       [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"Teats"]) {
                
                    if([string isEqualToString:@""]) {
                        NSMutableString *tmp = [newString mutableCopy];
                         
                        [pigletIdentityDict setObject:newString forKey:@"Teats"];
                           
                        [pigletIdentityJsonDict setObject:tmp forKey:@"39"];
                        return YES;
                    }
                    
                for (NSDictionary *entry in dka) {
                    if ([entry[@"dk"] intValue] == 39) {
                      
                        strMinVal = entry[@"mnv"];
                        strMaxVal = entry[@"mxv"];
                        break; // Exit the loop once the desired entry is found
                    }
                }
                if (newString.length > 2) {
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for Teats is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                message:custMsg
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil];
                       [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                       return NO;
                   }
                NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                if ([newString rangeOfCharacterFromSet:nonDigitCharacterSet].location != NSNotFound) {
                    
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for Teats is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                             message:custMsg
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return NO;
                }
                // Convert the newString to an integer value
                   NSInteger intValue = [newString integerValue];
                
                // Allow intermediate values that could form valid final values
                if (newString.length == 1) {
                    // For single digit intermediate values, allow if they can lead to a valid number
                    if (intValue >= [strMinVal integerValue] && intValue <= [strMaxVal integerValue]) {
                        //***added for saving single digit value By M.
                        [pigletIdentityDict setObject:newString forKey:@"Teats"];
                        [pigletIdentityJsonDict setObject:newString forKey:@"39"];
                        return YES;
                    } else {
                        // Allow typing '1' or '2' to form valid two-digit numbers later
                        return (intValue == 1 || intValue == 2);
                    }
                } else {
                    // For two-digit values, ensure they fall within the specified range
                    if (intValue >= [strMinVal integerValue] && intValue <= [strMaxVal integerValue]) {
                        // Update the dictionaries with the new value
                        [pigletIdentityDict setObject:newString forKey:@"Teats"];
                        [pigletIdentityJsonDict setObject:newString forKey:@"39"];
                        return YES;
                    } else {
                        
                        NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for Teats is %@ and %@",strMinVal,strMaxVal];
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                 message:custMsg
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:nil];
                        [alertController addAction:okAction];
                        [self presentViewController:alertController animated:YES completion:nil];
                        return NO;
                    }
                }
                }
                /*NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                for (NSDictionary *entry in dka) {
                    if ([entry[@"dk"] intValue] == 39) {
                        
                        strMinVal = entry[@"mnv"];
                        strMaxVal = entry[@"mxv"];
                        break; // Exit the loop once the desired entry is found
                    }
                }
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    NSMutableString *tmp = [newString mutableCopy];
                     
                    [pigletIdentityDict setObject:newString forKey:@"Teats"];
                       
                    [pigletIdentityJsonDict setObject:tmp forKey:@"39"];
                    /*if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                        [_pigletIdentitiesArray addObject:pigletIdentityDict];
                    }
                  
                  
                    [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                    if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                        [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                    }
                  
                    [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/
                    //return YES;
                /*}if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]))) {
                //if ((location.location != NSNotFound) && ([newString length]<=[strMaxVal length])) {
                    
                    NSMutableString *tmp = [newString mutableCopy];
                     
                    [pigletIdentityDict setObject:newString forKey:@"Teats"];
                       
                    [pigletIdentityJsonDict setObject:tmp forKey:@"39"];
                   /* if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                        [_pigletIdentitiesArray addObject:pigletIdentityDict];
                    }
                  
                    [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                    if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                        [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                    }
                  
                    [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/
                    
                    //return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
                //}
               /* else{
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for Teats is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                message:custMsg
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil];
                       [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    return NO;
                }*/
            //}
            else if ([textField.placeholder isEqualToString:@"Transponder"]) {
                
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                for (NSDictionary *entry in dka) {
                    if ([entry[@"dk"] intValue] == 36) {
                      
                        strMinVal = entry[@"mnv"];
                        strMaxVal = entry[@"mxv"];
                        break; // Exit the loop once the desired entry is found
                    }
                }
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    NSMutableString *tmp = [newString mutableCopy];
                 
                    [pigletIdentityDict setObject:newString forKey:@"Transponder"];
                    [pigletIdentityJsonDict setObject:tmp forKey:@"36"];
                        
                    /*if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                        [_pigletIdentitiesArray addObject:pigletIdentityDict];
                    }
                  
                  
                    [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                    if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                        [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                    }
                  
                    [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/
                    return YES;
                }
                if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]))) {
                    NSMutableString *tmp = [newString mutableCopy];
                 
                    [pigletIdentityDict setObject:newString forKey:@"Transponder"];
                    [pigletIdentityJsonDict setObject:tmp forKey:@"36"];
                        
                    /*if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                        [_pigletIdentitiesArray addObject:pigletIdentityDict];
                    }
                  
                    [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                    if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                        [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                    }
                  
                    [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/
                    return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
                }
                else{
                    
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"TeatsLeft"])
            {
                
                    if([string isEqualToString:@""]) {
                        NSMutableString *tmp = [newString mutableCopy];
                         
                        [pigletIdentityDict setObject:newString forKey:@"TeatsLeft"];
                           
                        [pigletIdentityJsonDict setObject:tmp forKey:@"40"];
                        return YES;
                    }
                    
                for (NSDictionary *entry in dka) {
                    if ([entry[@"dk"] intValue] == 40) {
                      
                        strMinVal = entry[@"mnv"];
                        strMaxVal = entry[@"mxv"];
                        break; // Exit the loop once the desired entry is found
                    }
                }
                if (newString.length > 2) {
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for TeatsLeft is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                message:custMsg
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil];
                       [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                       return NO;
                   }
                NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                if ([newString rangeOfCharacterFromSet:nonDigitCharacterSet].location != NSNotFound) {
                    
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for TeatsLeft is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                             message:custMsg
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return NO;
                }
                // Convert the newString to an integer value
                   NSInteger intValue = [newString integerValue];
                // Allow intermediate values that could form valid final values
                if (newString.length == 1) {
                    // For single digit intermediate values, allow if they can lead to a valid number
                    if (intValue >= [strMinVal integerValue] && intValue <= [strMaxVal integerValue]) {
                        //***code below added for saving the single digit value By M.
                        [pigletIdentityDict setObject:newString forKey:@"TeatsLeft"];
                        [pigletIdentityJsonDict setObject:newString forKey:@"40"];
                        return YES;
                    } else {
                        // Allow typing '1', '4', '5', '6' to form valid two-digit numbers later
                        return (intValue == 1 || intValue == 4 || intValue == 5 || intValue == 6);
                    }
                } else {
                    // For two-digit values, ensure they fall within the specified range
                    if (intValue >= [strMinVal integerValue] && intValue <= [strMaxVal integerValue]) {
                        // Update the dictionaries with the new value
                        [pigletIdentityDict setObject:newString forKey:@"TeatsLeft"];
                        [pigletIdentityJsonDict setObject:newString forKey:@"40"];
                        return YES;
                    } else {
                        return NO;
                    }
                }
                }
            /*{
                
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                for (NSDictionary *entry in dka) {
                    if ([entry[@"dk"] intValue] == 40) {
                      
                        strMinVal = entry[@"mnv"];
                        strMaxVal = entry[@"mxv"];
                        break; // Exit the loop once the desired entry is found
                    }
                }
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    NSMutableString *tmp = [newString mutableCopy];
                  
                    [pigletIdentityDict setObject:newString forKey:@"TeatsLeft"];
                                  
                    [pigletIdentityJsonDict setObject:tmp forKey:@"40"];
                   
                    return YES;
                }
                if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]))) {
             
                    NSMutableString *tmp = [newString mutableCopy];
                  
                    [pigletIdentityDict setObject:newString forKey:@"TeatsLeft"];
                                  
                    [pigletIdentityJsonDict setObject:tmp forKey:@"40"];
                   
                    return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
                }
                else{
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for TeatsLeft is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                message:custMsg
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil];
                       [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    return NO;
                }
            }*/
                
           
         else if ([textField.placeholder isEqualToString:@"TeatsBBL"]) {
             
             NSCharacterSet *characterSet = nil;
             characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
             NSRange location = [string rangeOfCharacterFromSet:characterSet];
             for (NSDictionary *entry in dka) {
                 if ([entry[@"dk"] intValue] == 41) {
                     
                     strMinVal = entry[@"mnv"];
                     strMaxVal = entry[@"mxv"];
                     break; // Exit the loop once the desired entry is found
                 }
             }
             //@@@@@ by M
             if([string isEqualToString:@""]) {
                 NSMutableString *tmp = [newString mutableCopy];
                 
                 [pigletIdentityDict setObject:newString forKey:@"TeatsBBL"];
                 [pigletIdentityJsonDict setObject:tmp forKey:@"41"];
                 
                 /*if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                     [_pigletIdentitiesArray addObject:pigletIdentityDict];
                 }
               
               
                 [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                 if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                     [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                 }
               
                 [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/
                 
                 return YES;
             }
             if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]))) {
             //if ((location.location != NSNotFound) && ([newString length]<=[strMaxVal length])) {
                 NSMutableString *tmp = [newString mutableCopy];
                 
                 [pigletIdentityDict setObject:newString forKey:@"TeatsBBL"];
                 [pigletIdentityJsonDict setObject:tmp forKey:@"41"];
                 
               /*  if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                     [_pigletIdentitiesArray addObject:pigletIdentityDict];
                 }
               
                 [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                 if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                     [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                 }
               
                 [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/

                 return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
             }
             else{
                 NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for TeatsBBL is %@ and %@",strMinVal,strMaxVal];
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                             message:custMsg
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                    [alertController addAction:okAction];
                 [self presentViewController:alertController animated:YES completion:nil];
                 
                 return NO;
             }
         }else if ([textField.placeholder isEqualToString:@"TeatsBBR"]) {
                
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
             for (NSDictionary *entry in dka) {
                 if ([entry[@"dk"] intValue] == 42) {
                    
                     strMinVal = entry[@"mnv"];
                     strMaxVal = entry[@"mxv"];
                     break; // Exit the loop once the desired entry is found
                 }
             }
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    NSMutableString *tmp = [newString mutableCopy];
                 
                    [pigletIdentityDict setObject:newString forKey:@"TeatsBBR"];
                    [pigletIdentityJsonDict setObject:tmp forKey:@"42"];
                    
                    /*if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                        [_pigletIdentitiesArray addObject:pigletIdentityDict];
                    }
                  
                  
                    [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                    if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                        [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                    }
                  
                    [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/

                    return YES;
                }
             if (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue]))) {
                 NSMutableString *tmp = [newString mutableCopy];
              
                 [pigletIdentityDict setObject:newString forKey:@"TeatsBBR"];
                 [pigletIdentityJsonDict setObject:tmp forKey:@"42"];
                 
                /* if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                     [_pigletIdentitiesArray addObject:pigletIdentityDict];
                 }
               
                 [self.dictDynamic setObject:_pigletIdentitiesArray forKey:[dict valueForKey:@"Lb"]];
                 if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                     [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                 }
               
                 [dictJson setObject:_pigletIdentitiesJsonArray forKey:[dict valueForKey:@"dk"]];*/
                 return (((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue] && [newString integerValue] <= [strMaxVal integerValue])));
             }
                else{
                    NSString *custMsg = [NSString stringWithFormat:@"The Minimum value and Maximum Value range for TeatsBBR is %@ and %@",strMinVal,strMaxVal];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                message:custMsg
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                       UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:nil];
                       [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return NO;
                }
            }
           //addnewPigFlg = NO;
        }
        else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])){
            
            NSLog(@"data item key=%@",[dict valueForKey:@"dk"]);
            
            __block NSMutableDictionary *dictText;
            [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key integerValue]==15 || [key integerValue]==51 || [key integerValue]==3) {
                    dictText = obj;
                }
            }];
            /* //commented below for Bug-27775 By M @@@@@
            if ([textField.placeholder isEqualToString:@"Male"]) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //***added below code for backspace not workin for Bug -27775 By M @@@@@
                if([string isEqualToString:@""]) {
                    [dictText setObject:newString forKey:@"Male"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                
                    return YES;
                }//@@@@@
                if (((location.location != NSNotFound) && (newString.length <3)) || [string isEqualToString:@""]) {
                    
                   // [dictText setValue:newString forKey:@"Male"];
                    //***code for Bug-27775 By M @@@@@
                    [dictText setObject:newString forKey:@"Male"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    
                    return (((location.location != NSNotFound) && (newString.length <3)) || [string isEqualToString:@""]);
                }
                else{
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"Female"]){
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //By M @@@@@ Bug-27775
                if([string isEqualToString:@""]) {
                    [dictText setObject:newString forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                
                    return YES;
                } //@@@@@
                if (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]) {
                    //[dictText setValue:newString forKey:@"Female"];
                    //By M @@@@@ Bug-27775
                    [dictText setObject:newString forKey:@"Female"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }*/
            
            if ([textField.placeholder isEqualToString:@"Male"]) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    [dictText setObject:newString forKey:@"Male"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                
                    return YES;
                }
                if (((location.location != NSNotFound) && (newString.length <3))|| [string isEqualToString:@" "]) {
                    //[dictText setValue:newString forKey:@"Male"];
                    
                        [dictText setObject:newString forKey:@"Male"];
                        
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && (newString.length <3)) || [string isEqualToString:@""]);
                }
                else{
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"Female"]){
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //@@@@@ by M.
                if([string isEqualToString:@""]) {
                    [dictText setObject:newString forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                
                    return YES;
                }
                if (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@" "]) {
                    //[dictText setValue:newString forKey:@"Female"];
                    [dictText setObject:newString forKey:@"Female"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }
            //*** code commented below for Bug-27775 By M @@@@@
          /*  else if ([[dict valueForKey:@"dk"] integerValue]==51) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                
                if (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]) {
                    [dictText setValue:newString forKey:@"Female"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }*/
        }// |||| added for fostered 57 for Bug-29732 By M.
        else if (([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
            
            NSLog(@"data item key=%@",[dict valueForKey:@"dk"]);
            
            __block NSMutableDictionary *dictText;
            [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                if ([key integerValue]==57) {
                    dictText = obj;
                }
            }];
            if ([textField.placeholder isEqualToString:@"Male"]) {
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //@@@@@ by M
                if([string isEqualToString:@""]) {
                    [dictText setObject:newString forKey:@"Male"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return YES;
                }
                if (((location.location != NSNotFound) && (newString.length <3))|| [string isEqualToString:@" "]) {
                    //[dictText setValue:newString forKey:@"Male"];
                    
                    [dictText setObject:newString forKey:@"Male"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && (newString.length <3)) || [string isEqualToString:@""]);
                }
                else{
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"Female"]){
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                //@@@@@ by M.
                if([string isEqualToString:@""]) {
                    [dictText setObject:newString forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return YES;
                }
                if (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@" "]) {
                    //[dictText setValue:newString forKey:@"Female"];
                    [dictText setObject:newString forKey:@"Female"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }
        }
        //Added for not able to enter value in Piglet Weaned and Liveborn by priyanka on 23rdOct20
        else if ([[dict valueForKey:@"dk"]integerValue]==51 || [[dict valueForKey:@"dk"]integerValue]==15){
            //  else if ([[dict valueForKey:@"dk"]integerValue]==51 || [[dict valueForKey:@"dk"]integerValue]==15  || [[dict valueForKey:@"dk"]integerValue]==3){ //Number of piglets
            NSCharacterSet *characterSet = nil;
            characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            
            if (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]) {
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                
                return (((location.location != NSNotFound) && ([newString length] < 3)) || [string isEqualToString:@""]);
            }
            else
                return NO;
        }
        //Added for not able to enter value in Piglet weaned by priyanka on 23rdOct20
        
        else if ([self getTextType:[dict valueForKey:@"dt"]]){
            
            if([string isEqualToString:@""]){
                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                return YES;
            }
            
            NSString *strMinVal =[dict valueForKey:@"mnV"]?[dict valueForKey:@"mnV"]:@"";
            NSString *strMaxVal = [dict valueForKey:@"mxV"]?[dict valueForKey:@"mxV"]:@"";
            
            NSCharacterSet *characterSet = nil;
            
            if ([[dict valueForKey:@"dk"]integerValue]==42 || [[dict valueForKey:@"dk"] integerValue]==51  || [[dict valueForKey:@"dk"] integerValue]==15 || [[dict valueForKey:@"dk"]integerValue]==3 || [[dict valueForKey:@"dk"]integerValue]==19|| [[dict valueForKey:@"dk"]integerValue]==18 || [[dict valueForKey:@"dt"] isEqualToString:@"IN"]) {
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
            }
            
            if((([[dict valueForKey:@"dk"]integerValue]!=5 || [[dict valueForKey:@"dk"]integerValue]!=151)&&[[dict valueForKey:@"dt"] isEqualToString:@"WT"]))
            {
                
                //**********Code changed on 18th April 2018**********//
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890.*"];
                
                NSString * stringAllowed = @"01234567890.*";
                NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:stringAllowed] invertedSet];
                NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
                
                NSArray * star = [textField.text componentsSeparatedByString:@"*"];
                if (star.count>1 && [string isEqualToString:@"*"])
                {
                    return NO;
                }
            }
            else{
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890."];
            }
            
            if ([[dict valueForKey:@"dk"]integerValue]==3 && [[dict valueForKey:@"dt"] isEqualToString:@"IN"] && strEventCode.integerValue == 93)
            {
                //*******Code change on 16th May by Priyanka bugnet 20927***********//
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890.-"];
                //*******Code change on 16th May by Priyanka bugnet 20927***********//
            }
            
            NSRange location = [string rangeOfCharacterFromSet:characterSet];
            if(location.location != NSNotFound){
//                if (([newString integerValue] >= [strMinVal integerValue]) && ([newString integerValue] <= [strMaxVal integerValue])) {
                if (([newString integerValue] <= [strMaxVal integerValue])) {
                    
                    if([[dict valueForKey:@"dk"] integerValue]==51  || [[dict valueForKey:@"dk"] integerValue]==15 || [[dict valueForKey:@"dk"] integerValue]==19 || [[dict valueForKey:@"dk"] integerValue]==42|| [[dict valueForKey:@"dk"]integerValue]==18 || [[dict valueForKey:@"dt"] isEqualToString:@"IN"] || [[dict valueForKey:@"dk"] integerValue]==40 || [[dict valueForKey:@"dk"] integerValue]==3) {
                        
                        
                        //*******Code change on 16th May by Priyanka bugnet 20927***********//
                        if ((location.location != NSNotFound) && ([newString length]<=3) && strEventCode.integerValue == 93)
                        {
                            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                            
                            return YES;
                        }
                        //*******Code change on 16th May by Priyanka bugnet 20927***********//
                        
                        
                        else if ((location.location != NSNotFound) && ([newString length]<=[strMaxVal length])) {
                            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                            
                            return YES;
                        }else {
                            return NO;
                        }
                        
                    }
                    
                    else if(([[dict valueForKey:@"dk"]integerValue]!=5 || [[dict valueForKey:@"dk"]integerValue]!=151)&&[[dict valueForKey:@"dt"] isEqualToString:@"WT"]){
                        if ((location.location != NSNotFound) && ([newString length]<=[strMaxVal length])) {
                            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                            
                            return YES;
                        }else {
                            
                            
                            return NO;
                        }
                    }
                    else {
                        if ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue]) && ([newString integerValue] <= [strMaxVal integerValue])) {
                            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                            return ((location.location != NSNotFound) && ([newString integerValue] >= [strMinVal integerValue]) && ([newString integerValue] <= [strMaxVal integerValue]));
                        }
                        else{
                            return NO;
                        }
                    }
                }
                else {
                    //[self notinRangeMessage:dict];
                    return NO;
                }
            }else{
                return NO;
            }
        }
        else if ([stnumberofchars integerValue]>0) {
            //            if ([[dict valueForKey:@"dk"] integerValue]==32) {
            //                NSCharacterSet *characterSet = nil;
            //                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
            //                NSRange location = [string rangeOfCharacterFromSet:characterSet];
            //
            //                if (((location.location != NSNotFound) && (newString.length <=[[dict valueForKey:@"nC"] integerValue])) || [string isEqualToString:@""]) {
            //                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
            //                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
            //
            //                    return (((location.location != NSNotFound) && (newString.length <=[[dict valueForKey:@"nC"] integerValue])) || [string isEqualToString:@""]);
            //                }
            //                else
            //                    return NO;
            //            }
            
            //Code changed by Priyanka for validating transponder field to 15 digits//
            if ([[dict valueForKey:@"dk"] integerValue]==32) {
                NSCharacterSet *characterSet = nil;
                //characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                //*** added code for alphanumeric values for Transponder Bug-28564 By M.
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                
                if (((location.location != NSNotFound) && (newString.length <=15)) || [string isEqualToString:@""]) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && (newString.length <=15)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }
            
            else if ([stnumberofchars length]>0 || [string isEqualToString:@""]){
                if (newString.length <=[[dict valueForKey:@"nC"] integerValue]) {
                    [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
                    return (newString.length <=[[dict valueForKey:@"nC"] integerValue]);
                }else{
                    return NO;
                }
            }
        }
        
        if ([[dict valueForKey:@"dk"]integerValue]!=92){
            [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
            [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
        }
        else if ([[dict valueForKey:@"dk"] integerValue] == 92){
            __block NSMutableDictionary *dictText;
            [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key integerValue]==92) {
                    dictText = obj;
                }
            }];
            
            if ([textField.placeholder isEqualToString:@"Prefix"]) {
                if([string isEqualToString:@" "]){
                    return NO;
                }
                else if ((newString.length <= 6) || [string isEqualToString:@""]) {//(location.location != NSNotFound)
                    [dictText setValue:newString forKey:@"first"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    return ((newString.length <= 6) || [string isEqualToString:@""]);
                }
                else{
                    return NO;
                }
            }else if ([textField.placeholder isEqualToString:@"From"]){
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                
                if (((location.location != NSNotFound) && ([newString length] < 10)) || [string isEqualToString:@""]) {
                    [dictText setValue:newString forKey:@"second"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && ([newString length] < 10)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }
            else if ([textField.placeholder isEqualToString:@"To"]){
                NSCharacterSet *characterSet = nil;
                characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
                NSRange location = [string rangeOfCharacterFromSet:characterSet];
                
                if (((location.location != NSNotFound) && ([newString length] < 10)) || [string isEqualToString:@""]) {
                    [dictText setValue:newString forKey:@"third"];
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    
                    return (((location.location != NSNotFound) && ([newString length] < 10)) || [string isEqualToString:@""]);
                }
                else
                    return NO;
            }
        }
        
        
        //        if(([[dict valueForKey:@"dk"] integerValue]==32)){
        //            NSString *newString = [[textField.text stringByReplacingCharactersInRange:range withString:string] uppercaseString];
        //            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"01234567890"];
        //            NSRange location = [string rangeOfCharacterFromSet:characterSet];
        //            if ((location.location != NSNotFound) && ([newString length]==15)) {
        //                [self.dictDynamic setValue:newString forKey:[dict valueForKey:@"Lb"]];
        //                [dictJson setValue:newString forKey:[dict valueForKey:@"dk"]];
        //
        //                return YES;
        //            }else{
        //                return NO;
        //            }
        //            return NO;
        //        }
        
        
        if([string isEqualToString:@""])
            return YES;
        
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in shouldChangeCharactersInRange- %@",[exception description]);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    @try{
        //        for (int i=(int)indexPath.row+1;i<self.arrDynamic.count;i++) {
        //            NSDictionary *dict = [self.arrDynamic objectAtIndex:i];
        //
        //             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //
        //            NSString *strDataType  = [self getViewType:[dict valueForKey:@"datatype"]?[dict valueForKey:@"datatype"]:@""];
        //            if ([strDataType isEqualToString:@"TextField"]) {
        //                UITableViewCell *cell = [self.tblDynamic cellForRowAtIndexPath:indexPath];
        //                UITextField *txtDynamic = (UITextField*)[cell viewWithTag:2];
        //                [txtDynamic becomeFirstResponder];
        //            }
        //        }
        
        [textField resignFirstResponder];
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in textFieldShouldReturn in ViewController- %@",[exception description]);
    }
}

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

float animatedDistance;

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeTextField = textView;
    
    
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        heightFraction = 0.0;
    }else if(heightFraction > 1.0){
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }else{
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // self.activeTextField = nil;
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    dictCurrentTextFieldClicked = [[NSDictionary alloc] init];
    // self.txtReference = nil;
    
    self.txtReference = textField;
    NSLog(@"form fields: %@",self.arrDynamic);
    
    /*dictCurrentTextFieldClicked =  [self.arrDynamic objectAtIndex:textField.tag];
    NSLog(@"Current field: %@",dictCurrentTextFieldClicked);*/
    //~~~~~ comented above two lines and added below for Piglet Identities By M.
    if([_strFromEditPage isEqualToString:@"FromEdit"]){
        NSInteger index = NSNotFound;
        // Iterate through the array of dictionaries
        for (NSInteger i = 0; i < self.arrDynamic.count; i++) {
            NSDictionary *dict = self.arrDynamic[i];
            
            // Check if the value of the "dk" key is equal to 169
            if ([dict[@"dk"] integerValue] == 169) {
                index = i;
                break; // Exit the loop since we found the index
            }
        }//added @@@@@
        if (index != NSNotFound) {
            dictCurrentTextFieldClicked = [self.arrDynamic objectAtIndex:index];
            } else {
                // Handle the case where the index was not found (optional)
                // For example, set dict to nil or an empty dictionary
                dictCurrentTextFieldClicked = @{};
            }
        } else {
            dictCurrentTextFieldClicked = [self.arrDynamic objectAtIndex:textField.tag];
        }//dictCurrentTextFieldClicked        dictCurrentTextFieldClicked =  [self.arrDynamic objectAtIndex:index];
        //end by M.
   // }else{
        //dictCurrentTextFieldClicked =  [self.arrDynamic objectAtIndex:textField.tag];
        NSLog(@"Current field: %@",dictCurrentTextFieldClicked);
    //}
    //    fullDataString = @"100000985152001342978";
    //    [self callTransponderClicked:self.txtReference];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
    [textField selectAll:nil];
    self.activeTextField = textField;
    
    //            UITableViewCell* cell = (UITableViewCell*)[[textField superview] superview];
    //            if (textField.tag==12){
    //                cell = [(UITableViewCell*)[[textField superview] superview] superview];
    //            }
    //            else if (textField.tag==13 || (textField.tag==14)){
    //                cell = [[(UITableViewCell*)[[textField superview] superview] superview] superview];
    //            }
    //            else if (textField.tag==100 || (textField.tag==101)){
    //                cell = [(UITableViewCell*)[[textField superview] superview] superview] ;
    //            }
    //
    //            NSIndexPath *indexPath = [self.tblDynamic indexPathForCell:cell];
    //
    //    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    //    [self performSelector:@selector(scrollToCell:) withObject:path afterDelay:0.5f];
    
}

//-(void) scrollToCell:(NSIndexPath*) path {
//    [self.tblDynamic scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
//}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.activeTextField = nil;
    //added @@@@@ below condition added  for piglet identities
    PigletIdentitiesTableViewCell *cell = [self findCellForTextField:textField];
    if (cell){
        //~~~~~ added below code for Piglet Identities By M.
        if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
            [_pigletIdentitiesArray addObject:pigletIdentityDict];
        }
        
        [self.dictDynamic setObject:[_pigletIdentitiesArray mutableCopy] forKey:@"Piglet Identities"];
        if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
            [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
        }
        [dictJson setObject:[_pigletIdentitiesJsonArray mutableCopy] forKey:@"169"];
    }
}

-(void)getRFID:(NSString*)transponder index:(NSInteger)index :(NSDictionary*)dictPassed{
    @try {
        NSDictionary *dict = [self.arrDynamic objectAtIndex:index];
        
        if ([[ControlSettings sharedSettings] isNetConnected ]) {
            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
            [_customIOS7AlertView showLoaderWithMessage:strWait];
            
            // NSString *strTransponder = [transponder stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
            transponder = [transponder stringByTrimmingCharactersInSet:characterSet];
            
            NSMutableDictionary *dictHeaders = [[NSMutableDictionary alloc]init];
            
            [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
            [dict setValue:transponder forKey:@"transponder"];
            //transponder = @"982000062204796";//@"985152001342994";
            //NSLog(@"The Token is ^^^^^^^^^^^^^^^^^^^^^^%@",dictHeaders);
            [ServerManager sendRequest:[NSString stringWithFormat:@"token=%@&transponder=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],transponder] idOfServiceUrl:15 headers:dictHeaders methodType:@"GET" onSucess:^(NSString *responseData) {
                [_customIOS7AlertView close];
                
                NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                isRFIDCalled = NO;
                
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                {
                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                    {
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
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
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
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
                        
                        if ([[dictPassed valueForKey:@"dk"] integerValue]==68 || [[dictPassed valueForKey:@"dk"] integerValue]==1 || [[dictPassed valueForKey:@"dk"] integerValue]==60 || [[dictPassed valueForKey:@"dk"] integerValue]==12 || [[dictPassed valueForKey:@"dk"] integerValue] == 27 || [[dictPassed valueForKey:@"dk"] integerValue] == 63)
                        {
                            [self.dictDynamic setValue:[dictResponse valueForKey:@"ResultString"]?[dictResponse valueForKey:@"ResultString"]:@"" forKey:[dictPassed valueForKey:@"Lb"]];
                            [dictJson setValue:[dictResponse valueForKey:@"ResultString"]?[dictResponse valueForKey:@"ResultString"]:@"" forKey:[dictPassed valueForKey:@"dk"]];
                            
                            for (NSDictionary *dictionary in self.arrDynamic)
                            {
                                if ([[dictionary valueForKey:@"dk"] integerValue]==32)
                                {
                                    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
                                    fullDataString = [fullDataString stringByTrimmingCharactersInSet:characterSet];
                                    
                                    [self.dictDynamic setValue:fullDataString forKey:[dictionary valueForKey:@"Lb"]];
                                    [dictJson setValue:fullDataString forKey:[dictionary valueForKey:@"dk"]];
                                    break;
                                }
                            }
                        }else if ([[dictPassed valueForKey:@"dk"] integerValue]==38 || [[dictPassed valueForKey:@"dk"] integerValue]==39)
                        {
                            [self.dictDynamic setValue:[dictResponse valueForKey:@"ResultString"]?[dictResponse valueForKey:@"ResultString"]:@"" forKey:[dictPassed valueForKey:@"Lb"]];
                            [dictJson setValue:[dictResponse valueForKey:@"ResultString"]?[dictResponse valueForKey:@"ResultString"]:@"" forKey:[dictPassed valueForKey:@"dk"]];
                        }
                        else if([[dictPassed valueForKey:@"dk"] integerValue]==32)
                        {
                            for (NSDictionary *dictionary in self.arrDynamic)
                            {
                                if ([[dictionary valueForKey:@"dk"] integerValue]==68 || [[dictionary valueForKey:@"dk"] integerValue]==1 || [[dictionary valueForKey:@"dk"] integerValue]==60 || [[dictionary valueForKey:@"dk"] integerValue]==7 || [[dictionary valueForKey:@"dk"] integerValue]==12 || [[dictionary valueForKey:@"dk"] integerValue] == 27 || [[dictPassed valueForKey:@"dk"] integerValue] == 63)
                                {
                                    [self.dictDynamic setValue:[dictResponse valueForKey:@"ResultString"]?[dictResponse valueForKey:@"ResultString"]:@"" forKey:[dictionary valueForKey:@"Lb"]];
                                    [dictJson setValue:[dictResponse valueForKey:@"ResultString"]?[dictResponse valueForKey:@"ResultString"]:@"" forKey:[dictionary valueForKey:@"dk"]];
                                    break;
                                }
                            }
                        }
                        else if([[dictPassed valueForKey:@"dk"] integerValue]==7)
                        {
                            if ([self.txtReference.text isEqualToString:@""])
                            {
                                [arrMultipleIdentities removeAllObjects];
                                [arrMultipleIdentities addObject:[dictResponse valueForKey:@"ResultString"]];
                            }
                            else
                            {
                                if ([arrMultipleIdentities containsObject:[dictResponse valueForKey:@"ResultString"]])
                                {
                                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP" message:[self getTranslatedTextForString:@"RFID tag is already scanned"] preferredStyle:UIAlertControllerStyleAlert];
                                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                                                {
                                    }]];
                                    [self presentViewController:alertController animated:YES completion:nil];
                                }
                                else{
                                    NSString * strData = [self.txtReference.text stringByAppendingString:[NSString stringWithFormat:@",%@",[dictResponse valueForKey:@"ResultString"]]];
                                    NSArray *listItems = [strData componentsSeparatedByString:@","];
                                    //  arrMultipleIdentities = listItems;
                                    arrMultipleIdentities = [listItems mutableCopy];
                                }
                            }
                            NSString *joinedString = [arrMultipleIdentities componentsJoinedByString:@","];
                            [self.dictDynamic setValue:joinedString forKey:[dictPassed valueForKey:@"Lb"]];
                            [dictJson setValue:joinedString forKey:[dictPassed valueForKey:@"dk"]];
                        }
                    }
                    [self.tblDynamic reloadData];
                }
                
                NSLog(@"responseData=%@",responseData);
            } onFailure:^(NSMutableDictionary *responseData, NSError *error){
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                //
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@,Descripyion=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text,@"on calling Rfid service"];
                [tracker set:kGAIScreenName value:strErr];
                
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                
                
                if ([responseData.allKeys containsObject:@"code"]) {
                    if ([[responseData valueForKey:@"code"]integerValue] ==401) {
                        
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:strUnauthorised
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
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
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
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
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
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
        } else{
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:strNoInternet
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            //** added Pigchamp logo on alert Bug-27920 by M.
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            
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

- (void)keyboardWasShown:(NSNotification*)aNotification {
    @try {
        isFromKeybord = YES;
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.tblDynamic.contentInset = contentInsets;
        _tblDynamic.scrollIndicatorInsets = contentInsets;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in keyboardWasShown in ViewController =%@",exception.description);
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    @try {
        [self.activeTextField resignFirstResponder];
        isFromKeybord = NO;
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.tblDynamic.contentInset = contentInsets;
        self.tblDynamic.scrollIndicatorInsets = contentInsets;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in keyboardWillHide in ViewController =%@",exception.description);
    }
}

#pragma mark - Other methods
- (IBAction)btnClear_tapped:(id)sender {
    @try {
        flag = 0;//For clearing maintain last entry field on clear click
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        if (![strFromDataEntry isEqualToString:@"1"]){
            
            NSLog(@"_dictDynamic %@",_dictDynamic);
            NSLog(@"dictJson %@",dictJson);
            
            [_dictDynamic removeAllObjects];
            [dictJson removeAllObjects];
            
            NSLog(@"_dictDynamic after%@",_dictDynamic);
            NSLog(@"dictJson after%@",dictJson);
            
            __block NSDictionary *dictBarnData,*dictForBarnRoomPen;
            dictForBarnRoomPen = [[NSDictionary alloc]init];
            dictBarnData = [[NSDictionary alloc]init];
            
            for (NSMutableDictionary *dict  in _arrDynamic){
                if ([[dict valueForKey:@"dk"] integerValue] == 92){
                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                    [dictText setValue:@"" forKey:@"first"];
                    [dictText setValue:@"" forKey:@"second"];
                    [dictText setValue:@"" forKey:@"third"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    // [_dictDynamic setObject:dictText forKey:[dict valueForKey:@"Lb"]];
                }else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])){
                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                    [dictText setValue:@"" forKey:@"Male"];
                    [dictText setValue:@"" forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    //[_dictDynamic setObject:dictText forKey:[dict valueForKey:@"Lb"]];
                }// |||| added for fostered 57 for Bug-29732 By M.
                else if (([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                    [dictText setValue:@"" forKey:@"Male"];
                    [dictText setValue:@"" forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    //[_dictDynamic setObject:dictText forKey:[dict valueForKey:@"Lb"]];
                } if([[dict valueForKey:@"dk"] integerValue] == 6){
                    NSMutableDictionary *dictBarn = [[NSMutableDictionary alloc]init];
                    [dictBarn setValue:@"" forKey:@"br"];
                    [dictBarn setValue:@"" forKey:@"rm"];
                    [dictBarn setValue:@"" forKey:@"pn"];
                    
                    NSMutableDictionary *dictData = [[NSMutableDictionary alloc]init];
                    [dictData setValue:@"" forKey:@"br"];
                    [dictData setValue:@"" forKey:@"rm"];
                    [dictData setValue:@"" forKey:@"pn"];
                    
                    [_dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setObject:dictData forKey:[dict valueForKey:@"dk"]];
                }
                else if([[dict valueForKey:@"dk"] integerValue] != 6){
                    [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:@"" forKey:[dict valueForKey:@"dk"]];
                }
            }
            
            [self fillDefaultValuesForMandatoryFields];
        }else{
            [_dictDynamic removeAllObjects];
            [dictJson removeAllObjects];
            
            NSMutableDictionary *dctReload = [[NSMutableDictionary alloc]initWithDictionary:_dictReload copyItems:YES];
            //            NSMutableDictionary *dctjsn=[dctReload objectForKey:@"dataToSend"];
            //            NSMutableDictionary *dctRes=[dctReload objectForKey:@"dataToDisplay"];
            
            NSMutableDictionary *dctjsn=[dctReload valueForKey:@"dataToSend"];
            NSMutableDictionary *dctRes=[dctReload valueForKey:@"dataToDisplay"];
            NSLog(@"  dataToSend=%@",dctjsn);
            NSLog(@"dataToDisplay=%@",dctRes);
            
            dictJson = [[NSMutableDictionary alloc]initWithDictionary:dctjsn copyItems:YES];
            _dictDynamic = [[NSMutableDictionary alloc]initWithDictionary:dctRes copyItems:YES];
            
            // dictJson =[dctReload objectForKey:@"dataToSend"] ;
            //_dictDynamic =[dctReload objectForKey:@"dataToDisplay"];
            NSLog(@"  dataToSend=%@",dictJson);
            NSLog(@"dataToDisplay=%@",_dictDynamic);
            
            
            //[self callEdit];
            
        }
        
        [self.tblDynamic reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in btnClear_tapped=%@",exception.description);
    }
}

//Added this method for bcz wanted to clear maintain last entry values to be clear on clear click
- (void)callClearFields {
    @try {
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        if (![strFromDataEntry isEqualToString:@"1"]){
            
            NSLog(@"_dictDynamic %@",_dictDynamic);
            NSLog(@"dictJson %@",dictJson);
            //***code added below for Bug-28446 and 28145 By M.
           // dateDeliveredValue = [_dictDynamic objectForKey:@"Date Delivered"];
          /*  NSString *tmpDate = [dictJson valueForKey:@"2"];
            
            // Create a date formatter for the input date format
                   NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                   [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                   
                   // Convert the input string to an NSDate
                   NSDate *inputDate = [inputDateFormatter dateFromString:tmpDate];
       
                   // Create a date formatter for the output date format
                   NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
           
            if([_strDateFormat isEqualToString:@"3"]){
                [outputDateFormatter setDateFormat:@"dd-MMM-yyyy"];
                
            }else if([_strDateFormat isEqualToString:@"4"]){
                [outputDateFormatter setDateFormat:@"MM/dd/yy"];
                
            }else if([_strDateFormat isEqualToString:@"5"]){
                [outputDateFormatter setDateFormat:@"dd/MM/yy"];
                
            }else if([_strDateFormat isEqualToString:@"7"]){
                [outputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                
            }else if([_strDateFormat isEqualToString:@"8"]){
                [outputDateFormatter setDateFormat:@"dd/MM/yyyy"];
                
            }else if([_strDateFormat isEqualToString:@"1"]){
                [outputDateFormatter setDateFormat:@"dd-MMM-yyyy"];
                
            }else if([_strDateFormat isEqualToString:@"6"]){
                [outputDateFormatter setDateFormat:@"mm/dd/yy"];
            }
                   // Convert the NSDate to the desired output format
                //   dateDeliveredValue= [outputDateFormatter stringFromDate:inputDate];
                
            */
            dateDelFlg = TRUE;
            [_dictDynamic removeAllObjects];
            [dictJson removeAllObjects];
            
            NSLog(@"_dictDynamic after%@",_dictDynamic);
            NSLog(@"dictJson after%@",dictJson);
            
            __block NSDictionary *dictBarnData,*dictForBarnRoomPen;
            dictForBarnRoomPen = [[NSDictionary alloc]init];
            dictBarnData = [[NSDictionary alloc]init];
            
            for (NSMutableDictionary *dict  in _arrDynamic){
                if ([[dict valueForKey:@"dk"] integerValue] == 92){
                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                    [dictText setValue:@"" forKey:@"first"];
                    [dictText setValue:@"" forKey:@"second"];
                    [dictText setValue:@"" forKey:@"third"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    // [_dictDynamic setObject:dictText forKey:[dict valueForKey:@"Lb"]];
                }else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])){
                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                    [dictText setValue:@"" forKey:@"Male"];
                    [dictText setValue:@"" forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    //[_dictDynamic setObject:dictText forKey:[dict valueForKey:@"Lb"]];
                }// |||| added for fostered 57 for Bug-29732 By M.
                else if (([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                    [dictText setValue:@"" forKey:@"Male"];
                    [dictText setValue:@"" forKey:@"Female"];
                    
                    [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                    //[_dictDynamic setObject:dictText forKey:[dict valueForKey:@"Lb"]];
                }
                else if([[dict valueForKey:@"dk"] integerValue] == 6){
                    NSMutableDictionary *dictBarn = [[NSMutableDictionary alloc]init];
                    [dictBarn setValue:@"" forKey:@"br"];
                    [dictBarn setValue:@"" forKey:@"rm"];
                    [dictBarn setValue:@"" forKey:@"pn"];
                    
                    NSMutableDictionary *dictData = [[NSMutableDictionary alloc]init];
                    [dictData setValue:@"" forKey:@"br"];
                    [dictData setValue:@"" forKey:@"rm"];
                    [dictData setValue:@"" forKey:@"pn"];
                    
                    [_dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setObject:dictData forKey:[dict valueForKey:@"dk"]];
                }//~~~~ added for Piglet Identities By M.
                else if([[dict valueForKey:@"dk"] integerValue] == 169){
                
                    [_dictDynamic setObject:pigletIdentityDict forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setObject:pigletIdentityJsonDict forKey:[dict valueForKey:@"dk"]];
                    [self.delegate ClearPigletIdentitiesList];
                } else if([[dict valueForKey:@"dk"] integerValue] != 6){
                    [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:@"" forKey:[dict valueForKey:@"dk"]];
                }
            }
            
            [self fillDefaultValuesForMandatoryFields];
            dateDelFlg = FALSE;
        }else{
            [_dictDynamic removeAllObjects];
            [dictJson removeAllObjects];
            
            NSMutableDictionary *dctReload = [[NSMutableDictionary alloc]initWithDictionary:_dictReload copyItems:YES];
            //            NSMutableDictionary *dctjsn=[dctReload objectForKey:@"dataToSend"];
            //            NSMutableDictionary *dctRes=[dctReload objectForKey:@"dataToDisplay"];
            
            NSMutableDictionary *dctjsn=[dctReload valueForKey:@"dataToSend"];
            NSMutableDictionary *dctRes=[dctReload valueForKey:@"dataToDisplay"];
            NSLog(@"  dataToSend=%@",dctjsn);
            NSLog(@"dataToDisplay=%@",dctRes);
            
            dictJson = [[NSMutableDictionary alloc]initWithDictionary:dctjsn copyItems:YES];
            _dictDynamic = [[NSMutableDictionary alloc]initWithDictionary:dctRes copyItems:YES];
            
            // dictJson =[dctReload objectForKey:@"dataToSend"] ;
            //_dictDynamic =[dctReload objectForKey:@"dataToDisplay"];
            NSLog(@"  dataToSend=%@",dictJson);
            NSLog(@"dataToDisplay=%@",_dictDynamic);
            
            
            //[self callEdit];
            
        }
        
        [self.tblDynamic reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in btnClear_tapped=%@",exception.description);
    }
}

- (IBAction)btnSave_tapped:(id)sender {
    @try {
        [self.activeTextField resignFirstResponder];
       NSString *strMustValue = @"You must enter value for ";
        NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"You must enter a value for", @"Need to define range of numbers for the gilts that arrived.",nil]];
        
        NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
        
        if (resultArray1.count!=0){
            for (int i=0; i<resultArray1.count; i++){
                [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
            }
            
            for (int i=0; i<1; i++) {
                if (i==0) {
                    if ([dictMenu objectForKey:[@"You must enter a value for" uppercaseString]] && ![[dictMenu objectForKey:[@"You must enter a value for" uppercaseString]] isKindOfClass:[NSNull class]]) {
                        if ([[dictMenu objectForKey:[@"You must enter a value for" uppercaseString]] length]>0) {
                            strMustValue = [dictMenu objectForKey:[@"You must enter a value for" uppercaseString]]?[dictMenu objectForKey:[@"You must enter a value for" uppercaseString]]:@"";
                        }
                    }
                }
            }
        }
//~~~~~ added for piglet Identities By M.
for (NSDictionary *dict in _arrDynamic)
{
    if ([[dict valueForKey:@"dk"]integerValue] == 169){
        //**** code changed below code for Bug-29652 By M.
        /*if (_pigletIdentitiesJsonArray1 == nil || [_pigletIdentitiesJsonArray1 count] == 0 ){
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:[self getTranslatedTextForString:@" Please add atleast on Piglet to the list."]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            //** added Pigchamp logo on alert Bug-27920 by M.
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOk
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                [myAlertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
            
            return;
            
        }else{*/
            if(![_strFromEditPage isEqualToString:@"FromEdit"]){
                for (NSDictionary *dict in _arrDynamic){
                    if ([[dict valueForKey:@"dk"]integerValue] == 169){
                        
                        [self.dictDynamic setValue:_pigletIdentitiesArray1 forKey:[dict valueForKey:@"Lb"]];
                        
                        for (NSDictionary *dict1 in _pigletIdentitiesJsonArray1){
                            if (([[dict1 valueForKey:@"43"] isEqualToString:@""] ||[[dict1 valueForKey:@"44"] isEqualToString:@""])&& [[dict1 valueForKey:@"34"] isEqualToString:[array169_1 valueForKey:@"34"]] ){
                                [dict1 setValue:[array169_1 valueForKey:@"43"] forKey:@"43"];
                                [dict1 setValue:[array169_1 valueForKey:@"44"] forKey:@"44"];
                                
                            }
                        }
                        NSMutableDictionary *seenp = [NSMutableDictionary dictionary];
                        NSMutableArray *uniqueArrayp = [NSMutableArray array];
                        
                        for (NSDictionary *item in _pigletIdentitiesJsonArray1) {
                            NSString *itemLb = item[@"34"];
                            if (![seenp objectForKey:itemLb]) {
                                [seenp setObject:@(1) forKey:itemLb];
                                [uniqueArrayp addObject:item];
                            }
                        }
                        [dictJson setValue:uniqueArrayp forKey:[dict valueForKey:@"dk"]];
                    }
                }
            } else if([_strFromEditPage isEqualToString:@"FromEdit"] && (addnewPigFlg)){
                for (NSDictionary *dict in _arrDynamic){
                    {
                        if ([[dict valueForKey:@"dk"]integerValue] == 169){
                            [self.dictDynamic setValue:_pigletIdentitiesArray1 forKey:[dict valueForKey:@"Lb"]];
                            
                            for (NSDictionary *dict in _pigletIdentitiesJsonArray1){
                                if ([[dict valueForKey:@"43"] isEqualToString:@""] ||[[dict valueForKey:@"44"] isEqualToString:@""] ){
                                    [dict setValue:[array169_1 valueForKey:@"43"] forKey:@"43"];
                                    [dict setValue:[array169_1 valueForKey:@"44"] forKey:@"44"];
                                    
                                }
                            }
                            NSMutableDictionary *seenp = [NSMutableDictionary dictionary];
                            NSMutableArray *uniqueArrayp = [NSMutableArray array];
                            
                            for (NSDictionary *item in _pigletIdentitiesJsonArray1) {
                                NSString *itemLb = item[@"34"];
                                if (![seenp objectForKey:itemLb]) {
                                    [seenp setObject:@(1) forKey:itemLb];
                                    [uniqueArrayp addObject:item];
                                }
                            }
                            //[dictJson setValue:uniqueArrayp forKey:[dict valueForKey:@"dk"]];
                            //added @@@@@ for piglet identities issue in Edit
                            if (!(strpigletIdentitiesEdit == nil)){
                                [uniqueArrayp addObjectsFromArray:[self getPigletsJsonStringToArray:strpigletIdentitiesEdit]];
                                [dictJson setValue:uniqueArrayp forKey:[dict valueForKey:@"dk"]];
                            }else{
                                [dictJson setValue:uniqueArrayp forKey:[dict valueForKey:@"dk"]];
                            }
                        }
                    }
                }
            }else if([_strFromEditPage isEqualToString:@"FromEdit"] && (!addnewPigFlg)){
                for (NSDictionary *dict in _arrDynamic){
                    if ([[dict valueForKey:@"dk"]integerValue] == 169){
                        //[self.dictDynamic setValue:_pigletIdentitiesArray1 forKey:[dict valueForKey:@"Lb"]];
                        
                        //[dictJson setValue:_pigletIdentitiesJsonArray1 forKey:[dict valueForKey:@"dk"]];
                        //added @@@@@ for piglet identities  Edit issue
                       
                        if (!(strpigletIdentitiesEdit == nil)){
                            [self.dictDynamic setValue:[self getPigletsJsonStringToArray:strpigletIdentitiesEdit] forKey:[dict valueForKey:@"Lb"]];
                          
                            [dictJson setValue:[self getPigletsJsonStringToArray:strpigletIdentitiesEdit] forKey:[dict valueForKey:@"dk"]];
                        }
                        else{
                           
                            [self.dictDynamic setValue:@[] forKey:[dict valueForKey:@"Lb"]];
                          
                            [dictJson setValue:@[] forKey:[dict valueForKey:@"dk"]];
                        }
                    }
                }
            }
        }
    //}
}
        //strMustValue = [strMustValue stringByReplacingOccurrencesOfString:@"#1" withString:@""];
        
        __block NSDictionary *dictBarnData,*dictForBarnRoomPen;
        __block NSDictionary *dictTextFieldData,*dictForGuilt,*dictPigletsData,*dictForPiglets;
        
        NSMutableArray *arrLableList = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dict in _arrDynamic) {
            NSString *str  = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
            
            
            //*******Code change on 16th May by Priyanka bugnet 20927***********//
            if ([[dict valueForKey:@"dk"] integerValue] == 3 && [[dict valueForKey:@"dt"] isEqualToString:@"IN"])
            {
                NSString * strPigletValue = [dictJson valueForKey:@"3"];
                
                for (int i=0; i<strPigletValue.length; i++)
                {
                    if (i>0)
                    {
                        if ([strPigletValue characterAtIndex:i] == '-')
                        {
                            //  NSLog(@"%c",[strPigletValue characterAtIndex:i]);
                            strPigletValue=@"";
                            //   NSLog(@"%lu",(unsigned long)[strPigletValue length]);
                            if ([[dict valueForKey:@"co"] isEqualToString:@"1"] && strPigletValue.length==0){
                                [arrLableList addObject:[dict valueForKey:@"Lb"]];
                                // NSLog(@"Label Name =%@",[dict valueForKey:@"Lb"]);
                            }
                        }
                    }
                }
            }
           
           ///***added for checking DOB Bug-27777 By M.
          /*  if (strEventCode.integerValue == 6){
                if ([[dict valueForKey:@"dk"] integerValue] == 35)
                {
                    NSString *str  = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
                    NSString *dobString,*tmpdateStr1,*tmpdateStr2;
                    NSDate *newDob,*newtmpDate1,*newtmpDate2;
                    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc]init];
                    [inputFormatter setDateFormat:@"dd/MM/yy"];//@"MM-dd-yyyy"];
                    //NSDateFormatter *inputFormatter1 = [[NSDateFormatter alloc]init];
                    //[inputFormatter1 setDateFormat:@"yyyy-MM-dd"];
                    for (NSString *key in _dictDynamic) {
                        if ([key isEqualToString:@"Date of Birth"]) {
                            dobString = _dictDynamic[key];
                            if(dobString){
                                newDob = [inputFormatter dateFromString:dobString];
                            }
                           // if (newDob){
                                
                             //   dobString = [inputFormatter stringFromDate:newDob];
                            //}
                        }else if ([key isEqualToString:@"Date Last Weaned"]) {
                            tmpdateStr1 = _dictDynamic[key];
                            if(tmpdateStr1){
                                newtmpDate1 = [inputFormatter dateFromString:tmpdateStr1];
                            }
                           // if (newtmpDate1){
                                
                               // tmpdateStr1 = [inputFormatter stringFromDate:newtmpDate1];
                           // }
                            
                            
                        }else if ([key isEqualToString:@"Date Last Served"]) {
                            tmpdateStr2 = _dictDynamic[key];
                            if(tmpdateStr2){
                                newtmpDate2 = [inputFormatter dateFromString:tmpdateStr2];
                            }
                            //if (newtmpDate2){
                                
                               // tmpdateStr2 = [inputFormatter stringFromDate:newtmpDate2];
                            //}
                        }
                    }
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                   // [dateFormatter setDateFormat:@"dd/MM/yy"];//@"yyyy-MM-dd"];
                    //NSDate *dobDate = [dateFormatter dateFromString: dobString];
                   // NSDate *date1 = [dateFormatter dateFromString: tmpdateStr1];
                   // NSDate *date2 = [dateFormatter dateFromString: tmpdateStr2];
                    
                    BOOL isDOBOlder = [self isDOB:newDob olderThanDate:newtmpDate1 andDate:newtmpDate2];
                    
                    if (!isDOBOlder)
                    {
                        NSLog(@"DOB is Not older than date1 and date2");
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:[self getTranslatedTextForString:@" Date of service must be after date of Birth."]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action){
                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
                        }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                        
                        return;
                    }
                    else {
                        NSLog(@"DOB is older than date1 and date2");
                    }
                    
                    
                }
            }*/
             //*******Code change on 16th May by Priyanka bugnet 20927***********//
            
            
            // Code change done by hari 9thMay2023
                       
                       if ([[dict valueForKey:@"dk"] integerValue] == 24 && [[dict valueForKey:@"dt"] isEqualToString:@"IN"])
                       {
                          // NSString * strPigletValue = [dictJson valueForKey:@"24"];
                           
                           NSString *str  = [_dictDynamic valueForKey:[dict valueForKey:@"Lb"]];
                           
                           if([str  isEqual: @"0"]) {
                               
                               UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                          message:[[[[NSString stringWithFormat:@"%@ %@",@"Please enter Doses value more than",str] stringByAppendingString:[arrLableList componentsJoinedByString:@","]] stringByAppendingString:@""] stringByAppendingString:@"."]
                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                               //** added Pigchamp logo on alert Bug-27920 by M.
                               UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                               logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                               UIView *controllerView = myAlertController.view;
                               [controllerView addSubview:logoImageView];
                               [controllerView bringSubviewToFront:logoImageView];
                               
                               UIAlertAction* ok = [UIAlertAction
                                                    actionWithTitle:strOk
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action){
                                   [myAlertController dismissViewControllerAnimated:YES completion:nil];
                               }];

                               [myAlertController addAction: ok];
                               [self presentViewController:myAlertController animated:YES completion:nil];

                                    return;
                           }else {
                               
                                                                 
                           }
                           
//                           for (int i=0; i<strPigletValue.length; i++)
//                           {
//                               if (strPigletValue > 0)
//                               {
//
//                                   strPigletValue=@"";
////                                   if ([[dict valueForKey:@"co"] isEqualToString:@"0"] && strPigletValue.length==0){
////                                       [arrLableList addObject:[dict valueForKey:@"Lb"]];
////                                       // NSLog(@"Label Name =%@",[dict valueForKey:@"Lb"]);
////                                   }
//                               } else {
//
//                                   UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
//                                                                                                              message:[[[[NSString stringWithFormat:@"%@ ",strMustValue] stringByAppendingString:[arrLableList componentsJoinedByString:@","]] stringByAppendingString:@""] stringByAppendingString:@"."]
//                                                                                                       preferredStyle:UIAlertControllerStyleAlert];
//                                   UIAlertAction* ok = [UIAlertAction
//                                                        actionWithTitle:strOk
//                                                        style:UIAlertActionStyleDefault
//                                                        handler:^(UIAlertAction * action){
//                                       [myAlertController dismissViewControllerAnimated:YES completion:nil];
//                                   }];
//
//                                   [myAlertController addAction: ok];
//                                   [self presentViewController:myAlertController animated:YES completion:nil];
//
//
//                               }
//                           }
                       }
            
            
            
            if ([[dict valueForKey:@"dk"] integerValue] == 92){
                dictForGuilt = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key integerValue]==92)
                    {
                        dictTextFieldData = obj;
                    }
                }];
            }//*** uncommented below condition for Bug-27775 By M @@@@@
            // |||| added for fostered for 57 Bug-29732 By M.
            else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
            //***condition removed for Bug-27735 by M.
            //else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])){
                dictForPiglets = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    //*** commented below condition for Bug-27775 By M @@@@@
                   // if ([key integerValue]==92){
                    if([key integerValue]==51 || [key integerValue]==15 || [key integerValue]==3 || [key integerValue]==57){
                        dictPigletsData = obj;
                    }
                }];
            }else if([[dict valueForKey:@"dk"] integerValue] == 6){
                dictForBarnRoomPen = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key isEqualToString:@"6"])
                    {
                        dictBarnData = obj;
                    }
                }];
            }
            else {//if([[dict valueForKey:@"dk"] integerValue] != 6)
                //~~~~ added below condition for Piglet Identities By M.
                if ([[dict valueForKey:@"dk"] integerValue] != 169){
                    if ([[dict valueForKey:@"co"] isEqualToString:@"1"] && str.length==0){
                        [arrLableList addObject:[dict valueForKey:@"Lb"]];
                    }
                }
            }
        }
        
        if (arrLableList.count>0) {
            NSString *strLastLbl = @"";
            if (arrLableList.count>=2) {
                strLastLbl = [@" and "stringByAppendingString:[arrLableList lastObject]];
                [arrLableList removeLastObject];
            }
            
            
            //            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
            //                                                                                       message:[[[strMustValue stringByAppendingString:[arrLableList componentsJoinedByString:@","]] stringByAppendingString:strLastLbl] stringByAppendingString:@"."]
            //                                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:[[[[NSString stringWithFormat:@"%@ ",strMustValue] stringByAppendingString:[arrLableList componentsJoinedByString:@","]] stringByAppendingString:strLastLbl] stringByAppendingString:@"."]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            //** added Pigchamp logo on alert Bug-27920 by M.
            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
            UIView *controllerView = myAlertController.view;
            [controllerView addSubview:logoImageView];
            [controllerView bringSubviewToFront:logoImageView];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOk
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                [myAlertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
            
            return;
        }
        
        NSArray *arrKeys = [dictBarnData allKeys];
        for (int i=0;i<arrKeys.count;i++){
            {
                __block NSString *strKey,*strBarn,*strRoom,*strPen;
                
                //[dictForBarnRoomPen setValue:@"1" forKey:@"co"];
                [dictBarnData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key isEqualToString:@"br"]){
                        strBarn = obj?obj:@"";
                        strKey =@"barn";
                    }
                    else if ([key isEqualToString:@"rm"]) {
                        strRoom = obj?obj:@"";
                        strKey =@"room";
                    }
                    else if ([key isEqualToString:@"pn"]) {
                        strKey =@"pen";
                        strPen = obj?obj:@"";
                    }
                }];
                
                NSString *barn,*room,*pen;
                barn = @"Barn";
                room = @"Room";
                pen = @"Pen";
                
                NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Barn",@"Room",@"Pen",nil]];
                NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
                
                if (resultArray1.count!=0){
                    for (int i=0; i<resultArray1.count; i++){
                        [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
                    }
                    
                    for (int i=0; i<1; i++) {
                        if (i==0) {
                            if ([dictMenu objectForKey:[@"Barn" uppercaseString]] && ![[dictMenu objectForKey:[@"Barn" uppercaseString]] isKindOfClass:[NSNull class]]) {
                                if ([[dictMenu objectForKey:[@"Barn" uppercaseString]] length]>0) {
                                    barn = [dictMenu objectForKey:[@"Barn" uppercaseString]]?[dictMenu objectForKey:[@"Barn" uppercaseString]]:@"";
                                }
                            }else if ([dictMenu objectForKey:[@"Room" uppercaseString]] && ![[dictMenu objectForKey:[@"Room" uppercaseString]] isKindOfClass:[NSNull class]]){
                                if ([[dictMenu objectForKey:[@"Room" uppercaseString]] length]>0) {
                                    room = [dictMenu objectForKey:[@"Room" uppercaseString]]?[dictMenu objectForKey:[@"Room" uppercaseString]]:@"";
                                }
                            }else if ([dictMenu objectForKey:[@"Pen" uppercaseString]] && ![[dictMenu objectForKey:[@"Pen" uppercaseString]] isKindOfClass:[NSNull class]]){
                                if ([[dictMenu objectForKey:[@"Pen" uppercaseString]] length]>0) {
                                    pen = [dictMenu objectForKey:[@"Pen" uppercaseString]]?[dictMenu objectForKey:[@"Pen" uppercaseString]]:@"";
                                }
                            }
                        }
                    }
                }
                
                //
                if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strBarn.length==0 && strBarn!=nil){
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[[strMustValue stringByAppendingString:barn] stringByAppendingString:@"."]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    
                    return;
                }else  if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strRoom.length==0 && strRoom!=nil){
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[[strMustValue stringByAppendingString:room] stringByAppendingString:@"."]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    [myAlertController addAction:ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    
                    return;
                }
                else  if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strPen.length==0 && strPen!=nil){
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[[strMustValue stringByAppendingString:pen] stringByAppendingString:@"."]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
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
            }
        }
        
        NSArray *arrTextKeys = [dictTextFieldData allKeys];
        __block NSString *strSecond,*strThird;
        
        for (int i=0;i<arrTextKeys.count;i++){
            NSString *strFrom,*strTo;
            strFrom = @"From";
            strTo = @"To";
            
            NSString *strGiltMSg = @"Need to define range of numbers for the gilts that arrived.";
            
            NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"From",@"To",@"Need to define range of numbers for the gilts that arrived.",nil]];
            NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
            
            if (resultArray1.count!=0){
                for (int i=0; i<resultArray1.count; i++){
                    [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
                }
                
                for (int i=0; i<1; i++) {
                    if (i==0) {
                        if ([dictMenu objectForKey:[@"Need to define range of numbers for the gilts that arrived." uppercaseString]] && ![[dictMenu objectForKey:[@"Need to define range of numbers for the gilts that arrived." uppercaseString]] isKindOfClass:[NSNull class]]) {
                            if ([[dictMenu objectForKey:[@"Need to define range of numbers for the gilts that arrived." uppercaseString]] length]>0) {
                                strGiltMSg = [dictMenu objectForKey:[@"Need to define range of numbers for the gilts that arrived." uppercaseString]]?[dictMenu objectForKey:[@"Need to define range of numbers for the gilts that arrived." uppercaseString]]:@"";
                            }
                        }
                    }
                }
            }
            
            [dictTextFieldData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if ([key isEqualToString:@"second"]) {
                    strSecond = obj?obj:@"";
                    
                }
                else if ([key isEqualToString:@"third"]) {
                    strThird = obj?obj:@"";
                }
            }];
            
            if ([[dictForGuilt valueForKey:@"co"] isEqualToString:@"1"] && strSecond.length==0 && strSecond!=nil){
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strGiltMSg
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
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
            else  if ([[dictForGuilt valueForKey:@"co"] isEqualToString:@"1"] && strThird.length==0 && strThird!=nil){
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strGiltMSg
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
                
                return;
            }
        }
        
        //        //*******************Code change by priyanka***************//
        //
        //        NSString * strPigletValue = [dictJson valueForKey:@"3"];
        //        NSString *theCharacter = [NSString stringWithFormat:@"%c", [strPigletValue characterAtIndex:1]];
        //        NSString *theCharacter1 = [NSString stringWithFormat:@"%c", [strPigletValue characterAtIndex:2]];
        //
        //        if ([theCharacter isEqualToString:@"-"] || [theCharacter1 isEqualToString:@"-"])
        //        {
        //            NSLog(@"Not in format");
        //            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                       message:@"You must enter value for Number of Piglets."
        //                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //            UIAlertAction* ok = [UIAlertAction
        //                                 actionWithTitle:strOk
        //                                 style:UIAlertActionStyleDefault
        //                                 handler:^(UIAlertAction * action)
        //                                 {
        //                                     [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                 }];
        //            [myAlertController addAction:ok];
        //            [self presentViewController:myAlertController animated:YES completion:nil];
        //        }
        //        else
        //        {
        //            NSLog(@"in format");
        //        }
        //        //*******************Code change by priyanka***************//
        
        
        
        if ([[dictJson allKeys]containsObject:@"32"] && strEventCode.integerValue == 52) {
            if ([[dictJson valueForKey:@"32"] length]==0) {
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strMsgTranspoder
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
                UIAlertAction* yes = [UIAlertAction
                                      actionWithTitle:strYes
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action){
                    [self callEventSaveService];
                }];
                
                UIAlertAction* no = [UIAlertAction
                                     actionWithTitle:strNo
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action){
                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [myAlertController addAction: yes];
                [myAlertController addAction: no];
                
                [self presentViewController:myAlertController animated:YES completion:nil];
            }else{
                [self callEventSaveService];
            }
        }else {
            [self callEventSaveService];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in btnSave_tapped=%@",exception.description);
    }
}

-(void)callEventSaveService {
    //    NSString *strSaved = @"Saved successfully";
    //    NSString *strSavedLitterNote = @"Litter Note Event added successfully";//Need to code yog
    //
    //    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Saved successfully",@"Litter Note Event added successfully", nil]];
    //    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    //
    //    for (int i=0; i<resultArray1.count; i++){
    //        [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
    //    }
    //
    //    for (int i=0; i<2; i++) {
    //        if (i==0) {
    //            if ([dictMenu objectForKey:[@"Saved successfully" uppercaseString]] && ![[dictMenu objectForKey:[@"Saved successfully" uppercaseString]] isKindOfClass:[NSNull class]]) {
    //                if ([[dictMenu objectForKey:[@"Saved successfully" uppercaseString]] length]>0) {
    //                    strSaved = [dictMenu objectForKey:[@"Saved successfully" uppercaseString]]?[dictMenu objectForKey:[@"Saved successfully" uppercaseString]]:@"";
    //                }
    //            }else if (i==1){
    //                if ([dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] && ![[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] isKindOfClass:[NSNull class]]) {
    //                    if ([[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] length]>0) {
    //                        strSavedLitterNote = [dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]]?[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]]:@"";
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    @try {
        [self.activeTextField resignFirstResponder];
        
        NSString *strServiceName= @"";
        switch ([strEventCode integerValue]) {
            case 1:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTSemenPurchase?";
                break;
            case 2:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTBoar?";
                break;
            case 4:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTGilt?";
                break;
            case 5:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTGiltRetained?";
                break;
            case 6:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTSowArrival?";
                break;
            case 8:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTBatchGiltArrival?";
                break;
            case 11:
                strServiceName = @"/SrvEVTDepartures.svc/SaveEVTSowDeath?";
                break;
            case 10:
                strServiceName = @"/SrvEVTDepartures.svc/SaveEVTBoarDeath?";
                break;
            case 13:
                strServiceName = @"/SrvEVTDepartures.svc/SaveEVTSowSale?";
                break;
            case 12:
                strServiceName = @"/SrvEVTDepartures.svc/SaveEVTBoarSale?";
                break;
            case 44:
                strServiceName = @"/SrvEVTDepartures.svc/SaveEVTFemaleTransfer?";
                break;
            case 21:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTAbortion?";
                break;
            case 22:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTBoarGrCreation?";
                break;
            case 23:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTBoarGrJoin?";
                break;
            case 24:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTBoarGrLeave?";
                break;
            case 17:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTGiltAvailable?";
                break;
            case 19:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTMating?";
                break;
            case 18:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTHeatCheck?";
                break;
            case 20:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTPregnancyCheck?";
                break;
            case 25:
                strServiceName = @"/SrvEVTMatings.svc/SaveEVTSemenCollection?";
                break;
            case 26:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTFarrowing?";
                break;
            case 27:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTFostering?";
                break;
            case 93:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTFostering?";      //Code Change by Priyanka on 11th May 18//
                break;
            case 28:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTPartWeaning?";
                break;
            case 30:
                //strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTBatchWeaning?";
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTCompleteWeaning?";
                break;
            case 31:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTNurseSow?";
                break;
            case 32:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTPigletLoss?";
                break;
            case 33:
                strServiceName = @"/SrvEVTHealth.svc/SaveEVTBoarTreatment?";
                break;
            case 34:
                strServiceName = @"/SrvEVTHealth.svc/SaveEVTSowTreatment?";
                break;
            case 35:
                strServiceName = @"/SrvEVTHealth.svc/SaveEVTPigletTreatment?";
                break;
            case 48:
                strServiceName = @"/SrvEVTHealth.svc/SaveEVTBoarBatchTreatment?";
                break;
            case 49:
                strServiceName = @"/SrvEVTHealth.svc/SaveEVTSowBatchTreatment?";
                break;
            case 36:
                strServiceName = @"/SrvEVTMiscellaneous.svc/SaveEVTBoarRetag?";
                break;
            case 37:
                strServiceName = @"/SrvEVTMiscellaneous.svc/SaveEVTFemaleRetag?";
                break;
            case 38:
                strServiceName = @"/SrvEVTMiscellaneous.svc/SaveEVTBoarMovement?";
                break;
            case 39:
                strServiceName = @"/SrvEVTMiscellaneous.svc/SaveEVTFemaleMovement?";
                break;
            case 52:
                strServiceName = @"/SrvEVTMiscellaneous.svc/SaveEVTTransponder?";
                break;
            case 40:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTBoarNote?";
                break;
            case 41:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTFemaleNote?";
                break;
            case 43:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTLitterNote?";
                break;
            case 45:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTBoarFlag?";
                break;
            case 46:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTFemaleFlag?";
                break;
            case 50:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTBoarBodyCondition?";
                break;
            case 51:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTFemaleBodyCondition?";
                break;
            case 15:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTBoarMarkForCull?";
                break;
            case 16:
                strServiceName = @"/SrvEVTNotesFlags.svc/SaveEVTFemaleMarkForCull?";
                break;
            case 29:
                strServiceName = @"/SrvEVTFarrowing.svc/SaveEVTCompleteWeaning?";
                break;
                //***code added for Bug-28548 By M.
            case 47:
                strServiceName = @"/SrvEVTCommon.svc/SaveEventJson?";
                break;
                //***added code for Piglet Identification Bug-28549 By M.
            case 112:
                strServiceName = @"/SrvEVTCommon.svc/SaveEventJson?";
                break;
                //"/SrvEVTCommon.svc/SaveEventJson/";
                //ttBoar
            case 113:
                strServiceName = @"/SrvEVTArival.svc/SaveEVTBoarRetained?";
                break;
            case 114:
                strServiceName = @"SrvEVTMatings.svc/SaveEVTBoarAvailable?";
                break;
            case 116:
                strServiceName = @"SrvEVTDepartures.svc/SaveEVTBoarTransfer";
                break;
          
            default:
                break;
        }
        NSString *reqStringFUll=@"{";
        NSInteger x = 0;
        
       
        for (NSDictionary *dict in _arrDynamic) {
            //***added code below for bug-28565 By M.
            if(![_strFromEditPage isEqualToString:@"FromEdit"]){
                if ([[dict valueForKey:@"dk"] integerValue] == 2){
                    if (strSelectedDateMMM == nil){
                        NSDateFormatter* dateFormatterNew = [[NSDateFormatter alloc] init];
                      //  [dateFormatterNew setDateFormat:@"YYYY-MM-dd"];//,MMMM dd
                        [dateFormatterNew setDateFormat:@"dd/MM/yyyy"];
                      //  strSelectedDatee = [dateFormatterr stringFromDate:[NSDate date]];
                        strSelectedDateMMM = convertDateFormat([dateFormatterNew stringFromDate:[NSDate date]]); // c
                     //   strSelectedDateMMM = [dateFormatterNew stringFromDate:[NSDate date]];
                        strSelectedDateMMM = [strSelectedDateMMM stringByReplacingOccurrencesOfString:@"-"
                                                                                           withString:@""];
                        [dictJson setValue:strSelectedDateMMM forKey:[dict valueForKey:@"dk"]];
                    }else {//added below changes for Bug-29712 By M.
                        if (strSelectedDateMMM != nil){
                          
                            [dictJson setValue:strSelectedDateMMM forKey:[dict valueForKey:@"dk"]];
                        }else{
                            NSString *currentValue = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                            
                            if ([currentValue rangeOfString:@"-"].location != NSNotFound) {
                                currentValue = [currentValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
                                [dictJson setValue:currentValue forKey:[dict valueForKey:@"dk"]];
                            } else {
                                [dictJson setValue:currentValue forKey:[dict valueForKey:@"dk"]];
                            }
                        }
                    }
                       
                    
                }
            }//added below code for Bug-29662
            
            //+++++ changed code below for Bug-29790 and 29788 By M.
            if([_strFromEditPage isEqualToString:@"FromEdit"]){
                NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]];
                
                if ([strDataType isEqualToString:@"Date"]){
                    
                    NSString *dateString = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                    if(![dateString isEqualToString:@""]){
                        NSString *strtmpDate1 =[dictJson valueForKey:[dict valueForKey:@"dk"]];
                        NSString *strtmpDate;
                        NSString *strOutputDateFormattmp;
                        BOOL isValidFormat = [self isStringInYYYYMMDDFormat:dateString];
                        if(!isValidFormat){
                        if ([_strDateFormat isEqualToString:@"1"]){
                            
                            NSArray *components = [strtmpDate1 componentsSeparatedByString:@"\n"];
                            
                            // Extract the individual parts
                            NSString *firstPart = components[0];
                            NSString *datePart = components[1];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                            NSDate *date = [dateFormatter dateFromString:datePart];
                            // Date formatter to convert date to the desired format
                            NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                            [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                            strtmpDate = [desiredDateFormatter stringFromDate:date];
                            [dictJson setValue:strtmpDate forKey:[dict valueForKey:@"dk"]];
                            
                        }
                        else if([_strDateFormat isEqualToString:@"6"]){
                            NSArray *components = [strtmpDate1 componentsSeparatedByString:@"\n"];
                            // Extract the individual parts
                            NSString *firstPart = components[0];
                            NSString *datePart = components[1];
                            
                            // Log the separated parts (Optional, for verification)
                            NSLog(@"First Part: %@", firstPart);
                            NSLog(@"Date Part: %@", datePart);
                            
                            // Date formatter to parse the original date string
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                            NSDate *date = [dateFormatter dateFromString:datePart];
                            
                            // Date formatter to convert date to the desired format
                            NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                            [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                            NSString *desiredDateString = [desiredDateFormatter stringFromDate:date];
                            [dictJson setValue:desiredDateString forKey:[dict valueForKey:@"dk"]];
                            
                        } else if([_strDateFormat isEqualToString:@"3"] || [_strDateFormat isEqualToString:@"2"]){
                            
                            NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                            [inputdateFormatter setDateFormat:@"dd-MMM-yy"];
                            NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate1];
                            
                            NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                            [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                            NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                            [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                        } else if([_strDateFormat isEqualToString:@"4"]){
                            
                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                            [inputDateFormatter setDateFormat:@"MM/dd/yy"];
                            NSDate *inputDate = [inputDateFormatter dateFromString:strtmpDate1];
                            
                            // Create a date formatter for the desired output format
                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                            [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                            
                            // Format the date to the desired output format
                            NSString *outputDateString  = [outputDateFormatter stringFromDate:inputDate];
                            [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                        }
                        else if([_strDateFormat isEqualToString:@"5"]){
                            
                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                            [inputDateFormatter setDateFormat:@"dd/MM/yy"];
                            NSDate *inputDate = [inputDateFormatter dateFromString:strtmpDate1];
                            
                            // Create a date formatter for the desired output format
                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                            [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                            
                            // Format the date to the desired output format
                            NSString *outputDateString  = [outputDateFormatter stringFromDate:inputDate];
                            [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                        }
                        else if([_strDateFormat isEqualToString:@"8"]){
                            
                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                            [inputDateFormatter setDateFormat:@"dd/MM/yyyy"];
                            NSDate *inputDate = [inputDateFormatter dateFromString:strtmpDate1];
                            
                            // Create a date formatter for the desired output format
                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                            [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                            
                            // Format the date to the desired output format
                            NSString *outputDateString  = [outputDateFormatter stringFromDate:inputDate];
                            [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                        }
                        else if([_strDateFormat isEqualToString:@"7"]){
                            
                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                            [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                            NSDate *inputDate = [inputDateFormatter dateFromString:strtmpDate1];
                            
                            // Create a date formatter for the desired output format
                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                            [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                            
                            // Format the date to the desired output format
                            NSString *outputDateString  = [outputDateFormatter stringFromDate:inputDate];
                            [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                        }
                            
                        }
                    }
                }
            } /*if([_strFromEditPage isEqualToString:@"FromEdit"]){
               NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]];
                 
                 if ([strDataType isEqualToString:@"Date"]){
                     NSString *dateString = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                     BOOL isValidFormat = [self isStringInYYYYMMDDFormat:dateString];
                     if(!isValidFormat){
                         if ([_strOutputDateFormat isEqualToString:@"dd-MMM-yy"]){
                             
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"MMM-dd-yy"]){
                             
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"M d yy"]){
                             _strOutputDateFormat = @"mm/dd/yy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"M d yyyy"]){
                             _strOutputDateFormat = @"mm/dd/yyyy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"MM dd yy"]){
                             _strOutputDateFormat = @"mm/dd/yy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"MM dd yyyy"]){
                             _strOutputDateFormat = @"mm/dd/yyyy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"D m yy"]){
                             _strOutputDateFormat = @"dd/mm/yy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"D m yyyy"]){
                             _strOutputDateFormat = @"dd/mm/yyyy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"DD mm yy"]){
                             _strOutputDateFormat = @"dd/mm/yy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"DD mm yyyy"]){
                             _strOutputDateFormat = @"dd/mm/yyyy";
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                             
                             [inputdateFormatter setDateFormat:_strOutputDateFormat];
                             NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                             
                             NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                             [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                             NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                             [dictJson setValue:outputDateString forKey:[dict valueForKey:@"dk"]];
                             
                         }else if ([_strOutputDateFormat isEqualToString:@"Day of Year Format"]){
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             if (![strtmpDate isEqualToString: @""]){
                                 NSArray *components = [strtmpDate componentsSeparatedByString:@"\n"];
                                 
                                 // Extract the individual parts
                                 NSString *firstPart = components[0];
                                 NSString *datePart = components[1];
                                 
                                 // Log the separated parts (Optional, for verification)
                                 //NSLog(@"First Part: %@", firstPart);
                                 //NSLog(@"Date Part: %@", datePart);
                                 
                                 // Date formatter to parse the original date string
                                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                 [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                                 NSDate *date = [dateFormatter dateFromString:datePart];
                                 
                                 // Date formatter to convert date to the desired format
                                 NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                                 [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                                 NSString *desiredDateString = [desiredDateFormatter stringFromDate:date];
                                 [dictJson setValue:desiredDateString forKey:[dict valueForKey:@"dk"]];
                             }
                             
                         }       else if ([_strOutputDateFormat isEqualToString:@"DAYNUMBER"]){
                             NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                             
                             if (![strtmpDate isEqualToString: @""]){
                                 NSArray *components = [strtmpDate componentsSeparatedByString:@"\n"];
                                 
                                 // Extract the individual parts
                                 NSString *firstPart = components[0];
                                 NSString *datePart = components[1];
                                 
                                 // Log the separated parts (Optional, for verification)
                                 NSLog(@"First Part: %@", firstPart);
                                 NSLog(@"Date Part: %@", datePart);
                                 
                                 // Date formatter to parse the original date string
                                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                 [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                                 NSDate *date = [dateFormatter dateFromString:datePart];
                                 
                                 // Date formatter to convert date to the desired format
                                 NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                                 [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                                 NSString *desiredDateString = [desiredDateFormatter stringFromDate:date];
                                 [dictJson setValue:desiredDateString forKey:[dict valueForKey:@"dk"]];
                             }
                         }
                     }
               }
           }*/
            
            x++;
            NSString *strKey = [dict valueForKey:@"dk"]?[dict valueForKey:@"dk"]:@"";
            NSMutableString *strValue = [dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@"";
            
            if ([strValue isKindOfClass:[NSString class]]) {
                if ([strValue rangeOfString:@"\""].location != NSNotFound) {
                    strValue = (NSMutableString*)[strValue stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                }
            }
            //~~~~~~~~~added for piglet identities by M.
            if ([[dict valueForKey:@"dk"] integerValue] == 169){
              
                __block NSDictionary *dictTextFieldData;
                
               
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key integerValue]==169){
                        dictTextFieldData = obj;
                        
                    }
                }];
                 
                       // NSMutableArray *dataArray = [NSMutableArray array];
                //added @@@@@ condition if added for Piglet Identities Edit issue
                NSMutableArray *dataArray = [NSMutableArray array];
                if ([dictTextFieldData count] > 0) {
                    
                    NSString *tmpSex,*tmpColor,*tmpDesig;
                    for (NSDictionary *textFieldDict  in dictTextFieldData) {
                        if ([textFieldDict[@"37"] isEqualToString:@""])
                        {
                            NSLog(@"No data found");
                        }else{
                            tmpSex = [self getPigletIDS:textFieldDict[@"37"] optVal:1];
                        }
                        if ([textFieldDict[@"43"] isEqualToString:@""]){
                            NSLog(@"No data found");
                        }else{
                            tmpColor = [self getPigletIDS:textFieldDict[@"43"] optVal:2];
                        }
                        if ([textFieldDict[@"44"] isEqualToString:@""]){
                            NSLog(@"No data found");
                        }else{
                            tmpDesig = [self getPigletIDS:textFieldDict[@"44"] optVal:3];
                        }
                        //*** code below changed for Bug-29816 By M.
                        NSDictionary *individualDict;
                        if (textFieldDict[@"UniqueKey"] == nil || textFieldDict[@"IdentityDBKey"] == nil){
                            individualDict = @{
                                
                                @"Identity": textFieldDict[@"34"],
                                @"Tattoo": textFieldDict[@"35"],
                                @"Transponder": textFieldDict[@"36"],
                                @"Sex": tmpSex,
                                @"Weight": textFieldDict[@"38"],
                                @"Teats": textFieldDict[@"39"],
                                @"TeatsLeft":textFieldDict[@"40"],
                                @"TeatsBBLeft":textFieldDict[@"41"],
                                @"TeatsBBRight":textFieldDict[@"42"],
                                @"Color": tmpColor,
                                @"Designation": tmpDesig
                            };
                            
                        }else{
                            individualDict = @{
                                
                                @"Identity": textFieldDict[@"34"],
                                @"Tattoo": textFieldDict[@"35"],
                                @"Transponder": textFieldDict[@"36"],
                                @"Sex": tmpSex,
                                @"Weight": textFieldDict[@"38"],
                                @"Teats": textFieldDict[@"39"],
                                @"TeatsLeft":textFieldDict[@"40"],
                                @"TeatsBBLeft":textFieldDict[@"41"],
                                @"TeatsBBRight":textFieldDict[@"42"],
                                @"Color": tmpColor,
                                @"Designation": tmpDesig,
                                //+++++ added for Transponder issue on edit of piglet
                                @"UniqueKey": textFieldDict[@"UniqueKey"],
                                @"IdentityDBKey": textFieldDict[@"IdentityDBKey"]
                            };
                        }// Add the individual dictionary to the array
                        [dataArray addObject:individualDict];
                    }
                }
                        // Convert the array to JSON
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataArray options:NSJSONWritingPrettyPrinted error:nil];
                //***condition below added for bug-29711 and 29652 By M.
                        if ([dataArray count] == 0){
                            NSString *jsonString =@"[]";
                            reqStringFUll=(NSMutableString*)[reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@",strKey,jsonString]];
                        }else{
                            // Convert JSON data to a string
                            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            
                            reqStringFUll=(NSMutableString*)[reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":%@",strKey,jsonString]];
                            NSLog(@"%@", reqStringFUll); // Print or use reqStringFUll as needed
                        }
                   
            }
            else if ([[dict valueForKey:@"dk"] integerValue] == 48){
                NSArray *arr = [strValue componentsSeparatedByString:@"\n"];
                strValue = (NSMutableString*)@"\\\"";
                strValue = (NSMutableString*)[strValue stringByAppendingString:[arr componentsJoinedByString:@"\\\"\\n\\\""]];//[arr componentsJoinedByString:@"\"\""];
                strValue = (NSMutableString*)[strValue stringByAppendingString:@"\\\""];
                reqStringFUll = (NSMutableString*)[reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
                
            }else if ([[dict valueForKey:@"dk"] integerValue] == 92){
                __block NSDictionary *dictTextFieldData,*dictForGuilt;
                
                dictForGuilt = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key integerValue]==92){
                        dictTextFieldData = obj;
                    }
                }];
                
                strValue = [dictTextFieldData valueForKey:@"first"];
                
                for (int i = (int)strValue.length; i<6; i++) {
                    strValue = (NSMutableString*)[strValue stringByAppendingString:@" "];
                }
                
                strValue = (NSMutableString*)[[[[strValue stringByAppendingString:@" "] stringByAppendingString:[dictTextFieldData valueForKey:@"second"]] stringByAppendingString:@"^"] stringByAppendingString:[dictTextFieldData valueForKey:@"third"]];
                
                reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
                
            }//condition removed for Bug-27735 By m
            //***uncommented below condition for Bug-27775 By M @@@@@
            else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])) {
            //else if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText])) {
                __block NSDictionary *dictTextFieldData,*dictForGuilt;
                strValue=(NSMutableString*)@"";
                dictForGuilt = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    //condition removed for Bug-27735 By M.
                    //***uncommented below condition for Bug-27775 By M @@@@@
                    if ([key integerValue]==51 || [key integerValue]==15 || [key integerValue]==3) {
                    //if ([key integerValue]==51 || [key integerValue]==3) {
                        dictTextFieldData = obj;
                    }
                }];
                
                strValue = (NSMutableString*)[[[strValue stringByAppendingString:[dictTextFieldData valueForKey:@"Male"]] stringByAppendingString:@"|"] stringByAppendingString:[dictTextFieldData valueForKey:@"Female"]];
                
                reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
            }// |||| added for fostered 57 for Bug-29732 By M.
            else if (([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])) {
                
                __block NSDictionary *dictTextFieldData,*dictForGuilt;
                strValue=(NSMutableString*)@"";
                dictForGuilt = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    
                    if ([key integerValue]==57) {
                  
                        dictTextFieldData = obj;
                    }
                }];
                
                strValue = (NSMutableString*)[[[strValue stringByAppendingString:[dictTextFieldData valueForKey:@"Male"]] stringByAppendingString:@"|"] stringByAppendingString:[dictTextFieldData valueForKey:@"Female"]];
                
                reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
            }else if([[dict valueForKey:@"dk"] integerValue] == 6) {
                __block NSMutableDictionary *dictBarn;
                
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key isEqualToString:@"6"]) {
                        dictBarn = obj;
                    }
                }];
                
                __block NSString *strBarn,*strRoom,*strPen;
                
                [dictBarn enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key isEqualToString:@"br"]){
                        strBarn = obj;
                    }
                    else if ([key isEqualToString:@"rm"]) {
                        strRoom = obj;
                    }
                    else if ([key isEqualToString:@"pn"]) {
                        strPen = obj;
                    }
                }];
                
                NSPredicate  *predicate;
                NSArray *resultArray;
                NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
                if (strBarn.length>0 && strRoom.length>0 && strPen.length>0) {
                   // predicate= [NSPredicate predicateWithFormat:@"br = %@ AND rm = %@ AND pn=%@",strBarn?strBarn:@"", strRoom?strRoom:@"",strPen?strPen:@""];
                    //***commented above condition for Bug-27877 By M.
                    resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"id" andPredicate:[NSPredicate predicateWithFormat:@"br = %@ AND rm = %@ AND pn=%@",strBarn,strRoom,strPen] andSortDescriptors:@[sortBy]];
                }else if (strRoom.length>0 && strBarn.length>0){
                    //predicate= [NSPredicate predicateWithFormat:@"br = %@ AND rm = %@ AND pn=nil",strBarn?strBarn:@"", strRoom?strRoom:@""];
                    //***commented above condition for Bug-27877 By M.
                    resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"id" andPredicate:[NSPredicate predicateWithFormat:@"br = %@ AND rm = %@ AND (pn = nil OR pn = '')", strBarn, strRoom] andSortDescriptors:@[sortBy]];

                }else {
                    //predicate= [NSPredicate predicateWithFormat:@"br = %@ AND rm = nil AND pn=nil",strBarn];//,strBarn?strBarn:@""];
                    //***commented above condition for Bug-27877 By M.
                    resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"id" andPredicate:[NSPredicate predicateWithFormat:@"br = %@ AND (rm == nil OR rm == '' OR rm = NULL) AND (pn == nil OR pn == '' OR pn = NULL)", strBarn]
                                                                     andSortDescriptors:@[sortBy]];
                }
                
                NSLog(@"strRoom=%@",strPen);
                NSLog(@"strRoom=%@",strRoom);
                NSLog(@"Predicate: %@", predicate);
              /*  NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
                NSArray *resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"id" andPredicate:predicate andSortDescriptors:[[NSArray alloc] initWithObjects:sortBy, nil]]; */
               //***predicate is changed as the resultArray should get some value for bug-27877 By M.
                //NSSortDescriptor *sortBy = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];

               // NSArray *resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"id" andPredicate:[NSPredicate predicateWithFormat:@"br = %@", strBarn] andSortDescriptors:@[sortBy]];
                

                NSLog(@"All records for br %@: %@", strBarn, resultArray);

                NSLog(@"Result Array: %@", resultArray);
                for (int count=0; count<resultArray.count; count++) {
                    strValue = [[resultArray objectAtIndex:count] valueForKey:@"id"];
                }
                
                if (resultArray.count==0) {
                    strValue=(NSMutableString*) @"";
                }
                
                reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
            }   //----------Code changes for Batch Weaning
            else if(strEventCode.integerValue == 30){
                if ([[dict valueForKey:@"dk"] integerValue]==7){
                    
                    id value = [dictJson objectForKey:[dict valueForKey:@"dk"]];
                    if (value != nil) {
                        id value = [dictJson objectForKey:[dict valueForKey:@"dk"]];
                        [dictJson setObject:value forKey:@"1"];
                        [dictJson removeObjectForKey:[dict valueForKey:@"dk"]];
                        
                        strKey = @"1";
                        strValue = [dictJson valueForKey:@"1"]?[dictJson valueForKey:@"1"]:@"";
                    }else{
                        strKey = @"1";
                        strValue = [dictJson valueForKey:@"1"]?[dictJson valueForKey:@"1"]:@"";
                    }
                }
                else
                {
                    strKey = [dict valueForKey:@"dk"]?[dict valueForKey:@"dk"]:@"";
                    strValue = [dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@"";
                }
                
                reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
            }
            //----------Code changes for Batch Weaning
            else if([[dict valueForKey:@"dk"] integerValue] != 6){
                reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
            }
            
            //            if (strEventCode.integerValue == 30) {
            //                if ([[dict valueForKey:@"dk"] integerValue]==7){
            //                    NSString * value = [dictJson objectForKey:@"1"];
            //                    NSArray *reqStringArray = [value componentsSeparatedByString:@","];
            //
            //                   for (NSString* item in reqStringArray) {
            //                       [dictJson removeObjectForKey:@"1"];
            //                       [dictJson setObject:item forKey:@"1"];
            //                       strKey = @"1";
            //                       strValue = item;
            //                       reqStringFUll = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"%@\":\"%@\"",strKey,strValue]];
            //                       [arrMultipleSowIdentities addObject:reqStringFUll];
            //                   }
            if (x!=_arrDynamic.count) {
                reqStringFUll  = [reqStringFUll stringByAppendingString:@","];
                
            }else {
                NSString *strFromDataEntry = [[NSUserDefaults standardUserDefaults] valueForKey:@"FromDataEntry"];
                //*** code added to check if on same event entry view if user try to create new data entry(issue raised by Martin Bug-28565 By M.
                // Extract the date string from the JSON
                    /*    NSRange dateRange = [reqStringFUll rangeOfString:@"\\\"2\\\":\\\"([^\\\"]+)\\\"" options:NSRegularExpressionSearch];
                        if (dateRange.location != NSNotFound) {
    
                            NSString *dateString = [reqStringFUll substringWithRange:NSMakeRange(dateRange.location + 6, dateRange.length - 9)];
                            // Check if the date string contains "-" or "/"
                            if ([dateString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-/"]].location != NSNotFound) {
                                // Try to parse the date with different formats
                                NSArray *dateFormats = @[@"dd-MMM-yyyy", @"yyyy-MM-dd", @"dd/MM/yyyy", @"dd-MM-yyyy", @"yy-DDD", @"yy-ddd"];

                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                
                                NSDate *date = nil;
                                for (NSString *format in dateFormats) {
                                   [dateFormatter setDateFormat:format];
                                   date = [dateFormatter dateFromString:dateString];
                                    if (date) {
                                        break;
                                    }
                            }
                                
                                if (date) {
                                    // Format the date as "yyyyMMdd"
                                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                                    NSString *convertedDateString = [dateFormatter stringFromDate:date];
                                    
                                    // Replace the original date string with the converted date string
                                    NSString *modifiedString = [reqStringFUll stringByReplacingCharactersInRange:dateRange withString:[NSString stringWithFormat:@"\\\"2\\\":\\\"%@\\\"", convertedDateString]];
                                    
                                    NSLog(@"Modified String: %@", modifiedString);
                                } else {
                                    NSLog(@"Failed to parse date.");
                                }
                            } else {
                                NSLog(@"Date string does not contain '-' or '/'. No conversion needed.");
                            }
                        } else {
                            NSLog(@"Date not found in the input string.");
                        }*/
                //*** end of code By M.
                if ([strFromDataEntry isEqualToString:@"1"]){
                    reqStringFUll  = [reqStringFUll stringByAppendingString:@","];
                    reqStringFUll  = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"eventid\":\"%@\"",[_dict valueForKey:@"EventKey"]]];
                }
                reqStringFUll  = [reqStringFUll stringByAppendingString:@","];
                //
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                //[dateformate setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
                [dateformate setDateFormat:@"yyyyMMdd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                //
                reqStringFUll  = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"SD\":\"%@\"",strDate]];
                //***code added below for Bug-28548 By M.
                if (strEventCode.integerValue == 47){
                    reqStringFUll  = [reqStringFUll stringByAppendingString:@","];
                    reqStringFUll  = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"EventCode\":\"47\""]];
                }//***code added for Bug-28549 By M.Piglet Identification
                else if (strEventCode.integerValue == 112){
                    reqStringFUll  = [reqStringFUll stringByAppendingString:@","];
                    reqStringFUll  = [reqStringFUll stringByAppendingString:[NSString stringWithFormat:@"\"EventCode\":\"112\""]];
                }
                reqStringFUll  = [reqStringFUll stringByAppendingString:@"}"];
            }
        }
        
        NSLog(@"dictJson=%@",dictJson);
        NSLog(@"_dictDynamic=%@",_dictDynamic);
        NSLog(@"reqStringFUll=%@",reqStringFUll);
        
        //reqStringFUll = [reqStringFUll stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        NSLog(@"reqStringFUll=%@",reqStringFUll);
        
        
        
        if (strEventCode.integerValue == 30) {
           //***added code below for Bug-29063 By M.
            self.currentIndex = 0;
           
            reqStringfulltmp = reqStringFUll;
            value = [dictJson objectForKey:@"1"];
            reqStringArray = [value componentsSeparatedByString:@","];
            strServiceName1 = strServiceName;
            [self makeAPICallsWithCallback:^{
                // This block will be executed after the completion of the API calls
                // Perform any additional actions or UI updates here
                NSLog(@"API calls completed!");
            }];
            //***end of 
            /*NSString * value = [dictJson objectForKey:@"1"];
            NSArray *reqStringArray = [value componentsSeparatedByString:@","];
            
            for (NSString* item in reqStringArray) {
                NSString * reqString = [[reqStringFUll stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"1\":\"%@\"", value] withString:[NSString stringWithFormat:@"\"1\":\"%@\"", item]] mutableCopy];
                
                NSError *error;
                NSMutableDictionary* jsonDict = [[NSMutableDictionary alloc]init];
                [jsonDict setObject:reqString forKey:@"arguments"];
                NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                                   options:kNilOptions error:nil];
                if(!jsonData && error) {
                    NSLog(@"Error creating JSON: %@", [error localizedDescription]);
                    return;
                }
                [self callSaveEvent:strServiceName :jsonData];
            } */
        }
          
            
        else{
            NSError *error;
            
            NSMutableDictionary* jsonDict = [[NSMutableDictionary alloc]init];
            [jsonDict setObject:reqStringFUll forKey:@"arguments"];
            
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                               options:kNilOptions error:nil];
            
            if(!jsonData && error) {
                NSLog(@"Error creating JSON: %@", [error localizedDescription]);
                return;
            }
            
            [self callSaveEvent:strServiceName :jsonData];
        }
        
        
        
        
        
        
        
        
        //        if ([[ControlSettings sharedSettings] isNetConnected ]){
        //            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        //            [_customIOS7AlertView showLoaderWithMessage:strWait];
        //
        //            [ServerManager sendRequestEvent:[strServiceName stringByAppendingString:[NSString stringWithFormat:@"token=%@&ignoreWarnings=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"0"]] idOfServiceUrl:jsonData methodType:@"POST" onSucess:^(NSString *responseData) {
        //                [_customIOS7AlertView close];
        //
        //                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //
        //                // [dict setValue:@"Not connected" forKey:@"ResultString"];
        //                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
        //                {
        //                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
        //                    {
        //                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                   message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
        //                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                        UIAlertAction* ok = [UIAlertAction
        //                                             actionWithTitle:strOk
        //                                             style:UIAlertActionStyleDefault
        //                                             handler:^(UIAlertAction * action) {
        //                            [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        //                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                        }];
        //
        //                        [myAlertController addAction: ok];
        //                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                    }
        //                    else if ([responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
        //                    {
        //                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                   message:[self getTranslatedTextForString:@"Token not found"]
        //                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                        UIAlertAction* ok = [UIAlertAction
        //                                             actionWithTitle:strOk
        //                                             style:UIAlertActionStyleDefault
        //                                             handler:^(UIAlertAction * action) {
        //                            [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        //                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                        }];
        //
        //                        [myAlertController addAction: ok];
        //                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                    }
        //                }else if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:@"Not connected"])
        //                { //to do too
        //                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                               message:NSLocalizedString(@"connection_lost", @"")
        //                                                                                        preferredStyle:UIAlertControllerStyleAlert];
        //                    UIAlertAction* ok = [UIAlertAction
        //                                         actionWithTitle:strOk
        //                                         style:UIAlertActionStyleDefault
        //                                         handler:^(UIAlertAction * action) {
        //                        if ([[ControlSettings sharedSettings] isNetConnected ]){
        //                            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        //                            [_customIOS7AlertView showLoaderWithMessage:strSignOff];
        //
        //                            [ServerManager sendRequestForLogout:^(NSString *responseData) {
        //                                NSLog(@"%@",responseData);
        //                                [_customIOS7AlertView close];
        //
        //                                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])  {
        //                                }else if ([responseData isEqualToString:@"\"Loged out\""] || [responseData isEqualToString:@""]){
        //                                    [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        //                                }
        //
        //                            } onFailure:^(NSString *responseData, NSError *error) {
        //                                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        //                                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        //                                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //                                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
        //
        //                                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,On log out=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate, self.title];
        //                                [tracker set:kGAIScreenName value:strErr];
        //                                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        //
        //                                [_customIOS7AlertView close];
        //                            }];
        //                        }
        //                        else {
        //                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                       message:strNoInternet
        //                                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //                            UIAlertAction* ok = [UIAlertAction
        //                                                 actionWithTitle:strOk
        //                                                 style:UIAlertActionStyleDefault
        //                                                 handler:^(UIAlertAction * action)
        //                                                 {
        //                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                            }];
        //
        //                            [myAlertController addAction: ok];
        //                            [self presentViewController:myAlertController animated:YES completion:nil];
        //                        }
        //
        //                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                    }];
        //
        //                    [myAlertController addAction: ok];
        //                    [self presentViewController:myAlertController animated:YES completion:nil];
        //                }
        //                else if (dict!=nil){
        //                    if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:[self getTranslatedTextForString:@"Are you sure?"]]){
        //                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                   message:[dict valueForKey:@"ResultString"]
        //                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                        UIAlertAction* yes = [UIAlertAction
        //                                              actionWithTitle:strYes
        //                                              style:UIAlertActionStyleDefault
        //                                              handler:^(UIAlertAction * action){
        //                            if ([[ControlSettings sharedSettings] isNetConnected ]){
        //                                _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        //                                [_customIOS7AlertView showLoaderWithMessage:strWait];
        //                                [ServerManager sendRequestEvent:[strServiceName stringByAppendingString:[NSString stringWithFormat:@"token=%@&ignoreWarnings=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"1"]] idOfServiceUrl:jsonData methodType:@"POST" onSucess:^(NSString *responseData) {
        //
        //                                    [_customIOS7AlertView close];
        //                                    id dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //
        //
        //                                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
        //                                    {
        //                                        if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
        //                                        {
        //                                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                                       message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
        //                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //                                            UIAlertAction* ok = [UIAlertAction
        //                                                                 actionWithTitle:strOk
        //                                                                 style:UIAlertActionStyleDefault
        //                                                                 handler:^(UIAlertAction * action) {
        //                                                [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        //                                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                            }];
        //
        //                                            [myAlertController addAction: ok];
        //                                            [self presentViewController:myAlertController animated:YES completion:nil];
        //                                        }
        //                                        else if ([responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
        //                                        {
        //                                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                                       message:[self getTranslatedTextForString:@"Token not found"]
        //                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //                                            UIAlertAction* ok = [UIAlertAction
        //                                                                 actionWithTitle:strOk
        //                                                                 style:UIAlertActionStyleDefault
        //                                                                 handler:^(UIAlertAction * action) {
        //                                                [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        //                                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                            }];
        //
        //                                            [myAlertController addAction: ok];
        //                                            [self presentViewController:myAlertController animated:YES completion:nil];
        //                                        }
        //                                    }else if ([dict isKindOfClass:[NSDictionary class]]) {
        //                                        if ([[dict valueForKey:@"ResultString"] isEqualToString:strSaved]) {
        //                                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                                       message:strSaved
        //                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //
        //                                            UIAlertAction* ok = [UIAlertAction
        //                                                                 actionWithTitle:strOk
        //                                                                 style:UIAlertActionStyleDefault
        //                                                                 handler:^(UIAlertAction * action)
        //                                                                 {
        //                                                //For maintaining last selected values
        //                                                [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
        //                                                [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
        //                                                [pref synchronize];
        //                                                flag = 1;
        //
        //
        //                                                NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        //                                                NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        //                                                if ([strFromDataEntry isEqualToString:@"1"]){
        //                                                    [self.navigationController popViewControllerAnimated:YES];
        //                                                }else{
        //
        //                                                    [self clearFileds];
        //                                                }
        //                                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                            }];
        //
        //                                            [myAlertController addAction:ok];
        //                                            [self presentViewController:myAlertController animated:YES completion:nil];
        //                                        }else{
        //                                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                                       message:[dict valueForKey:@"ResultString"]
        //                                                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //                                            UIAlertAction* ok = [UIAlertAction
        //                                                                 actionWithTitle:strOk
        //                                                                 style:UIAlertActionStyleDefault
        //                                                                 handler:^(UIAlertAction * action)
        //                                                                 {
        //                                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                            }];
        //
        //                                            [myAlertController addAction: ok];
        //                                            [self presentViewController:myAlertController animated:YES completion:nil];
        //                                        }
        //                                    }
        //
        //                                    NSLog(@"responseData=%@",responseData);
        //                                } onFailure:^(NSString *responseData, NSError *error) {
        //
        //                                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        //                                    //
        //                                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        //                                    [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //                                    NSString *strDate = [dateformate stringFromDate:[NSDate date]];
        //
        //                                    NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
        //                                    [tracker set:kGAIScreenName value:strErr];
        //                                    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        //
        //                                    [_customIOS7AlertView close];
        //
        //                                    if (responseData.integerValue ==401) {
        //
        //                                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                                   message:strUnauthorised
        //                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                                        UIAlertAction* ok = [UIAlertAction
        //                                                             actionWithTitle:strOk
        //                                                             style:UIAlertActionStyleDefault
        //                                                             handler:^(UIAlertAction * action) {
        //                                            [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                                                                       [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                        }];
        //
        //                                        [myAlertController addAction: ok];
        //                                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                                        //[self.navigationController popToRootViewControllerAnimated:YES];
        //                                    }else{
        //                                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                                   message:responseData
        //                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                                        UIAlertAction* ok = [UIAlertAction
        //                                                             actionWithTitle:strOk
        //                                                             style:UIAlertActionStyleDefault
        //                                                             handler:^(UIAlertAction * action) {
        //                                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                        }];
        //
        //                                        [myAlertController addAction: ok];
        //                                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                                    }
        //
        //                                }];
        //
        //                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //
        //                            }else{
        //                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                           message:strNoInternet
        //                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
        //                                UIAlertAction* ok = [UIAlertAction
        //                                                     actionWithTitle:strOk
        //                                                     style:UIAlertActionStyleDefault
        //                                                     handler:^(UIAlertAction * action)                                                                          {
        //                                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                }];
        //                                [myAlertController addAction: ok];
        //                                [self presentViewController:myAlertController animated:YES completion:nil];
        //                            }
        //                        }];
        //
        //                        UIAlertAction* no = [UIAlertAction
        //                                             actionWithTitle:strNo
        //                                             style:UIAlertActionStyleDefault
        //                                             handler:^(UIAlertAction * action){
        //                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                        }];
        //
        //                        [myAlertController addAction: yes];
        //                        [myAlertController addAction: no];
        //
        //                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                    }else if ([[dict valueForKey:@"ResultString"] isEqualToString:strSaved] || [[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:strSavedLitterNote]){
        //                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                   message:strSaved
        //                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //
        //                        UIAlertAction* ok = [UIAlertAction
        //                                             actionWithTitle:strOk
        //                                             style:UIAlertActionStyleDefault
        //                                             handler:^(UIAlertAction * action) {
        //                            NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        //                            NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        //
        //                            //For maintaining last selected values
        //                            [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
        //                            [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
        //                            [pref synchronize];
        //                            flag = 1;
        //
        //                            if ([strFromDataEntry isEqualToString:@"1"]) {
        //                                [self.navigationController popViewControllerAnimated:YES];
        //                            }else {
        //                                [self clearFileds];
        //                            }
        //
        //                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                        }];
        //
        //                        [myAlertController addAction: ok];
        //                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                    }else if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:@"Not connected"]) {//to do too
        //                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                   message:NSLocalizedString(@"connection_lost", @"")
        //                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                        UIAlertAction* ok = [UIAlertAction
        //                                             actionWithTitle:strOk
        //                                             style:UIAlertActionStyleDefault
        //                                             handler:^(UIAlertAction * action) {
        //                            if ([[ControlSettings sharedSettings] isNetConnected ]){
        //                                _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        //                                [_customIOS7AlertView showLoaderWithMessage:strSignOff];
        //
        //                                [ServerManager sendRequestForLogout:^(NSString *responseData) {
        //                                    NSLog(@"%@",responseData);
        //                                    [_customIOS7AlertView close];
        //
        //                                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])  {
        //                                    }else if ([responseData isEqualToString:@"\"Loged out\""] || [responseData isEqualToString:@""]){
        //                                        [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
        //                                    }
        //                                } onFailure:^(NSString *responseData, NSError *error) {
        //                                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        //                                    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        //                                    [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //                                    NSString *strDate = [dateformate stringFromDate:[NSDate date]];
        //
        //                                    NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,On log out=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate, self.title];
        //                                    [tracker set:kGAIScreenName value:strErr];
        //                                    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        //
        //                                    // [[NSNotificationCenter defaultCenter]postNotificationName:@"CloseAlert" object:responseData];
        //
        //                                    [_customIOS7AlertView close];
        //                                }];
        //                            }
        //                            else {
        //                                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                           message:strNoInternet
        //                                                                                                    preferredStyle:UIAlertControllerStyleAlert];
        //                                UIAlertAction* ok = [UIAlertAction
        //                                                     actionWithTitle:strOk
        //                                                     style:UIAlertActionStyleDefault
        //                                                     handler:^(UIAlertAction * action)
        //                                                     {
        //                                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                                }];
        //
        //                                [myAlertController addAction: ok];
        //                                [self presentViewController:myAlertController animated:YES completion:nil];
        //                            }
        //
        //                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                        }];
        //
        //                        [myAlertController addAction: ok];
        //                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                    }
        //                    else {
        //                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                                   message:[dict valueForKey:@"ResultString"]
        //                                                                                            preferredStyle:UIAlertControllerStyleAlert];
        //                        UIAlertAction* ok = [UIAlertAction
        //                                             actionWithTitle:strOk
        //                                             style:UIAlertActionStyleDefault
        //                                             handler:^(UIAlertAction * action) {
        //                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                        }];
        //
        //                        [myAlertController addAction: ok];
        //                        [self presentViewController:myAlertController animated:YES completion:nil];
        //                    }
        //                }
        //
        //                NSLog(@"responseData=%@",responseData);
        //            } onFailure:^(NSString *responseData, NSError *error) {
        //                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        //                //
        //                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        //                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
        //
        //                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
        //                [tracker set:kGAIScreenName value:strErr];
        //                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        //
        //                if (responseData.integerValue ==401) {
        //
        //                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                               message:strUnauthorised
        //                                                                                        preferredStyle:UIAlertControllerStyleAlert];
        //                    UIAlertAction* ok = [UIAlertAction
        //                                         actionWithTitle:strOk
        //                                         style:UIAlertActionStyleDefault
        //                                         handler:^(UIAlertAction * action) {
        //                        [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                    }];
        //
        //                    [myAlertController addAction: ok];
        //                    [self presentViewController:myAlertController animated:YES completion:nil];
        //                    //[self.navigationController popToRootViewControllerAnimated:YES];
        //                }else{
        //                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                               message:responseData
        //                                                                                        preferredStyle:UIAlertControllerStyleAlert];
        //                    UIAlertAction* ok = [UIAlertAction
        //                                         actionWithTitle:strOk
        //                                         style:UIAlertActionStyleDefault
        //                                         handler:^(UIAlertAction * action) {
        //                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //                    }];
        //
        //                    [myAlertController addAction: ok];
        //                    [self presentViewController:myAlertController animated:YES completion:nil];
        //                }
        //
        //                [_customIOS7AlertView close];
        //            }];
        //        }else{
        //            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                       message:strNoInternet
        //                                                                                preferredStyle:UIAlertControllerStyleAlert];
        //            UIAlertAction* ok = [UIAlertAction
        //                                 actionWithTitle:strOk
        //                                 style:UIAlertActionStyleDefault
        //                                 handler:^(UIAlertAction * action)
        //                                 {
        //                [myAlertController dismissViewControllerAnimated:YES completion:nil];
        //            }];
        //            [myAlertController addAction: ok];
        //            [self presentViewController:myAlertController animated:YES completion:nil];
        //        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in callEventSaveService=%@",exception.description);
    }
}

-(void)callSaveEvent:(NSString*)strService :(NSData*)reqJSONData {
    
    NSString *strSaved = @"Saved successfully";
    NSString *strSavedLitterNote = @"Litter Note Event added successfully";//Need to code yog
    
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Saved successfully",@"Litter Note Event added successfully", nil]];
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    
    for (int i=0; i<resultArray1.count; i++){
        [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
    }
    
    for (int i=0; i<2; i++) {
        if (i==0) {
            if ([dictMenu objectForKey:[@"Saved successfully" uppercaseString]] && ![[dictMenu objectForKey:[@"Saved successfully" uppercaseString]] isKindOfClass:[NSNull class]]) {
                if ([[dictMenu objectForKey:[@"Saved successfully" uppercaseString]] length]>0) {
                    strSaved = [dictMenu objectForKey:[@"Saved successfully" uppercaseString]]?[dictMenu objectForKey:[@"Saved successfully" uppercaseString]]:@"";
                }
            }else if (i==1){
                if ([dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] && ![[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] length]>0) {
                        strSavedLitterNote = [dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]]?[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]]:@"";
                    }
                }
            }
        }
    }
    
    
    if ([[ControlSettings sharedSettings] isNetConnected ]){
        _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        [_customIOS7AlertView showLoaderWithMessage:strWait];
        
        [ServerManager sendRequestEvent:[strService stringByAppendingString:[NSString stringWithFormat:@"token=%@&ignoreWarnings=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"0"]] idOfServiceUrl:reqJSONData methodType:@"POST" onSucess:^(NSString *responseData) {
            [_customIOS7AlertView close];
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            // [dict setValue:@"Not connected" forKey:@"ResultString"];
            if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
            {
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
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
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
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
            }else if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:@"Not connected"])
            { //to do too
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:NSLocalizedString(@"connection_lost", @"")
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
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
                            
                            [_customIOS7AlertView close];
                        }];
                    }
                    else {
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:strNoInternet
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
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
                    
                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }
            else if (dict!=nil){
                if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:[self getTranslatedTextForString:@"Are you sure?"]]){
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[dict valueForKey:@"ResultString"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* yes = [UIAlertAction
                                          actionWithTitle:strYes
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action){
                        if ([[ControlSettings sharedSettings] isNetConnected ]){
                            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                            [_customIOS7AlertView showLoaderWithMessage:strWait];
                            [ServerManager sendRequestEvent:[strService stringByAppendingString:[NSString stringWithFormat:@"token=%@&ignoreWarnings=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"1"]] idOfServiceUrl:reqJSONData methodType:@"POST" onSucess:^(NSString *responseData) {
                                
                                [_customIOS7AlertView close];
                                id dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                                
                                
                                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                                {
                                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                                    {
                                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                   message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                        //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIView *controllerView = myAlertController.view;
                                        [controllerView addSubview:logoImageView];
                                        [controllerView bringSubviewToFront:logoImageView];
                                        
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
                                        //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIView *controllerView = myAlertController.view;
                                        [controllerView addSubview:logoImageView];
                                        [controllerView bringSubviewToFront:logoImageView];
                                        
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
                                }else if ([dict isKindOfClass:[NSDictionary class]]) {
                                    if ([[dict valueForKey:@"ResultString"] isEqualToString:strSaved])
                                    {
                                        //                                              UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                        //                                                                                                                         message:strSaved
                                        //                                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                        //
                                        //                                              UIAlertAction* ok = [UIAlertAction
                                        //                                                                   actionWithTitle:strOk
                                        //                                                                   style:UIAlertActionStyleDefault
                                        //                                                                   handler:^(UIAlertAction * action)
                                        //                                                                   {
                                        //                                                  //For maintaining last selected values
                                        //                                                  [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                                        //                                                  [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                                        //                                                  [pref synchronize];
                                        //                                                  flag = 1;
                                        //
                                        //
                                        //                                                  NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                                        //                                                  NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                                        //                                                  if ([strFromDataEntry isEqualToString:@"1"]){
                                        //                                                      [self.navigationController popViewControllerAnimated:YES];
                                        //                                                  }else{
                                        //
                                        //                                                      [self clearFileds];
                                        //                                                  }
                                        //                                                  [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                        //                                              }];
                                        //
                                        //                                              [myAlertController addAction:ok];
                                        //                                              [self presentViewController:myAlertController animated:YES completion:nil];
                                        
                                        /*
                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                        hud.mode = MBProgressHUDModeText;
                                        hud.labelText = strSaved;
                                        hud.margin = 10.f;
                                        hud.yOffset = 150.f;
                                        hud.removeFromSuperViewOnHide = YES;*/
                                        //***code commented above for Bug-29140 By M.
                                        UIImage *logoImage = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
                                        logoImageView.frame = CGRectMake(0, 0, 30, 30);
                                        logoImageView.contentMode = UIViewContentModeScaleAspectFit;

                                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 160, 30)]; // Adjust the frame as needed
                                        label.text = strSaved;
                                        label.textColor = [UIColor whiteColor];
                                        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)]; // Adjust the frame as needed
                                        //customView.backgroundColor = [UIColor blackColor];
                                        [customView addSubview:logoImageView];
                                        [customView addSubview:label];

                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                        hud.mode = MBProgressHUDModeCustomView;
                                        hud.customView = customView;
                                        hud.margin = 10.f;
                                        hud.yOffset = 150.f;                                        // Set the correct size for the custom view
                                        hud.customView.bounds = CGRectMake(0, 0, 200, 30);
                                        hud.removeFromSuperViewOnHide = YES;
                                        
                                        
                                        //For maintaining last selected values
                                        [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                                        [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                                        [pref synchronize];
                                        flag = 1;
                                        
                                        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                                        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                                        if ([strFromDataEntry isEqualToString:@"1"]){
                                            [self.navigationController popViewControllerAnimated:YES];
                                        }else{
                                            [self clearFileds];
                                        }
                                        [hud hide:YES afterDelay:3];

                                        
                                    }else{
                                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                   message:[dict valueForKey:@"ResultString"]
                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                        //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIView *controllerView = myAlertController.view;
                                        [controllerView addSubview:logoImageView];
                                        [controllerView bringSubviewToFront:logoImageView];
                                        
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
                                
                                NSLog(@"responseData=%@",responseData);
                            } onFailure:^(NSString *responseData, NSError *error) {
                                
                                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                //
                                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                                
                                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
                                [tracker set:kGAIScreenName value:strErr];
                                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                                
                                [_customIOS7AlertView close];
                                
                                if (responseData.integerValue ==401) {
                                    
                                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                               message:strUnauthorised
                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                    //** added Pigchamp logo on alert Bug-27920 by M.
                                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                    UIView *controllerView = myAlertController.view;
                                    [controllerView addSubview:logoImageView];
                                    [controllerView bringSubviewToFront:logoImageView];
                                    
                                    UIAlertAction* ok = [UIAlertAction
                                                         actionWithTitle:strOk
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                        [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                                                                       [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                    }];
                                    
                                    [myAlertController addAction: ok];
                                    [self presentViewController:myAlertController animated:YES completion:nil];
                                    //[self.navigationController popToRootViewControllerAnimated:YES];
                                }else{
                                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                               message:responseData
                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                    //** added Pigchamp logo on alert Bug-27920 by M.
                                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                    UIView *controllerView = myAlertController.view;
                                    [controllerView addSubview:logoImageView];
                                    [controllerView bringSubviewToFront:logoImageView];
                                    
                                    UIAlertAction* ok = [UIAlertAction
                                                         actionWithTitle:strOk
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                    }];
                                    
                                    [myAlertController addAction: ok];
                                    [self presentViewController:myAlertController animated:YES completion:nil];
                                }
                                
                            }];
                            
                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
                            
                        }else{
                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                       message:strNoInternet
                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                            //** added Pigchamp logo on alert Bug-27920 by M.
                            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                            UIView *controllerView = myAlertController.view;
                            [controllerView addSubview:logoImageView];
                            [controllerView bringSubviewToFront:logoImageView];
                            
                            UIAlertAction* ok = [UIAlertAction
                                                 actionWithTitle:strOk
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action)                                                                          {
                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
                            }];
                            [myAlertController addAction: ok];
                            [self presentViewController:myAlertController animated:YES completion:nil];
                        }
                    }];
                    
                    UIAlertAction* no = [UIAlertAction
                                         actionWithTitle:strNo
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action){
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: yes];
                    [myAlertController addAction: no];
                    
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else if ([[dict valueForKey:@"ResultString"] isEqualToString:strSaved] || [[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:strSavedLitterNote]){
                    
                   /* MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                       hud.mode = MBProgressHUDModeText;
                                       hud.labelText = strSaved;
                                       hud.margin = 10.f;
                                       hud.yOffset = 150.f;
                                       hud.removeFromSuperViewOnHide = YES;*/
                    //***code commented above for Bug-29140 By M.
                    UIImage *logoImage = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
                    logoImageView.frame = CGRectMake(0, 0, 30, 30);
                    logoImageView.contentMode = UIViewContentModeScaleAspectFit;

                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 160, 30)]; // Adjust the frame as needed
                    label.text = strSaved;
                    label.textColor = [UIColor whiteColor];
                    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)]; // Adjust the frame as needed
                    //customView.backgroundColor = [UIColor blackColor];
                    [customView addSubview:logoImageView];
                    [customView addSubview:label];

                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeCustomView;
                    hud.customView = customView;
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;                                        // Set the correct size for the custom view
                    hud.customView.bounds = CGRectMake(0, 0, 200, 30);
                    hud.removeFromSuperViewOnHide = YES;
                    
                    //For maintaining last selected values
                    [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                    [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                    [pref synchronize];
                    flag = 1;
                    
                    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                    NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                    if ([strFromDataEntry isEqualToString:@"1"]){
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        
                        [self clearFileds];
                    }
                    [hud hide:YES afterDelay:3];

                    
//                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
//                                                                                               message:strSaved
//                                                                                        preferredStyle:UIAlertControllerStyleAlert];
//
//                    UIAlertAction* ok = [UIAlertAction
//                                         actionWithTitle:strOk
//                                         style:UIAlertActionStyleDefault
//                                         handler:^(UIAlertAction * action) {
//                        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
//                        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
//
//                        //For maintaining last selected values
//                        [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
//                        [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
//                        [pref synchronize];
//                        flag = 1;
//
//                        if ([strFromDataEntry isEqualToString:@"1"]) {
//                            [self.navigationController popViewControllerAnimated:YES];
//                        }else {
//                            [self clearFileds];
//                        }
//
//                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
//                    }];
//
//                    [myAlertController addAction: ok];
//                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:@"Not connected"]) {//to do too
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:NSLocalizedString(@"connection_lost", @"")
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
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
                            //** added Pigchamp logo on alert Bug-27920 by M.
                            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                            UIView *controllerView = myAlertController.view;
                            [controllerView addSubview:logoImageView];
                            [controllerView bringSubviewToFront:logoImageView];
                            
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
                        
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
                else {
                    [_customIOS7AlertView close];
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[dict valueForKey:@"ResultString"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                   //** added code for Logo image on alert Bug-27920
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                  //  CGFloat offsetX = logoImageView.frame.size.width + 8.0;
                    //UILabel *titleLabel = [controllerView valueForKey:@"ResultString"];
                   // CGRect titleFrame = titleLabel.frame;
                   // titleFrame.origin.x += offsetX;
                   // titleLabel.frame  = titleFrame;
                    //end of by M.
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
            }
            
            NSLog(@"responseData=%@",responseData);
        } onFailure:^(NSString *responseData, NSError *error) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            //
            NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
            [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *strDate = [dateformate stringFromDate:[NSDate date]];
            
            NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
            [tracker set:kGAIScreenName value:strErr];
            [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
            
            if (responseData.integerValue ==401) {
                
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:strUnauthorised
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                    [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
                //[self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:responseData
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }
            
            [_customIOS7AlertView close];
        }];
    }else{
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

- (void)makeAPICallsWithCallback:(void (^)(void))callback {
   
    if (self.currentIndex < reqStringArray.count) {
        NSString *item = reqStringArray[self.currentIndex];
        
        NSString *reqString = [[reqStringfulltmp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"1\":\"%@\"", value] withString:[NSString stringWithFormat:@"\"1\":\"%@\"", item]] mutableCopy];
        
        NSError *error;
        NSMutableDictionary* jsonDict = [[NSMutableDictionary alloc]init];
        [jsonDict setObject:reqString forKey:@"arguments"];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:nil];
        if(!jsonData && error) {
            NSLog(@"Error creating JSON: %@", [error localizedDescription]);
            return;
        }
        
        // Call the API with a completion block
        [self callSaveEvent1:strServiceName1 :jsonData completion:^(BOOL success, NSString *responseString) {
            if (success) {
                // Handle the response from the first API call
                NSLog(@"Response from API: %@", responseString);
                
                // Perform any action based on the response
                
                // Move to the next index
                self.currentIndex++;
                
                // Call the callback block
                if (callback) {
                    
                    callback();
                   // [self makeAPICallsWithCallback:callback];
                }
            } else {
                // Handle error if needed
            }
        }];
    }
}

- (void)callSaveEvent1:(NSString *)strService :(NSData *)jsonData completion:(void (^)(BOOL success, NSString *responseString))completion {
    
    NSString *strSaved = @"Saved successfully";
    NSString *strSavedLitterNote = @"Litter Note Event added successfully";//Need to code yog
    
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Saved successfully",@"Litter Note Event added successfully", nil]];
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    
    for (int i=0; i<resultArray1.count; i++){
        [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
    }
    
    for (int i=0; i<2; i++) {
        if (i==0) {
            if ([dictMenu objectForKey:[@"Saved successfully" uppercaseString]] && ![[dictMenu objectForKey:[@"Saved successfully" uppercaseString]] isKindOfClass:[NSNull class]]) {
                if ([[dictMenu objectForKey:[@"Saved successfully" uppercaseString]] length]>0) {
                    strSaved = [dictMenu objectForKey:[@"Saved successfully" uppercaseString]]?[dictMenu objectForKey:[@"Saved successfully" uppercaseString]]:@"";
                }
            }else if (i==1){
                if ([dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] && ![[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]] length]>0) {
                        strSavedLitterNote = [dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]]?[dictMenu objectForKey:[@"Litter Note Event added successfully" uppercaseString]]:@"";
                    }
                }
            }
        }
    }
    
    
    if ([[ControlSettings sharedSettings] isNetConnected ]){
        _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
        [_customIOS7AlertView showLoaderWithMessage:strWait];
     
        
        [ServerManager sendRequestEvent:[strService stringByAppendingString:[NSString stringWithFormat:@"token=%@&ignoreWarnings=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"0"]] idOfServiceUrl:jsonData methodType:@"POST" onSucess:^(NSString *responseData) {
            [_customIOS7AlertView close];
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            // [dict setValue:@"Not connected" forKey:@"ResultString"];
            if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
            {
                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                {
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
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
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
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
            }else if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:@"Not connected"])
            { //to do too
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                           message:NSLocalizedString(@"connection_lost", @"")
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                //** added Pigchamp logo on alert Bug-27920 by M.
                UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                UIView *controllerView = myAlertController.view;
                [controllerView addSubview:logoImageView];
                [controllerView bringSubviewToFront:logoImageView];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:strOk
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
                            
                            [_customIOS7AlertView close];
                        }];
                    }
                    else {
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:strNoInternet
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        //** added Pigchamp logo on alert Bug-27920 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        
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
                    
                    [myAlertController dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [myAlertController addAction: ok];
                [self presentViewController:myAlertController animated:YES completion:nil];
            }
            else if (dict!=nil){
                if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:[self getTranslatedTextForString:@"Are you sure?"]]){
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[dict valueForKey:@"ResultString"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* yes = [UIAlertAction
                                          actionWithTitle:strYes
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action){
                        if ([[ControlSettings sharedSettings] isNetConnected ]){
                            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
                            [_customIOS7AlertView showLoaderWithMessage:strWait];
                            [ServerManager sendRequestEvent:[strService stringByAppendingString:[NSString stringWithFormat:@"token=%@&ignoreWarnings=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],@"1"]] idOfServiceUrl:jsonData methodType:@"POST" onSucess:^(NSString *responseData) {
                                
                                [_customIOS7AlertView close];
                                id dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                                
                                
                                if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""] || [responseData localizedCaseInsensitiveContainsString:@"\"Token not found\""])
                                {
                                    if ([responseData isEqualToString:@"\"User is not signed in or Session expired\""])
                                    {
                                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                   message:[self getTranslatedTextForString:@"User is not signed in or Session expired"]
                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                        //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIView *controllerView = myAlertController.view;
                                        [controllerView addSubview:logoImageView];
                                        [controllerView bringSubviewToFront:logoImageView];
                                        
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
                                        //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIView *controllerView = myAlertController.view;
                                        [controllerView addSubview:logoImageView];
                                        [controllerView bringSubviewToFront:logoImageView];
                                        
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
                                }else if ([dict isKindOfClass:[NSDictionary class]]) {
                                    if ([[dict valueForKey:@"ResultString"] isEqualToString:strSaved])
                                    {
                                        //                                              UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                        //                                                                                                                         message:strSaved
                                        //                                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                        //
                                        //                                              UIAlertAction* ok = [UIAlertAction
                                        //                                                                   actionWithTitle:strOk
                                        //                                                                   style:UIAlertActionStyleDefault
                                        //                                                                   handler:^(UIAlertAction * action)
                                        //                                                                   {
                                        //                                                  //For maintaining last selected values
                                        //                                                  [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                                        //                                                  [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                                        //                                                  [pref synchronize];
                                        //                                                  flag = 1;
                                        //
                                        //
                                        //                                                  NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                                        //                                                  NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                                        //                                                  if ([strFromDataEntry isEqualToString:@"1"]){
                                        //                                                      [self.navigationController popViewControllerAnimated:YES];
                                        //                                                  }else{
                                        //
                                        //                                                      [self clearFileds];
                                        //                                                  }
                                        //                                                  [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                        //                                              }];
                                        //
                                        //                                              [myAlertController addAction:ok];
                                        //                                              [self presentViewController:myAlertController animated:YES completion:nil];
                                        
                                        
                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                        hud.mode = MBProgressHUDModeText;
                                        hud.labelText = strSaved;
                                        hud.margin = 10.f;
                                        hud.yOffset = 150.f;
                                        hud.removeFromSuperViewOnHide = YES;
                                        
                                        //For maintaining last selected values
                                        [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                                        [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                                        [pref synchronize];
                                        flag = 1;
                                        
                                        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                                        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                                        if ([strFromDataEntry isEqualToString:@"1"]){
                                            [self.navigationController popViewControllerAnimated:YES];
                                        }else{
                                            //***code added for Bug-29063 By M.   Isha
                                            [self makeAPICallsWithCallback:^{
                                                // This block will be executed after the completion of the API calls
                                                // Perform any additional actions or UI updates here
                                                NSLog(@"API calls completed!");
                                                [self clearFileds];
                                            }];
                                            //***end By M.
                                        }
                                        [hud hide:YES afterDelay:3];
                                        
                                        
                                    }else{
                                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                   message:[dict valueForKey:@"ResultString"]
                                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                        //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                        UIView *controllerView = myAlertController.view;
                                        [controllerView addSubview:logoImageView];
                                        [controllerView bringSubviewToFront:logoImageView];
                                        
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
                                
                                NSLog(@"responseData=%@",responseData);
                            } onFailure:^(NSString *responseData, NSError *error) {
                                
                                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                //
                                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                                
                                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
                                [tracker set:kGAIScreenName value:strErr];
                                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                                
                                [_customIOS7AlertView close];
                                
                                if (responseData.integerValue ==401) {
                                    
                                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                               message:strUnauthorised
                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                    //** added Pigchamp logo on alert Bug-27920 by M.
                                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                    UIView *controllerView = myAlertController.view;
                                    [controllerView addSubview:logoImageView];
                                    [controllerView bringSubviewToFront:logoImageView];
                                    
                                    UIAlertAction* ok = [UIAlertAction
                                                         actionWithTitle:strOk
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                        [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                                                                       [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                    }];
                                    
                                    [myAlertController addAction: ok];
                                    [self presentViewController:myAlertController animated:YES completion:nil];
                                    //[self.navigationController popToRootViewControllerAnimated:YES];
                                }else{
                                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                               message:responseData
                                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                    //** added Pigchamp logo on alert Bug-27920 by M.
                                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                    UIView *controllerView = myAlertController.view;
                                    [controllerView addSubview:logoImageView];
                                    [controllerView bringSubviewToFront:logoImageView];
                                    
                                    UIAlertAction* ok = [UIAlertAction
                                                         actionWithTitle:strOk
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                    }];
                                    
                                    [myAlertController addAction: ok];
                                    [self presentViewController:myAlertController animated:YES completion:nil];
                                }
                                
                            }];
                            
                            [myAlertController dismissViewControllerAnimated:YES completion:nil];
                            
                        }else{
                            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                       message:strNoInternet
                                                                                                preferredStyle:UIAlertControllerStyleAlert];
                            //** added Pigchamp logo on alert Bug-27920 by M.
                            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                            UIView *controllerView = myAlertController.view;
                            [controllerView addSubview:logoImageView];
                            [controllerView bringSubviewToFront:logoImageView];
                            
                            UIAlertAction* ok = [UIAlertAction
                                                 actionWithTitle:strOk
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action)                                                                          {
                                [myAlertController dismissViewControllerAnimated:YES completion:nil];
                            }];
                            [myAlertController addAction: ok];
                            [self presentViewController:myAlertController animated:YES completion:nil];
                        }
                    }];
                    
                    UIAlertAction* no = [UIAlertAction
                                         actionWithTitle:strNo
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action){
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: yes];
                    [myAlertController addAction: no];
                    
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else if ([[dict valueForKey:@"ResultString"] isEqualToString:strSaved] || [[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:strSavedLitterNote]){
                    
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = strSaved;
                    hud.margin = 10.f;
                    hud.yOffset = 150.f;
                    hud.removeFromSuperViewOnHide = YES;
                    
                    //For maintaining last selected values
                    [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                    [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                    [pref synchronize];
                    flag = 1;
                    
                    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                    NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                    if ([strFromDataEntry isEqualToString:@"1"]){
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        
                        [self clearFileds];
                    }
                    [hud hide:YES afterDelay:3];
                    
                    
                    //                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                    //                                                                                               message:strSaved
                    //                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //
                    //                    UIAlertAction* ok = [UIAlertAction
                    //                                         actionWithTitle:strOk
                    //                                         style:UIAlertActionStyleDefault
                    //                                         handler:^(UIAlertAction * action) {
                    //                        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
                    //                        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
                    //
                    //                        //For maintaining last selected values
                    //                        [pref setObject:dictJson forKey:@"lastSelectedDictJSON"];
                    //                        [pref setObject:_dictDynamic forKey:@"lastSelectedDictDynamic"];
                    //                        [pref synchronize];
                    //                        flag = 1;
                    //
                    //                        if ([strFromDataEntry isEqualToString:@"1"]) {
                    //                            [self.navigationController popViewControllerAnimated:YES];
                    //                        }else {
                    //                            [self clearFileds];
                    //                        }
                    //
                    //                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    //                    }];
                    //
                    //                    [myAlertController addAction: ok];
                    //                    [self presentViewController:myAlertController animated:YES completion:nil];
                }else if ([[dict valueForKey:@"ResultString"] localizedCaseInsensitiveContainsString:@"Not connected"]) {//to do too
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:NSLocalizedString(@"connection_lost", @"")
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
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
                            //** added Pigchamp logo on alert Bug-27920 by M.
                            UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                            logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                            UIView *controllerView = myAlertController.view;
                            [controllerView addSubview:logoImageView];
                            [controllerView bringSubviewToFront:logoImageView];
                            
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
                        
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
                else {
                    [_customIOS7AlertView close];
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:[dict valueForKey:@"ResultString"]
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added code for Logo image on alert Bug-27920
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    //  CGFloat offsetX = logoImageView.frame.size.width + 8.0;
                    //UILabel *titleLabel = [controllerView valueForKey:@"ResultString"];
                    // CGRect titleFrame = titleLabel.frame;
                    // titleFrame.origin.x += offsetX;
                    // titleLabel.frame  = titleFrame;
                    //end of by M.
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
            }
            
            NSLog(@"responseData=%@",responseData);
            // Assuming you have some way to check if the API call was successful, update the condition accordingly
            BOOL success = YES; /* Check if the API call was successful */;
            NSString *responseString = responseData;
                // Call the completion block with the success status
                if (completion) {
                    completion(success,responseString);
                }
        }
                                  
                onFailure:^(NSString *responseData, NSError *error) {
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                //
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                
                if (responseData.integerValue ==401) {
                    
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:strUnauthorised
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    //** added Pigchamp logo on alert Bug-27920 by M.and Bug-29344
                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                    logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                    UIView *controllerView = myAlertController.view;
                    [controllerView addSubview:logoImageView];
                    [controllerView bringSubviewToFront:logoImageView];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                        [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                    //[self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                               message:responseData
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                        [myAlertController dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [myAlertController addAction: ok];
                    [self presentViewController:myAlertController animated:YES completion:nil];
                }
                
                [_customIOS7AlertView close];
               
            }];
          
        
    }else{
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
-(void)clearFileds {
    @try {
        // [self btnClear_tapped:nil];
        [self callClearFields];
    }
    
    //        NSLog(@"strTitleInt=%@",self.strTitleInt);
    //
    //        __block NSDictionary *dictBarnData,*dictForBarnRoomPen;
    //        NSArray *arrArrivalClear = [[NSArray alloc]initWithObjects:@"23",@"67",@"6", nil];//@"35" is dob field was not getting clear prev now made c hange
    //
    //        if ([self.strTitleInt isEqualToString:@"0"]) {
    //            for (NSMutableDictionary *dict  in _arrDynamic){
    //                if(![arrArrivalClear containsObject:[dict valueForKey:@"dk"]]){
    //                    [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
    //                    [dictJson setValue:@"" forKey:[dict valueForKey:@""]];
    //
    //                    NSString *strDataType  = [self getViewType:[dict valueForKey:@"datatype"]];
    //                    if ([strDataType isEqualToString:@"DropDown"]){
    //                        [self fillDropDn:0 dict:dict];
    //                    }
    //                }
    //            }
    //        }else if([self.strTitleInt isEqualToString:@"1"]){
    //            for (NSMutableDictionary *dict  in _arrDynamic){
    //
    //                if([self ifForDeparture:dict]){
    //                    [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
    //                    [dictJson setValue:@"" forKey:[dict valueForKey:@""]];
    //
    //                    NSString *strDataType  = [self getViewType:[dict valueForKey:@"datatype"]];
    //                    if ([strDataType isEqualToString:@"DropDown"]){
    //                        [self fillDropDn:0 dict:dict];
    //                    }
    //                }
    ////                else if((strEventCode.integerValue==13 && [[dict valueForKey:@""]integerValue]!=62) || (strEventCode.integerValue==12 && [[dict valueForKey:@""]integerValue]!=62)){
    ////                        [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
    ////                        [dictJson setValue:@"" forKey:[dict valueForKey:@""]];
    ////                }
    //            }
    //        }
    //        else {
    //            for (NSMutableDictionary *dict  in _arrDynamic){
    //                if([[dict valueForKey:@""] integerValue]!=67 && [[dict valueForKey:@""] integerValue]!=6){
    //                        [_dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
    //                        [dictJson setValue:@"" forKey:[dict valueForKey:@""]];
    //
    //                    NSString *strDataType  = [self getViewType:[dict valueForKey:@"datatype"]];
    //                    if ([strDataType isEqualToString:@"DropDown"]){
    //                        [self fillDropDn:0 dict:dict];
    //                    }
    //                }
    //               else if([strEventCode integerValue]==28 || [strEventCode integerValue]==29 || [strEventCode integerValue]==30 || [strEventCode integerValue]==31 ){
    //                    [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
    //
    //                   if ([[dict valueForKey:@""] integerValue]==6){
    //
    //                       [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
    //                           if ([key isEqualToString:@"6"]){
    //                               dictBarnData = obj;
    //                           }
    //                       }];
    //
    //                       [dictBarnData setValue:@"" forKey:@"pen"];
    //                       [dictJson setObject:dictBarnData forKey:[dict valueForKey:@""]];
    //                   }else
    //                    [dictJson setValue:@"0" forKey:[dict valueForKey:@""]];
    //                }
    //            }
    //        }
    //
    //        for (NSMutableDictionary *dict  in _arrDynamic){
    //            if ([[dict valueForKey:@""] integerValue]==6){
    //                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
    //                     if ([key isEqualToString:@"6"]){
    //                         dictBarnData = obj;
    //                     }
    //                 }];
    //
    //                [dictBarnData setValue:@"" forKey:@"pen"];
    //                [dictJson setObject:dictBarnData forKey:[dict valueForKey:@""]];
    //            }else if ([[dict valueForKey:@""] integerValue] == 92){
    //                    NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
    //                    [dictText setValue:@"" forKey:@"first"];
    //                    [dictText setValue:@"" forKey:@"second"];
    //                    [dictText setValue:@"" forKey:@"third"];
    //                    [dictJson setObject:dictText forKey:[dict valueForKey:@""]];
    //            }else if (([[dict valueForKey:@""] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@""] integerValue]==15 && [self isTwoText])){
    //                NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
    //                [dictText setValue:@"" forKey:@"first"];
    //                [dictText setValue:@"" forKey:@"second"];
    //                [dictJson setObject:dictText forKey:[dict valueForKey:@""]];
    //            }
    //        }
    //
    //        NSLog(@"_dictDynamic=%@",_dictDynamic);
    //        NSLog(@"dictJson=%@",dictJson);
    //
    //        [self.tblDynamic reloadData];
    //    }
    @catch (NSException *exception) {
        NSLog(@"Exception in clearFileds=%@",exception.description);
    }
}

-(BOOL)ifForDeparture:(NSDictionary*)dict{
    @try {
        if([[dict valueForKey:@"dk"]integerValue]==141){
            return NO;
        }else if([[dict valueForKey:@"dk"]integerValue]==6)
        {
            return NO;
        }else if((strEventCode.integerValue==13 && [[dict valueForKey:@"dk"]integerValue]==62)){
            return NO;
        } else if( (strEventCode.integerValue==12 && [[dict valueForKey:@"dk"]integerValue]==62)){
            return NO;
        }else {
            return YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in ifForDeparture =%@",exception.description);
    }
}

//------------------------------------------------------------------------------------------------------------------------------------------

- (IBAction)btnDropdown_tapped:(id)sender {
    @try {
        [self.activeTextField resignFirstResponder];
        
        NSSortDescriptor *sortBy; // = [[NSSortDescriptor alloc] initWithKey:@"ln"
        NSArray *sortDescriptors; // = [[NSArray alloc] initWithObjects:sortBy, nil];
        
        UIButton *btnTapped = (UIButton*)sender;
        TapedDropDownTag = btnTapped.tag;
        
        NSLog(@"TapedDropDownTag=%ld",(long)TapedDropDownTag);
        
        UITableViewCell* cell = (UITableViewCell*)[[sender superview] superview];
        NSIndexPath *indexPath = [self.tblDynamic indexPathForCell:cell];
        NSDictionary *dict = [_arrDynamic objectAtIndex:indexPath.row];
        
        //serviceUrl=http://pcrds.farmsstaging.com/SrvReports_2.svc/GetWarningListNotServedReport?sortFld=&sortOrd=0&DaysSinceWean=0&DueToBeServed=20170529&FromRec=1&token=95294c0db0686c91bf121e64ec84be22&ToRec=20
        __block NSString *strTitle=[dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
        [_arrDropDown removeAllObjects];
        
        NSString *strPrevSelectedValue= [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
        NSInteger prevSelectedIndex  = 0;
        
        switch ([[dict valueForKey:@"dk"]integerValue]) {
            case 4: {
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                //*** uncommented below line for Bug-28302 By M.
                 sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                      ascending:YES];
               // sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                
                //** code below changed cause of API response changed for key from bool to string Bug-28302 and 28307 By M.
                NSString *strPredicate;
                if ([strEventCode isEqualToString:@"33"]||[strEventCode isEqualToString:@"48"]) {
                    strPredicate = @"br != 'false' AND tr == 'true'";// @"br != 0 AND tr == 1";
                }
                else if ([strEventCode isEqualToString:@"34"]||[strEventCode isEqualToString:@"49"]) {
                    strPredicate =@"(sg != 'false' OR sp != 'false' OR sd != 'false') AND tr == 'true'";//@"(sg != 0 OR sp != 0 OR sd != 0 ) AND tr == 1";
                }
                else if ([strEventCode isEqualToString:@"35"]) {
                    strPredicate =  @"pg != 'false' AND tr == 'true'";//@"pg != 0 AND tr == 1";
                }
                else if ([strEventCode isEqualToString:@"10"]||[strEventCode isEqualToString:@"12"]) {
                    strPredicate =  @"br != 'false' AND ds == 'true'";//@"br != 0 AND ds == 1";
                }
                else if ([strEventCode isEqualToString:@"11"]||[strEventCode isEqualToString:@"13"]) {
                    //strPredicate = @"(sg != 0 OR sp != 0 OR sd != 0 ) AND ds==1";
                    strPredicate = @"(sg != 'false' OR sp != 'false' OR sd != 'false') AND ds == 'true'";//@"(sg != 0 || sp != 0 || sd != 0) && ds == 1";

                }
                else if ([strEventCode isEqualToString:@"32"]) {
                    strPredicate = @"pg != 'false' AND ds == 'true'";//@"pg != 0 AND ds == 1";
                }
                NSPredicate *predicate = [NSPredicate predicateWithFormat:strPredicate];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Conditions" andPredicate:predicate andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    //***uncommented below line for Bug - 28027 by M.
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    //***end By M.
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0){
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue]){
                            prevSelectedIndex = count;
                        }
                    }
                }
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];

            }
                break;
                
            case 6:{
                __block NSMutableDictionary *dictBarnDataToSend;
                
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key isEqualToString:@"6"]) {
                        dictBarnDataToSend = obj;
                    }
                }];
                
                __block NSString *strBarn;
                __block NSString *strRoom;
                
                [dictBarnDataToSend enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                    if ([key isEqualToString:@"br"]){
                        strBarn = obj;
                    }
                    else if ([key isEqualToString:@"rm"]) {
                        strRoom = obj;
                    }
                }];
                
                NSPredicate *predicate;
                NSArray* resultArray ;
                if (TapedDropDownTag==2){
                    predicate  = [NSPredicate predicateWithFormat:@"sid=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictBarnDataToSend valueForKey:@"br"]?[dictBarnDataToSend valueForKey:@"br"]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"br"
                                                         ascending:YES];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"br" andPredicate:predicate andSortDescriptors:[[NSArray alloc] initWithObjects:sortBy, nil]];
                }else if (TapedDropDownTag==3){
                    predicate  = [NSPredicate predicateWithFormat:@"br=%@ AND sid=%@",strBarn,[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictBarnDataToSend valueForKey:@"rm"]?[dictBarnDataToSend valueForKey:@"rm"]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"rm"
                                                         ascending:YES];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"rm" andPredicate:predicate andSortDescriptors:[[NSArray alloc] initWithObjects:sortBy, nil]];
                }else if (TapedDropDownTag==4){
                    predicate  = [NSPredicate predicateWithFormat:@"br = %@ AND rm = %@ AND sid=%@",strBarn, strRoom,[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictBarnDataToSend valueForKey:@"pn"]?[dictBarnDataToSend valueForKey:@"pn"]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"pn"
                                                         ascending:YES];
                    
                    resultArray = [[CoreDataHandler sharedHandler] getValuesBarnRoomPen:@"Locations" column:@"pn" andPredicate:predicate andSortDescriptors:[[NSArray alloc] initWithObjects:sortBy, nil]];
                    
                    NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
                    for (int count=0; count<resultArray.count; count++){
                        if ([[[resultArray objectAtIndex:count] valueForKey:@"br"]length]>0) {
                            [arrTemp addObject:[resultArray objectAtIndex:count]];
                        }
                    }
                    
                    //                resultArray =[NSArray arrayWithArray:arrTemp];
                }
                
                if (TapedDropDownTag==2){
                    // strTitle = @"Barn";
                    strTitle = [self getTranslatedTextForString:@"Barn"];
                }else if (TapedDropDownTag==3)
                {
                    //  strTitle =@"Room";
                    strTitle = [self getTranslatedTextForString:@"Room"];
                }
                else if(TapedDropDownTag==4){
                    // strTitle =@"Pen";
                    strTitle = [self getTranslatedTextForString:@"Pen"];
                }
                
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    if (TapedDropDownTag==2){
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"br"] forKey:@"visible"];
                    }else if (TapedDropDownTag==3)
                    {
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"rm"] forKey:@"visible"];
                    }
                    else if(TapedDropDownTag==4){
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"pn"] forKey:@"visible"];
                    }
                    
                    if ([[dict valueForKey:@"visible"] length]>0){
                        [_arrDropDown addObject:dict];
                    }
                }
                for (int count=0; count<_arrDropDown.count; count++){
                    NSDictionary *dict = [_arrDropDown objectAtIndex:count];
                    if (strPrevSelectedValue.length>0){
                        if( [strPrevSelectedValue caseInsensitiveCompare:[dict valueForKey:@"visible"]] == NSOrderedSame){
                            prevSelectedIndex = count;
                        }
                    }
                }
                
                NSLog(@"_arrDropDown=%@",_arrDropDown);
            }
                break;
            case 8:{
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Pd_Results" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++)  {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"]?[[resultArray objectAtIndex:count] valueForKey:@"dt"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"]?[[resultArray objectAtIndex:count] valueForKey:@"dk"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0){
                        if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                            prevSelectedIndex = count;
                        }
                    }
                }
            }
                break;
            case 9:{
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                
                // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"it != '' AND sid=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ln != '' || ln != nil"];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Operator" andPredicate:predicate andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0){
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue]){
                            prevSelectedIndex = count;
                        }
                    }
                }
            }
                break;
            case 11:{
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Treatments" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++)
                {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                }
            }
                break;
                
            case 13:{
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Tod" andPredicate:nil andSortDescriptors:sortDescriptors];
                //** changed the valueforkey from dT to dt and dK to dk Bug -27758 by M.
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"]?[[resultArray objectAtIndex:count] valueForKey:@"dt"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"]?[[resultArray objectAtIndex:count] valueForKey:@"dk"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        ///*** valueforkey corrected for Bu - 27758  by M.
                        if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                            ///*** end By M.
                            prevSelectedIndex = count;
                        }
                    }
                }
            }
                break;
            case 23: {
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                
                NSArray* resultArray;
                NSPredicate *predicate;
                if ([self.strEventCode isEqualToString:@"1"] || [self.strEventCode isEqualToString:@"2"]) {
                    predicate = [NSPredicate predicateWithFormat:@"sx == 'M' OR sx == '' OR sx == null"];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Genetics" andPredicate:predicate andSortDescriptors:sortDescriptors];
                }else if ([self.strEventCode isEqualToString:@"4"] || [self.strEventCode isEqualToString:@"5"] || [self.strEventCode isEqualToString:@"8"]||[self.strEventCode isEqualToString:@"6"] || [self.strEventCode isEqualToString:@"113"]){
                    predicate = [NSPredicate predicateWithFormat:@"sx == 'F' OR sx == '' OR sx == null"];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Genetics" andPredicate:predicate andSortDescriptors:sortDescriptors];
                }
                
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    
                    ///*** added for Genetics are not getting saved in DB Bugnet No- 27969  by M. start
                   [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    
                    if (_arrDropDown.count > 0) {

                        NSDictionary *dic1 = [_arrDropDown objectAtIndex:count-1];

                        if ([dict valueForKey:@"visible"]  == [dic1 valueForKey:@"visible"]) {
                                [_arrDropDown addObject:dict];
                            
                        }else {
                            [_arrDropDown addObject:dict];
                        }}else {
                                [_arrDropDown addObject:dict];
                            }
                     ///code added by M. End
                    ///  //   [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                }
                
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];

            }
                break;
            case 34:{
                NSArray* resultArray;
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                if ([self.strEventCode isEqualToString:@"1"]){
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"AI_STUDS" andPredicate:nil andSortDescriptors:sortDescriptors];
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
                else {
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ds"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Origin" andPredicate:nil andSortDescriptors:sortDescriptors];
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ds"]?[[resultArray objectAtIndex:count] valueForKey:@"ds"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"sid"]?[[resultArray objectAtIndex:count] valueForKey:@"sid"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        //NSLog(@"site key=%@",[[resultArray objectAtIndex:count] valueForKey:@"siteKey"]);
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"sid"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                        
                    }
                }
            }
                break;
            case 37:{
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Halothane" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"]?[[resultArray objectAtIndex:count] valueForKey:@"dt"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"]?[[resultArray objectAtIndex:count] valueForKey:@"dk"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame)
                        {
                            prevSelectedIndex = count;
                        }
                    }
                }
            }
                break;
            case 62:{
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                NSArray* resultArray;
                if ([self.strEventCode isEqualToString:@"12"] || [self.strEventCode isEqualToString:@"13"]||[self.strEventCode isEqualToString:@"29"] ||[self.strEventCode isEqualToString:@"30"] || [self.strEventCode isEqualToString:@"31"]|| [self.strEventCode isEqualToString:@"28"]) {
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Packing_Plants" andPredicate:nil andSortDescriptors:sortDescriptors];
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0){
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue]){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
                else {
                    ///***code added below for Bug- 28030 By M.
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ds"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Destination" andPredicate:nil andSortDescriptors:sortDescriptors];
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ds"]?[[resultArray objectAtIndex:count] valueForKey:@"ds"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"sid"]?[[resultArray objectAtIndex:count] valueForKey:@"sid"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        if (strPrevSelectedValue.length>0){
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"sid"] integerValue]){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 73:{
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Admin_Routes" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++){
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"]?[[resultArray objectAtIndex:count] valueForKey:@"dt"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"]?[[resultArray objectAtIndex:count] valueForKey:@"dk"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
            }
                break;
            case 67: { //case 80:case 81:case 82:case 83:case 84:case 72:
                NSArray* resultArray;
                NSPredicate *predicate;
                NSString *strcategory;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"ConditionScore" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];

            }
                break;
                
                //
                
            case 80: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Lesion_Scores" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
                
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];

            }
                break;
                
                
            case 81: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Lock" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
            }
                break;
                
            case 82: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Leakage" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
            }
                break;
                
            case 83: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Quality" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
            }
                break;
                
                
            case 84: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Standing_Reflex" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
            }
                break;
                
            case 72: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Test_Type" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    //***code added for Bug-28045 removing duplicate entry for Test_type By M.
                    if (![_arrDropDown containsObject:dict]) {
                        [_arrDropDown addObject:dict];
                        }
                    //*** by M. end
                    // [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
                
            }
                break;
                
                //
                
            case 41: {
                NSArray* resultArray;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"HerdCategory" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
                
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];
            }
                break;
                
            case 47:{
                NSArray* resultArray;
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                if ([self.strEventCode isEqualToString:@"45"]){
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sx != 'F' OR sx == null"];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Flags" andPredicate:predicate andSortDescriptors:sortDescriptors];
                }
                else{
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Flags" andPredicate:nil andSortDescriptors:sortDescriptors];
                }
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                }
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];

            }
                break;
            case 78:{
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Transport_Companies" andPredicate:nil andSortDescriptors:sortDescriptors];
                //***below condition is added for Bug- 28011
                if (resultArray.count>0){
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                       //*** code added below for Bug-28636 removing duplicate entry for Transport By M.
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }

                        // [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
                
                else{
                    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                        message:[self getTranslatedTextForString:@"No Data Available"]preferredStyle:UIAlertControllerStyleAlert];
                                           //** added Pigchamp logo on alert Bug-27920 by M.
                                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                           logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                           UIView *controllerView = myAlertController.view;
                                           [controllerView addSubview:logoImageView];
                                           [controllerView bringSubviewToFront:logoImageView];
                                           
                                          UIAlertAction* ok = [UIAlertAction
                                                                actionWithTitle:strOk
                                                                style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action){
                                               [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                           }];

                                           [myAlertController addAction: ok];
                                           [self presentViewController:myAlertController animated:YES completion:nil];

                                                return;
                }
                //***end of by M.
            }
                
                break;
                ///***added below case 164 for Bug-28180 By M.
            case 150:case 141:case 74:case 28:case 70:case 33:case 164:{
                NSDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setValue:strNo forKey:@"visible"];
                [dict setValue:@"0" forKey:@"dataTosend"];
                [_arrDropDown addObject:dict];
                
                NSDictionary *dict1 = [[NSMutableDictionary alloc]init];
                [dict1 setValue:strYes forKey:@"visible"];
                [dict1 setValue:@"1" forKey:@"dataTosend"];
                [_arrDropDown addObject:dict1];
                
                if (strPrevSelectedValue.length>0){
                    if ([strPrevSelectedValue integerValue] == 1){
                        prevSelectedIndex = 1;
                    }else if ([strPrevSelectedValue integerValue] == 0){
                        prevSelectedIndex = 0;
                    }
                }
            }
                break;
                //***code added for Piglet_Defects by M. Bug-28548 By M.
            case 152: {
                NSArray* resultArray;
                NSPredicate *predicate;
                NSString *strcategory;
                
                strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                
                // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                
                sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                     ascending:YES];
                sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Piglet_Defects" andPredicate:nil andSortDescriptors:sortDescriptors];
                
                for (int count=0; count<resultArray.count; count++) {
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                    [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                        {
                            prevSelectedIndex = count;
                        }
                    }
                    
                }
                NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:_arrDropDown];
                _arrDropDown = [orderedSet mutableCopy];

            }
                break;
                //~~~for piglet identities By M.
            case 169:{
               /* __block NSMutableDictionary *dictDataToSend;
                
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key isEqualToString:@"169"]) {
                        dictDataToSend = obj;
                    }
                }];
                
                NSMutableDictionary *dictDataToSend1 = (NSMutableDictionary *)dictDataToSend;
                
                    __block NSString *strSex,*strColor,*strDestination;
                    [dictDataToSend1 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key isEqualToString:@"37"]){
                            strSex = obj;
                        }
                        else if ([key isEqualToString:@"43"]) {
                            strColor = obj;
                        }else if ([key isEqualToString:@"44"]) {
                            strDestination = obj;
                        }
                    }];
                */
                NSArray *array169 = dictJson[@"169"];

                if ([array169 isKindOfClass:[NSArray class]]) {
                    // Extract the first dictionary from the array (assuming there's only one dictionary in the array)
                    NSDictionary *dictDataToSend = array169[0];
                    
                    // Process the dictionary to retrieve values for specific keys
                    NSString *strSex = dictDataToSend[@"37"];
                    NSString *strColor = dictDataToSend[@"43"];
                    NSString *strDestination = dictDataToSend[@"44"];
                    
                    // Use the retrieved values as needed
                    NSLog(@"Sex: %@, Color: %@, Destination: %@", strSex, strColor, strDestination);
                }
                
                NSArray* resultArray ;
                if (TapedDropDownTag==4){
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Sex" andPredicate:nil andSortDescriptors:sortDescriptors];
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }

                        //[_arrDropDown addObject:dict];
                    }
                   
                   
                }else if (TapedDropDownTag==5){
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Color" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }

                           // [_arrDropDown addObject:dict];
                       
                    }
                }else if (TapedDropDownTag==6){
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Designation" andPredicate:nil andSortDescriptors:sortDescriptors];
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }

                            //[_arrDropDown addObject:dict];
                       
                    }
                
                  
                }
                
                if (TapedDropDownTag==4){
                    strTitle = [self getTranslatedTextForString:@"Sex"];
                }else if (TapedDropDownTag==5)
                {
                    strTitle = [self getTranslatedTextForString:@"Color"];
                }
                else if(TapedDropDownTag==6){
                   
                    strTitle = [self getTranslatedTextForString:@"Designation"];
                }
                
                NSLog(@"_arrDropDown=%@",_arrDropDown);
              
            }
            break;
            default:{
                NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]];
                if ([strDataType isEqualToString:@"DropDown"]){
                    if ([[dict valueForKey:@"dk"] hasPrefix:@"UDF"]){
                        if ([[dict valueForKey:@"dt"] isEqualToString:@"BL"]){
                            NSDictionary *dict = [[NSMutableDictionary alloc]init];
                            [dict setValue:strNo forKey:@"visible"];
                            [dict setValue:@"0" forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict];
                            
                            NSDictionary *dict1 = [[NSMutableDictionary alloc]init];
                            [dict1 setValue:strYes forKey:@"visible"];
                            [dict1 setValue:@"1" forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict1];
                            
                            if (strPrevSelectedValue.length>0){
                                if ([strPrevSelectedValue integerValue] == 1){
                                    prevSelectedIndex = 1;
                                } else if ([strPrevSelectedValue integerValue] == 0){
                                    prevSelectedIndex = 0;
                                }
                            }
                        }
                        else{
                            NSString *str = [dict valueForKey:@"op"];//opt
                            str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            //NSArray *arrStringComponents = [str componentsSeparatedByString:@","];
                            NSArray *sortedStrings = [str componentsSeparatedByString:@","];
                            
                            //
                            NSArray *arrStringComponents =
                            [sortedStrings sortedArrayUsingSelector:@selector(compare:)];
                            //
                            
                            for (int count=0; count<arrStringComponents.count; count++){
                                NSDictionary *dict = [[NSMutableDictionary alloc]init];
                                [dict setValue:[arrStringComponents objectAtIndex:count] forKey:@"visible"];
                                [dict setValue:[arrStringComponents objectAtIndex:count] forKey:@"dataTosend"];
                                [_arrDropDown addObject:dict];
                                
                                if (strPrevSelectedValue.length>0){
                                    if ([strPrevSelectedValue isEqualToString:[arrStringComponents objectAtIndex:count]]){
                                        prevSelectedIndex = count;
                                    }
                                }
                            }
                        }
                    }
                }
            }
                
                break;
        }
        
        if (![[dict valueForKey:@"co"] isEqualToString:@"1"]){
            if (_arrDropDown.count>0){
                NSDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setValue:@"" forKey:@"visible"];
                [dict setValue:@"" forKey:@"dataTosend"];
                [_arrDropDown insertObject:dict atIndex:0];
            }
        }
        
        NSLog(@"weakSelf.dictDynamic=%@",_dictDynamic);
        self.pickerDropDown = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 10, 270, 150.0)];
        [self.pickerDropDown setDelegate:self];
        // self.pickerDropDown.showsSelectionIndicator = YES;
        
        // [[self.pickerDropDown.subviews objectAtIndex:1] setBackgroundColor:[UIColor redColor]];
        // [[self.pickerDropDown.subviews objectAtIndex:2] setBackgroundColor:[UIColor redColor]];
        
        _alertForOrgName = [[CustomIOS7AlertView alloc] init];
        [_alertForOrgName setMyDelegate:self];
        [_alertForOrgName setUseMotionEffects:true];
        [_alertForOrgName setButtonTitles:[NSMutableArray arrayWithObjects:strOk,strCancel, nil]];
        
        __weak typeof(self) weakSelf = self;
        
        [_alertForOrgName setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            
            if(buttonIndex == 0 && weakSelf.pickerDropDown>0){
                NSInteger row = [weakSelf.pickerDropDown selectedRowInComponent:0];
                NSDictionary *dict = [weakSelf.arrDynamic objectAtIndex:indexPath.row];
                
                if ([[dict valueForKey:@"dk"] integerValue] == 6){
                    // __block NSMutableDictionary *dictBarn;
                    __block NSMutableDictionary *dictBarnDataToSend;
                    
                    [weakSelf.dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key isEqualToString:@"6"]){
                            dictBarnDataToSend = [obj mutableCopy];
                        }
                    }];
                    
                    NSString *strVal=[[weakSelf.arrDropDown objectAtIndex:row] valueForKey:@"visible"]?[[weakSelf.arrDropDown objectAtIndex:row] valueForKey:@"visible"]:@"";
                    
                    if (TapedDropDownTag==2) {
                        [dictBarnDataToSend setValue:strVal forKey:@"br"];
                        [dictBarnDataToSend setValue:@"" forKey:@"rm"];
                        [dictBarnDataToSend setValue:@"" forKey:@"pn"];
                    }else if (TapedDropDownTag==3){
                        [dictBarnDataToSend setValue:strVal forKey:@"rm"];
                        [dictBarnDataToSend setValue:@"" forKey:@"pn"];
                    }
                    else if (TapedDropDownTag==4){
                        [dictBarnDataToSend setValue:strVal forKey:@"pn"];
                    }
                    
                    //[weakSelf.dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
                    [weakSelf.dictJson setObject:dictBarnDataToSend forKey:[dict valueForKey:@"dk"]];
                }
                //~~~~ for piglet identities By m
                if ([[dict valueForKey:@"dk"] integerValue] == 169){
                    
                    __block NSMutableDictionary *dictDataToSend;
                    
                    [weakSelf.dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key isEqualToString:@"169"]){
                            dictDataToSend = [obj mutableCopy];
                        }
                    }];
                    
                    NSString *strVal=[[weakSelf.arrDropDown objectAtIndex:0] valueForKey:@"visible"]?[[weakSelf.arrDropDown objectAtIndex:0] valueForKey:@"visible"]:@"";
                    
                    if (TapedDropDownTag==4) {
                        [dictDataToSend setValue:strVal forKey:@"37"];
                      
                    }else if (TapedDropDownTag==5){
                        [dictDataToSend setValue:strVal forKey:@"43"];
                        
                    }
                    else if (TapedDropDownTag==6){
                        [dictDataToSend setValue:strVal forKey:@"44"];
                    }
                    
                    //[weakSelf.dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
                    [weakSelf.dictJson setObject:dictDataToSend forKey:[dict valueForKey:@"dk"]];
                }else {
                    [weakSelf.dictDynamic setValue:[[weakSelf.arrDropDown objectAtIndex:row] valueForKey:@"visible"] forKey:[dict valueForKey:@"Lb"]];
                    [weakSelf.dictJson setValue:[[weakSelf.arrDropDown objectAtIndex:row] valueForKey:@"dataTosend"] forKey:[dict valueForKey:@"dk"]];
                }
                
                NSLog(@"weakSelf.dictDynamic=%@",weakSelf.dictDynamic);
                NSLog(@"dictJson=%@",weakSelf.dictJson);
                
                [weakSelf.tblDynamic reloadData];
            }
            
            [weakSelf.alertForOrgName close];
        }];
        
        // NSLog(@"weakSelf.dictJson=%@",weakSelf.dictJson);
        
        if (![[dict valueForKey:@"co"] isEqualToString:@"1"]) {
            {
                [self.pickerDropDown selectRow:prevSelectedIndex+1 inComponent:0 animated:NO];
            }
        }
        else {
            if (_arrDropDown.count>=prevSelectedIndex){
                [self.pickerDropDown selectRow:prevSelectedIndex inComponent:0 animated:NO];
            }
        }
        
        [self.pickerDropDown setShowsSelectionIndicator:YES];
        
        if (_arrDropDown.count>0){
            
            //            if (_arrDropDown.count < 5){
            //                [weakSelf.alertForOrgName showCustomwithView:self.pickerDropDown title:strTitle];
            //            }
            //            else{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DropDownSearchViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"DropDownSearchViewController"];
            ivc.arrDropDownData = _arrDropDown;
            ivc.dictData = dict;
            ivc.delegate = self;
            ivc.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self.navigationController presentViewController:ivc animated:YES completion:nil];
            //            }
        }
        //added below alert when Any dropdown doesn't have values By M.
        else {
            //NSLog(@"no data");
            
                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                    message:[self getTranslatedTextForString:@"No Data Available"]preferredStyle:UIAlertControllerStyleAlert];
                                       //** added Pigchamp logo on alert Bug-27920 by M.
                                    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                       logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                       UIView *controllerView = myAlertController.view;
                                       [controllerView addSubview:logoImageView];
                                       [controllerView bringSubviewToFront:logoImageView];
                                       
                                      UIAlertAction* ok = [UIAlertAction
                                                            actionWithTitle:strOk
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action){
                                           [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                       }];

                                       [myAlertController addAction: ok];
                                       [self presentViewController:myAlertController animated:YES completion:nil];

                                            return;
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in btnDropdown_tapped =%@",exception.description);
    }
}

- (IBAction)btnDate_tapped:(id)sender {
    @try {
        [self.activeTextField resignFirstResponder];
        UITableViewCell* cell = (UITableViewCell*)[[sender superview] superview];
        NSIndexPath* indexPath = [self.tblDynamic indexPathForCell:cell];
        NSDictionary *dict = [_arrDynamic objectAtIndex:indexPath.row];
        NSString *strPrevSelectedValue= [dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@"";
        __block NSString *strTitle=[dict valueForKey:@"Lb"]?[dict valueForKey:@"Lb"]:@"";
        
        NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init];
        
        //***commented below for Bug-29092 By M.
        //[dateFormatterr setDateFormat:@"YYYYMMdd"];
      
        //***added below for Bug-29092 By M.
        if ([_strDateFormat isEqualToString:@"1"]){
            [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
        }else if ([_strDateFormat isEqualToString:@"2"] || [_strDateFormat isEqualToString:@"3"]){
            [dateFormatterr setDateFormat:@"dd-MMM-yy"];
        }else if ([_strDateFormat isEqualToString:@"4"]){
            [dateFormatterr setDateFormat:@"mm/dd/yy"];
        }else if ([_strDateFormat isEqualToString:@"5"]){
            [dateFormatterr setDateFormat:@"dd/mm/yy"];
        }else if ([_strDateFormat isEqualToString:@"6"]){
            [dateFormatterr setDateFormat:@"dd/MM/yyyy"];
        }else if ([_strDateFormat isEqualToString:@"7"]){
            [dateFormatterr setDateFormat:@"mm/dd/yyyy"];
        }else if ([_strDateFormat isEqualToString:@"8"]){
            [dateFormatterr setDateFormat:@"dd/mm/yyyy"];
        }else{
            
            [dateFormatterr setDateFormat:@"MMddYYYY"];
        }
        //end of M.
       //***commented below for Bug-29662 By M.
       // NSDate *dt2 = [dateFormatterr dateFromString:strPrevSelectedValue]; //YYYYMMDD
        
        //***added below code of Edit for Bug-29662 By M.
        //+++++ changed code below for Bug-29790 and 29788 By M.
        NSArray *arrUserParameter = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"User_Parameters" andPredicate:nil andSortDescriptors:nil];
        for (NSInteger i = 0; i < arrUserParameter.count; i++) {
            NSManagedObject *managedObject = arrUserParameter[i];
           
            _strOutputDateFormat = [[managedObject valueForKey:@"up_date_settings_output_format"] stringValue];
            
        }
        NSDate *dt2;
        if(![_strFromEditPage isEqualToString:@"FromEdit"]){
            dt2 = [dateFormatterr dateFromString:strPrevSelectedValue];//YYYYMMDD
        }else{
            //+++++ changed code below for Bug-29790 and 29788 By M.
            NSString *str = [dictJson valueForKey:[dict valueForKey:@"dk"]];
            if(![str isEqualToString:@""]){
               
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                if ([_strDateFormat isEqualToString: @"1"]) {
                    // Extract the individual parts
                    NSArray *components = [str componentsSeparatedByString:@"\n"];
                    NSString *firstPart = components[0];
                    NSString *datePart = components[1];
                    
                    // Log the separated parts (Optional, for verification)
                    NSLog(@"First Part: %@", firstPart);
                    NSLog(@"Date Part: %@", datePart);
                    
                    // Date formatter to parse the original date string
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                    NSDate *date = [dateFormatter dateFromString:datePart];
                    
                    // Date formatter to convert date to the desired format
                    NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                    [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                    NSString *desiredDateString = [desiredDateFormatter stringFromDate:date];
                    dt2 = [desiredDateFormatter dateFromString:desiredDateString];
                    
                    
                }
                
                else if([_strDateFormat isEqualToString:@"6"]){
                    NSArray *components = [str componentsSeparatedByString:@"\n"];
                    // Extract the individual parts
                    NSString *firstPart = components[0];
                    NSString *datePart = components[1];
                    
                    // Log the separated parts (Optional, for verification)
                    NSLog(@"First Part: %@", firstPart);
                    NSLog(@"Date Part: %@", datePart);
                    
                    // Date formatter to parse the original date string
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                    NSDate *date = [dateFormatter dateFromString:datePart];
                    
                    // Date formatter to convert date to the desired format
                    NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                    [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                    NSString *desiredDateString = [desiredDateFormatter stringFromDate:date];
                    dt2 = [desiredDateFormatter dateFromString:desiredDateString];
                    
                }
                else if([_strDateFormat isEqualToString:@"3"] || [_strDateFormat isEqualToString:@"2"]){
                    
                    NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                    [inputdateFormatter setDateFormat:@"dd-MMM-yy"];
                    NSDate *inputDate = [inputdateFormatter dateFromString:str];
                    
                    NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                    NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                    dt2 = [outputDateFormatter dateFromString:outputDateString];
                }
                else if([_strDateFormat isEqualToString:@"4"]){
                    
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"MM/dd/yy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:str];
                    
                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                    
                    // Format the date to the desired output format
                    NSString *strtmp  = [outputDateFormatter stringFromDate:inputDate];
                    dt2 = [outputDateFormatter dateFromString:strtmp];
                }
                else if([_strDateFormat isEqualToString:@"5"]){
                    
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"dd/MM/yy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:str];
                    
                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                    
                    // Format the date to the desired output format
                    NSString *strtmp  = [outputDateFormatter stringFromDate:inputDate];
                    dt2 = [outputDateFormatter dateFromString:strtmp];
                }
                else if([_strDateFormat isEqualToString:@"8"]){
                    
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"dd/MM/yyyy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:str];
                    
                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                    
                    // Format the date to the desired output format
                    NSString *strtmp  = [outputDateFormatter stringFromDate:inputDate];
                    dt2 = [outputDateFormatter dateFromString:strtmp];
                }
                else if([_strDateFormat isEqualToString:@"7"]){
                    
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:str];
                    
                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                    
                    // Format the date to the desired output format
                    NSString *outputDateString  = [outputDateFormatter stringFromDate:inputDate];
                    dt2 = [outputDateFormatter dateFromString:outputDateString];
                }//else{
                   // dt2 = [dateFormatterr dateFromString:strPrevSelectedValue];
                //}
               
            }
        }//end of M.
        /*
        NSDate *dt2;
        if(![_strFromEditPage isEqualToString:@"FromEdit"]){
            dt2 = [dateFormatterr dateFromString:strPrevSelectedValue];//YYYYMMDD
        }else{
            if ([_strOutputDateFormat isEqualToString:@"dd-MMM-yy"]){
                
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
            
            }else if ([_strOutputDateFormat isEqualToString:@"MMM-dd-yy"]){
                
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
            }else if ([_strOutputDateFormat isEqualToString:@"M d yy"]){
                _strOutputDateFormat = @"mm/dd/yy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
            }else if ([_strOutputDateFormat isEqualToString:@"M d yyyy"]){
                _strOutputDateFormat = @"mm/dd/yyyy";
                
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
            }else if ([_strOutputDateFormat isEqualToString:@"MM dd yy"]){
                _strOutputDateFormat = @"mm/dd/yy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
            }else if ([_strOutputDateFormat isEqualToString:@"MM dd yyyy"]){
                _strOutputDateFormat = @"mm/dd/yyyy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
                
            }else if ([_strOutputDateFormat isEqualToString:@"D m yy"]){
                _strOutputDateFormat = @"dd/mm/yy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
                
            }else if ([_strOutputDateFormat isEqualToString:@"D m yyyy"]){
                _strOutputDateFormat = @"dd/mm/yyyy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
                
            }else if ([_strOutputDateFormat isEqualToString:@"DD mm yy"]){
                _strOutputDateFormat = @"dd/mm/yy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
                
            }else if ([_strOutputDateFormat isEqualToString:@"DD mm yyyy"]){
                _strOutputDateFormat = @"dd/mm/yyyy";
                NSString *strtmpDate = [dictJson valueForKey:[dict valueForKey:@"dk"]];
                
                NSDateFormatter* inputdateFormatter = [[NSDateFormatter alloc] init];
                
                [inputdateFormatter setDateFormat:_strOutputDateFormat];
                NSDate *inputDate = [inputdateFormatter dateFromString:strtmpDate];
                
                NSDateFormatter* outputDateFormatter = [[NSDateFormatter alloc] init];
                [outputDateFormatter setDateFormat:@"yyyyMMdd"];
                NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                dt2 = [outputDateFormatter dateFromString:outputDateString];
                
            }
                else if ([_strOutputDateFormat isEqualToString:@"DAYNUMBER"] || [_strOutputDateFormat isEqualToString:@"Day of Year Format"] ){
                
                if (![strPrevSelectedValue isEqualToString: @""]){
                    NSArray *components = [strPrevSelectedValue componentsSeparatedByString:@"\n"];
                    
                    // Extract the individual parts
                    NSString *firstPart = components[0];
                    NSString *datePart = components[1];
                    
                    // Log the separated parts (Optional, for verification)
                    NSLog(@"First Part: %@", firstPart);
                    NSLog(@"Date Part: %@", datePart);
                    
                    // Date formatter to parse the original date string
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                    NSDate *date = [dateFormatter dateFromString:datePart];
                    
                    // Date formatter to convert date to the desired format
                    NSDateFormatter *desiredDateFormatter = [[NSDateFormatter alloc] init];
                    [desiredDateFormatter setDateFormat:@"yyyyMMdd"];
                    NSString *desiredDateString = [desiredDateFormatter stringFromDate:date];
                    dt2 = [desiredDateFormatter dateFromString:desiredDateString];
                }
                
            }else{
                [dateFormatterr setDateFormat:@"MMddYYYY"];
                dt2 = [dateFormatterr dateFromString:strPrevSelectedValue];
            }
        }//end of M.
        */
        
        self.dtPicker= [[UIDatePicker alloc] init];
        self.dtPicker.frame = CGRectMake(15, 20, 250, 80.0);
       
       // self.dtPicker.transform = CGAffineTransformMake(0.8, 0, 0, 0.8, 80, 0);
        self.dtPicker.datePickerMode = UIDatePickerModeDate;
        if (@available(iOS 13.4, *)) {
            self.dtPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
           // self.dtPicker.datePickerMode = UIDatePickerModeDate;
            
        } else {
            // Fallback on earlier versions
        }
        self.dtPicker.contentMode = UIViewContentModeScaleAspectFit;
        
        if ([[dict valueForKey:@"dk"]integerValue]!=22) {
            
            self.dtPicker.maximumDate=[NSDate date];
            
            NSDateFormatter *dateFormatterrr = [[NSDateFormatter alloc]init];
            [dateFormatterrr setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [dateFormatterrr dateFromString:@"1/1/2034"];
            self.dtPicker.minimumDate = date;
        }else {
            
            NSDateFormatter *dateFormatterrr1 = [[NSDateFormatter alloc]init];
            [dateFormatterrr1 setDateFormat:@"MM/dd/yyyy"];
            NSDate *date1 = [dateFormatterrr1 dateFromString:@"1/1/2090"];
            self.dtPicker.maximumDate= date1;
            
            NSDateFormatter *dateFormatterrr = [[NSDateFormatter alloc]init];
            [dateFormatterrr setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [dateFormatterrr dateFromString:@"1/1/1990"];
            self.dtPicker.minimumDate = date;
        }
        
        //Adding this for Add forward Date change for wean,transfer events - Repro New Features
        if([strEventCode isEqualToString:@"12"] || [strEventCode isEqualToString:@"13"] || [strEventCode isEqualToString:@"28"] || [strEventCode isEqualToString:@"29"] || [strEventCode isEqualToString:@"30"] || [strEventCode isEqualToString:@"31"] || [strEventCode isEqualToString:@"44"]){
            
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDate *tomorrow = [cal dateByAddingUnit:NSCalendarUnitDay
                                               value:1
                                              toDate:[NSDate date]
                                             options:0];
            self.dtPicker.maximumDate= tomorrow;
        }
        
        
        if (strPrevSelectedValue.length>0) {
            [self.dtPicker setDate:dt2];
        }
        else{
            [self.dtPicker setDate:[NSDate date]];
        }
        
        //
//        NSDateFormatter *dateFormatterrr = [[NSDateFormatter alloc]init];
//        [dateFormatterrr setDateFormat:@"MM/dd/yyyy"];
//        NSDate *date = [dateFormatterrr dateFromString:@"1/1/2034"];
//        self.dtPicker.minimumDate = [NSDate date];
        //
        
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        
        _alertForPickUpDate = [[CustomIOS7AlertView alloc] init];
        [_alertForPickUpDate setMyDelegate:self];
        
        if ([strFromDataEntry isEqualToString:@"0"]) {
            if ([[dict valueForKey:@"ac"] integerValue]==1 && [[dict valueForKey:@"co"] integerValue]==1){
                [_alertForPickUpDate setButtonTitles:[NSMutableArray arrayWithObjects:strOk,strCancel, nil]];
            }else {
                [_alertForPickUpDate setButtonTitles:[NSMutableArray arrayWithObjects:strOk,strCancel,strClear, nil]];//
            }
        }else {
            [_alertForPickUpDate setButtonTitles:[NSMutableArray arrayWithObjects:strOk,strCancel,nil]];//yogita removed Clrbtn
        }
        
        _alertForPickUpDate.fromDynamic = @"Dynamic";
        
        [_alertForPickUpDate showCustomwithView:self.dtPicker title:strTitle];
        __weak typeof(self) weakSelf = self;
        
        [_alertForPickUpDate setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            if(buttonIndex == 0){
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"dd/MM/yyyy"];
                
                NSString *strSelectedDate = [formatter stringFromDate:weakSelf.dtPicker.date];
                NSString *strBaseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZD"];
                //***added code for Bug-27818 by M
                if ([[dict valueForKey:@"dk"] integerValue]==35){
                    [pref setObject:strSelectedDate forKey:@"PrevSelectedDate"];
                    [pref synchronize];
                    NSDate *currentDate = [NSDate date];
                    NSComparisonResult result = [currentDate compare:weakSelf.dtPicker.date];
                    if (result == NSOrderedDescending || result == NSOrderedSame){
                        NSLog(@"Date is within range");
                    }
                    else{
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                                          message:[self getTranslatedTextForString:@"You cannot enter future Date"]
                                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                               //** added Pigchamp logo on alert Bug-27920 by M.
                                               UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                                               logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                                               UIView *controllerView = myAlertController.view;
                                               [controllerView addSubview:logoImageView];
                                               [controllerView bringSubviewToFront:logoImageView];
                                               
                                              UIAlertAction* ok = [UIAlertAction
                                                                    actionWithTitle:strOk
                                                                    style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * action){
                                                   [myAlertController dismissViewControllerAnimated:YES completion:nil];
                                               }];

                                               [myAlertController addAction: ok];
                                               [self presentViewController:myAlertController animated:YES completion:nil];

                                                    return;
                    }
                }
                //*** end by M.
                NSDateFormatter* dateFormatterNew = [[NSDateFormatter alloc] init];
                //*** code changed dateformatter changed from dd-MM-yyyy to YYYY-MM-dd cause format required to sent to API --Bugnet No- 27974 by M.Start
                [dateFormatterNew setDateFormat:@"YYYY-MM-dd"];//,MMMM dd
              //    [dateFormatterNew setDateFormat:@"dd-MM-yyyy"];
                // code added by M. End
                //***condition of else added below for bug - 28889 By M.
                if ([[dict valueForKey:@"dk"] integerValue] == 2){
                            
                    strSelectedDateMMM = convertDateFormat(strSelectedDate);// add by sachin due to bug 30436
              //    strSelectedDateMMM = [dateFormatterNew stringFromDate:weakSelf.dtPicker.date];
                    strSelectedDateMMM = [strSelectedDateMMM stringByReplacingOccurrencesOfString:@"-"
                                                                                       withString:@""];
                    //***commented below line cause of duplication By M.
                    //[weakSelf.dictJson setValue:strSelectedDateMMM forKey:[dict valueForKey:@"dk"]];
                    [weakSelf.dictJson setValue:strSelectedDateMMM forKey:[dict valueForKey:@"dk"]];//change strSelectedDate to strSelectedDateMMM
                }
                //***code below added for bug - 28889 By M.
                else{
                    strSelectedDateOTH = [dateFormatterNew stringFromDate:weakSelf.dtPicker.date];
                    strSelectedDateOTH = [strSelectedDateOTH stringByReplacingOccurrencesOfString:@"-"
                                                                                       withString:@""];
                    
                    [weakSelf.dictJson setValue:strSelectedDateOTH forKey:[dict valueForKey:@"dk"]];//change
                }
                if (isThousandFormat) {
                    NSString *strBaseDate = [pref valueForKey:@"ZD"];
                    [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
                    NSString *strSelectedDate = [dateFormatterr stringFromDate:weakSelf.dtPicker.date]; // add by sachin due to bug 30436
                    NSDate *dtselectedDate = [dateFormatterr dateFromString:strSelectedDate];
                    [dateFormatterr setDateFormat:@"YYYYMMdd"];
                    NSDate *BaseDate = [dateFormatterr dateFromString:strBaseDate];
                    int days = [dtselectedDate timeIntervalSinceDate:BaseDate]/24/60/60;
                    
                    NSString *strDate = [NSString stringWithFormat:@"%05d",days];
                    NSString *calFormat,*strFromString;
                    
                    if (strDate.length>=2) {
                        calFormat = [strDate substringToIndex:2];
                    }else{
                        calFormat = strDate;
                    }
                    
                    if (strDate.length>=3){
                        strFromString = [strDate substringFromIndex:2];
                    }
                    
                    calFormat = [[calFormat stringByAppendingString:@"-"] stringByAppendingString:strFromString?strFromString:@""];
                    [dateFormatterr setDateFormat:@"EEE,dd-MMM-yyyy"];
                    
                    NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[dateFormatterr stringFromDate:dtselectedDate]];
                    [_dictDynamic setValue:strSelectedDate100 forKey:[dict valueForKey:@"Lb"]];
                    
                }//*** changed below code for strDateFormat due to User_Paramters APi changes By M.
                //else if([weakSelf.strDateFormat isEqualToString:@"6"]){
                else if([_strDateFormat isEqualToString:@"6"]){
                    [formatter setDateFormat:@"dd/MM/yyyy"];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                    NSDate *dtselectedDate = [formatter dateFromString:strSelectedDate];
                    NSDate *Firstdate= [weakSelf getFirstDateOfCurrentYear:dtselectedDate];
                    
//                    // demo code
//                    //
//                            [formatter setDateFormat:@"MM/dd/yyyy"];
//                            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
//                            // Convert string to NSDate
//                            NSDate *dtSelectedDates = [formatter dateFromString:strSelectedDate];
//                     
//                                NSLog(@"Converted date: %@", dtSelectedDates);
//                                [formatter setDateFormat:@"dd/MM/yyyy"];
//                                NSString *dtselectedDate = [formatter stringFromDate:dtSelectedDates];
//                                NSLog(@"Formatted date string: %@", dtselectedDate);
//                            
//                    NSDate *Firstdate= [weakSelf getFirstDateOfCurrentYear:dtselectedDate];
//                    //
                    
                    
                    
                    
                    // NSDate *BaseDate = [formatter dateFromString:strBaseDate];
                    //int days = [dtselectedDate timeIntervalSinceDate:Firstdate]/24/60/60;
                    // NSLog(@"days:%d",days);
                    NSInteger days=[weakSelf daysBetweenDate:Firstdate andDate:dtselectedDate];
                    
                    NSLog(@"days:%ld",days);
                    
                    NSString *strDate = [NSString stringWithFormat:@"%03li",days];
                    [formatter setDateFormat:@"yy"];
                    
                    NSString *strSelectedDateyearformat = [[[formatter stringFromDate:dtselectedDate] stringByAppendingString:@"-"] stringByAppendingString:strDate];
                    
                    /*********************/
                    [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                    
                    /***************/
                    
                    NSString *strSelectedDateDayOFYear = [[strSelectedDateyearformat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
                    
                    /*****************/
                    
                    
                    /*[weakSelf.dictDynamic setValue:strSelectedDateyearformat forKey:[dict valueForKey:@"Lb"]];*/
                    [weakSelf.dictDynamic setValue:strSelectedDateDayOFYear forKey:[dict valueForKey:@"Lb"]];
                   //*** codition added for response of User_Params API for Bug-27782 By M.
                }else if([_strDateFormat isEqualToString:@"3"]){
                    
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDate];

                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"dd-MMM-yy"];

                    // Format the date to the desired output format
                    NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                    [weakSelf.dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    //*** codition added for response of User_Params API for Bug-27782 By M.
                }else if([_strDateFormat isEqualToString:@"4"]){
                    //4 = mm/dd/yy        e.g. 10/09/23
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                  //  [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                    //issue here 30218 V10
                      [inputDateFormatter setDateFormat:@"dd/MM/yyyy"]; //changed due to bug 30218

                    NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDate];
                    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
                    [dateFormatters setDateFormat:@"dd/MM/yyyy"];
                    NSDate *date  = [dateFormatters dateFromString:strSelectedDate];
                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"MM/dd/yy"];

                    // Format the date to the desired output format
                    NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                    [weakSelf.dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    //*** codition added for response of User_Params API for Bug-27782 By M.
                }else if([_strDateFormat isEqualToString:@"5"]){
                    //5 = dd/mm/yy        e.g. 09/10/23
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                 //   [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                    [inputDateFormatter setDateFormat:@"dd/MM/yyyy"]; // format changed due to date format issue bug 30218
                    NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDate];

                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"dd/MM/yy"];

                    // Format the date to the desired output format
                    NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                    [weakSelf.dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    //*** codition added for response of User_Params API for Bug-27782 By M.
                }else if([_strDateFormat isEqualToString:@"8"]){
                    //8 = dd/mm/yyyy        e.g. 09/10/2023
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDate];

                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"dd/MM/yyyy"];

                    // Format the date to the desired output format
                    NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                    [weakSelf.dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                }//***condition cause the 7 date format was not considered by M.
                /*else if([_strDateFormat isEqualToString:@"7"] || [_strDateFormat isEqualToString:@"2"]){
                    //7 = mm/dd/yyyy        e.g. 10/09/2023
                    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                    [inputDateFormatter setDateFormat:@"MM/dd/yyyy"];
                    NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDate];

                    // Create a date formatter for the desired output format
                    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                    [outputDateFormatter setDateFormat:@"MM/dd/yyyy"];

                    // Format the date to the desired output format
                    NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                    [weakSelf.dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                }*/
                else {
                    [weakSelf.dictDynamic setValue:strSelectedDate forKey:[dict valueForKey:@"Lb"]];
                }
            }else if(buttonIndex == 2){
                [weakSelf.dictJson setValue:@"" forKey:[dict valueForKey:@"dk"]];
                [weakSelf.dictDynamic setValue:@"" forKey:[dict valueForKey:@"Lb"]];
            }
            
            NSLog(@"buttonIndex=%d",buttonIndex);
            NSLog(@"dictjson=%@",weakSelf.dictJson);
            //***code added for Bug-28565 By M.
            isDateSelected = TRUE;
            [weakSelf.tblDynamic reloadData];
           
            [alertView close];
        }];
        
        [weakSelf.alertForPickUpDate setUseMotionEffects:true];
      
    }
    @catch (NSException *exception) {
        NSLog(@"Exception =%@",exception.description);
    }
}
-(NSString*)daysBetweenDateForThousand:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    @try{
        NSDate *fromDate;
        NSDate *toDate;
        NSString *formatted = @"";
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        
        unsigned long miliSecondForDate1=  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                     interval:NULL forDate:fromDateTime] * 1000;
        unsigned long miliSecondForDate2 = [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                     interval:NULL forDate:toDateTime] * 1000;
   
          unsigned long diffInMilis = miliSecondForDate1 - miliSecondForDate2;
          NSInteger diffInDays = diffInMilis / (24 * 60 * 60 * 1000);

          if (diffInDays >= 0) {
              formatted = [NSString stringWithFormat:@"%05ld", (long)diffInDays];
              NSMutableString *buffer = [formatted mutableCopy];
              [buffer insertString:@"-" atIndex:2];
              formatted = [buffer copy];
          }

          NSLog(@"Formatted Date Difference: %@", formatted);

          return formatted;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception in fillDefaultValuesForMandatoryFields=%@",exception.description);
    }
}
-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    @try{
        NSDate *fromDate;
        NSDate *toDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
        
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

-(void)fillDefaultValuesForMandatoryFields {
    @try {
        NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
        NSString *strFromDataEntry = [pref valueForKey:@"FromDataEntry"];
        
        __block NSDictionary *dictBarnData,*dictForBarnRoomPen;
        for (NSMutableDictionary *dict  in _arrDynamic){
            NSLog(@"compuslary=%@",dict);
            
            NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]];
            NSLog(@"compuslary=%@",[dict valueForKey:@"co"]);
            NSLog(@"strDataType=%@",strDataType);
            
            if([[dict valueForKey:@"dk"] integerValue] == 6){
                dictForBarnRoomPen = dict;
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key integerValue]==6){
                        dictBarnData = obj;
                    }
                }];
            }
            else if ([strDataType isEqualToString:@"DropDown"]){
                [self fillDropDn:0 dict:dict];
            }
            else if ([strDataType isEqualToString:@"Date"] && [[dict valueForKey:@"dk"] integerValue]==2){
                //***code added below with if condition and keep all other logic of dateformat in else for Bug-28446 and 28145 By M.
                if (dateDelFlg){
                    [_dictDynamic setValue:dateDeliveredValue forKey:[dict valueForKey:@"Lb"]];
                    [dictJson setValue:dateDeliveredValue forKey:[dict valueForKey:@"dk"]];
                }
                else{
                    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                    
                    NSDateFormatter *dateFormatterr = [[NSDateFormatter alloc]init] ;
                    [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
                    
                    NSString *prevDate=[pref valueForKey:@"PrevSelectedDate"];
                    NSString *strSelectedDate;
                    NSString *strSelectedDatee;
                    
                    // prevDate=@"24/4/2017";
                    
                    if (prevDate.length==0) {
                        strSelectedDate = [dateFormatterr stringFromDate:[NSDate date]];
                    }else{
                        strSelectedDate = prevDate;
                    }
                    //SDate *dt2=[NSDate date];;
                    [dateFormatterr setDateFormat:@"YYYYMMdd"];
                    if (prevDate.length==0) {
                        [dateFormatterr setDateFormat:@"dd/MM/yyyy"];
                      //  strSelectedDatee = [dateFormatterr stringFromDate:[NSDate date]];
                        strSelectedDatee = convertDateFormat([dateFormatterr stringFromDate:[NSDate date]]); // change due to wrong date (bug 30436), change by sachin
                        // dt2=[NSDate date];
                    }else{
                        [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
                        NSDate *dt2 = [dateFormatterr dateFromString:prevDate];
                        [dateFormatterr setDateFormat:@"YYYYMMdd"];
                        strSelectedDatee = [dateFormatterr stringFromDate:dt2];
                    }
                    
                    [dictJson setValue:strSelectedDatee forKey:[dict valueForKey:@"dk"]];
                    
                    if (isThousandFormat) {
                        NSString *strBaseDate = [pref valueForKey:@"ZD"];
                        [dateFormatterr setDateFormat:@"MM/dd/yyyy"];
                        NSDate *dtselectedDate = [dateFormatterr dateFromString:strSelectedDate];
                        [dateFormatterr setDateFormat:@"YYYYMMdd"];
                        NSDate *BaseDate = [dateFormatterr dateFromString:strBaseDate];
                        int days = [dtselectedDate timeIntervalSinceDate:BaseDate]/24/60/60;
                        
                        NSString *strDate = [NSString stringWithFormat:@"%05d",days];
                        NSString *calFormat,*strFromString;
                        
                        if (strDate.length>=2) {
                            calFormat = [strDate substringToIndex:2];
                        }else{
                            calFormat = strDate;
                        }
                        
                        if (strDate.length>=3){
                            strFromString = [strDate substringFromIndex:2];
                        }
                        
                        calFormat = [[calFormat stringByAppendingString:@"-"] stringByAppendingString:strFromString?strFromString:@""];
                        [dateFormatterr setDateFormat:@"EEE,dd-MMM-yyyy"];
                        
                        NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[dateFormatterr stringFromDate:dtselectedDate]];
                        [_dictDynamic setValue:strSelectedDate100 forKey:[dict valueForKey:@"Lb"]];
                        //*** changed below code for strDateFormat due to User_Paramters APi changes By M.
                        //}else if([self.strDateFormat isEqualToString:@"6"]){
                    }else if([_strDateFormat isEqualToString:@"6"]){
                        // NSString *strBaseDate = [pref valueForKey:@"ZD"];
                        [dateFormatterr setDateFormat:@"YYYYMMdd"];
                        [dateFormatterr setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                        
                        //  [dateFormatterr setTimeZone:[NSTimeZone defaultTimeZone]];
                        NSDate *dtselectedDate = [dateFormatterr dateFromString:strSelectedDatee];
                        NSDate *Firstdate= [self getFirstDateOfCurrentYear:dtselectedDate];
                        // NSTimeZone *tz = [NSTimeZone defaultTimeZone];
                        //[dateFormatterr setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                        
                        NSInteger days=[self daysBetweenDate:Firstdate andDate:dtselectedDate];
                        NSLog(@"days:%ld",days);
                        
                        NSString *strDate = [NSString stringWithFormat:@"%03li",days];
                        [dateFormatterr setDateFormat:@"yy"];
                        NSString *strSelectedDateyearformat = [[[dateFormatterr stringFromDate:dtselectedDate] stringByAppendingString:@"-"] stringByAppendingString:strDate];
                        [dateFormatterr setDateFormat:@"EEE,dd-MMM-yyyy"];
                        
                        /***************/
                        
                        NSString *strSelectedDateDayOFYear = [[strSelectedDateyearformat stringByAppendingString:@"\n"] stringByAppendingString:[dateFormatterr stringFromDate:dtselectedDate]];
    //********
                        /*****************/
                        
                        // NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[dateFormatterr stringFromDate:dtselectedDate]];6
                        //[_dictDynamic setValue:strSelectedDateyearformat forKey:[dict valueForKey:@"Lb"]];
                        [_dictDynamic setValue:strSelectedDateDayOFYear forKey:[dict valueForKey:@"Lb"]];
                    }
                    //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                    else if([_strDateFormat isEqualToString:@"3"]){
                        
                        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                        [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                        NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDatee];
                        
                        // Create a date formatter for the desired output format
                        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                        [outputDateFormatter setDateFormat:@"dd-MMM-yy"];
                        
                        // Format the date to the desired output format
                        NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                        [_dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                    else if([_strDateFormat isEqualToString:@"4"]){
                        
                        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                        [inputDateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDatee];
                        
                        // Create a date formatter for the desired output format
                        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                        [outputDateFormatter setDateFormat:@"MM/dd/yy"];
                        
                        // Format the date to the desired output format
                        NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                        [_dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                    else if([_strDateFormat isEqualToString:@"5"]){
                        
                        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                        inputDateFormatter.timeZone = [NSTimeZone localTimeZone];
                        [inputDateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDatee];
                        
                        // Create a date formatter for the desired output format
                        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                        [outputDateFormatter setDateFormat:@"dd/MM/yy"];
                        
                        // Format the date to the desired output format
                        NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                        [_dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                    else if([_strDateFormat isEqualToString:@"8"]){
                        
                        NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                        [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                        NSDate *inputDate = [inputDateFormatter dateFromString:strSelectedDatee];
                        
                        // Create a date formatter for the desired output format
                        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                        [outputDateFormatter setDateFormat:@"dd/MM/yyyy"];
                        
                        // Format the date to the desired output format
                        NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                        [_dictDynamic setValue:outputDateString forKey:[dict valueForKey:@"Lb"]];
                    }
                    else{
                        
                        [_dictDynamic setValue:strSelectedDate forKey:[dict valueForKey:@"Lb"]];
                    }
                }
            }
            else if ([strDataType isEqualToString:@"TextField"] && [strFromDataEntry isEqualToString:@"0"]){
                if (strEventCode.integerValue == 26){
                    if ([[dict valueForKey:@"dk"] integerValue]==15 ||[[dict valueForKey:@"dk"] integerValue]==18 ||[[dict valueForKey:@"dk"] integerValue]==19 ||[[dict valueForKey:@"dk"] integerValue]==153) {
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        
                        //For setting default value 0
                        if ([[dict valueForKey:@"dk"] integerValue]==15 && [self isTwoText]){
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"0" forKey:@"Male"];
                            [dictText setValue:@"0" forKey:@"Female"];
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }
                    }//15,18,19,153 = 0 ...-Farrowing
                    else if ([[dict valueForKey:@"dk"] integerValue]==169){ // add by sachin due to bug 30218 set defalult value
                        NSMutableDictionary *mutableDict = [[dictJson valueForKey:@"169"] mutableCopy];
                        [mutableDict setValue:@"Barrow" forKey:@"37"];
                        [mutableDict setValue:@"BBwrk - Black Berkshire" forKey:@"43"];
                        [mutableDict setValue:@"FP - Final Product" forKey:@"44"];
                        [dictJson setObject:mutableDict forKey:@"169"];
                    }
                }else if(strEventCode.integerValue ==27){
                    if ([[dict valueForKey:@"dk"] integerValue]==3) {
                        if ([self isTwoText]){
                            [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"0" forKey:@"Male"];
                            [dictText setValue:@"0" forKey:@"Female"];
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }else{
                            [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                        }
                    }//3 = 1 Fostering
                }else if(strEventCode.integerValue ==28 || strEventCode.integerValue ==29){
                    if ([[dict valueForKey:@"dk"] integerValue]==51 || [[dict valueForKey:@"dk"] integerValue]==54){
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        //For setting default value 0
                        if ([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]){
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"0" forKey:@"Male"];
                            [dictText setValue:@"0" forKey:@"Female"];
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }
                    }//51 = 0 part weaning, complete weaning
                }else if(strEventCode.integerValue ==30){
                    if ([[dict valueForKey:@"dk"] integerValue]==3){
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"0" forKey:[dict valueForKey:@"dk"]];
                    }//3 = 1 Batch weaning
                    //***condition added below for default value Bug-28761 By M.
                    if ([[dict valueForKey:@"dk"] integerValue]==51){
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"0" forKey:[dict valueForKey:@"dk"]];
                    }
                    //For setting default value 0
                    // |||| added for fostered 57 for Bug-29732 By M.
                    if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
                        NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                        [dictText setValue:@"0" forKey:@"Male"];
                        [dictText setValue:@"0" forKey:@"Female"];
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                    }//3 = 1 Batch weaning
                }else if(strEventCode.integerValue ==31){
                   // if ([[dict valueForKey:@"dk"] integerValue]==54){
                        //***condition changed below for Bug-28575 By M.
                    if ([[dict valueForKey:@"dk"] integerValue]==51 || [[dict valueForKey:@"dk"] integerValue]==54 || [[dict valueForKey:@"dk"] integerValue]==58){
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"0" forKey:[dict valueForKey:@"dk"]];
                    }//changed below default value from 1 to 0 below code for Bug-29666 by M.
                    else if ([[dict valueForKey:@"dk"] integerValue]==57){
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"0" forKey:[dict valueForKey:@"dk"]];
                    }
                    
                    //51 = 0,57 = 1 Nurse sow wean
                    
                    //***added below condition for Avg.Piglet Age default to 0 Bug- 28603
                    else if ([[dict valueForKey:@"dk"] integerValue]==58){
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"0" forKey:[dict valueForKey:@"dk"]];
                    }
                    //For setting default value 0
                    // |||| added for fostered 57 for Bug-29732 By M.
                    if (([[dict valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[dict valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
                        NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                        [dictText setValue:@"0" forKey:@"Male"];
                        [dictText setValue:@"0" forKey:@"Female"];
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                    }//51 = 0,57 = 1 Nurse sow wean
                }
                /*else if(strEventCode.integerValue ==32){//3=1 piglet death
                    if ([[dict valueForKey:@"dk"] integerValue]==3){
                        [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                    }
                    
                    //For setting default value 0
                    if ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText]){
                        NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                        [dictText setValue:@"0" forKey:@"Male"];
                        [dictText setValue:@"0" forKey:@"Female"];
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                    }
                }else if(strEventCode.integerValue ==35){//3=1 piglet treatment
                    if ([[dict valueForKey:@"dk"] integerValue]==3){
                        [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                    }
                    
                    //For setting default value 0
                    if ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText]){
                        NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                        [dictText setValue:@"0" forKey:@"Male"];
                        [dictText setValue:@"0" forKey:@"Female"];
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                    }
                }*/
                //***commented above and added below condition for Bug-27775 By M @@@@@
                else if(strEventCode.integerValue ==32){//3=1 piglet death
                    //For setting default value 0
                    if ([[dict valueForKey:@"dk"] integerValue]==3) {
                        if ([self isTwoText]){
                            [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                            
                            NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                            [dictText setValue:@"0" forKey:@"Male"];
                            [dictText setValue:@"0" forKey:@"Female"];
                            [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        }else{
                            [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                            [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                        }
                    }
                    
                }else if(strEventCode.integerValue ==35){//3=1 piglet treatment
                    //For setting default value 0
                    if ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText]){
                        NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                        [dictText setValue:@"0" forKey:@"Male"];
                        [dictText setValue:@"0" forKey:@"Female"];
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                    } else if ([[dict valueForKey:@"dk"] integerValue]==3){
                        [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                    }
                    
                    
                }
                else if(strEventCode.integerValue ==6){
                    if ([[dict valueForKey:@"dk"] integerValue]==42){
                        [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                    }
                }//***condition added for Bug-28761 By M.
               /* else if(strEventCode.integerValue ==47){
                    if ([[dict valueForKey:@"dk"] integerValue]==3){
                        [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                    }
                }*/
                //*** added below code for Bug-27775 By M @@@@@
                else if(strEventCode.integerValue ==47){
                    if ([[dict valueForKey:@"dk"] integerValue]==3 && [self isTwoText]){
                        NSMutableDictionary *dictText = [[NSMutableDictionary alloc]init];
                        [dictText setValue:@"0" forKey:@"Male"];
                        [dictText setValue:@"0" forKey:@"Female"];
                        [dictJson setObject:dictText forKey:[dict valueForKey:@"dk"]];
                        [_dictDynamic setValue:@"0" forKey:[dict valueForKey:@"Lb"]];
                    }
                    //@@@@@ added for Splitsex By M.
                    else if ([[dict valueForKey:@"dk"] integerValue]==3){
                        [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                        [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
                    }
                }
                else if(strEventCode.integerValue == 19){
                    if ([[dict valueForKey:@"dk"] integerValue]==12){
                        if (flag == 1){
//                            NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
//                            [dictJson setValue:[dictJSON valueForKey:@"12"] forKey:@"12"];
                            
                            NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                            NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                            [dictJson setValue:[dictJSON valueForKey:@"12"] forKey:[dict valueForKey:@"dk"]];
                            [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                        }
                    }
                }
                                
                
                // NSLog(@"strEventCode=%@",strEventCode);
            }else if ([[dict valueForKey:@"dk"] integerValue]==42){
                [_dictDynamic setValue:@"1" forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:@"1" forKey:[dict valueForKey:@"dk"]];
            }else if ([[dict valueForKey:@"dk"] integerValue]==169){    //~~~~ added for Piglet Identities By M.
                [_dictDynamic setValue:pigletIdentityDict forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:pigletIdentityJsonDict forKey:[dict valueForKey:@"dk"]];
            }
        }
        
        //        if (dictForBarnRoomPen!=nil) {
        //            NSString *strDataType  = [self getViewType:[dictForBarnRoomPen valueForKey:@"dt"]];
        //            if ([strDataType isEqualToString:@"DropDown"]){
        //                // NSArray *arrKeys = [dictBarnData allKeys];
        //                __block NSString *strKey,*strBarn,*strRoom;
        //
        //                //[dictForBarnRoomPen setValue:@"1" forKey:@"co"];
        //                [dictBarnData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        //                    if ([key isEqualToString:@"br"]){
        //                        strBarn = obj?obj:@"";
        //                        strKey =@"br";
        //                    }
        //                    else if ([key isEqualToString:@"rm"]) {
        //                        strRoom = obj?obj:@"";
        //                        strKey =@"rm";
        //                    }
        //                }];
        //
        //                if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strBarn.length==0 && strBarn!=nil){
        //                    [self fillDropDn:2 dict:dictForBarnRoomPen];
        //                }
        //
        //                if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strRoom.length==0 && strRoom!=nil){
        //                    [self fillDropDn:3 dict:dictForBarnRoomPen];
        //                }
        //            }
        //        }
        
        //Changed on 21st Oct 20 For maintaining last selected value of Locations
        
        if (flag == 1){
            NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
            [dictJson setValue:[dictJSON valueForKey:@"6"] forKey:@"6"];
        }
        else{
            if (dictForBarnRoomPen!=nil) {
                NSString *strDataType  = [self getViewType:[dictForBarnRoomPen valueForKey:@"dt"]];
                if ([strDataType isEqualToString:@"DropDown"]){
                    // NSArray *arrKeys = [dictBarnData allKeys];
                    __block NSString *strKey,*strBarn,*strRoom;
                    
                    //[dictForBarnRoomPen setValue:@"1" forKey:@"co"];
                    [dictBarnData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key isEqualToString:@"br"]){
                            strBarn = obj?obj:@"";
                            strKey =@"br";
                        }
                        else if ([key isEqualToString:@"rm"]) {
                            strRoom = obj?obj:@"";
                            strKey =@"rm";
                        }
                    }];
                    
                    if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strBarn.length==0 && strBarn!=nil){
                        [self fillDropDn:2 dict:dictForBarnRoomPen];
                    }
                    
                    if ([[dictForBarnRoomPen valueForKey:@"co"] isEqualToString:@"1"] && strRoom.length==0 && strRoom!=nil){
                        [self fillDropDn:3 dict:dictForBarnRoomPen];
                    }
                }
            }
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception in fillDefaultValuesForMandatoryFields=%@",exception.description);
    }
}

-(NSDate *)getFirstDateOfCurrentYear:(NSDate*)selecteddate
{
    //Get current year
    //NSDate *currentYear=[[NSDate alloc]init];
    // currentYear=selecteddate
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    [formatter1 setDateFormat:@"yyyy"];
    NSString *currentYearString = [formatter1 stringFromDate:selecteddate];
    // [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
    //Get first date of current year
    NSString *firstDateString=[NSString stringWithFormat:@"10 01-01-%@",currentYearString];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"hh dd-MM-yyyy"];
    
    NSDate *firstDate = [[NSDate alloc]init];
    firstDate = [formatter2 dateFromString:firstDateString];
    
    NSLog(@"firstDate=%@",firstDate);
    
    return firstDate;
}

-(void)fillDropDn:(NSInteger)tag dict:(NSDictionary*)dict
{
    @try {
        [_arrDropDown removeAllObjects];
        NSSortDescriptor *sortBy;
        NSArray *sortDescriptors;
        
        NSString *strPrevSelectedValue= [dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@"";
        NSInteger prevSelectedIndex  = 0;
        
        switch ([[dict valueForKey:@"dk"]integerValue]) {
            case 4:{
                //Added this if loop bcz all conditions dropdowns getting blank bcz dk=4//
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"4"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSString *strPredicate;
                    //*** code changed below cause API response changed for key from Bool to string Bug-28302 and 28307 By M.
                    /*
                    if ([strEventCode isEqualToString:@"33"]||[strEventCode isEqualToString:@"48"]) {
                        strPredicate = @"br != 0 AND tr==1";
                    }
                    else if ([strEventCode isEqualToString:@"34"]||[strEventCode isEqualToString:@"49"]) {
                        strPredicate = @"(sg != 0 OR sp != 0 or sd != 0 ) AND tr==1";
                    }
                    else if ([strEventCode isEqualToString:@"35"]) {
                        strPredicate = @"pg != 0 AND tr==1";
                    }
                    else if ([strEventCode isEqualToString:@"10"]||[strEventCode isEqualToString:@"12"]) {
                        strPredicate = @"br != 0 AND ds==1";
                    }
                    else if ([strEventCode isEqualToString:@"11"]||[strEventCode isEqualToString:@"13"]) {
                        strPredicate = @"(sg != 0 OR sp != 0 or sd != 0 ) AND ds==1";
                    }
                    else if ([strEventCode isEqualToString:@"32"]) {
                        strPredicate = @"pg != 0 AND ds==1";
                    }*/
                    if ([strEventCode isEqualToString:@"33"]||[strEventCode isEqualToString:@"48"]) {
                        strPredicate = @"br != 'false' AND tr == 'true'";// @"br != 0 AND tr == 1";
                    }
                    else if ([strEventCode isEqualToString:@"34"]||[strEventCode isEqualToString:@"49"]) {
                        strPredicate =@"(sg != 'false' OR sp != 'false' OR sd != 'false') AND tr == 'true'";//@"(sg != 0 OR sp != 0 OR sd != 0 ) AND tr == 1";
                    }
                    else if ([strEventCode isEqualToString:@"35"]) {
                        strPredicate =  @"pg != 'false' AND tr == 'true'";//@"pg != 0 AND tr == 1";
                    }
                    else if ([strEventCode isEqualToString:@"10"]||[strEventCode isEqualToString:@"12"]) {
                        strPredicate =  @"br != 'false' AND ds == 'true'";//@"br != 0 AND ds == 1";
                    }
                    else if ([strEventCode isEqualToString:@"11"]||[strEventCode isEqualToString:@"13"]) {
                        //strPredicate = @"(sg != 0 OR sp != 0 OR sd != 0 ) AND ds==1";
                        strPredicate = @"(sg != 'false' OR sp != 'false' OR sd != 'false') AND ds == 'true'";//@"(sg != 0 || sp != 0 || sd != 0) && ds == 1";

                    }
                    else if ([strEventCode isEqualToString:@"32"]) {
                        strPredicate = @"pg != 'false' AND ds == 'true'";//@"pg != 0 AND ds == 1";
                    }
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:strPredicate];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Conditions" andPredicate:predicate andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 6:{
                //For maintaining last selected value of Genetics
                if (flag == 1){
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    // NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"6"] forKey:[dict valueForKey:@"dk"]];
                    // [_dictDynamic setValue:[dictDictDynamic valueForKey:@"Loss Reason"] forKey:@"Loss Reason"];
                }
                else{
                    __block NSMutableDictionary *dictBarnDataToSend;
                    
                    [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                     {
                        if ([key isEqualToString:@"6"])
                        {
                            dictBarnDataToSend = obj;
                        }
                    }];
                    
                    __block NSString *strBarn;
                    __block NSString *strRoom;
                    
                    [dictBarnDataToSend enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                        if ([key isEqualToString:@"br"]){
                            strBarn = obj;
                        }
                        else if ([key isEqualToString:@"rm"]) {
                            strRoom = obj;
                        }
                    }];
                    
                    NSPredicate *predicate;
                    NSArray* resultArray ;
                    if (tag==2){
                        predicate  = [NSPredicate predicateWithFormat:@"id=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                        sortBy = [[NSSortDescriptor alloc] initWithKey:@"br" ascending:YES];
                        
                    }else if (tag==3){
                        predicate  = [NSPredicate predicateWithFormat:@"br=%@ AND id=%@",strBarn,[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                        sortBy = [[NSSortDescriptor alloc] initWithKey:@"rm" ascending:YES];
                        
                    }else if (tag==4){
                        predicate  = [NSPredicate predicateWithFormat:@"br = %@ AND rm = %@ AND id=%@",strBarn, strRoom,[[NSUserDefaults standardUserDefaults] objectForKey:@"id"]];
                        //  strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictBarnDataToSend valueForKey:@"pen"]?[dictBarnDataToSend valueForKey:@"pen"]:@""];
                        sortBy = [[NSSortDescriptor alloc] initWithKey:@"pn" ascending:YES];
                    }
                    
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Locations" andPredicate:predicate andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        if (tag==2){
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"br"] forKey:@"visible"];
                        }else if (tag==3)
                        {
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"rm"] forKey:@"visible"];
                        }
                        else if(tag==4){
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"pn"] forKey:@"visible"];
                        }
                        
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0){
                            if ([strPrevSelectedValue isEqualToString:[dict valueForKey:@"visible"]]){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                    NSLog(@"_arrDropDown=%@",_arrDropDown);
                }
            }
                break;
            case 8:{//***code - valueforkey is changed from capital to small letters for Bug-27764 By M.
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"8"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Pd_Results" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++)  {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 9:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"9"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ln != null"];
                    
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Operator" andPredicate:predicate andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++)
                    {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue]){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 11:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"11"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Treatments" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++)
                    {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 13:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"13"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Tod" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0){
                            if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 23: {
                
                //For maintaining last selected value of Genetics
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"23"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    
                    NSArray* resultArray;
                    NSPredicate *predicate;
                    if ([self.strEventCode isEqualToString:@"1"] || [self.strEventCode isEqualToString:@"2"]) {
                        predicate = [NSPredicate predicateWithFormat:@"sx == 'M' OR sx == '' OR sx == null"];
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Genetics" andPredicate:predicate andSortDescriptors:sortDescriptors];
                    }
                    else if ([self.strEventCode isEqualToString:@"4"] || [self.strEventCode isEqualToString:@"5"] || [self.strEventCode isEqualToString:@"8"]||[self.strEventCode isEqualToString:@"6"] || [self.strEventCode isEqualToString:@"113"]){
                        predicate = [NSPredicate predicateWithFormat:@"sx == 'F' OR sx == '' OR sx == null"];
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Genetics" andPredicate:predicate andSortDescriptors:sortDescriptors];
                    }
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 34:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"34"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    if ([self.strEventCode isEqualToString:@"1"]){
                        sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                        sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"AI_STUDS" andPredicate:nil andSortDescriptors:sortDescriptors];
                        for (int count=0; count<resultArray.count; count++){
                            NSDictionary *dict = [[NSMutableDictionary alloc]init];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict];
                            
                            if (strPrevSelectedValue.length>0)
                            {
                                if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                                {
                                    prevSelectedIndex = count;
                                }
                            }
                        }
                    }
                    else {
                        strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                        sortBy = [[NSSortDescriptor alloc] initWithKey:@"ds" ascending:YES];
                        sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Origin" andPredicate:nil andSortDescriptors:sortDescriptors];
                        for (int count=0; count<resultArray.count; count++) {
                            NSDictionary *dict = [[NSMutableDictionary alloc]init];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ds"] forKey:@"visible"];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"sid"] forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict];
                            
                            NSLog(@"site key=%@",[[resultArray objectAtIndex:count] valueForKey:@"sid"]);
                            
                            if (strPrevSelectedValue.length>0)
                            {
                                if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"sid"] integerValue])
                                {
                                    prevSelectedIndex = count;
                                }
                            }
                            
                        }
                    }
                }
            }
                break;
            case 37:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"37"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Halothane" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 62:{
                //For maintaining last selected value of Destination
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"62"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray;
                    if ([self.strEventCode isEqualToString:@"12"] || [self.strEventCode isEqualToString:@"13"]||[self.strEventCode isEqualToString:@"29"] ||[self.strEventCode isEqualToString:@"30"] || [self.strEventCode isEqualToString:@"31"]){
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Packing_Plants" andPredicate:nil andSortDescriptors:sortDescriptors];
                        for (int count=0; count<resultArray.count; count++){
                            NSDictionary *dict = [[NSMutableDictionary alloc]init];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict];
                            if (strPrevSelectedValue.length>0)
                            {
                                if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                                {
                                    prevSelectedIndex = count;
                                }
                            }
                        }
                    }
                    else{
                        sortBy = [[NSSortDescriptor alloc] initWithKey:@"ds" ascending:YES];
                        sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Destination" andPredicate:nil andSortDescriptors:sortDescriptors];
                        for (int count=0; count<resultArray.count; count++){
                            NSDictionary *dict = [[NSMutableDictionary alloc]init];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ds"] forKey:@"visible"];
                            [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"sid"] forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict];
                            
                            if (strPrevSelectedValue.length>0)
                            {
                                if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"sid"] integerValue])
                                {
                                    prevSelectedIndex = count;
                                }
                            }
                        }
                    }
                }
            }
                break;
            case 73:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"73"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"dt" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Admin_Routes" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dt"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"dk"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if( [strPrevSelectedValue caseInsensitiveCompare:[[resultArray objectAtIndex:count] valueForKey:@"dk"]] == NSOrderedSame){
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 67: {
                //For maintaining last selected value of Condition Score
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"67"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    NSArray* resultArray;
                    NSPredicate *predicate;
                    
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    //predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                    
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"ConditionScore" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++)
                    {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                        
                    }
                }
            }
                break;
                
            case 80: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"80"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Lesion_Scores" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 81: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"81"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Lock" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 82: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"82"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Leakage" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 83: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"83"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Quality" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 84: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"84"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Standing_Reflex" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 72: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"72"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    // predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"lookup_category ==%@",strcategory]];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Test_Type" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        //***code added for Bug-28045 removing duplicate entry for Test_type By M.
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }
                        //***By M. End
                        // [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 41: {
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"41"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSArray* resultArray;
                    strPrevSelectedValue = [NSString stringWithFormat:@"%@",[dictJson valueForKey:[dict valueForKey:@"dk"]]?[dictJson valueForKey:[dict valueForKey:@"dk"]]:@""];
                    
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln"
                                                         ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"HerdCategory" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"]?[[resultArray objectAtIndex:count] valueForKey:@"ln"]:@"" forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"]?[[resultArray objectAtIndex:count] valueForKey:@"id"]:@"" forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                
            case 47:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"47"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray;
                    if ([self.strEventCode isEqualToString:@"45"]){
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sx != 'F' OR sx == null"];
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Flags" andPredicate:predicate andSortDescriptors:sortDescriptors];
                    }
                    else{
                        resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Flags" andPredicate:nil andSortDescriptors:sortDescriptors];
                    }
                    
                    for (int count=0; count<resultArray.count; count++) {
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        [_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            case 78:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"78"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Transport_Companies" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        //**code added below for Bug-28636 removing duplicate entry for Transport By M.
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }

                        //[_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
                //***added below case 164 for Bug-28180 By M.
            case 150:case 141:case 74:case 28:case 70:case 33:case 164:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:[dict valueForKey:@"dk"]] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else{
                    NSDictionary *dict = [[NSMutableDictionary alloc]init];
                    [dict setValue:strNo forKey:@"visible"];
                    [dict setValue:@"0" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict];
                    
                    NSDictionary *dict1 = [[NSMutableDictionary alloc]init];
                    [dict1 setValue:strYes forKey:@"visible"];
                    [dict1 setValue:@"1" forKey:@"dataTosend"];
                    [_arrDropDown addObject:dict1];
                    
                    if (strPrevSelectedValue.length>0)
                    {
                        if ([strPrevSelectedValue integerValue] == 1)
                        {
                            prevSelectedIndex = 1;
                        }
                        else if ([strPrevSelectedValue integerValue] == 0)
                        {
                            prevSelectedIndex = 0;
                        }
                    }
                }
            }
                break;
                //***code added for Piglet_defects Bug-28548 By M.
            case 152:{
                if (flag == 1) {
                    NSDictionary * dictJSON = [pref objectForKey:@"lastSelectedDictJSON"];
                    NSDictionary * dictDictDynamic = [pref objectForKey:@"lastSelectedDictDynamic"];
                    [dictJson setValue:[dictJSON valueForKey:@"152"] forKey:[dict valueForKey:@"dk"]];
                    [_dictDynamic setValue:[dictDictDynamic valueForKey:[dict valueForKey:@"Lb"]] forKey:[dict valueForKey:@"Lb"]];
                }
                else
                {
                    sortBy = [[NSSortDescriptor alloc] initWithKey:@"ln" ascending:YES];
                    sortDescriptors = [[NSArray alloc] initWithObjects:sortBy, nil];
                    NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Piglet_Defects" andPredicate:nil andSortDescriptors:sortDescriptors];
                    
                    for (int count=0; count<resultArray.count; count++){
                        NSDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"ln"] forKey:@"visible"];
                        [dict setValue:[[resultArray objectAtIndex:count] valueForKey:@"id"] forKey:@"dataTosend"];
                        
                        if (![_arrDropDown containsObject:dict]) {
                                [_arrDropDown addObject:dict];
                            }

                        //[_arrDropDown addObject:dict];
                        
                        if (strPrevSelectedValue.length>0)
                        {
                            if ([strPrevSelectedValue integerValue] == [[[resultArray objectAtIndex:count] valueForKey:@"id"] integerValue])
                            {
                                prevSelectedIndex = count;
                            }
                        }
                    }
                }
            }
                break;
            default:
            {
                NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]];
                if ([strDataType isEqualToString:@"DropDown"])
                {
                    if ([[dict valueForKey:@"dk"] hasPrefix:@"UDF"])
                    {
                        if ([[dict valueForKey:@"dt"] isEqualToString:@"BL"])
                        {
                            NSDictionary *dict = [[NSMutableDictionary alloc]init];
                            [dict setValue:@"No" forKey:@"visible"];
                            [dict setValue:@"0" forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict];
                            
                            NSDictionary *dict1 = [[NSMutableDictionary alloc]init];
                            [dict1 setValue:@"Yes" forKey:@"visible"];
                            [dict1 setValue:@"1" forKey:@"dataTosend"];
                            [_arrDropDown addObject:dict1];
                            
                            if (strPrevSelectedValue.length>0)
                            {
                                if ([strPrevSelectedValue integerValue] == 1)
                                {
                                    prevSelectedIndex = 1;
                                }
                                else if ([strPrevSelectedValue integerValue] == 0)
                                {
                                    prevSelectedIndex = 0;
                                }
                            }
                        }
                        else
                        {
                            NSString *str = [dict valueForKey:@"dfv"];
                            NSArray *arrStringComponents = [str componentsSeparatedByString:@","];
                            
                            for (int count=0; count<arrStringComponents.count; count++){
                                NSDictionary *dict = [[NSMutableDictionary alloc]init];
                                [dict setValue:[arrStringComponents objectAtIndex:count] forKey:@"visible"];
                                [dict setValue:[arrStringComponents objectAtIndex:count] forKey:@"dataTosend"];
                                [_arrDropDown addObject:dict];
                                
                                if (strPrevSelectedValue.length>0)
                                {
                                    if ([strPrevSelectedValue isEqualToString:[arrStringComponents objectAtIndex:count]])
                                    {
                                        prevSelectedIndex = count;
                                    }
                                }
                            }
                        }
                    }
                }
            }
                
                break;
        }
        
        NSLog(@"compuslary=%@",[dict valueForKey:@"co"]);
        if (_arrDropDown.count>0 && ![[dict valueForKey:@"co"] isEqualToString:@"1"])//[[dict valueForKey:@"co"] isEqualToString:@"1"]
        {
            NSDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setValue:@"" forKey:@"visible"];
            [dict setValue:@"" forKey:@"dataTosend"];
            [_arrDropDown insertObject:dict atIndex:0];
        }
        
        if (_arrDropDown.count>0)
        {
            if ([[dict valueForKey:@"dk"] integerValue] == 6)
            {
                __block NSMutableDictionary *dictBarn;
                __block NSMutableDictionary *dictBarnDataToSend;
                
                //
                [_dictDynamic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key isEqualToString:@"Barn-Room-Pen"])
                    {
                        dictBarn = obj;
                    }
                }];
                
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key isEqualToString:@"6"])
                    {
                        dictBarnDataToSend = obj;
                    }
                }];
                
                NSString *strVal=[[_arrDropDown objectAtIndex:0] valueForKey:@"visible"]?[[_arrDropDown objectAtIndex:0] valueForKey:@"visible"]:@"";
                NSString *strValToSend=[[_arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]?[[_arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]:@"";
                
                if (tag==2) {
                    [dictBarn setValue:strVal forKey:@"br"];
                    [dictBarnDataToSend setValue:strValToSend forKey:@"br"];
                }else if (tag==3){
                    [dictBarn setValue:strVal forKey:@"room"];
                    [dictBarnDataToSend setValue:strValToSend forKey:@"room"];
                }
                else if (tag==4){
                    [dictBarn setValue:strVal forKey:@"pen"];
                    [dictBarnDataToSend setValue:strValToSend forKey:@"pen"];
                }
                
                [_dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
                [dictJson setObject:dictBarnDataToSend forKey:[dict valueForKey:@"dk"]];
            }
            else
            {
                [_dictDynamic setValue:[[_arrDropDown objectAtIndex:0] valueForKey:@"visible"] forKey:[dict valueForKey:@"Lb"]];
                [dictJson setValue:[[_arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"] forKey:[dict valueForKey:@"dk"]];
            }
            
            //NSLog(@"weakSelf.dictDynamic=%@",_dictDynamic);
            // NSLog(@"dictJson=%@",dictJson);
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in fillDropDn =%@",exception.description);
    }
}

-(void)callEdit {
    @try {
        if ([[ControlSettings sharedSettings] isNetConnected ]){
            _customIOS7AlertView = [[CustomIOS7AlertView alloc] init];
            [_customIOS7AlertView showLoaderWithMessage:strWait];
            
            NSString *strPigIdKey;
            NSString *strEventKey;
            
            if (![[_dict valueForKey:@"PigIdKey"] isKindOfClass:[NSNull class]]){
                strPigIdKey = [_dict valueForKey:@"PigIdKey"]?[_dict valueForKey:@"PigIdKey"]:@"";
            }
            
            if (![[_dict valueForKey:@"EventKey"] isKindOfClass:[NSNull class]]) {
                strEventKey = [_dict valueForKey:@"EventKey"]?[_dict valueForKey:@"EventKey"]:@"";
            }
            
            //
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            [dict setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
            [dict setValue:strPigIdKey forKey:@"PigIdKey"];
            [dict setValue:strEventKey forKey:@"EventKey"];
            //
            
            [ServerManager sendRequest:[NSString stringWithFormat:@"token=%@&PigIdKey=%@&eventArg=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],strPigIdKey,strEventKey] idOfServiceUrl:13  headers:dict methodType:@"GET" onSucess:^(NSString *responseData) {
                [_customIOS7AlertView close];
                
                //id dict = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
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
                }
                else{
                    NSArray *arrDictData =  [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSMutableArray *arrAvailableValues = [[NSMutableArray alloc]init];
                    for (NSDictionary *Dict in arrDictData) {
                        //***added for bug-28969 By M.
                     /*   if(strEventCode.integerValue == 10 || strEventCode.integerValue == 11 ||strEventCode.integerValue == 12 ||strEventCode.integerValue == 13){
                            if ([[Dict valueForKey:@"dataItemKey"] integerValue] == 69){
                                [Dict setValue:@"" forKey:@"val"];
                            }
                        }*/
                        if (![[Dict valueForKey:@"val"] isKindOfClass:[NSNull class]]){
                            if ([[Dict valueForKey:@"val"] length]>0 && ![[Dict valueForKey:@"val"] isEqualToString:@"-9999"]){
                                [arrAvailableValues addObject:Dict];
                            }
                        }
                    }
                    
                    //For handling value suffix "," in dict response data bugnet #24539
                    for (NSDictionary *Dict in arrDictData) {
                        if (![[Dict valueForKey:@"val"] isKindOfClass:[NSNull class]]){
                            if ([[Dict valueForKey:@"val"] hasSuffix:@","]){
                                NSString *strValue = [[Dict valueForKey:@"val"]  substringToIndex:[[Dict valueForKey:@"val"]  length]-1];
                                [Dict setValue:strValue forKey:@"val"];
                                [arrAvailableValues addObject:Dict];
                            }
                        }
                    }
                    //For handling suffix "," in response data bugnet #24539
                    
                    for (NSDictionary *DictDynamic in _arrDynamic){
                        NSString *strDataType  = [self getViewType:[DictDynamic valueForKey:@"dt"]];
                        NSLog(@"strDataType=%@",strDataType);
                        NSLog(@"dk=%@",[DictDynamic valueForKey:@"dk"]);
                        
                        for (NSDictionary *DictAvailble in arrAvailableValues) {
                            @try {
                                NSLog(@"itemkey=%@",[DictAvailble valueForKey:@"dataItemKey"]);
                                
                                if (([[DictDynamic valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[DictDynamic valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[DictDynamic valueForKey:@"dk"] integerValue]==3 && [self isTwoText])){
                                    if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]]) ) && [strDataType isEqualToString:@"TextField"]) {
                                        __block NSMutableDictionary *dictText; //= [[NSMutableDictionary alloc]init];
                                        __block  NSString *strVal = [DictAvailble valueForKey:@"val"];
                                        [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                            if ([key integerValue]==51 || [key integerValue]==15 || [key integerValue]==3) {
                                                dictText = obj;
                                            }
                                        }];
                                        
                                        if ([strVal rangeOfString:@"|"].location != NSNotFound) {
                                            NSArray *explodedString = [strVal componentsSeparatedByString:@"|"];
                                            if (explodedString.count==2) {
                                                //  [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"first"];
                                                //  [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"second"];
                                                [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"Male"];
                                                [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"Female"];
                                            }
                                        }else{
                                            [dictText setValue:strVal forKey:@"Male"];
                                            [dictText setValue:@"" forKey:@"Female"];
                                        }
                                        
                                        [dictJson setObject:dictText forKey:[DictAvailble valueForKey:@"dataItemKey"]];
                                    }
                                }// |||| added for fostered for Bug-29732
                                if ( ([[DictDynamic valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
                                    if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]]) ) && [strDataType isEqualToString:@"TextField"]) {
                                        __block NSMutableDictionary *dictText; //= [[NSMutableDictionary alloc]init];
                                        __block  NSString *strVal = [DictAvailble valueForKey:@"val"];
                                        [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                            if ([key integerValue]==57) {
                                                dictText = obj;
                                            }
                                        }];
                                        
                                        if ([strVal rangeOfString:@"|"].location != NSNotFound) {
                                            NSArray *explodedString = [strVal componentsSeparatedByString:@"|"];
                                            if (explodedString.count==2) {
                                                //  [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"first"];
                                                //  [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"second"];
                                                [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"Male"];
                                                [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"Female"];
                                            }
                                        }else{
                                            [dictText setValue:strVal forKey:@"Male"];
                                            [dictText setValue:@"" forKey:@"Female"];
                                        }
                                        
                                        [dictJson setObject:dictText forKey:[DictAvailble valueForKey:@"dataItemKey"]];
                                    }
                                }
                                
                                
                                if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]])) && [strDataType isEqualToString:@"DropDown"]) {
                                    if ([[DictDynamic valueForKey:@"dk"] integerValue]!=6) {
                                        [dictJson setValue:[DictAvailble valueForKey:@"val"] forKey:[DictDynamic valueForKey:@"dk"]];
                                    }
                                    
                                    [self fillDropDownsOnEdit:[DictAvailble valueForKey:@"val"] dict:DictDynamic];
                                }else if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]]) ) && [strDataType isEqualToString:@"TextField"]) {
                                    
                                    if ([[DictDynamic valueForKey:@"dk"] integerValue]==48) {
                                        NSString *strVal = [DictAvailble valueForKey:@"val"];
                                        strVal = [strVal stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
                                        strVal = [strVal stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                        
                                        [self.dictDynamic setValue:strVal forKey:[DictDynamic valueForKey:@"Lb"]];
                                        [dictJson setValue:strVal forKey:[DictDynamic valueForKey:@"dk"]];
                                    }
                                    else{
                                        //-----------
                                        if (([[DictDynamic valueForKey:@"dk"] integerValue]==51 && [self isTwoText]) || ([[DictDynamic valueForKey:@"dk"] integerValue]==15 && [self isTwoText]) || ([[DictDynamic valueForKey:@"dk"] integerValue]==3 && [self isTwoText])){
                                            if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]]) ) && [strDataType isEqualToString:@"TextField"]) {
                                                __block NSMutableDictionary *dictText; //= [[NSMutableDictionary alloc]init];
                                                __block  NSString *strVal = [DictAvailble valueForKey:@"val"];
                                                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                                    if ([key integerValue]==51 || [key integerValue]==15 || [key integerValue]==3) {
                                                        dictText = obj;
                                                    }
                                                }];
                                                
                                                NSArray *explodedString = [strVal componentsSeparatedByString:@"|"];
                                                if (explodedString.count==2) {
                                                    //  [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"first"];
                                                    //  [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"second"];
                                                    [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"Male"];
                                                    [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"Female"];
                                                }
                                                [dictJson setObject:dictText forKey:[DictAvailble valueForKey:@"dataItemKey"]];
                                            }
                                        }// |||| added for fostered 57 for Bug-29732
                                        else if (([[DictDynamic valueForKey:@"dk"] integerValue]==57 && [self isTwoText])){
                                            if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]]) ) && [strDataType isEqualToString:@"TextField"]) {
                                                __block NSMutableDictionary *dictText; //=
                                                __block  NSString *strVal = [DictAvailble valueForKey:@"val"];
                                                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                                    if ([key integerValue]==57) {
                                                        dictText = obj;
                                                    }
                                                }];
                                                
                                                NSArray *explodedString = [strVal componentsSeparatedByString:@"|"];
                                                if (explodedString.count==2) {
                                                    //  [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"first"];
                                                    //  [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"second"];
                                                    [dictText setValue:[explodedString objectAtIndex:0]?[explodedString objectAtIndex:0]:@"" forKey:@"Male"];
                                                    [dictText setValue:[explodedString objectAtIndex:1]?[explodedString objectAtIndex:1]:@"" forKey:@"Female"];
                                                }
                                                [dictJson setObject:dictText forKey:[DictAvailble valueForKey:@"dataItemKey"]];
                                            }
                                        }
                                        //-----------
                                        else{
                                            [self.dictDynamic setValue:[DictAvailble valueForKey:@"val"] forKey:[DictDynamic valueForKey:@"Lb"]];
                                            [dictJson setValue:[DictAvailble valueForKey:@"val"] forKey:[DictDynamic valueForKey:@"dk"]];
                                        }
                                    }
                                }else if ((([DictDynamic valueForKey:@"dk"] == [DictAvailble valueForKey:@"dataItemKey"]) || ([[DictDynamic valueForKey:@"dk"] isEqualToString:[DictAvailble valueForKey:@"dataItemKey"]]) ) && [strDataType isEqualToString:@"Date"]){
                                    
                                    NSMutableString *str = [DictAvailble valueForKey:@"val"];
                                    if (str.length>0) {
                                        NSString *strBaseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZD"];
                                        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                                        if (isThousandFormat) {
                                            [formatter setDateFormat:@"YYYYMMdd"];
                                            NSDate *dtselectedDate = [formatter dateFromString:str];
                                            [formatter setDateFormat:@"YYYYMMdd"];
                                            NSDate *BaseDate = [formatter dateFromString:strBaseDate];
                                            int days = [dtselectedDate timeIntervalSinceDate:BaseDate]/24/60/60;
                                            
                                            NSString *strDate = [NSString stringWithFormat:@"%05d",days];
                                            NSString *calFormat,*strFromString;
                                            
                                            if (strDate.length>=2) {
                                                calFormat = [strDate substringToIndex:2];
                                            }else {
                                                calFormat = strDate;
                                            }
                                            
                                            if (strDate.length>=3){
                                                strFromString = [strDate substringFromIndex:2];
                                            }
                                            
                                            calFormat = [[calFormat stringByAppendingString:@"-"] stringByAppendingString:strFromString?strFromString:@""];
                                            [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                                            
                                            NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
                                            
                                            [_dictDynamic setValue:strSelectedDate100 forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //Added below for Bug-29092 By M.
                                            [dictJson setValue:strSelectedDate100 forKey:[DictDynamic valueForKey:@"dk"]];
                                        }
                                        //*** changed below code for strDateFormat due to User_Paramters APi changes By M.
                                        //else if([self.strDateFormat isEqualToString:@"6"]){
                                        else if([_strDateFormat isEqualToString:@"6"]){
                                            [formatter setDateFormat:@"YYYYMMdd"];
                                            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                                            
                                            NSDate *dtselectedDate = [formatter dateFromString:str];
                                            NSDate *Firstdate= [self getFirstDateOfCurrentYear:dtselectedDate];
                                            
                                            [formatter setDateFormat:@"DDD"];
                                            NSInteger days= [[formatter stringFromDate:dtselectedDate] integerValue];
                                            
                                            // NSInteger days=[self daysBetweenDate:Firstdate andDate:dtselectedDate];
                                            NSLog(@"days:%ld",days);
                                            
                                            NSString *strDate = [NSString stringWithFormat:@"%03li",days];
                                            [formatter setDateFormat:@"yy"];
                                            NSString *strSelectedDateyearformat = [[[formatter stringFromDate:dtselectedDate] stringByAppendingString:@"-"] stringByAppendingString:strDate];
                                            
                                            /* [_dictDynamic setValue:strSelectedDateyearformat forKey:[DictDynamic valueForKey:@"Lb"]];*///commented by amit
                                            
                                            /*********************/
                                            [formatter setDateFormat:@"EEE,dd-MMM-yyyy"];
                                            
                                            /***************/
                                            
                                            NSString *strSelectedDateDayOFYear = [[strSelectedDateyearformat stringByAppendingString:@"\n"] stringByAppendingString:[formatter stringFromDate:dtselectedDate]];
                                            
                                            /*****************/
                                            
                                            // NSString *strSelectedDate100 = [[calFormat stringByAppendingString:@"\n"] stringByAppendingString:[dateFormatterr stringFromDate:dtselectedDate]];
                                            //[_dictDynamic setValue:strSelectedDateyearformat forKey:[dict valueForKey:@"Lb"]];
                                            [_dictDynamic setValue:strSelectedDateDayOFYear forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //added for Bug-29092
                                            [dictJson setValue:strSelectedDateDayOFYear forKey:[DictDynamic valueForKey:@"dk"]];
                                            /**********************/
                                            
                                            
                                            // [_dictDynamic setValue:strSelectedDateyearformat forKey:[dict valueForKey:@"Lb"]];
                                        }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                                        //***added check for 2 below in condition for bug-29092 by M
                                        else if([_strDateFormat isEqualToString:@"3"] || [_strDateFormat isEqualToString:@"2"]){
                                            
                                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                                            [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                                            NSDate *inputDate = [inputDateFormatter dateFromString:str];

                                            // Create a date formatter for the desired output format
                                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                                            [outputDateFormatter setDateFormat:@"dd-MMM-yy"];

                                            // Format the date to the desired output format
                                            NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                                            [_dictDynamic setValue:outputDateString forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //added for Bug-29092
                                            [dictJson setValue:outputDateString forKey:[DictDynamic valueForKey:@"dk"]];
                                        }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                                        else if([_strDateFormat isEqualToString:@"4"]){
                                            
                                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                                            [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                                            NSDate *inputDate = [inputDateFormatter dateFromString:str];

                                            // Create a date formatter for the desired output format
                                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                                            [outputDateFormatter setDateFormat:@"MM/dd/yy"];

                                            // Format the date to the desired output format
                                            NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                                            [_dictDynamic setValue:outputDateString forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //added for Bug-29092
                                            [dictJson setValue:outputDateString forKey:[DictDynamic valueForKey:@"dk"]];
                                        }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                                        else if([_strDateFormat isEqualToString:@"5"]){
                                            
                                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                                            [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                                            NSDate *inputDate = [inputDateFormatter dateFromString:str];

                                            // Create a date formatter for the desired output format
                                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                                            [outputDateFormatter setDateFormat:@"dd/MM/yy"];

                                            // Format the date to the desired output format
                                            NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                                            [_dictDynamic setValue:outputDateString forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //added for Bug-29092
                                            [dictJson setValue:outputDateString forKey:[DictDynamic valueForKey:@"dk"]];
                                        }  //*** condition added below code for strDateFormat due to User_Paramters APi changes Bug 27782 -By M.
                                        else if([_strDateFormat isEqualToString:@"8"]){
                                            
                                            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
                                            [inputDateFormatter setDateFormat:@"yyyyMMdd"];
                                            NSDate *inputDate = [inputDateFormatter dateFromString:str];

                                            // Create a date formatter for the desired output format
                                            NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
                                            [outputDateFormatter setDateFormat:@"dd/MM/yyyy"];

                                            // Format the date to the desired output format
                                            NSString *outputDateString = [outputDateFormatter stringFromDate:inputDate];
                                            [_dictDynamic setValue:outputDateString forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //added for Bug-29092
                                            [dictJson setValue:outputDateString forKey:[DictDynamic valueForKey:@"dk"]];
                                        }
                                        else{
                                            [_dictDynamic setValue:[[[[str substringWithRange:NSMakeRange(4, [str length]-6)] stringByAppendingString:@"/"] stringByAppendingString:[[str substringWithRange:NSMakeRange(6, [str length]-6)] stringByAppendingString:@"/"]] stringByAppendingString:[str substringToIndex:4]] forKey:[DictDynamic valueForKey:@"Lb"]];
                                            //added for Bug-29092
                                            [dictJson setValue:[[[[str substringWithRange:NSMakeRange(4, [str length]-6)] stringByAppendingString:@"/"] stringByAppendingString:[[str substringWithRange:NSMakeRange(6, [str length]-6)] stringByAppendingString:@"/"]] stringByAppendingString:[str substringToIndex:4]] forKey:[DictDynamic valueForKey:@"dk"]];
                                        }
                                        //
                                        //commenetd below line for Bug-29092
                                       // [dictJson setValue:str forKey:[DictDynamic valueForKey:@"dk"]];
                                    }
                                }else if ([strDataType isEqualToString:@"IR"]){
                                    __block NSMutableDictionary *dictText;
                                    
                                    [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                                        if ([key integerValue]==92) {
                                            dictText = obj;
                                        }
                                    }];
                                    
                                    [dictText setValue:@"" forKey:@"first"];
                                    [dictText setValue:@"" forKey:@"second"];
                                    [dictText setValue:@"" forKey:@"third"];
                                    [dictJson setObject:dictText forKey:[DictAvailble valueForKey:@"dataItemKey"]];
                                }
                            }
                            @catch (NSException *exception) {
                                
                                NSLog(@"Exception =%@",exception.description);
                            }
                        }
                    }
                    
                    NSLog(@"dictJson=%@",dictJson);
                    NSLog(@"data=%@",_dictDynamic);
                    NSLog(@"data=%@",arrAvailableValues);
                    //***added code for Bug-29092 By M.
                    BOOL found = NO;
                    for (NSDictionary *dict in arrAvailableValues) {
                        if ([[dict valueForKey:@"dataItemKey"] isEqualToString:@"169"]) {
                            found = YES;
                            break;
                        }
                    }
                    if(found){
                        strpigletIdentitiesEdit = [dictJson valueForKey:@"169"];
                        
                        NSString * dataArray = [dictJson valueForKey:@"169"];
                       
                        if (dataArray != nil) {
                           
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadNestedTableNotification" object:nil userInfo:@{@"data": dataArray}];
                            
                        }
                    }
                    //end By M.
                   

                    _dictReload = [[NSMutableDictionary alloc] init];
                    
                    //  NSArray *deepCopyArray=[[NSArray alloc] initWithArray:someArray copyItems:YES];
                    
                    NSMutableDictionary *dctjson = [[NSMutableDictionary alloc]initWithDictionary:dictJson copyItems:YES];
                    NSMutableDictionary *dctDynamic = [[NSMutableDictionary alloc]initWithDictionary:_dictDynamic copyItems:YES];
                    
                    [_dictReload setValue:dctjson forKey:@"dataToSend"];
                    [_dictReload setValue:dctDynamic forKey:@"dataToDisplay"];
                    
                    //[_dictReload setObject:dctjson forKey:@"dataToSend"];
                    // [_dictReload setObject:dctDynamic forKey:@"dataToDisplay"];
                    
                    [self.tblDynamic reloadData];
                }
            } onFailure:^(NSMutableDictionary *responseData, NSError *error){
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                // 5     //
                NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
                [dateformate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *strDate = [dateformate stringFromDate:[NSDate date]];
                
                NSString *strErr = [NSString stringWithFormat:@"User Name = %@,Farm Name = %@,error = %@,DateTime=%@,Event on Edit=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"f_nm"],error.description,strDate,self.lblSelectedValue.text];
                [tracker set:kGAIScreenName value:strErr];
                [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
                
                if ([responseData.allKeys containsObject:@"code"]) {
                    if ([[responseData valueForKey:@"code"]integerValue] ==401) {
                        
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:strUnauthorised
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        //** added Pigchamp logo on alert Bug-27920 and Bug-29344 by M.
                        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
                        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
                        UIView *controllerView = myAlertController.view;
                        [controllerView addSubview:logoImageView];
                        [controllerView bringSubviewToFront:logoImageView];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                            [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
                        }];
                        
                        [myAlertController addAction: ok];
                        [self presentViewController:myAlertController animated:YES completion:nil];
                        
                        // [self.navigationController popToRootViewControllerAnimated:YES];
                    }else if ([[responseData valueForKey:@"code"]integerValue] ==408) {
                        
                        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                                   message:[responseData valueForKey:@"Error"]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* ok = [UIAlertAction
                                             actionWithTitle:strOk
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                            [self.navigationController popViewControllerAnimated:YES];
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
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:strOk
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
                                                                                       message:strNoInternet
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:strOk
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                [myAlertController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [myAlertController addAction: ok];
            [self presentViewController:myAlertController animated:YES completion:nil];
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in callEdit =%@",exception.description);
    }
}


-(void)fillDropDownsOnEdit:(NSString*)Id dict:(NSDictionary*)dict{
    @try {
        // NSInteger tag=0;
        [_arrDropDown removeAllObjects];
        // NSSortDescriptor *sortBy;
        //  NSArray *sortDescriptors;
        
        // NSString *strPrevSelectedValue= [dictJson valueForKey:[dict valueForKey:@""]]?[dictJson valueForKey:[dict valueForKey:@""]]:@"";
        //  NSInteger prevSelectedIndex  = 0;
        
        switch ([[dict valueForKey:@"dk"]integerValue]){
            case 4:{
                
                //*** code commented to show same value which previsouly saved Bug-28302 and 28307 By M.
                NSLog(@"id=%@",Id);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ln != null AND id=%@",Id];
               /* NSString *strPredicate;
                if ([strEventCode isEqualToString:@"33"]||[strEventCode isEqualToString:@"48"]) {
                    strPredicate = [NSString stringWithFormat:@"br != 0 AND tr==1 AND id=%@",Id];
                }
                else if ([strEventCode isEqualToString:@"34"]||[strEventCode isEqualToString:@"49"]) {
                    strPredicate =[NSString stringWithFormat:@"(sg != 0 OR sp != 0 or sd != 0 ) AND tr==1 AND id=%@",Id];
                }
                else if ([strEventCode isEqualToString:@"35"]) {
                    strPredicate = [NSString stringWithFormat:@"pg != 0 AND tr==1 AND id=%@",Id];
                }
                else if ([strEventCode isEqualToString:@"10"]||[strEventCode isEqualToString:@"12"]) {
                    strPredicate =[NSString stringWithFormat:@"br != 0 AND ds==1 AND id=%@",Id];
                }
                else if ([strEventCode isEqualToString:@"11"]||[strEventCode isEqualToString:@"13"]) {
                    strPredicate = [NSString stringWithFormat:@"(sg != 0 OR sp != 0 or sd != 0 ) AND ds==1 AND id=%@",Id];
                }
                else if ([strEventCode isEqualToString:@"32"]) {
                    strPredicate = [NSString stringWithFormat:@"pg != 0 AND ds==1 AND id=%@",Id];
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:strPredicate];*/
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Conditions" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 6:{
                __block NSMutableDictionary *dictBarnDataToSend;
                
                [dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                 {
                    if ([key isEqualToString:@"6"])
                    {
                        dictBarnDataToSend = obj;
                    }
                }];
                
                //                __block NSMutableDictionary *dictBarn;
                //                [_dictDynamic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                //                 {
                //                     if ([key isEqualToString:@"Barn-Room-Pen"])
                //                     {
                //                         dictBarn = obj;
                //                     }
                //                 }];
                
                NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"id=%@",Id];
                NSArray* resultArray ;
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Locations" andPredicate:predicate andSortDescriptors:nil];
                
                for (int count=0; count<resultArray.count; count++) {
                    
                    @try {
                        [dictBarnDataToSend setValue:[[resultArray objectAtIndex:count] valueForKey:@"br"] forKey:@"br"];
                        [dictBarnDataToSend setValue:[[resultArray objectAtIndex:count] valueForKey:@"rm"] forKey:@"rm"];
                        [dictBarnDataToSend setValue:[[resultArray objectAtIndex:count] valueForKey:@"pn"] forKey:@"pn"];
                    }
                    @catch (NSException *exception) {
                        
                        NSLog(@"Exception =%@",exception.description);
                    }
                }
                
                //[_dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
                [dictJson setObject:dictBarnDataToSend forKey:[dict valueForKey:@""]];
            }
                break;
            case 8:{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dk=%@",Id];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Pd_Results" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"dt"]?[[resultArray objectAtIndex:0] valueForKey:@"dt"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 9:{
                NSLog(@"id=%@",Id);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ln != null AND id=%@",Id];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Operator" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 11: {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@",Id];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Treatments" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 13:{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dk=%@",Id];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Tod" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"dt"]?[[resultArray objectAtIndex:0] valueForKey:@"dt"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 23: {
                NSArray* resultArray;
                NSPredicate *predicate;
                if ([self.strEventCode isEqualToString:@"1"] || [self.strEventCode isEqualToString:@"2"]) {
                    predicate = [NSPredicate predicateWithFormat:@"(sx == 'M' OR sx == '' OR sx == null) AND id=%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Genetics" andPredicate:predicate andSortDescriptors:nil];
                }
                else if ([self.strEventCode isEqualToString:@"4"] || [self.strEventCode isEqualToString:@"5"] || [self.strEventCode isEqualToString:@"8"]||[self.strEventCode isEqualToString:@"6"]|| [self.strEventCode isEqualToString:@"113"]){
                    predicate = [NSPredicate predicateWithFormat:@"(sx == 'F' OR sx == '' OR sx == null) AND id==%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Genetics" andPredicate:predicate andSortDescriptors:nil];
                }
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 34:{
                NSArray* resultArray;
                if ([self.strEventCode isEqualToString:@"1"]){
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"AI_STUDS" andPredicate:predicate andSortDescriptors:nil];
                    
                    if (resultArray.count>0) {
                        [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                    }
                }
                else {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sid=%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Origin" andPredicate:predicate andSortDescriptors:nil];
                    if (resultArray.count>0) {
                        [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ds"]?[[resultArray objectAtIndex:0] valueForKey:@"ds"]:@"" forKey:[dict valueForKey:@"Lb"]];
                    }
                }
            }
                break;
            case 37:{
                //*** changed code predicateWithFormat:@"dK=%@" to predicateWithFormat:@"dk=%@"
                //Bug 27950 added by M.
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dk=%@",Id];
                //*** end of added by M.
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Halothane" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"dt"]?[[resultArray objectAtIndex:0] valueForKey:@"dt"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 62:{
                NSArray* resultArray;
                if ([self.strEventCode isEqualToString:@"12"] || [self.strEventCode isEqualToString:@"13"]||[self.strEventCode isEqualToString:@"29"] || [self.strEventCode isEqualToString:@"28"] ||[self.strEventCode isEqualToString:@"30"] || [self.strEventCode isEqualToString:@"31"]){
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@",Id];
                    
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Packing_Plants" andPredicate:predicate andSortDescriptors:nil];
                    
                    if (resultArray.count>0) {
                        [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                    }
                }
                else{
                    //**commented below line for bug 28030 by M.
                   // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"siteKey=%@",Id];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sid=%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Destination" andPredicate:predicate andSortDescriptors:nil];
                    
                    if (resultArray.count>0) {
                        [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ds"]?[[resultArray objectAtIndex:0] valueForKey:@"ds"]:@"" forKey:[dict valueForKey:@"Lb"]];
                    }
                }
            }
                break;
            case 73:{
                //***code commented below for Bug-27867 By M.
                //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dK=%@",Id];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dk=%@",Id];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Admin_Routes" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"dt"]?[[resultArray objectAtIndex:0] valueForKey:@"dt"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 67: {
                NSArray* resultArray;
                NSPredicate *predicate;
                NSString *strcategory;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"ConditionScore" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
                //
            case 80: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Lesion_Scores" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 81: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Lock" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 82: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Leakage" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 83: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Quality" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 84: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Standing_Reflex" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 72: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Test_Type" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                //
                
            case 41: {
                NSArray* resultArray;
                NSPredicate *predicate;
                
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"HerdCategory" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                
            case 47:{
                NSArray* resultArray;
                NSPredicate *predicate;
                if ([self.strEventCode isEqualToString:@"45"]){
                    predicate = [NSPredicate predicateWithFormat:@"(sx != 'F' OR sx == null) AND id=%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Flags" andPredicate:predicate andSortDescriptors:nil];
                }
                else {
                    predicate = [NSPredicate predicateWithFormat:@"id=%@",Id];
                    resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Flags" andPredicate:predicate andSortDescriptors:nil];
                }
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            case 78:{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@",Id];
                NSArray* resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Transport_Companies" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
               ///***added below case 164 for Bug-28180 By M.
            case 150:case 141:case 74:case 28:case 70:case 33:case 164:{
                if ([Id isEqualToString:@"0"]){
                    [_dictDynamic setValue:@"NO" forKey:[dict valueForKey:@"Lb"]];
                }
                else if ([Id isEqualToString:@"1"]){
                    [_dictDynamic setValue:@"Yes" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
                //***code added for Piglet_Defects Bug-28548 By M.
            case 152: {
                NSArray* resultArray;
                NSPredicate *predicate;
               
                predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id==%@",Id]];
                resultArray = [[CoreDataHandler sharedHandler] getValuesToListWithEntityName:@"Piglet_Defects" andPredicate:predicate andSortDescriptors:nil];
                
                if (resultArray.count>0) {
                    [_dictDynamic setValue:[[resultArray objectAtIndex:0] valueForKey:@"ln"]?[[resultArray objectAtIndex:0] valueForKey:@"ln"]:@"" forKey:[dict valueForKey:@"Lb"]];
                }
            }
                break;
            default:
            {
                NSString *strDataType  = [self getViewType:[dict valueForKey:@"dt"]];
                if ([strDataType isEqualToString:@"DropDown"]){
                    if ([[dict valueForKey:@"dk"] hasPrefix:@"UDF"]){
                        if ([[dict valueForKey:@"dt"] isEqualToString:@"BL"])
                        {
                            if ([Id isEqualToString:@"0"]){
                                [_dictDynamic setValue:@"NO" forKey:[dict valueForKey:@"Lb"]];
                            }
                            else if ([Id isEqualToString:@"1"]){
                                [_dictDynamic setValue:@"Yes" forKey:[dict valueForKey:@"Lb"]];
                            }
                        }
                        else{
                            [_dictDynamic setValue:Id forKey:[dict valueForKey:@"Lb"]];
                        }
                    }
                }
            }
                
                break;
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in fillDropDn =%@",exception.description);
    }
}

-(void)btnSettings_tapped
{
    @try {
        settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
        [self presentViewController:settingsViewController animated:NO completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in btnSettings_tapped =%@",exception.description);
    }
}

- (IBAction)btnSnnerType_tapped:(id)sender {
    @try {
        ///*** added code below for  bug- 27755    By M.
        UITableViewCell* cell = (UITableViewCell*)[[sender superview] superview];
        NSIndexPath* indexPath = [self.tblDynamic indexPathForCell:cell];
        NSDictionary *dict = [_arrDynamic objectAtIndex:indexPath.row];
        
        strScan = [dict valueForKey:@"Lb"];
        strScandk = [dict valueForKey:@"dk"];
        ///*** End By M.
        ///
        if([strScandk isEqualToString:@"169"]){
       
            //~~~~~added below code for Piglet Identities Bug-29637 By M.
            if ([cell isKindOfClass:[PigletIdentitiesTableViewCell class]]) {
                PigletIdentitiesTableViewCell *pigletCell = (PigletIdentitiesTableViewCell *)cell;
                pigletCell.btnSex.userInteractionEnabled = YES;
                pigletCell.btnColor.userInteractionEnabled = YES;
                pigletCell.btnDestination.userInteractionEnabled = YES;
            }
        }
        //~~~~~added below code for Piglet Identities Bug-29596 By M.
        UIButton *btn = (UIButton*)sender;
        btnTag = btn.tag;
        //End of M.
        pref = [NSUserDefaults standardUserDefaults];
        // NSString *strRFID = [pref valueForKey:@"isRFID"];
        NSString *strBar = [pref valueForKey:@"isBarcode"];
        
        if ([strBar isEqualToString:@"1"]){
            barcodeScannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"segueBarcode"];
            barcodeScannerViewController.delegate = self;
            ///*** added code below for  bug- 27755    By M.
            [self presentViewController:barcodeScannerViewController animated:NO completion:nil];
            ///*** end by M.
            //[self.navigationController pushViewController:barcodeScannerViewController animated:NO];
        }else{
        }
    }
    @catch (NSException *exception) {
        {
            UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                       message:exception.description
                                                                                preferredStyle:UIAlertControllerStyleAlert];
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
        NSLog(@"Exception in btnSnnerType_tapped=%@",exception.description);
    }
}

-(void)scannedBarcode:(NSString *)barcode{
    @try {
        //        [_dictDynamic setValue:barcode forKey:strScan];
        //        [dictJson setValue:barcode forKey:@"1"];
        //        [self.tblDynamic reloadData];
        
                //[_dictDynamic setValue:barcode forKey:strScan];
                //[dictJson setValue:barcode forKey:@"1"];
        /*
        ///*** added code below for  bug- 27755    By M.
        [_dictDynamic setValue:barcode forKey:strScan];
        [dictJson setValue:barcode forKey:strScandk];
        ///***end By M.
        */
        //~~~~commented above code and added new code for Piglet Identities By M.
        if([strScandk isEqualToString:@"169"]){
        //~~~~~ added below code for Piglet Identities By M.
        //***code added for Bug-29637 By M.
             if ([_strFromEditPage isEqualToString:@"FromEdit"]){
                 addnewPigFlg = YES;
             }else{
                 addnewPigFlg = NO;
             }
             if(btnTag == 4){
                 
                 if (![_pigletIdentitiesArray containsObject:pigletIdentityDict]){
                     [_pigletIdentitiesArray addObject:pigletIdentityDict];
                 }
                 
                 [self.dictDynamic setObject:[_pigletIdentitiesArray mutableCopy] forKey:@"Piglet Identities"];
                 if (![_pigletIdentitiesJsonArray containsObject:pigletIdentityJsonDict]){
                     [_pigletIdentitiesJsonArray addObject:pigletIdentityJsonDict];
                 }
                 [dictJson setObject:[_pigletIdentitiesJsonArray mutableCopy] forKey:@"169"];
             }
             tattooScannedValue = [barcode mutableCopy];
             NSArray *array169 = dictJson[@"169"];
             NSDictionary *dictDataToSend;
             if(btnTag == 4){
                 if (array169 && [array169 isKindOfClass:[NSArray class]]) {
                     dictDataToSend = [array169 lastObject];
                     [dictDataToSend setValue:barcode forKey:@"34"];
                     NSMutableArray *mutableArray169 = [array169 mutableCopy];
                     if (!mutableArray169) {
                         mutableArray169 = [NSMutableArray array];
                     }
                     if (![mutableArray169 containsObject:dictDataToSend]){
                         [mutableArray169 addObject:dictDataToSend];
                     }
                    
                     [self.dictJson setObject:mutableArray169 forKey:strScandk];
                     //[self.dictJson setObject:dictDataToSend forKey:strScandk];
                     [pigletIdentityJsonDict setValue:tattooScannedValue forKey:@"34"];
                     tagScanflg = 1;
                 }if ([array169 isKindOfClass:[NSMutableDictionary class]]) {
                     array169_1 =[array169 mutableCopy];
                     [array169_1 setValue:barcode forKey:@"34"];
                     [self.dictJson setObject:array169_1 forKey:strScandk];
                     [pigletIdentityJsonDict setValue:tattooScannedValue forKey:@"34"];
                     tagScanflg = 1;
                 }
             }if(btnTag == 3){
                 if (array169 && [array169 isKindOfClass:[NSArray class]]) {
                     dictDataToSend = [array169 lastObject];
                     [dictDataToSend setValue:barcode forKey:@"35"];
                     NSMutableArray *mutableArray169 = [array169 mutableCopy];
                     if (!mutableArray169) {
                         mutableArray169 = [NSMutableArray array];
                     }
                     if (![mutableArray169 containsObject:dictDataToSend]){
                         [mutableArray169 addObject:dictDataToSend];
                     }
                    
                     [self.dictJson setObject:mutableArray169 forKey:strScandk];
                    // [self.dictJson setObject:dictDataToSend forKey:strScandk];
                     [pigletIdentityJsonDict setValue:tattooScannedValue forKey:@"35"];
                     tattooScanflg = 1;
                 }if ([array169 isKindOfClass:[NSMutableDictionary class]]) {
                     array169_1 =[array169 mutableCopy];
                     [array169_1 setValue:barcode forKey:@"35"];
                     [self.dictJson setObject:array169_1 forKey:strScandk];
                     [pigletIdentityJsonDict setValue:tattooScannedValue forKey:@"35"];
                     tattooScanflg = 1;
                 }
             }
           
        }else{
            ///*** added code below for  bug- 27755    By M.
            [_dictDynamic setValue:barcode forKey:strScan];
            [dictJson setValue:barcode forKey:strScandk];
            ///***end By M.
        }
        [self.tblDynamic reloadData];
        
    
       // [_dictDynamic setValue:barcode forKey:[dictCurrentTextFieldClicked valueForKey:@"Lb"]];
     //   [dictJson setValue:barcode forKey:[dictCurrentTextFieldClicked valueForKey:@"dk"]];
        
       // [self.tblDynamic reloadData];
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception in scannedBarcode=%@",exception.description);
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
- (BOOL)isDOB:(NSDate *)dobDate olderThanDate:(NSDate *)date1 andDate:(NSDate *)date2 {
        // Compare the DOB date with date1 and date2
        if ([dobDate compare:date1] == NSOrderedAscending || [dobDate compare:date2] == NSOrderedAscending) {
            // DOB is older than date1 and date2
            return YES;
        }
        // DOB is not older than date1 and date2
        return NO;
    }
- (NSString *)getDateFromString:(NSString *)dateString {
    NSArray *dateFormats = @[@"yyyyMMdd", @"yyyy-MM-dd", @"MM/dd/yyyy", @"dd/MM/yyyy"]; // Add more formats if needed
    
    for (NSString *dateFormat in dateFormats) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        NSDate *date = [dateFormatter dateFromString:dateString];
        
        if (date) {
            NSLog(@"Successfully detected date format: %@", dateFormat);
            return dateFormat;
        }
    }
    
    NSLog(@"Unable to detect date format for string: %@", dateString);
    return nil;
    }
- (NSString *)convertDateToStringWithDetectedFormat:(NSString *)newDateString {
    // Assuming you have a global variable or property to store the detected date format
    //NSString *detectedDateFormat = @"yyyy-MM-dd"; // Example detected date format

    NSString *strBaseDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"ZD"];

    detectedDateFormat = [self getDateFromString:strBaseDate];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
       [outputFormatter setDateFormat:detectedDateFormat];
       
       NSDate *newDate = [outputFormatter dateFromString:newDateString];
    
    NSString *newDate11 = [outputFormatter stringFromDate: newDate];
       if (newDate11) {
           //[outputFormatter setDateFormat:@"dd MMM yyyy"]; // Change to desired output format
          //ce NSString *formattedDateString = [outputFormatter stringFromDate:newDate];
           return newDate11;
       } else {
           return @"Invalid date format";
       }
}

-(void)notinRangeMessage:(NSDictionary*)dict {
    @try {
        NSString *strMustValue = @"Value entered for #1 is more than the maximum allowed, #2";
        NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:@"Value entered for #1 is more than the maximum allowed, #2", nil]];
        
        NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
        
        if (resultArray1.count!=0)
        {
            for (int i=0; i<resultArray1.count; i++){
                [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"trn"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"key"] uppercaseString]];
            }
            
            for (int i=0; i<1; i++) {
                // if (i==0) {
                if ([dictMenu objectForKey:[@"Value entered for #1 is more than the maximum allowed, #2" uppercaseString]] && ![[dictMenu objectForKey:[@"Value entered for #1 is more than the maximum allowed, #2" uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[@"Value entered for #1 is more than the maximum allowed, #2" uppercaseString]] length]>0) {
                        NSLog(@"%@",[dictMenu objectForKey:[@"Value entered for #1 is more than the maximum allowed, #2" uppercaseString]]);
                        strMustValue = [dictMenu objectForKey:[@"Value entered for #1 is more than the maximum allowed, #2" uppercaseString]];
                    }
                }
                // }
            }
        }
        
        strMustValue = [strMustValue stringByReplacingOccurrencesOfString:@"#1" withString:[dict valueForKey:@"Lb"]];
        strMustValue = [strMustValue stringByReplacingOccurrencesOfString:@"#2" withString:[dict valueForKey:@"mxV"]];
        //
        
        //        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
        //                                                                                   message:strMustValue
        //                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                   message:[NSString stringWithFormat:@"%@ ",strMustValue]
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
        
        return;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in =%@",exception.description);
    }
}

-(NSString*)getTranslatedTextForString:(NSString*)Checkstring
{
    NSString *strSearch;
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
                        strSearch = [dictMenu objectForKey:[Checkstring uppercaseString]]?[dictMenu objectForKey:[Checkstring uppercaseString]]:@"";
                    }
                    else
                    {
                        strSearch = Checkstring;
                    }
                }
            }
        }
    }
    else
    {
        strSearch = Checkstring;
    }
    return strSearch;
}

- (IBAction)btnConnectAccessoryClicked:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = strWait;
    
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showBTTalbe) userInfo:nil repeats:NO];
}

- (void)accessoryDisconnected:(NSNotification *)notification {
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
   // NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                            //connectedAccessories];
    //EAAccessory *accessory = nil;

    //for (EAAccessory *obj in accessories)
    //{
     //   NSLog(@"Found accessory named: %@", obj.name);
    //}
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

- (void)accessoryConnected:(NSNotification *)notification
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
- (void)_sessionDataReceived:(NSNotification *)notification
{
    NSLog(@"Data Received on data entry");
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
    
    [self callTransponderClicked:self.txtReference];
}

//For diasplaying and calling get transponder API//
-(void)callTransponderClicked:(UITextField*)textField
{
    @try {
        if (!([fullDataString length]<17))
        {
            if ([fullDataString length]>17)
            {
                fullDataString = [fullDataString substringFromIndex:[fullDataString length] - 17];//For trimming suffix 100000//
                if([[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue]==32)
                {
                    self.txtReference.text = @"";
                    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
                    fullDataString = [fullDataString stringByTrimmingCharactersInSet:characterSet];
                    self.txtReference.text = fullDataString;
                    
                    [self.dictDynamic setValue:fullDataString forKey:[dictCurrentTextFieldClicked valueForKey:@"Lb"]];
                    [dictJson setValue:fullDataString forKey:[dictCurrentTextFieldClicked valueForKey:@"dk"]];
                    
                    if (![_strFromEditPage isEqualToString:@"FromEdit"])
                    {
                        [self getRFID:fullDataString index:self.txtReference.tag :dictCurrentTextFieldClicked]; //API Call
                    }
                }
                else if([[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] ==1 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 68 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 7 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 60 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 12 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 27 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 63 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 38 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 39)
                {
                    [self getRFID:fullDataString index:self.txtReference.tag :dictCurrentTextFieldClicked]; //API Call
                }
            }else if(fullDataString.length==17)
            {
                if([[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue]==32)
                {
                    self.txtReference.text = @"";
                    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
                    fullDataString = [fullDataString stringByTrimmingCharactersInSet:characterSet];
                    self.txtReference.text = fullDataString;
                    
                    [self.dictDynamic setValue:fullDataString forKey:[dictCurrentTextFieldClicked valueForKey:@"Lb"]];
                    [dictJson setValue:fullDataString forKey:[dictCurrentTextFieldClicked valueForKey:@"dk"]];
                    
                    if (![_strFromEditPage isEqualToString:@"FromEdit"])
                    {
                        [self getRFID:fullDataString index:self.txtReference.tag :dictCurrentTextFieldClicked]; //API Call
                    }
                }
                else if([[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] ==1 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 68 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 7 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 60 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 12 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 27 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 63 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 38 || [[dictCurrentTextFieldClicked valueForKey:@"dk"] integerValue] == 39)
                {
                    [self getRFID:fullDataString index:self.txtReference.tag :dictCurrentTextFieldClicked]; //API Call
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception in Called Responder Clicked%@",exception.description);
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_alertForPickUpDate close];
    [_alertForOrgName close];
    [_pickerDropDown setHidden:YES];
    [_customIOS7AlertView close];
    
    //    for (UIView *subview in self.view.subviews)
    //        [subview removeFromSuperview];
    
}
  
-(void)sendDataToDynamicForm:(NSMutableArray *)arrDropSelectedData :(NSDictionary*)dictData{
    if (arrDropSelectedData ==nil) {
        strFromDropDownView = @"fromDropDownView";
    }else{
        strFromDropDownView = @"fromDropDownView";
        _arrDropDown = arrDropSelectedData;
        if ([[dictData valueForKey:@"dk"] integerValue] == 6){
            // __block NSMutableDictionary *dictBarn;
            __block NSMutableDictionary *dictBarnDataToSend;
            
            [self.dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if ([key isEqualToString:@"6"]){
                    dictBarnDataToSend = [obj mutableCopy];
                }
            }];
            
            NSString *strVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]:@"";
            
            if (TapedDropDownTag==2) {
                [dictBarnDataToSend setValue:strVal forKey:@"br"];
                [dictBarnDataToSend setValue:@"" forKey:@"rm"];
                [dictBarnDataToSend setValue:@"" forKey:@"pn"];
            }else if (TapedDropDownTag==3){
                [dictBarnDataToSend setValue:strVal forKey:@"rm"];
                [dictBarnDataToSend setValue:@"" forKey:@"pn"];
            }
            else if (TapedDropDownTag==4){
                [dictBarnDataToSend setValue:strVal forKey:@"pn"];
            }
            
            //[weakSelf.dictDynamic setObject:dictBarn forKey:[dict valueForKey:@"Lb"]];
            [self.dictJson setObject:dictBarnDataToSend forKey:[dictData valueForKey:@"dk"]];
        }//~~~~ added for piglet identities by M
        else if ([[dictData valueForKey:@"dk"] integerValue] == 169){
            
          /*  __block NSMutableDictionary *dictDataToSend,*dictDataToSend1;
            
            [self.dictJson enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
                if ([key isEqualToString:@"169"]){
                    dictDataToSend = [obj mutableCopy];
                    dictDataToSend1 = [obj mutableCopy];
                }
            }];*/
            NSArray *array169 = dictJson[@"169"];
            NSDictionary *dictDataToSend;
           
            if (array169 && [array169 isKindOfClass:[NSArray class]]) {
                if (array169.count == 1){
                    dictDataToSend = array169[0];
                    
                    dictDataToSend_1 = [dictDataToSend mutableCopy];
                   
                    NSString *strIden = dictDataToSend[@"34"];
                    
                    NSString *strVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]:@"";
                    NSString *idVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]:@"";
                    [dictDataToSend_1 setValue:strIden forKey:@"34"];
                    if (TapedDropDownTag==4) {
                        [dictDataToSend setValue:strVal forKey:@"37"];
                        [dictDataToSend_1 setValue:idVal forKey:@"37"];
                        //***code added for Bug-29637 By M.
                        [pigletIdentityJsonDict setValue:strVal forKey:@"37"];
                        
                    }else if (TapedDropDownTag==5){
                        [dictDataToSend setValue:strVal forKey:@"43"];
                        [dictDataToSend_1 setValue:idVal forKey:@"43"];
                        
                    }
                    else if (TapedDropDownTag==6){
                        [dictDataToSend setValue:strVal forKey:@"44"];
                        [dictDataToSend_1 setValue:idVal forKey:@"44"];
                    }
                   // [self.dictDynamic setObject:dictDataToSend forKey:[dictData valueForKey:@"Lb"]];
                   
                    [self.dictJson setObject:dictDataToSend forKey:[dictData valueForKey:@"dk"]];
                }
                else if(array169.count > 1) {
                    dictDataToSend = [array169 lastObject];
                    dictDataToSend_1 = [dictDataToSend mutableCopy];
                    
                    NSString *strIden = dictDataToSend[@"34"];
                  
                    NSString *strVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]:@"";
                    NSString *idVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]:@"";
                    [dictDataToSend_1 setValue:strIden forKey:@"34"];
                    if (TapedDropDownTag==4) {
                        [dictDataToSend setValue:strVal forKey:@"37"];
                        [dictDataToSend_1 setValue:idVal forKey:@"37"];
                        //***code added for Bug-29637 By M.
                        [pigletIdentityJsonDict setValue:strVal forKey:@"37"];
                        
                    }else if (TapedDropDownTag==5){
                        [dictDataToSend setValue:strVal forKey:@"43"];
                        [dictDataToSend_1 setValue:idVal forKey:@"43"];
                        
                    }
                    else if (TapedDropDownTag==6){
                        [dictDataToSend setValue:strVal forKey:@"44"];
                        [dictDataToSend_1 setValue:idVal forKey:@"44"];
                    }
                    // [self.dictDynamic setObject:dictDataToSend forKey:[dictData valueForKey:@"Lb"]];
                    
                    NSMutableArray *mutableArray169 = [array169 mutableCopy];
                    if (!mutableArray169) {
                        mutableArray169 = [NSMutableArray array];
                    }
                    if (![mutableArray169 containsObject:dictDataToSend]){
                        [mutableArray169 addObject:dictDataToSend];
                    }
                   
                    [self.dictJson setObject:mutableArray169 forKey:[dictData valueForKey:@"dk"]];
                }
            } if ([array169 isKindOfClass:[NSMutableDictionary class]]) {
               
                array169_1 =[array169 mutableCopy];
               
                NSString *strIden = [array169 valueForKey:@"34"];
               
                NSString *strVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"visible"]:@"";
                NSString *idVal=[[self.arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]?[[self.arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"]:@"";
               
                
                if (TapedDropDownTag==4) {
                    [array169_1 setValue:strVal forKey:@"37"];
                    //***code added for Bug-29637 By M.
                    [pigletIdentityJsonDict setValue:strVal forKey:@"37"];
                    
                }else if (TapedDropDownTag==5){
                    [array169_1 setValue:strVal forKey:@"43"];
                    
                }
                else if (TapedDropDownTag==6){
                    [array169_1 setValue:strVal forKey:@"44"];
                }
                //[self.dictDynamic setObject:array169 forKey:[dictData valueForKey:@"Lb"]];
                
                [self.dictJson setObject:array169_1 forKey:[dictData valueForKey:@"dk"]];
            }
            //pigdrop = YES;
        }
        else{
            [self.dictDynamic setValue:[[_arrDropDown objectAtIndex:0] valueForKey:@"visible"] forKey:[dictData valueForKey:@"Lb"]];
            [self.dictJson setValue:[[_arrDropDown objectAtIndex:0] valueForKey:@"dataTosend"] forKey:[dictData valueForKey:@"dk"]];
        }
        [self.tblDynamic reloadData];
    }
}

//~~~~~ for Piglet Identities by M.
-(void)PigletIdentitiesListUpdate:(NSString *)strIdent {
   // NSLog(@"Received row: %@", strIdent);
    NSString *capIden = [strIdent uppercaseString];
    //NSString *strWithoutLastChar= [capIden substringToIndex:[capIden length] - 1];
    NSMutableArray *tmppigletIdentitiesArray1 = [[NSMutableArray alloc]init];
    NSMutableArray *tmppigletIdentitiesJsonArray1 = [[NSMutableArray alloc]init];
    if([_strFromEditPage isEqualToString:@"FromEdit"] && addnewPigFlg){
        NSMutableArray *tmppigletIdentitiesArray11 = [[NSMutableArray alloc]init];
        NSMutableArray *tmppigletIdentitiesJsonArray11 = [[NSMutableArray alloc]init];

        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
         
        //[tmppigletIdentitiesArray11 addObject:pigletIdentityDict];
        //[tmppigletIdentitiesJsonArray11 addObject:pigletIdentityJsonDict];
        tmppigletIdentitiesArray11  = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray11 = [dictJson valueForKey:@"169"];
        
       
        [tmppigletIdentitiesArray1 addObject:tmppigletIdentitiesArray11];
        [tmppigletIdentitiesJsonArray1 addObject:tmppigletIdentitiesJsonArray11];
        
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 addObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 addObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 addObject:item1];
            }
        }
    }else if([_strFromEditPage isEqualToString:@"FromEdit"] && (!addnewPigFlg)){
       
        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 addObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 addObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 addObject:item1];
            }
        }
    }
    else{
        tmppigletIdentitiesArray1 = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray1 = [dictJson valueForKey:@"169"];
        
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = item[@"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 addObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 addObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 addObject:item1];
            }
        }
    }
    // Handle the row value here

}
//~~~~~ for Piglet Identities by M.
/*
-(void)PigletIdentitiesListUpdateUnchk:(NSString *)strIdent {
   // NSLog(@"Received row: %@", strIdent);
    NSString *capIden = [strIdent uppercaseString];
    //NSString *strWithoutLastChar= [capIden substringToIndex:[capIden length] - 1];
    NSMutableArray *tmppigletIdentitiesArray1 = [[NSMutableArray alloc]init];
    NSMutableArray *tmppigletIdentitiesJsonArray1 = [[NSMutableArray alloc]init];
    if([_strFromEditPage isEqualToString:@"FromEdit"] && addnewPigFlg){
        NSMutableArray *tmppigletIdentitiesArray11 = [[NSMutableArray alloc]init];
        NSMutableArray *tmppigletIdentitiesJsonArray11 = [[NSMutableArray alloc]init];

        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
         
        tmppigletIdentitiesArray11  = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray11 = [dictJson valueForKey:@"169"];
        
       
        [tmppigletIdentitiesArray1 addObject:tmppigletIdentitiesArray11];
        [tmppigletIdentitiesJsonArray1 addObject:tmppigletIdentitiesJsonArray11];
        
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 removeObject:item1];
            }
        }
    }else if([_strFromEditPage isEqualToString:@"FromEdit"] && (!addnewPigFlg)){
       
        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 addObject:item1];
            }
        }
    }
    else{
        tmppigletIdentitiesArray1 = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray1 = [dictJson valueForKey:@"169"];
        
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = item[@"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 removeObject:item1];
            }
        }
    }
    // Handle the row value here

}*/
//~~~~~ for Piglet Identities Bug-29596 made changes to function by M.
-(void)PigletIdentitiesListUpdateUnchk:(NSString *)strIdent {
   // NSLog(@"Received row: %@", strIdent);
    NSString *capIden = [strIdent uppercaseString];
    //NSString *capIden = [capIden1 substringToIndex:[capIden1 length] - 1];
   
    NSMutableArray *tmppigletIdentitiesArray1 = [[NSMutableArray alloc]init];
    NSMutableArray *tmppigletIdentitiesJsonArray1 = [[NSMutableArray alloc]init];
    if([_strFromEditPage isEqualToString:@"FromEdit"] && addnewPigFlg){
        NSMutableArray *tmppigletIdentitiesArray11 = [[NSMutableArray alloc]init];
        NSMutableArray *tmppigletIdentitiesJsonArray11 = [[NSMutableArray alloc]init];

        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
         
        tmppigletIdentitiesArray11  = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray11 = [dictJson valueForKey:@"169"];
        
       
        [tmppigletIdentitiesArray1 addObjectsFromArray:tmppigletIdentitiesArray11];
        [tmppigletIdentitiesJsonArray1 addObject:tmppigletIdentitiesJsonArray11];
        //~~~~ for Piglet Identities added for Bug-29596 By M.
        if (_pigletidentitiesArryinUnchk.count <= 0 && _pigletidentitiesJsonArryinUnchk.count <= 0){
            _pigletIdentitiesArray1 = [tmppigletIdentitiesArray1 mutableCopy];
            _pigletIdentitiesJsonArray1 = [tmppigletIdentitiesJsonArray1 mutableCopy];
        }else{
            _pigletIdentitiesArray1 = [_pigletidentitiesArryinUnchk mutableCopy];
            _pigletIdentitiesJsonArray1 = [_pigletidentitiesJsonArryinUnchk mutableCopy];
        }
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
                _pigletidentitiesArryinUnchk = [_pigletIdentitiesArray1 mutableCopy];
            }
        }
            
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                    _pigletidentitiesJsonArryinUnchk = [_pigletIdentitiesJsonArray1 mutableCopy];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 removeObject:item1];
                _pigletidentitiesJsonArryinUnchk = [_pigletIdentitiesJsonArray1 mutableCopy];
            }
        }
    }else if([_strFromEditPage isEqualToString:@"FromEdit"] && (!addnewPigFlg)){
       
        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
        //~~~~ for Piglet Identities added for Bug-29596 By M.
        if (_pigletidentitiesArryinUnchk.count <= 0 && _pigletidentitiesJsonArryinUnchk.count <= 0){
            _pigletIdentitiesArray1 = [tmppigletIdentitiesArray1 mutableCopy];
            _pigletIdentitiesJsonArray1 = [tmppigletIdentitiesJsonArray1 mutableCopy];
        }else{
            _pigletIdentitiesArray1 = [_pigletidentitiesArryinUnchk mutableCopy];
            _pigletIdentitiesJsonArray1 = [_pigletidentitiesJsonArryinUnchk mutableCopy];
        }
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
                _pigletidentitiesArryinUnchk = [_pigletIdentitiesArray1 mutableCopy];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                    _pigletidentitiesJsonArryinUnchk = [_pigletIdentitiesJsonArray1 mutableCopy];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary
                                                          class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 addObject:item1];
                _pigletidentitiesJsonArryinUnchk = [_pigletIdentitiesJsonArray1 mutableCopy];
            }
        }
    }
    else{
        tmppigletIdentitiesArray1 = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray1 = [dictJson valueForKey:@"169"];
        //~~~~ for Piglet Identities added for Bug-29596 By M.
        if (_pigletidentitiesArryinUnchk.count <= 0 && _pigletidentitiesJsonArryinUnchk.count <= 0){
            _pigletIdentitiesArray1 = [tmppigletIdentitiesArray1 mutableCopy];
            _pigletIdentitiesJsonArray1 = [tmppigletIdentitiesJsonArray1 mutableCopy];
        }else{
            _pigletIdentitiesArray1 = [_pigletidentitiesArryinUnchk mutableCopy];
            _pigletIdentitiesJsonArray1 = [_pigletidentitiesJsonArryinUnchk mutableCopy];
        }
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = item[@"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                
                [_pigletIdentitiesArray1 removeObject:item];
                _pigletidentitiesArryinUnchk = [_pigletIdentitiesArray1 mutableCopy];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                    _pigletidentitiesJsonArryinUnchk = [_pigletIdentitiesJsonArray1 mutableCopy];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary
                                                          class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 removeObject:item1];
                _pigletidentitiesJsonArryinUnchk = [_pigletIdentitiesJsonArray1 mutableCopy];
            }
        }
    }
    // Handle the row value here

}
//~~~~ for Piglet Identities added for Bug-29596 By M.
-(void)AddPigletIdentityToArray{
   
    //[_pigletIdentitiesArray1 addObject: [self.dictDynamic valueForKey:@"Piglet Identities"]];
    //[_pigletIdentitiesJsonArray1 addObject:[dictJson valueForKey:@"169"]];
    NSMutableArray *pigletIdentitiesArrayTmp = [[NSMutableArray alloc]init];
    NSMutableArray *pigletIdentitiesJsonArrayTmp = [[NSMutableArray alloc]init];
    
    pigletIdentitiesArrayTmp  = [self.dictDynamic valueForKey:@"Piglet Identities"];
    pigletIdentitiesJsonArrayTmp = [dictJson valueForKey:@"169"];
    _pigletIdentitiesArray1 = [pigletIdentitiesArrayTmp mutableCopy];
    //_pigletIdentitiesJsonArray1 = [pigletIdentitiesJsonArrayTmp mutableCopy];
    
    //***added for Bug-29646 By M.
    _pigletIdentitiesJsonArray1 = [_pigletIdentitiesJsonArray mutableCopy];
    
    //[_pigletIdentitiesArray1 addObject:pigletIdentitiesArrayTmp];
    //[_pigletIdentitiesJsonArray1 addObject:pigletIdentitiesJsonArrayTmp];
}


//~~~~ for Piglet Identities By M.
-(void)PigletIdentitiesRemoveObject:(NSString *)strRIdent {
    NSLog(@"Received row: %@", strRIdent);
    NSString *capIden = [strRIdent uppercaseString];
    //NSString *strWithoutLastChar= [capIden substringToIndex:[capIden length] - 1];
    NSMutableArray *tmppigletIdentitiesArray1 = [[NSMutableArray alloc]init];
    NSMutableArray *tmppigletIdentitiesJsonArray1 = [[NSMutableArray alloc]init];
    if([_strFromEditPage isEqualToString:@"FromEdit"] && addnewPigFlg){
        NSMutableArray *tmppigletIdentitiesArray11 = [[NSMutableArray alloc]init];
        NSMutableArray *tmppigletIdentitiesJsonArray11 = [[NSMutableArray alloc]init];

        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
         
        tmppigletIdentitiesArray11  = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray11 = [dictJson valueForKey:@"169"];
        
       
        [tmppigletIdentitiesArray1 addObject:tmppigletIdentitiesArray11];
        [tmppigletIdentitiesJsonArray1 addObject:tmppigletIdentitiesJsonArray11];
        
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 removeObject:item1];
            }
        }
    }else if([_strFromEditPage isEqualToString:@"FromEdit"] && (!addnewPigFlg)){
       
        tmppigletIdentitiesArray1 = [self getPigletsJsonDynamicStringToArray:strpigletIdentitiesEdit];
        tmppigletIdentitiesJsonArray1 = [self getPigletsJsonStringToArray:strpigletIdentitiesEdit];
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = [item valueForKey: @"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = [item1 valueForKey: @"34"];//item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 addObject:item1];
            }
        }
    }
    else{
        tmppigletIdentitiesArray1 = [self.dictDynamic valueForKey:@"Piglet Identities"];
        tmppigletIdentitiesJsonArray1 = [dictJson valueForKey:@"169"];
        
        
        for (NSDictionary *item in tmppigletIdentitiesArray1){
            NSString *itemLb = item[@"Identity"];//item[@"Identity"];
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesArray1 removeObject:item];
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item1 in tmppigletIdentitiesJsonArray1){
                NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
                
                if ([itemLb isEqual:capIden]){
                    [_pigletIdentitiesJsonArray1 removeObject:item1];
                }
            }
        }
        if ([tmppigletIdentitiesJsonArray1 isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *item1 =[tmppigletIdentitiesJsonArray1 mutableCopy];
            NSString *itemLb = item1[@"34"]; //--working for device~~~~~~
            
            if ([itemLb isEqual:capIden]){
                [_pigletIdentitiesJsonArray1 removeObject:item1];
            }
        }
    }
    /*for (NSDictionary *dict in _arrDynamic){
        if ([[dict valueForKey:@"dk"]integerValue] == 169){
            [self.dictDynamic setValue:_pigletIdentitiesArray1 forKey:[dict valueForKey:@"Lb"]];
            [dictJson setValue:_pigletIdentitiesJsonArray1 forKey:[dict valueForKey:@"dk"]];
        }
    } */
}

//~~~~~for Piglet Identities By M.
- (void)clearAlldicts{
    pigletIdentityDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"Identity": @"",
        @"Tattoo": @"",
        @"Transponder": @"",
        @"Sex": @"",
        @"Weight": @0,
        @"Teats": @0,
        @"TeatsLeft": @0,
        @"TeatsBBL": @0,
        @"TeatsBBR": @0,
        @"Color": @"",
        @"Designation": @""
    }];
    pigletIdentityJsonDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"34": @"", //Identity
        @"35": @"", //Tattoo
        @"36": @"", //Transponder
        @"37": @"", //Sex
        @"38": @0,//Weight
        @"39": @0, //Teats
        @"40": @0,//TeatsLeft
        @"41": @0, //TeatsBBL
        @"42": @0, //TeatsBBR
        @"43": @"", //Color
        @"44": @"" //Designation
    }];
}
    //~~~~~ for Piglet Identities by M.
    - (void)showAlertFromCell:(nonnull UITableViewCell *)cell {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                    message:@"Please fill in all values for Piglet Identity"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
           UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil];
           [alertController addAction:okAction];
           [self presentViewController:alertController animated:YES completion:nil];
    }

- (NSString *)getPigletIDS:(NSString *)inPString optVal:(int)inputopt{
    NSString *strId;
    NSArray *arrDropDownSex = [[CoreDataHandler sharedHandler]getValuesToListWithEntityName:@"Sex" andPredicate:nil andSortDescriptors:nil];
    NSArray *arrDropDownColor = [[CoreDataHandler sharedHandler]getValuesToListWithEntityName:@"Color" andPredicate:nil andSortDescriptors:nil];
    NSArray *arrDropDownDesig = [[CoreDataHandler sharedHandler]getValuesToListWithEntityName:@"Designation" andPredicate:nil andSortDescriptors:nil];
    
    switch(inputopt){
        case 1:
            //code changed for Sex for Bug-29678 By M.
            for (int count=0; count<arrDropDownSex.count; count++)
            {
                NSString *dtValue = [[arrDropDownSex objectAtIndex:count] valueForKey:@"ln"]?[[arrDropDownSex objectAtIndex:count] valueForKey:@"ln"]:@"";
                if ([dtValue isEqualToString:inPString]) {
                    strId = [[arrDropDownSex objectAtIndex:count] valueForKey:@"id"]?[[arrDropDownSex objectAtIndex:count] valueForKey:@"id"]:@"";
                    break;
                }
            }
            return strId;
            break;
        case 2:
            for (int count=0; count<arrDropDownColor.count; count++)
            {
                NSString *dtValue = [[arrDropDownColor objectAtIndex:count] valueForKey:@"ln"]?[[arrDropDownColor objectAtIndex:count] valueForKey:@"ln"]:@"";
                if ([dtValue isEqualToString:inPString]) {
                    strId = [[arrDropDownColor objectAtIndex:count] valueForKey:@"id"]?[[arrDropDownColor objectAtIndex:count] valueForKey:@"id"]:@"";
                    break;
                }
            }
            return strId;
            break;
            
        case 3:
            for (int count=0; count<arrDropDownDesig.count; count++)
            {
                NSString *dtValue = [[arrDropDownDesig objectAtIndex:count] valueForKey:@"ln"]?[[arrDropDownDesig objectAtIndex:count] valueForKey:@"ln"]:@"";
                if ([dtValue isEqualToString:inPString]) {
                    strId = [[arrDropDownDesig objectAtIndex:count] valueForKey:@"id"]?[[arrDropDownDesig objectAtIndex:count] valueForKey:@"id"]:@"";
                    break;
                }
            }
            return strId;
            break;
        case 4:
            //code changed for Sex for Bug-29678 By M.
            for (int count=0; count<arrDropDownSex.count; count++)
            {
                NSString *dtValue = [[arrDropDownSex objectAtIndex:count] valueForKey:@"id"]?[[arrDropDownSex objectAtIndex:count] valueForKey:@"id"]:@"";
                if ([dtValue isEqualToString:inPString]) {
                    strId = [[arrDropDownSex objectAtIndex:count] valueForKey:@"ln"]?[[arrDropDownSex objectAtIndex:count] valueForKey:@"ln"]:@"";
                    break;
                }
            }
            return strId;
            break;
        case 5:
            for (int count=0; count<arrDropDownColor.count; count++)
            {
                NSString *dtValue = [[arrDropDownColor objectAtIndex:count] valueForKey:@"id"]?[[arrDropDownColor objectAtIndex:count] valueForKey:@"id"]:@"";
                if ([dtValue isEqualToString:inPString]) {
                    strId = [[arrDropDownColor objectAtIndex:count] valueForKey:@"ln"]?[[arrDropDownColor objectAtIndex:count] valueForKey:@"ln"]:@"";
                    break;
                }
            }
            return strId;
            break;
        case 6:
            for (int count=0; count<arrDropDownDesig.count; count++)
            {
                NSString *dtValue = [[arrDropDownDesig objectAtIndex:count] valueForKey:@"id"]?[[arrDropDownDesig objectAtIndex:count] valueForKey:@"id"]:@"";
                if ([dtValue isEqualToString:inPString]) {
                    strId = [[arrDropDownDesig objectAtIndex:count] valueForKey:@"ln"]?[[arrDropDownDesig objectAtIndex:count] valueForKey:@"ln"]:@"";
                    break;
                }
            }
            return strId;
            break;
            
    }
    return nil;
}
- (PigletIdentitiesTableViewCell *)findCellForTextField:(UITextField *)textField {
    UIResponder *responder = textField;
    while (![responder isKindOfClass:[PigletIdentitiesTableViewCell class]] && responder != nil) {
        responder = [responder nextResponder];
    }
    return (PigletIdentitiesTableViewCell *)responder;
}
//~~~~~~added for Piglet Identities By M.
-(NSMutableArray *)getPigletsJsonDynamicStringToArray:(NSString *)PigletsJson{
    NSMutableArray *pigletsArray = [[NSMutableArray alloc]init];
    NSData *jsonData = [PigletsJson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
   
    if (!error) {
        for (NSDictionary *dict in jsonArray) {
            NSMutableDictionary *editdata = [[NSMutableDictionary alloc]init];
            NSString *tmpSx,*tmpCol,*tmpDesg;
            
            [editdata setValue:dict[@"Identity"] forKey:@"Identity"];
            
            [editdata setValue:dict[@"Tattoo"] forKey:@"Tattoo"];
            
            [editdata setValue:dict[@"Transponder"] forKey:@"Transponder"];
            
            tmpSx = [self getPigletIDS:dict[@"Sex"] optVal:4];
            [editdata setValue:tmpSx forKey:@"Sex"];
            
            [editdata setValue:dict[@"Weight"] forKey:@"Weight"];
            
            [editdata setValue:dict[@"Teats"] forKey:@"Teats"];
            
            [editdata setValue:dict[@"TeatsLeft"] forKey:@"TeatsLeft"];
            
            [editdata setValue:dict[@"TeatsBBLeft"] forKey:@"TeatsBBL"];
            
            [editdata setValue:dict[@"TeatsBBRight"] forKey:@"TeatsBBR"];
            
            tmpCol = [self getPigletIDS:dict[@"Color"] optVal:5];
            [editdata setValue:tmpCol forKey:@"Color"];
            
            tmpDesg = [self getPigletIDS:dict[@"Designation"] optVal:6];
            [editdata setValue:tmpDesg forKey:@"Designation"];
            
            [pigletsArray addObject:editdata];
        }
    }
    return pigletsArray;
}
//~~~~~~added for Piglet Identities By M.
-(NSMutableArray *)getPigletsJsonStringToArray:(NSString *)PigletsJson{
    NSMutableArray *pigletsArray = [[NSMutableArray alloc]init];
    NSData *jsonData = [PigletsJson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (!error) {
        for (NSDictionary *dict in jsonArray) {
            NSMutableDictionary *editdata = [[NSMutableDictionary alloc]init];
            NSString *tmpSx,*tmpCol,*tmpDesg;
            
            [editdata setValue:dict[@"Identity"] forKey:@"34"];
            
            [editdata setValue:dict[@"Tattoo"] forKey:@"35"];
            
            [editdata setValue:dict[@"Transponder"] forKey:@"36"];
            
            tmpSx = [self getPigletIDS:dict[@"Sex"] optVal:4];
            [editdata setValue:tmpSx forKey:@"37"];
            
            [editdata setValue:dict[@"Weight"] forKey:@"38"];
            
            [editdata setValue:dict[@"Teats"] forKey:@"39"];
            
            [editdata setValue:dict[@"TeatsLeft"] forKey:@"40"];
            
            [editdata setValue:dict[@"TeatsBBLeft"] forKey:@"41"];
            
            [editdata setValue:dict[@"TeatsBBRight"] forKey:@"42"];
            
            tmpCol = [self getPigletIDS:dict[@"Color"] optVal:5];
            [editdata setValue:tmpCol forKey:@"43"];
            
            tmpDesg = [self getPigletIDS:dict[@"Designation"] optVal:6];
            [editdata setValue:tmpDesg forKey:@"44"];
            //+++ added for piglet Identities Transponder issue By M.
            
            [editdata setValue:dict[@"IdentityDBKey"] forKey:@"IdentityDBKey"];
            
            [editdata setValue:dict[@"UniqueKey"] forKey:@"UniqueKey"];
            
            [pigletsArray addObject:editdata];
        }
    }
    return pigletsArray;
}
-(NSMutableArray*)ConvertStrTOArrayEdit:(NSString *)pigStrEdit{
    NSMutableArray *pigletsArray = [[NSMutableArray alloc]init];
    NSData *jsonData = [pigStrEdit dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (!error) {
        for (NSDictionary *dict in jsonArray) {
            NSMutableDictionary *editdata = [[NSMutableDictionary alloc]init];
            NSString *tmpSx,*tmpCol,*tmpDesg;
            
            [editdata setValue:dict[@"Identity"] forKey:@"34"];
            
            [editdata setValue:dict[@"Tattoo"] forKey:@"35"];
            
            [editdata setValue:dict[@"Transponder"] forKey:@"36"];
            
            tmpSx = [self getPigletIDS:dict[@"Sex"] optVal:4];
            [editdata setValue:tmpSx forKey:@"37"];
            
            [editdata setValue:dict[@"Weight"] forKey:@"38"];
            
            [editdata setValue:dict[@"Teats"] forKey:@"39"];
            
            [editdata setValue:dict[@"TeatsLeft"] forKey:@"40"];
            
            [editdata setValue:dict[@"TeatsBBLeft"] forKey:@"41"];
            
            [editdata setValue:dict[@"TeatsBBRight"] forKey:@"42"];
            
            tmpCol = [self getPigletIDS:dict[@"Color"] optVal:5];
            [editdata setValue:tmpCol forKey:@"43"];
            
            tmpDesg = [self getPigletIDS:dict[@"Designation"] optVal:6];
            [editdata setValue:tmpDesg forKey:@"44"];
            
            [pigletsArray addObject:editdata];
        }
    }
    return pigletsArray;
}
- (BOOL)isStringInYYYYMMDDFormat:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    // Set the locale to en_US_POSIX to ensure consistent parsing regardless of the user's locale settings
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    return (date != nil);
}
NSString *convertDateFormat(NSString *dateString) {
    // Create a date formatter for the original format (dd-MM-yyyy)
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"dd-MM-yyyy"];
    
    // Parse the input string into a NSDate object
    NSDate *date = [inputFormatter dateFromString:dateString];
    
    if (!date) {
        // If the input string is not a valid date, return nil or handle the error
        NSLog(@"Invalid date format");
        return nil;
    }
    
    // Create a date formatter for the new format (yyyy-MM-dd)
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Convert the NSDate object to the new format string
    NSString *formattedDate = [outputFormatter stringFromDate:date];
    
    return formattedDate;
}
@end
