//
//  SetValueViewController.m
//  demo
//
//  Created by --- on 11/5/12.
//
//

#import "ChangeUserViewController.h"
#import "CMClient.h"

@interface ChangeUserViewController ()

@end

@implementation ChangeUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_lblNameString release];
    [_lblNameString release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLblNameString:nil];
    [self setLblNameString:nil];
    [super viewDidUnload];
}
- (IBAction)btnOkClick:(id)sender {
    
    @try {
        if( _lblNameString.text.length > 0  )
        {
            [[CMClient sharedInstance] changeUserId:_lblNameString.text errorBlock:nil succesBlock:nil];
            
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue: _lblNameString.text forKey: @"LOGIN"];
            [defaults synchronize];
        }
        
        
    }
    @catch (NSException *exception) {
        NSString* ex  = [NSString stringWithFormat:@"%@\n%@", exception.name, exception.reason];
       
        [[[UIAlertView alloc] initWithTitle:@"Error" message:ex delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
    }
    @finally {
    }
    
    
    [self.view removeFromSuperview];
}

- (IBAction)btnCancelClick:(id)sender {
    [self.view removeFromSuperview];
}
@end
