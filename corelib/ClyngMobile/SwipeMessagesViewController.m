//
//  SwipeMessagesViewController.m
//  ClyngMobile
//
//  Created by --- on 8/4/12.
//
//

#import "SwipeMessagesViewController.h"
#import "PageView.h"
#import "Message.h"
#import "CMClient.h"

@interface SwipeMessagesViewController ()

@end

@implementation SwipeMessagesViewController

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
    [_scrollView release];
    [_messages release];
    [super dealloc];
}

- (void) loadView {
    
    int width = [UIScreen mainScreen].applicationFrame.size.width;
    int height = [UIScreen mainScreen].applicationFrame.size.height;
    
    UIView* view = [[[UIView alloc] initWithFrame: [UIScreen mainScreen].applicationFrame] autorelease];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.delegate = self;
    [view addSubview: _scrollView];
    
    UIButton* button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(width - 30, 10, 20, 20);
    [button setBackgroundImage: [UIImage imageNamed: @"ClyngMobile.bundle/circlex.png"] forState: UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [button addTarget: self action: @selector(onRemoveClicked:) forControlEvents: UIControlEventTouchUpInside];
    
    [view addSubview: button];
    
    self.view = view;
    
    
    
    [self buildScrollView];
    
    int width2 = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ?
    [UIScreen mainScreen].applicationFrame.size.width : [UIScreen mainScreen].applicationFrame.size.height;
    _messageIndex = (int) _scrollView.contentOffset.x / width2;
    Message* message = [_messages objectAtIndex: _messageIndex];
    //[[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:htmlMessageID:campaignId:) withObject: [NSNumber numberWithInt: message.messageId] withObject:[NSNumber numberWithInt:message.htmlMessageId] ];
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt: message.messageId],[NSNumber numberWithInt:message.htmlMessageId],[NSNumber numberWithInt:message.campaignID], nil];
    [[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:) withObject:array];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int width = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ?
                    [UIScreen mainScreen].applicationFrame.size.width : [UIScreen mainScreen].applicationFrame.size.height;
    
    _messageIndex = (int) scrollView.contentOffset.x / width;
    Message* message = [_messages objectAtIndex: _messageIndex];
    //[[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:htmlMessageID:) withObject: [NSNumber numberWithInt: message.messageId] withObject:[NSNumber numberWithInt:message.htmlMessageId]];
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt: message.messageId],[NSNumber numberWithInt:message.htmlMessageId],[NSNumber numberWithInt:message.campaignID], nil];
    [[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:) withObject:array];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return true;
}



- (void) buildScrollView {
    
    for(int i = _scrollView.subviews.count - 1; i >=0 ; i--){
        [[_scrollView.subviews objectAtIndex: i] removeFromSuperview];
    }
    
    int width = [UIScreen mainScreen].applicationFrame.size.width;
    int height = [UIScreen mainScreen].applicationFrame.size.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        int temp = width;
        width = height;
        height = temp;
    }
    
    int index = 0;
    for(Message* message in _messages){
        NSLog(@"-messages = %@",_messages);
        if ([message.html length])
        {
            NSLog(@"html = %@",message.html);
            PageView* page = [[[PageView alloc] initWithFrame: CGRectMake(index * width, 0, width, height)] autorelease];
            [page showMessage: message.html withBaseURL: [CMClient sharedInstance].serverUrl];
            [_scrollView addSubview: page];
            index++;
        }
        
    }
    
    [_scrollView setContentSize: CGSizeMake(width * index, height)];
    [_scrollView setContentOffset: CGPointMake(_messageIndex * width, 0)];
    
    
}


- (void) viewWillLayoutSubviews {
    [self buildScrollView];
}

- (void) setMessages: (NSArray*) messages startIndex: (int) index {
    [_messages removeAllObjects];
    [_messages addObjectsFromArray: messages];
    _messageIndex = index;
    
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
    Message* message = [_messages objectAtIndex: _messageIndex];
    int neededMessageId = (message.isPull) ? message.messageId : message.htmlMessageId;
    int isPull = (message.isPull) ? 1 : 0;
    [[CMClient sharedInstance] performSelector: @selector(removeMessage:isPull:) withObject: [NSNumber numberWithInt: neededMessageId] withObject: [NSNumber numberWithInt:isPull]];
    [_messages removeObjectAtIndex: _messageIndex];
    
    
    [self dismiss];
    
    
    /*
    if(_messages.count == 0){
        [self dismiss];
    }

    if(_messageIndex >= _messages.count){
        _messageIndex--;
    }

    if(_messages.count > 0){
        [self buildScrollView];
        message = [_messages objectAtIndex: _messageIndex];
        //[[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:htmlMessageID:) withObject: [NSNumber numberWithInt: message.messageId] withObject:[NSNumber numberWithInt:message.htmlMessageId]];
        NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt: message.messageId],[NSNumber numberWithInt:message.htmlMessageId],[NSNumber numberWithInt:message.campaignID], nil];
        [[CMClient sharedInstance] performSelector: @selector(notifyMessageOpened:) withObject:array];
    }
     */
}

@end
