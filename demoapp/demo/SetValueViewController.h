//
//  SetValueViewController.h
//  demo
//
//  Created by --- on 11/5/12.
//
//

#import <UIKit/UIKit.h>

@interface SetValueViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *lblNameString;
@property (retain, nonatomic) IBOutlet UITextField *lblValueString;
@property (retain, nonatomic) IBOutlet UITextField *lblNameDouble;
@property (retain, nonatomic) IBOutlet UITextField *lblValueDouble;
@property (retain, nonatomic) IBOutlet UITextField *lblNameBoolean;
@property (retain, nonatomic) IBOutlet UITextField *lblValueBoolean;
@property (retain, nonatomic) IBOutlet UITextField *lblNameDate;
@property (retain, nonatomic) IBOutlet UITextField *lblValueDate;
- (IBAction)btnOkClick:(id)sender;
- (IBAction)btnCancelClick:(id)sender;

@end
