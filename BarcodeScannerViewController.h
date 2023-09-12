//
//  BarcodeScannerViewController.h
//  PigChamp
//
//  Created by Venturelabour on 22/12/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@protocol barcodeScanner <NSObject>
-(void)scannedBarcode:(NSString*)barcode;
@end

@interface BarcodeScannerViewController : UIViewController
{
   // id<barcodeScanner> delegate;
    
}


@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property(nonatomic,weak)id delegate;
//@property(weak,nonatomic) id<PermissionSettingsDelegate> delegateapp;

@end
