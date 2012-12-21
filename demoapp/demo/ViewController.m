//
//  ViewController.m
//  demo
//
//  Created by --- on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "CMClient.h"
#import "SetValueViewController.h"
#import "ChangeUserViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CMClient sharedInstance].viewMode = CMClientViewMode_Fullscreen;
	
    _txtServer.text = [CMClient sharedInstance].serverUrl;
    _txtServer.delegate = self;
    
    //_txtServer.text = @"http://will.clyng.com";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _txtServer.text = [defaults objectForKey:@"SERVER"];	
    
    _txtSerialKey.text = [CMClient sharedInstance].serial;
    _txtSerialKey.delegate = self;
    
    //_txtSerialKey.text = @"9453ca9d-3b4d-48ee-b8f9-3e2afe9fce31";
    _txtSerialKey.text = [defaults objectForKey:@"SERIAL"];
    
    [_scollView setContentSize:CGSizeMake(320.0f, 500.0f)];
    
    [self performSelector: @selector(updateDeviceToken) withObject: nil afterDelay: 1.0f];
    
    
    [[CMClient sharedInstance] setGlobalHandler:^(NSError*err)
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ViewController: Error" message:[err description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         [alert release];
     }successBlock:^()
     {
         NSLog(@"viewDidLoad: server responce is ok!");
     }];
     
}

- (void) updateDeviceToken {
    NSString* token = [[CMClient sharedInstance] performSelector: @selector(deviceToken)];
    if(token.length > 0){
        _token.text = token;
    } else {
        [self performSelector: @selector(updateDeviceToken) withObject: nil afterDelay: 1.0f];
    }
}

- (void)viewDidUnload
{
    [_scollView release];
    _scollView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark ------
#pragma mark IBActions

- (IBAction) onApplyServer:(id)sender {
    [[CMClient sharedInstance] setServerUrl: _txtServer.text];
    [[CMClient sharedInstance] registerUser:^(NSError *err)
     {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"LOCAL FUNCTION onApplyServer Error" message:[err description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
         [alert release];
     }
                                succesBlock:^(){
         NSLog(@"onApplyServer LOCAL SUCCESS!!!");
    }];
    [_txtServer resignFirstResponder];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: _txtServer.text forKey: @"SERVER"];
    [defaults synchronize];
}

- (IBAction) onApplySerialKey:(id)sender{
    [[CMClient sharedInstance] setSerial: _txtSerialKey.text];
    [[CMClient sharedInstance] registerUser:nil succesBlock:nil];
    [_txtSerialKey resignFirstResponder];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: _txtSerialKey.text forKey: @"SERIAL"];
    [defaults synchronize];
}

- (IBAction) onSignIn:(id)sender {
    [[CMClient sharedInstance] sendEvent: @"sign-in" withDetails:nil errorBlock:nil successBlock:nil];
}

- (IBAction) onSignOut:(id)sender {
    [[CMClient sharedInstance] sendEvent: @"sign-out" withDetails: nil errorBlock:nil successBlock:nil];
}

- (IBAction) onShare:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Share event" 
                                                    message: nil 
                                                   delegate: self 
                                          cancelButtonTitle: @"Cancel" 
                                          otherButtonTitles: @"OK", nil];
    [alert performSelector: @selector(addTextFieldWithValue:label:) withObject: @"" withObject: @"shared-with"];
    alert.tag = 1;
    [alert show];
    [alert release];
}

- (IBAction) onCustom:(id)sender {
    [self.view viewWithTag: 1000].hidden = false;
}

- (IBAction) onPendingMessages:(id)sender {
    [[CMClient sharedInstance] getPendingMessages:nil
                                     successBlock:^{
                                         NSLog(@"getPendingMessages OK!");
                                     }];
}

- (IBAction)_btnReInitPressed:(id)sender
{

    NSString* userId    = [CMClient sharedInstance].userId;
    NSString* email     = [CMClient sharedInstance].email;
    BOOL gps            = [CMClient sharedInstance].useGps;
    NSString* serverUrl = [CMClient sharedInstance].serverUrl;
    NSString* serial = [CMClient sharedInstance].serial;
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:serverUrl forKey: serverUrl];
    [properties setObject:serial forKey: cm_apiKey];

    [CMClient initWithDictionary:properties];
    [properties release];
    
    [CMClient sharedInstance].userId = userId;
    [CMClient sharedInstance].email = email;
    [CMClient sharedInstance].useGps = gps;    
}

- (IBAction)onUnregister:(id)sender
{
    
    [[CMClient sharedInstance] unregisterUser:nil succesBlock:nil];

}





- (void) removeFocusFromFields {
    for(int i = 1001; i <= 1007; i++){
        [[self.view viewWithTag: i] resignFirstResponder];
        [(UITextField*)[self.view viewWithTag: i] setText: @""];
    }
}

- (IBAction) onCustomCancel: (id) sender {
    [self.view viewWithTag: 1000].hidden = true;
    [self removeFocusFromFields];
}



- (NSString*) valueForField: (int) tag {
    UITextField* f = (UITextField*) [self.view viewWithTag: tag];
    return f.text;
}

- (IBAction) onCustomOK: (id) sender {
    [self.view viewWithTag: 1000].hidden = true;

    NSMutableArray *arrayKeys = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *arrayValues = [[[NSMutableArray alloc] init] autorelease];
    
    for (int i=0; i<3 ;i++)
    {
        if ([[self valueForField:1003 + i * 2] length])
        {
            [arrayKeys addObject:[self valueForField:1002 + i * 2]];
            [arrayValues addObject:[self valueForField:1003 + i * 2]];
        }
    }

    NSDictionary * params = [NSDictionary dictionaryWithObjects: arrayValues forKeys: arrayKeys];    
    
    [[CMClient sharedInstance] sendEvent: [self valueForField: 1001] withDetails: params errorBlock:nil successBlock:nil];
    [self removeFocusFromFields];
}

- (IBAction) onViewmodeChanged:(id)sender {
    [[CMClient sharedInstance] setViewMode: _fullscreen.on ? CMClientViewMode_Fullscreen : CMClientViewMode_Normal];
}

- (IBAction)onSetValue:(id)sender {
    if( self.setValueController == nil )
        self.setValueController = [[SetValueViewController alloc] initWithNibName:@"SetValueViewController" bundle:nil];
    
    [self.view addSubview:self.setValueController.view];
}

- (IBAction)onChangeUser:(id)sender {
    if( self.changeUserController == nil )
        self.changeUserController = [[ChangeUserViewController alloc] initWithNibName:@"ChangeUserViewController" bundle:nil];
    
    [self.view addSubview:self.changeUserController.view];
}

#pragma mark ------
#pragma mark UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

#pragma mark ------
#pragma mark alertView

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if(buttonIndex == 1){
        if(alertView.tag == 1){
            NSString* value = [alertView textFieldAtIndex: 0].text;
            [[CMClient sharedInstance] sendEvent: @"share" withDetails: [NSDictionary dictionaryWithObject: value forKey: @"shared-with"] errorBlock:nil successBlock:nil];
            
        }
        
    }
}

#pragma mark ------
#pragma mark dealloc

- (void)dealloc {
    [_scollView release];
    [super dealloc];
}
@end
