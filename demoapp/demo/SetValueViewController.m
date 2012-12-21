//
//  SetValueViewController.m
//  demo
//
//  Created by --- on 11/5/12.
//
//

#import "SetValueViewController.h"
#import "CMClient.h"

@interface SetValueViewController ()

@end

@implementation SetValueViewController

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
    [_lblValueString release];
    [_lblNameDouble release];
    [_lblValueDouble release];
    [_lblNameBoolean release];
    [_lblValueBoolean release];
    [_lblNameDate release];
    [_lblValueDate release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLblNameString:nil];
    [self setLblValueString:nil];
    [self setLblNameDouble:nil];
    [self setLblValueDouble:nil];
    [self setLblNameBoolean:nil];
    [self setLblValueBoolean:nil];
    [self setLblNameDate:nil];
    [self setLblValueDate:nil];
    [super viewDidUnload];
}
- (IBAction)btnOkClick:(id)sender {
    
    @try {
        if( _lblNameString.text.length > 0 && _lblValueString.text.length > 0 )
            [[CMClient sharedInstance] setStringVal:_lblValueString.text withName:_lblNameString.text errorBlock:nil succesBlock:nil];
        
        if( _lblNameDouble.text.length > 0 && _lblValueDouble.text.length > 0 )
            [[CMClient sharedInstance] setDoubleVal:[_lblValueDouble.text doubleValue] withName:_lblNameDouble.text errorBlock:nil succesBlock:nil];
        
        if( _lblNameBoolean.text.length > 0 && _lblValueBoolean.text.length > 0 )
            [[CMClient sharedInstance] setBooleanVal:[_lblValueBoolean.text boolValue] withName:_lblNameBoolean.text errorBlock:nil succesBlock:nil];
        
        
        if( _lblNameDate.text.length > 0 && _lblValueDate.text.length > 0 )
        {
            NSDateFormatter* formatter = [NSDateFormatter new];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate* val = [formatter dateFromString:_lblValueDate.text];
            [[CMClient sharedInstance] setDateVal:val withName:_lblNameDate.text errorBlock:nil succesBlock:nil];
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
