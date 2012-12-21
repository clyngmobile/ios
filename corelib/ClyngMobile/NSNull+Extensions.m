//
//  NSNull+Extensions.m
//  ClyngMobile
//
//  Created by --- on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSNull+Extensions.h"

@implementation NSNull (extensions)

- (int) intValue {
	return 0;	
}

- (float) floatValue {
	return 0.0f;
}

- (double) doubleValue {
	return 0.0f;
}

- (NSString*) stringValue {
	return nil;
}

- (NSObject*) objectForKey: (NSString*) key {
	return nil;
}

- (bool) boolValue {
    return false;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return 0;
}

@end

@implementation NSString (Extension)

- (NSString*) stringValue {
	return self;
}

@end
