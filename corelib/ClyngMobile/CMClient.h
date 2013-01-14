//
//  CMClient.h
//  ClyngMobile
//
//  Created by --- on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


extern NSString* const cm_serverUrl;
extern NSString* const cm_apiKey;
extern NSString* const cm_useGpsLocation;
extern NSString* const cm_userId;
extern NSString* const cm_email;
extern NSString* const cm_locale;

typedef void (^CMErrorBlock)(NSError *error);
typedef void (^CMSuccessBlock)();

typedef enum {
    CMClientViewMode_Normal = 0,
    CMClientViewMode_Fullscreen = 1
} CMClientViewMode;

@class CMMessage;

@interface CMClient : NSObject  {
    NSString* _serverUrl;
    NSString* _serial;
    NSString* _userId;
    NSString* _email;
    NSString* _locale;
    BOOL _useGps;
    CLLocationCoordinate2D _coordinates;
    CLLocationCoordinate2D _detectedLocation;
    CLLocationManager* _locationManager;
    NSTimer* _locationTimer;
    id _currentViewer;
    
   // id <ClyngErrorDelegate>_delegate;
    CMErrorBlock _onError;
    CMSuccessBlock _onSucces;
}


//host application should call one of init** methods only once. second call with take no effect
//init client with default ClyngConfig.plist
+ (void) init;
//init client with dictionary
+ (void) initWithDictionary: (NSDictionary*) properties;
//init client with plist file name
+ (void) initWithPlist: (NSString*) propertiesFileName;
//get instance of client, host application should call one of init** methods first
+ (CMClient*) sharedInstance;

-(void)setGlobalHandler:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;

+(void)registerWithApple;

//register user
- (void) registerUser: (CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;
//unregister user
- (void) unregisterUser:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

//send event to server
- (void) sendEvent: (NSString*) event withDetails: (NSDictionary*) data errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;

//pull server for pending messages
- (void) getPendingMessages:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;

//register device token
+ (void) storeDeviceToken: (NSData*) deviceToken;
//handle remove notification
- (void) handleRemoteNotification: (NSDictionary*) notificationData errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;

-(void)setGlobalHandler:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;

- (void) stopDetermineLocation;
- (void) startDetermineLocation;


- (NSObject*) parseRegistration: (NSData*) data  errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;
- (NSObject*) parse: (NSData*) data errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock;

-(void)notifyMessageOpened:(NSArray*)array;
-(void)removeMessage: (NSNumber*) messageWrapper isPull:(NSNumber*) isPull;


- (void) getMessagesHtml: (NSArray*) messages index: (int) index callback: (void(^)(NSArray* messages)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;
- (void) getMessageHtml: (CMMessage *) message callback: (void(^)(NSString* html)) callback  errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

- (void) removeMessage: (NSNumber*) messageWrapper isPull:(NSNumber*) isPull errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

- (void) notifyMessageOpened: (NSArray *)array errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

- (void) notifyMessageOpened: (int) messageId htmlMessageID:(int)htmlMessageID campaignID:(int)campaignId callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess ;

- (void) sendEvent: (NSString*) eventName params: (NSDictionary*) params callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

- (void) setVal:(NSObject*)value withName:(NSString *)name  callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;
- (void) setStringVal:(NSString*)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;
- (void) setDoubleVal:(double)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;
- (void) setDateVal:(NSDate*)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;
- (void) setBooleanVal:(BOOL)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

- (void) changeUserId:(NSString*)newUserId  errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess;

@property (nonatomic, retain) NSString *serverUrl;
@property (nonatomic, retain) NSString *serial;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *locale;
@property (nonatomic, assign) BOOL useGps;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, readonly) NSString* platform;
@property (nonatomic, readonly) NSString* deviceType;
@property (nonatomic, assign) CMClientViewMode viewMode;


@end
