//
//  LoginViewController.m
//  demo
//
//  Created by --- on 8/4/12.
//
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "CMClient.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _username.text = [defaults stringForKey: @"LOGIN"];
    _password.text = [defaults stringForKey: @"PASSWORD"];
    _email.text = [defaults stringForKey: @"EMAIL"];
    _version.text = [NSString stringWithFormat: @"Version: %@", CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey)];
}

- (IBAction) onLogin:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: _username.text forKey: @"LOGIN"];
    [defaults setValue: _password.text forKey: @"PASSWORD"];
    [defaults setValue: _email.text forKey: @"EMAIL"];
    [defaults synchronize];
    
    [CMClient init];

    CMClient* sharedClient = [CMClient sharedInstance];
    
    sharedClient.useGps = YES;
    
    sharedClient.userId = _username.text;
    
    NSString* url = [defaults stringForKey: @"SERVER"];
    if( url != nil && url.length > 0 ){
        sharedClient.serverUrl = [defaults stringForKey: @"SERVER"];
    }
    
    NSString* serial = [defaults stringForKey: @"SERIAL"];
    if(serial != nil && serial.length > 0){
        sharedClient.serial = [defaults stringForKey: @"SERIAL"];
    }
    
    if([defaults stringForKey: @"EMAIL"]){
        sharedClient.email = [defaults stringForKey: @"EMAIL"];
    }
    
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: sharedClient.serial forKey: @"SERIAL"];
    [defaults setValue: sharedClient.serverUrl forKey: @"SERVER"];
    [defaults synchronize];

    
    [[CMClient sharedInstance] setGlobalHandler:^(NSError *error)
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LoginViewController: Error" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         [alert release];
     }successBlock:^()
     {
         NSLog(@"LoginViewController: server responce is ok!");
     }];
    
    
    [[CMClient sharedInstance] registerUser:nil succesBlock:nil];
    
    ViewController* controller = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController: controller animated: true];
}

@end
