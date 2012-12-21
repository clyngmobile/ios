//
//  MessagesViewController.m
//  ClyngMobile
//
//  Created by --- on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesViewController.h"
#import "Message.h"
#import "CMClient.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController

@synthesize delegate = _delegate;

- (id) init
{
    self = [super init];
    if (self) {
        _messages = [[NSMutableArray alloc] initWithCapacity: 10];
    }
    return self;
}

- (void) dealloc {
    [_messages release];
    [_txtCounter release];
    [_webView release];
    [_segmented release];
    [_activity release];
    [super dealloc];
}

- (void) loadView {
    int width = [UIScreen mainScreen].applicationFrame.size.width;
    int height = [UIScreen mainScreen].applicationFrame.size.height;
    
    UIView* view = [[[UIView alloc] initWithFrame: [UIScreen mainScreen].applicationFrame] autorelease];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    
    UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, width, 44)] autorelease];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [view addSubview: toolbar];
    
    UIBarButtonItem* btnDone = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone 
                                                                             target: self 
                                                                              action: @selector(onDoneClicked:)] autorelease];
    
    UIBarButtonItem* btnRemove = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemTrash
                                                                                target: self 
                                                                                action: @selector(onRemoveClicked:)] autorelease];
    btnRemove.style = UIBarButtonItemStyleBordered;
    
    _txtCounter = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 80, toolbar.frame.size.height)];
    _txtCounter.textColor = [UIColor whiteColor];
    _txtCounter.font = [UIFont boldSystemFontOfSize: 20];
    _txtCounter.backgroundColor = [UIColor clearColor];
    _txtCounter.textAlignment = UITextAlignmentCenter;
    
    UIBarButtonItem* title = [[[UIBarButtonItem alloc] initWithCustomView: _txtCounter] autorelease];
    
    
    _segmented = [[UISegmentedControl alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
    _segmented.segmentedControlStyle = UISegmentedControlStyleBar;
    _segmented.momentary = true;
    [_segmented insertSegmentWithImage: [UIImage imageNamed: @"ClyngMobile.bundle/arrow-north.png"] atIndex: 0 animated: false];
    [_segmented insertSegmentWithImage: [UIImage imageNamed: @"ClyngMobile.bundle/arrow-south.png"] atIndex: 1 animated: false];
    [_segmented setWidth: 50 forSegmentAtIndex: 0];
    [_segmented setWidth: 50 forSegmentAtIndex: 1];
    [_segmented sizeToFit];
    [_segmented addTarget: self action: @selector(onNextPrevClicked:) forControlEvents: UIControlEventValueChanged];
    
    UIBarButtonItem* segmentHolder = [[[UIBarButtonItem alloc] initWithCustomView: _segmented] autorelease];
    
    UIBarButtonItem* s1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease];
    UIBarButtonItem* s2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil] autorelease];
    
    [toolbar setItems: [NSArray arrayWithObjects: btnDone, btnRemove, s1, title, s2, segmentHolder, nil]];
    
    _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, toolbar.frame.size.height, width, height - toolbar.frame.size.height)];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webView.delegate = self;
    [view addSubview: _webView];
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    _activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | 
                                 UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    _activity.center = view.center;
    _activity.hidesWhenStopped = true;
    [view addSubview: _activity];
    
    self.view = view;
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [_activity startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [_activity stopAnimating];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self showMessage];
}

- (void)viewDidUnload {
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return true;
}

- (IBAction) onDoneClicked: (id) sender {
    [self dismiss];
}

- (void) dismiss {
    CGPoint center = self.view.window.center;
    
    [UIView animateWithDuration: 0.3 animations: ^(void) {
        [self.view.window setCenter: CGPointMake(center.x, center.y + self.view.window.frame.size.height)];
    } completion: ^(BOOL finished) {
        [self.delegate messageViewControllerDidDismissed: self];
        [self.view.window resignKeyWindow];
        [self.view.window release];
    }];
}

- (IBAction) onRemoveClicked: (id) sender {
    
    if (_messageIndex < 0) return;
    Message* message = [_messages objectAtIndex: _messageIndex];
    int neededMessageId = (message.isPull) ? message.messageId : message.htmlMessageId;
    int isPull = (message.isPull) ? 1 : 0;
    [[CMClient sharedInstance] performSelector: @selector(removeMessage:isPull:) withObject: [NSNumber numberWithInt: neededMessageId] withObject: [NSNumber numberWithInt:isPull]];
     [_messages removeObjectAtIndex: _messageIndex];
    
    if(_messages.count == 0){
        [self onDoneClicked: nil];
    }
    
    if(_messageIndex >= _messages.count){
        //NSLog(@"onRemoveClicked messageIndex = %i  _messages.count = %i",_messageIndex,_messages.count);
        _messageIndex--;
    }
    
    [self showMessage];
    
    
}

- (IBAction) onNextPrevClicked: (id) sender {
    if(_segmented.selectedSegmentIndex == 0){
        --_messageIndex;
    } else if (_segmented.selectedSegmentIndex == 1) {
        ++_messageIndex;
    }
    [self showMessage];
}

- (void) showMessage {
    if (_messageIndex < 0)
        return;
    Message* message = [_messages objectAtIndex: _messageIndex];
    if ([message.html length])
    {
        [_webView loadHTMLString: message.html baseURL: [NSURL URLWithString: [CMClient sharedInstance].serverUrl]];
    
        
        
        [_segmented setEnabled: _messageIndex > 0 forSegmentAtIndex: 0];
        [_segmented setEnabled: _messageIndex < _messages.count - 1 forSegmentAtIndex: 1];
        _txtCounter.text = [NSString stringWithFormat: @"%d of %d", (_messageIndex + 1), _messages.count];
    
        if(_messages.count == 1)
        {
            [_segmented setHidden:YES];
            [_txtCounter setHidden:YES];
        }
        
        //[[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:htmlMessageID:campaignId:) withObject: [NSNumber numberWithInt: message.messageId] withObject:[NSNumber numberWithInt:message.htmlMessageId]];
        NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt: message.messageId],[NSNumber numberWithInt:message.htmlMessageId],[NSNumber numberWithInt:message.campaignID], nil];
        [[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:) withObject:array];
    }
}

- (void) setMessages: (NSArray*) messages startIndex: (int) index {
    [_messages removeAllObjects];
    [_messages addObjectsFromArray: messages];
    _messageIndex = index;
    
   
}

@end
