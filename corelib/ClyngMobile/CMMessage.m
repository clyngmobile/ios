//
//  CMMessage.m
//  ClyngMobile
//
//  Created by --- on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMMessage.h"
#import "JSON.h"

@implementation CMMessage

@synthesize customerId = _customerId;
@synthesize displayWidth = _displayWidth;
@synthesize displayHeight = _displayHeight;
@synthesize name = _name;
@synthesize unique = _unique;
@synthesize expiration = _expiration;
@synthesize filter = _filter;
@synthesize id = _id;
@synthesize embTag = _embTag;
@synthesize html = _html;
@synthesize viewed = _viewed;

@synthesize isPhone = _isPhone;
@synthesize isTablet = _isTablet;
@synthesize isPull = _isPull;

@synthesize htmlMessageId = _htmlMessageId;
@synthesize messageId = _messageId;
@synthesize campaignID = _campaignID;


@synthesize htmlMessage = _htmlMessage;



- (void)dealloc {
    [_name release];
    [_embTag release];
    [_html release];
    [_htmlMessage release];
    [super dealloc];
}

+ (CMMessage *) messageWithDictionary: (NSDictionary*) values deviceType: (NSString*) deviceType {
    CMMessage * message = [[CMMessage alloc] init];
    
    message.customerId = [[values objectForKey: @"customer_id"] intValue];
    message.displayWidth = [[values objectForKey: @"display_w"] intValue];
    message.displayHeight = [[values objectForKey: @"display_h"] intValue];
    message.name = [[values objectForKey: @"name"] stringValue];
    message.unique = [[values objectForKey: @"unique"] boolValue];
    message.id = [[values objectForKey: @"id"] intValue];
    message.expiration = [[values objectForKey: @"expiration"] intValue];
    message.filter = [[values objectForKey: @"filter"] intValue];
    
    message.isPhone = [[values objectForKey: @"isPhone"] boolValue];
    message.isTablet = [[values objectForKey: @"isTablet"] boolValue];
    message.htmlMessageId = [[values objectForKey: @"htmlMessageId"] intValue];
    message.messageId = [[values objectForKey: @"messageId"] intValue];
    message.campaignID = -1;
    message.htmlMessage = [values objectForKey:@"htmlMessage"];
    
    message.isPull = TRUE;
    
    if (message.isPhone)
    {
        message.html = [message.htmlMessage objectForKey:@"phoneHtml"];
    }
    else if (message.isTablet)
    {
        message.html = [deviceType isEqualToString: @"phone"] ? @"" : [message.htmlMessage objectForKey:@"tabletHtml"];
    }
    else
        message.html = @"";
    
    NSString* tagName = [deviceType isEqualToString: @"phone"] ? @"phoneHtml" : @"tabletHtml";
    id embededTagElem = [values objectForKey: @"embed_tag"];
    if(![embededTagElem isKindOfClass: [NSDictionary class]]){
        embededTagElem = [[embededTagElem description] JSONValue];
    }
    
    message.embTag = [EmbeddedElement embeddedElementWithDictionary: [embededTagElem objectForKey: tagName]];
    
    return [message autorelease];
}

- (NSString*) description {
    
    NSString *data = ([self.html length] > 30) ? [self.html substringToIndex:30] : self.html;
    return [NSString stringWithFormat: @"message_id: %d, htmlId: %d, messId: %d, isPull: %i, filter: :%i, data: %@...", self.id,self.htmlMessageId, self.messageId,self.isPull,self.filter, data];
}

@end
