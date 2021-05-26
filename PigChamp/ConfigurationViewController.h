//
//  ConfigurationViewController.h
//  PigChamp
//
//  Created by Venturelabour on 30/04/19.
//  Copyright © 2019 Venturelabour. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationViewController : UIViewController<UITextViewDelegate>
- (IBAction)btnSaveClicked:(id)sender;
//@property (weak, nonatomic) IBOutlet UITextField *txtURL;
- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnResetClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *txtURL;

@end

NS_ASSUME_NONNULL_END
