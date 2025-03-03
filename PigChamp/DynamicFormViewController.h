//
//  DynamicFormViewController.h
//  PigChamp
//
//  Created by Venturelabour on 26/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"
//#import "BarcodeScannerViewController.h"
#import <Google/Analytics.h>
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "BarcodeScannerViewController.h"


//#import "APParser.h"
@class CustomIOS7AlertView;
@class SettingsViewController;
@class DropDown;
//~~~For piglet identites By M.
@protocol DynamicFormViewControllerDelegate<NSObject>
- (void)ClearPigletIdentitiesList;

@end
@interface DynamicFormViewController : UIViewController<barcodeScanner,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate,SlideNavigationControllerDelegate,NSStreamDelegate> {
    SettingsViewController *settingsViewController;
    BarcodeScannerViewController *barcodeScannerViewController;
    ////***added one string for bug- 27755
    NSString *strScan,*strScandk,*strYes,*strNo,*strOk,*strCancel,*strWait,*strNoInternet,*strStillLive,*strClear,*strServerErr,*strUnauthorised,*strSignOff,*strMsgTranspoder;
    //NSString *strSplitSex,*strSplitWex;
    //***code added for SplitSex Functionality Bug-27775 By M @@@@@
    BOOL strSplitSex,strSplitWex,strSplitLosses,strSplitFostered,strSplitDefects,strSplitTreatments;
    MenuViewController *tlc;
}

#pragma mark - Property
@property (weak, nonatomic) IBOutlet UIView *vwcontainer;
@property (weak, nonatomic) NSString *strDateFormat;
@property (weak, nonatomic) NSString *strOutputDateFormat;
@property (weak, nonatomic) IBOutlet UIView *vwFooter;
@property (weak, nonatomic) IBOutlet UIButton *btnDropDown;
@property(nonatomic,strong)UIView *activeTextField;
@property (weak, nonatomic) IBOutlet UITableView *tblDynamic;
@property(nonatomic,strong)IBOutlet UIDatePicker *dtPicker;
@property(strong, nonatomic)IBOutlet UIPickerView *pickerDropDown;
@property(nonatomic,strong)NSMutableArray *arrDropDown;
@property(nonatomic,strong)NSMutableArray *arrDynamic;
@property(nonatomic,strong) NSMutableDictionary *dictDynamic,*dictJson,*dictReload;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedValue;
@property(nonatomic,strong)NSString *strEventCode;
@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,strong)NSString *strTitleInt;
@property(nonatomic,strong)NSString *lblTitle,*strFromEditPage;
@property (strong, nonatomic) CustomIOS7AlertView *alertForOrgName;
@property (strong, nonatomic) CustomIOS7AlertView *alertForPickUpDate;
@property(strong,nonatomic)CustomIOS7AlertView *customIOS7AlertView;
@property(nonatomic,strong) NSDictionary *dict;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIView *vwOverlay;
//~~~~ added for Piglet Identities By M.
@property(nonatomic,strong)NSMutableArray *pigletIdentitiesArray,*pigletIdentitiesArray1,*tmparray;
@property(nonatomic,strong)NSMutableArray *pigletIdentitiesJsonArray,*pigletIdentitiesJsonArray1;

@property(nonatomic,strong)NSMutableArray *pigletidentitiesArryinUnchk,*pigletidentitiesJsonArryinUnchk;
@property (weak, nonatomic) IBOutlet UITextField *txtReference;
///***added for new API call for User_Paramters
@property (nonatomic) NSNumber *boolVal;
@property (weak, nonatomic) IBOutlet UIButton *btnConnectAccessory;

- (IBAction)btnConnectAccessoryClicked:(id)sender;
//~~~For piglet identites By M.
@property (nonatomic, weak) id<DynamicFormViewControllerDelegate> delegate;
#pragma mark method
-(void)callEdit;

@end
