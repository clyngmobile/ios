//
//  ClyngErrorProtocol.m
//  ClyngMobile
//
//  Created by Dmytro Kalachniuk on 11/20/12.
//
//

#import "ClyngErrorProtocol.h"

@implementation ClyngErrorProtocol

- (void)errorOccurred:(NSError *)error withAPI:(NSString*)api;
{
    NSLog(@"ClyngErrorProtocol: errorOccured");
}



@end
