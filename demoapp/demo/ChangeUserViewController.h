//
//  SetValueViewController.h
//  demo
//
//  Created by --- on 11/5/12.
//
//

#import <UIKit/UIKit.h>

@interface ChangeUserViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *lblNameString;

- (IBAction)btnOkClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;

@end
