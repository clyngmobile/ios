//
//  CMMessage.h
//  ClyngMobile
//
//  Created by --- on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmbeddedElement.h"

@interface CMMessage : NSObject {
    int _customerId;
    int _displayWidth;
    int _displayHeight;
    NSString* _name;
    bool _unique;
    int _expiration;
    int _filter;
    int _id;
    EmbeddedElement* _embTag;
    NSString* _html;
    bool _viewed;
    
    bool _isPhone;
    bool _isTablet;
    
    int _htmlMessageId;
    int _messageId;
    int _campaignID;

    bool _isPull;
    
    NSDictionary *_htmlMessage;
}

@property (nonatomic, assign) int customerId;
@property (nonatomic, assign) int displayWidth;
@property (nonatomic, assign) int displayHeight;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) bool unique;
@property (nonatomic, assign) int expiration;
@property (nonatomic, assign) int filter;
@property (nonatomic, assign) int id;
@property (nonatomic, retain) EmbeddedElement *embTag;
@property (nonatomic, retain) NSString *html;
@property (nonatomic, assign) bool viewed;

@property (nonatomic, assign) bool isPhone;
@property (nonatomic, assign) bool isTablet;

@property (nonatomic, assign) bool isPull;

@property (nonatomic, assign) int htmlMessageId;
@property (nonatomic, assign) int messageId;
@property (nonatomic, assign) int campaignID;

@property (nonatomic,retain) NSDictionary *htmlMessage;

+ (CMMessage *) messageWithDictionary: (NSDictionary*) values deviceType: (NSString*) deviceType;

@end
