//
//  MessagesViewController.h
//  ClyngMobile
//
//  Created by --- on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessagesViewController;

@protocol MessagesViewControllerProtocol

- (void) messageViewControllerDidDismissed: (UIViewController*) controller;

@end

@interface MessagesViewController : UIViewController<UIWebViewDelegate> {
    UIWebView* _webView;
    UILabel* _txtCounter;
    UISegmentedControl* _segmented;
    UIActivityIndicatorView* _activity;
    
    int _messageIndex;
    NSMutableArray* _messages;
    id<MessagesViewControllerProtocol> _delegate;
}

@property (nonatomic,assign) id<MessagesViewControllerProtocol> delegate;

- (void) setMessages: (NSArray*) messages startIndex: (int) index; 

- (IBAction) onDoneClicked: (id) sender;
- (IBAction) onRemoveClicked: (id) sender;
- (IBAction) onNextPrevClicked: (id) sender;

- (void) dismiss;
- (void) showMessage;
@end
