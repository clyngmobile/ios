//
//  PageView.h
//  ClyngMobile
//
//  Created by --- on 8/4/12.
//
//

#import <UIKit/UIKit.h>

@interface PageView : UIView<UIWebViewDelegate> {
    UIWebView* _webView;
    UIActivityIndicatorView* _activity;
}

- (void) showMessage: (NSString*) content withBaseURL: (NSString*) baseUrl;

@end
