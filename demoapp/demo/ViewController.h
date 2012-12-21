//
//  ViewController.h
//  demo
//
//  Created by --- on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SetValueViewController;
@class ChangeUserViewController;

@interface ViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate> {
    IBOutlet UITextField *_txtServer;
    IBOutlet UITextField *_txtSerialKey;
    IBOutlet UILabel *_token;
    IBOutlet UISwitch *_fullscreen;
    IBOutlet UIScrollView *_scollView;
    
}

- (IBAction) onApplyServer:(id)sender;
- (IBAction) onApplySerialKey:(id)sender;

- (IBAction) onSignIn:(id)sender;
- (IBAction) onSignOut:(id)sender;
- (IBAction) onShare:(id)sender;
- (IBAction) onCustom:(id)sender;
- (IBAction) onPendingMessages:(id)sender;

- (IBAction) onCustomCancel: (id) sender;
- (IBAction) onCustomOK: (id) sender;

- (IBAction) onViewmodeChanged:(id)sender;
- (IBAction) onSetValue:(id)sender;
- (IBAction) onChangeUser:(id)sender;

- (IBAction)onUnregister:(id)sender;
- (IBAction)_btnReInitPressed:(id)sender;


@property (nonatomic, strong) SetValueViewController* setValueController;
@property (nonatomic, strong) ChangeUserViewController* changeUserController;

@end
