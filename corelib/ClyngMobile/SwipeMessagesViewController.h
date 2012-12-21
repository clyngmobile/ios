//
//  SwipeMessagesViewController.h
//  ClyngMobile
//
//  Created by --- on 8/4/12.
//
//

#import <UIKit/UIKit.h>
#import "MessagesViewController.h"

@interface SwipeMessagesViewController : UIViewController<UIScrollViewDelegate> {
    UIScrollView* _scrollView;
    
    int _messageIndex;
    NSMutableArray* _messages;
    id<MessagesViewControllerProtocol> _delegate;
}

@property (nonatomic,assign) id<MessagesViewControllerProtocol> delegate;

- (void) setMessages: (NSArray*) messages startIndex: (int) index;

- (void) dismiss;

- (void) buildScrollView;

@end
