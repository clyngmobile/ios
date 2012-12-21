//
//  EmbeddedElement.m
//  ClyngMobile
//
//  Created by --- on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmbeddedElement.h"

@implementation EmbeddedElement

@synthesize display = _display;
@synthesize removeAct = _removeAct;
@synthesize width = _width;
@synthesize height = _height;
@synthesize clickClose = _clickClose;
@synthesize embeddedTag = _embeddedTag;
@synthesize isAutoRemove = _isAutoRemove;

- (void)dealloc {
    [_display release];
    [_removeAct release];
    [_embeddedTag release];
    
    [super dealloc];
}

+ (EmbeddedElement*) embeddedElementWithDictionary: (NSDictionary*) values {
    EmbeddedElement* elem = [[EmbeddedElement alloc] init];
    
    elem.display = [[values objectForKey: @"disptype"] stringValue];
    elem.removeAct = [[values objectForKey: @"removeact"] stringValue];
    elem.clickClose = [[values objectForKey: @"clickClose"] boolValue];
    elem.embeddedTag = [[values objectForKey: @"embedtag"] stringValue];
    elem.width = [[[values objectForKey: @"dims"] objectForKey: @"width"] intValue];
    elem.height = [[[values objectForKey: @"dims"] objectForKey: @"height"] intValue];
    
    return [elem autorelease];
}

@end
