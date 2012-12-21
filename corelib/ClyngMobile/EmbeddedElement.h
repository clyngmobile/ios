//
//  EmbeddedElement.h
//  ClyngMobile
//
//  Created by --- on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmbeddedElement : NSObject {
    NSString* _display;
    NSString* _removeAct;
    int _width;
    int _height;
    bool _clickClose;
    NSString* _embeddedTag;
}

@property (nonatomic, retain) NSString *display;
@property (nonatomic, retain) NSString *removeAct;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) bool clickClose;
@property (nonatomic, retain) NSString *embeddedTag;

@property (nonatomic, readonly) bool isAutoRemove;

+ (EmbeddedElement*) embeddedElementWithDictionary: (NSDictionary*) values;

@end
