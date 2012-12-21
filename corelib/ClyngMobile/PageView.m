//
//  PageView.m
//  ClyngMobile
//
//  Created by --- on 8/4/12.
//
//

#import "PageView.h"

@implementation PageView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float width = frame.size.width;
        float height = frame.size.height;
        
        _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 0, width, height)];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.delegate = self;
        [self addSubview: _webView];
        
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        _activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activity.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        _activity.hidesWhenStopped = true;
        [self addSubview: _activity];
    }
    return self;
}

- (void) dealloc {
    [_webView release];
    [_activity release];
    [super dealloc];
}

- (void) showMessage:(NSString *)content withBaseURL:(NSString *)baseUrl {
    [_webView loadHTMLString: content baseURL: [NSURL URLWithString: baseUrl]];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [_activity startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [_activity stopAnimating];
}

@end
