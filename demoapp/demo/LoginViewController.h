//
//  LoginViewController.h
//  demo
//
//  Created by --- on 8/4/12.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController {
    IBOutlet UITextField* _username;
    IBOutlet UITextField* _password;
    IBOutlet UITextField* _email;
    IBOutlet UILabel* _version;
}

- (IBAction) onLogin:(id)sender;

@end
