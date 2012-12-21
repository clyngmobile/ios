//
//  ClyngErrorProtocol.h
//  ClyngMobile
//
//  Created by Dmytro Kalachniuk on 11/20/12.
//
//


#import <Foundation/Foundation.h>


@protocol ClyngErrorDelegate <NSObject>

@required
- (void)errorOccurred:(NSError *)error withAPI:(NSString*)api;
@end

@interface ClyngErrorProtocol : NSObject <ClyngErrorDelegate>
{

}

@end

