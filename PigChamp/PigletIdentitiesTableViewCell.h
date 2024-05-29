//
//  PigletIdentitiesTableViewCell.h
//  PigChamp
//
//  Created by Nikhil Nandre on 12/3/20.
//  Copyright © 2020 Venturelabour. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DynamicFormViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol PigletIdentitiesTableViewCellDelegate <NSObject>
- (void)showAlertFromCell:(UITableViewCell *)cell;
- (void)PigletIdentitiesListUpdate:(NSString *)strIden;
- (void)PigletIdentitiesRemoveObject:(NSString *)strRIden;
-(void)PigletIdentitiesListUpdateUnchk:(NSString *)strIdent;

- (void)clearAlldicts;
@end

@interface PigletIdentitiesTableViewCell : UITableViewCell  <DynamicFormViewControllerDelegate>
@property (nonatomic, weak) id<PigletIdentitiesTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (weak, nonatomic) IBOutlet UILabel *piglet_Identity;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_den;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCell;
@property (weak, nonatomic) IBOutlet UIButton *btnRemoveCell;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_Tattoo;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_Weight;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_Teats;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_TeatsLeft;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_TeatsBBR;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_TeatsBBL;
@property (weak, nonatomic) IBOutlet UITextField *txtpiglet_transp;
@property (weak, nonatomic) IBOutlet UITableView *identitiestblView;
@property(nonatomic,strong)NSMutableArray *pigletIdenListArray;
@property (weak, nonatomic) IBOutlet UIButton *btnSex;
@property (weak, nonatomic) IBOutlet UIButton *btnColor;
@property (weak, nonatomic) IBOutlet UIButton *btnDestination;
@property (weak, nonatomic) IBOutlet UIButton *btnTattaoScanner;

-(void)showPigletIdentityList:(NSString *)pigletStringEdit;
@end

NS_ASSUME_NONNULL_END
