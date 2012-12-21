//
//  CMClient.m
//  ClyngMobile
//
//  Created by --- on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CMClient.h"
#import "OHURLLoader.h"
#import "JSON.h"
#import "Message.h"
#import "MessagesViewController.h"
#import "SwipeMessagesViewController.h"
#import "CustomExceptions.h"

#define DEFAULT_PLIST_NAME @"ClyngConfig.plist"
#define DEVICE_TOKEN_PREF @"Clynd_DeviceToken"
#define MESSAGE_FILTER 1

NSString* const op_RegisterUser = @"registerUser";

NSString* const cm_serverUrl = @"serverUrl";
NSString* const cm_apiKey = @"apiKey";
NSString* const cm_useGpsLocation = @"useGpsLocation";
NSString* const cm_userId = @"UserId";
NSString* const cm_email = @"Email";
NSString* const cm_locale = @"Locale";

static CMClient* _instance;

@interface CMClient ()

@property (nonatomic, retain) NSString* deviceToken;
- (void) setVal:(NSObject*)value withName:(NSString *)name;
@end

@implementation CMClient

@synthesize serverUrl = _serverUrl;
@synthesize serial = _serial;
@synthesize userId = _userId;
@synthesize email = _email;
@synthesize locale = _locale;
@synthesize useGps = _useGps;
@synthesize coordinates = _coordinates;
@synthesize viewMode;


- (id) init {
    self = [super init];
    if (self == [super init]){

        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = (id<CLLocationManagerDelegate>) self;
		_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _onError = nil;
        _onSucces = nil;
    }
    return self;
}

- (void)dealloc {
    [_serverUrl release];
    [_serial release];
    [_userId release];
    [_email release];
    [_locale release];
    [_locationManager release];
    [_locationTimer invalidate];
    
    [super dealloc];
}

+ (CMClient*) sharedInstance {
    if(_instance)
        return _instance;
    else
    {
        _instance = [[CMClient alloc] init];
        return _instance;
    }
}

+(void)registerWithApple
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
}

+ (void) init {
    [CMClient initWithPlist: DEFAULT_PLIST_NAME];
}

+ (void) initWithDictionary: (NSDictionary*) properties {
    if(_instance){
        NSLog(@"Instance already created. I will release it and create new one");
        [_instance release];        
        //return;
    }
    
    _instance = [[CMClient alloc] init];
    CMClient* client = [CMClient sharedInstance];
    
    client.serverUrl = [properties objectForKey: cm_serverUrl];
    client.serial = [properties objectForKey: cm_apiKey];
}

+ (void) initWithPlist: (NSString*) propertiesFileName {
    NSString* path = [[NSBundle mainBundle] pathForResource: propertiesFileName ofType: nil];
    NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile: path];
    if(!properties){
        NSLog(@"Can't load properties file: %@", propertiesFileName);
    }
    [CMClient initWithDictionary: properties];
}

-(void)setGlobalHandler:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock
{
    if (_onError){
        Block_release(_onError);
    }
    if (_onSucces){
        Block_release(_onSucces);
    }
    _onError = Block_copy(errorBlock);
    //_onError = errorBlock;
    _onSucces = Block_copy(successBlock);
    //_onSucces = successBlock;

}


- (void) sendEvent: (NSString*) event withDetails: (NSDictionary*) data errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock {
    if(self.useGps){
        [self startDetermineLocation];
    }
    
    [self sendEvent: event params: data callback:^{} errorBlock:errorBlock succesBlock:successBlock];
}   

- (void) getPendingMessages:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock
{
   [self getPendingMessages:^(NSArray *messages)
    {
        [self showMessages: messages];
    }
                 errorBlock:errorBlock
                succesBlock:successBlock
    ];
}

//store device token
+ (void) storeDeviceToken: (NSData*) deviceToken {
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([deviceToken length] * 2)];
	const unsigned char *dataBuffer = [deviceToken bytes];
	for (int i = 0; i < [deviceToken length]; ++i)
    {
        [stringBuffer appendFormat:@"%02X", (unsigned int)dataBuffer[i]];
	}
    
    NSLog(@"DeviceToken: %@", stringBuffer);
    [CMClient setDeviceToken: stringBuffer];
}

//handle push message if it contains message_id
- (void) handleRemoteNotification: (NSDictionary*) notificationData errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock {
    NSLog(@"handle push message if it contains htmlMessageId");
    int htmlMessageId = [[notificationData objectForKey: @"htmlMessageId"] intValue];
    int messageId = [[notificationData objectForKey: @"messageId"] intValue];
    int camId = [[notificationData objectForKey: @"campaignId"] intValue];
    NSLog(@"push message = %@",notificationData);
    Message* message = [[[Message alloc] init] autorelease];
    message.isPull = NO;
    message.htmlMessageId = htmlMessageId;
    message.messageId = messageId;
    message.campaignID = camId;
    
    [self getMessageHtml: message callback:^(NSString *html) {
        message.html = html;        
        NSLog(@"message.html = %@",message.html);
        NSArray *arr = [NSArray arrayWithObject:message];
        [self showMessages:arr];
    } errorBlock:errorBlock succesBlock:successBlock];
}

- (void) setUseGps:(BOOL)useGps {
    _useGps = useGps;
    if(useGps){
        [self startDetermineLocation];
    } else {
        [self stopDetermineLocation];
    }
}

- (void) startDetermineLocation {
    [_locationManager startUpdatingLocation];
    [_locationTimer invalidate];
    _locationTimer = [NSTimer scheduledTimerWithTimeInterval: 10 
                                                      target: self 
                                                    selector: @selector(onLocationTimer) 
                                                    userInfo: nil 
                                                     repeats: false];
}

- (void) stopDetermineLocation {
    [_locationTimer invalidate];
    _locationTimer = nil;
    [_locationManager stopUpdatingLocation];
}

- (void) onLocationTimer {
    _locationTimer = nil;
    [_locationManager stopUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    float lifetime = fabsf([newLocation.timestamp timeIntervalSinceNow]);
    if(lifetime <= 3 * 60){ //3 minutes expiration for location
        _detectedLocation = newLocation.coordinate;
    }
}

- (NSString*) platform {
    return @"iOS";
}

- (NSString*) deviceType {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? @"phone" : @"tablet";
}

- (NSString*) locale {
    NSString* language = [[NSLocale preferredLanguages] objectAtIndex: 0];
    return _locale ? _locale : language;
}

#if TARGET_IPHONE_SIMULATOR

- (NSString*) deviceToken {
    return @"FAKE_TOKEN_FOR_SIMULATOR";
}

#else 

- (NSString*) deviceToken {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey: DEVICE_TOKEN_PREF];
}

#endif

+ (void) setDeviceToken:(NSString *) deviceToken {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: deviceToken forKey: DEVICE_TOKEN_PREF];
    [defaults synchronize];
}

//filter messages
- (NSArray*) filterMessages: (NSArray*) messages {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: messages.count];
    for(Message* message in messages){
        if(message.filter != MESSAGE_FILTER && message.html.length > 0){
            [result addObject: message];
        }
    }
    return result;
}

//show message
- (void) showMessages: (NSArray*) messages {
    
    NSLog(@"NOT filteredMessages = %@",messages);
   NSArray *filteredMessages =[NSArray arrayWithArray:[self filterMessages:messages]];
    NSLog(@"filteredMessages = %@",filteredMessages);
   if(filteredMessages.count > 0){
        if(_currentViewer){
            [_currentViewer dismiss];
        }

        UIViewController* rootController = nil;
        if(self.viewMode == CMClientViewMode_Normal){
            MessagesViewController* controller = [[[MessagesViewController alloc] init] autorelease];
            [controller setMessages: filteredMessages startIndex: 0];
            controller.delegate = (id<MessagesViewControllerProtocol>) self;
            rootController = controller;
        } else {
            
            SwipeMessagesViewController* controller = [[[SwipeMessagesViewController alloc] init] autorelease];
            [controller setMessages: filteredMessages startIndex: 0];
            controller.delegate = (id<MessagesViewControllerProtocol>) self;
            rootController = controller;
        }
        
        UIWindow* ow = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
        ow.alpha = 1.0;
        ow.backgroundColor = [UIColor clearColor];
        ow.rootViewController = rootController;
        ow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [ow makeKeyAndVisible];
        
        CGPoint center = ow.center;
        [ow setCenter: CGPointMake(center.x, center.y + ow.frame.size.height)];
        
        [UIView animateWithDuration: 0.3 animations: ^(void) {
            [ow setCenter: center];
        }];
        
        _currentViewer = rootController;
    }
}

- (void) messageViewControllerDidDismissed: (MessagesViewController*) controller {
    if(controller == _currentViewer){
        _currentViewer = nil;
    }
}

//API methods

//build NSURL with by appending serverUrl and relative http path
- (NSURL*) apiUrlWithPath: (NSString*) path {
    return [NSURL URLWithString: path relativeToURL: [NSURL URLWithString: self.serverUrl]];
}

//build NSURLRequest for relatvie path and json data
- (NSMutableURLRequest*) requestWithPath: (NSString*) path data: (NSObject*) data {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: [self apiUrlWithPath: path]];
    NSString* jsonString = [data JSONRepresentation];
	[request setHTTPBody: [jsonString dataUsingEncoding: NSUTF8StringEncoding]];
	[request setHTTPMethod: @"PUT"];
	[request setTimeoutInterval: 20.0f];
	[request addValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    
    NSLog(@"Perform request with path: %@", path);
    NSLog(@"Request data: %@", jsonString);
    
    return request;
}

//parse response to json object
- (NSObject*) parseRegistration: (NSData*) data  errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock
{
    NSString* stringRepresentation = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSLog(@"parseRegistration: stringRepresentation = %@",stringRepresentation);
    if(stringRepresentation.length > 0){
        NSDictionary *parsedObject = [stringRepresentation JSONValue];
        if ([parsedObject isKindOfClass:[NSDictionary class]])
        {
            NSString *errorStr = [parsedObject objectForKey:@"status"];
            if ([errorStr isEqualToString:@"ERROR"])
            {
                NSString *errorMes = [[parsedObject objectForKey:@"message"] stringByAppendingFormat:@". Code: %@",[parsedObject objectForKey:@"code"]];               
                NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
                [details setValue:errorMes forKey:NSLocalizedDescriptionKey];
                NSError *er = [[NSError alloc] initWithDomain:@"NSOSStatusErrorDomain" code:0 userInfo:details];
                
                if (errorBlock!=nil)
                    errorBlock(er);
                else
                {
                    if (_onError!=nil)
                        _onError(er);
                }
                 
                [er release];
                [details release];
                return nil;
            }
        }
        else if ([stringRepresentation isKindOfClass:[NSString class]])
        {
            if ([stringRepresentation rangeOfString:@"<!DOCTYPE"].location != NSNotFound)
            {
                NSString *str = [stringRepresentation substringFromIndex:[stringRepresentation rangeOfString:@"<title>"].location+7];
                str = [str substringToIndex:[str rangeOfString:@"<"].location];
                NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
                [details setValue:[@"Server Error. " stringByAppendingString:str] forKey:NSLocalizedDescriptionKey];
                NSError *er = [[NSError alloc] initWithDomain:@"NSOSStatusErrorDomain" code:0 userInfo:details];
                
                if (errorBlock!=nil)
                    errorBlock(er);
                else
                {
                    if (_onError!=nil)
                        _onError(er);
                }
                
                [er release];
                [details release];
                return nil;
            }
        }
        
        NSLog(@"parse = %@",parsedObject);
        if (parsedObject == NULL)
        {
            
            NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
            [details setValue:@"Server Error. Parsed object from server is null" forKey:NSLocalizedDescriptionKey];
            NSError *er = [[NSError alloc] initWithDomain:@"NSOSStatusErrorDomain" code:0 userInfo:details];
            if (errorBlock!=nil)
                errorBlock(er);
            else
            {
                if (_onError!=nil)
                    _onError(er);
            }
            [er release];
            [details release];
            return nil;
        }
        
        return [stringRepresentation JSONValue];
    }
    return nil;
}

- (NSObject*) parse: (NSData*) data errorBlock:(CMErrorBlock)errorBlock successBlock:(CMSuccessBlock)successBlock {
    NSString* stringRepresentation = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    if(stringRepresentation.length > 0){
        return [stringRepresentation JSONValue];
    }
    else
    {
        
        NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
        [details setValue:@"Server Error. Parsed object from server is null." forKey:NSLocalizedDescriptionKey];
        NSError *er = [[NSError alloc] initWithDomain:@"NSOSStatusErrorDomain" code:0 userInfo:details];
        if (errorBlock!=nil)
            errorBlock(er);
        else
        {
            if (_onError!=nil)
                _onError(er);
        }
        [er release];
        [details release];
        
    }
    return nil;
}

//handle api request error
- (bool) handleError:response errorBlock:(CMErrorBlock)errorBlock succesBlock:(CMSuccessBlock)succesBlock
{
    if([response isKindOfClass: [NSDictionary class]]){
        NSString* errorValue = [(id)response objectForKey: @"status"];
        if([errorValue isEqualToString:@"ERROR"]){
            NSLog(@"handleError: %@", errorValue);            
            NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
            [details setValue:[[(id)response objectForKey:@"message" ] stringByAppendingFormat:@" %@",[(id)response objectForKey: @"code"]] forKey:NSLocalizedDescriptionKey];
            NSError *er = [[NSError alloc] initWithDomain:@"NSOSStatusErrorDomain" code:0 userInfo:details];
            
            if (errorBlock != nil)
                errorBlock(er);
            else
            {
                if (_onError != nil)
                    _onError(er);
            }
            
            [er release];
            [details release];
            
            return true;
        }
    }
    if(response != nil)
    {
        if (succesBlock != nil)
            succesBlock();
        else
        {
            if (_onSucces!=nil)
            _onSucces();
        }
    }
    return false;
}



//handle http or connection error
- (void) handleNSError:(NSError*)error errorBlock:(CMErrorBlock)errorBlock succesBlock:(CMSuccessBlock)succesBlock
{
    NSLog(@"handleNSError: %@", [error description]);
    if (errorBlock != nil)
    {
        errorBlock(error);
    }else
    {
        if (_onError != nil)
            _onError(error);
    }
    
}



//reigster user
- (void) registerUser: (CMErrorBlock)errorBlock succesBlock:(CMSuccessBlock)successBlock {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 3];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: self.deviceToken forKey: @"identifier"];
    if( self.email != nil && self.email.length > 0 )
        [data setValue: self.email forKey:@"email"];
    
    [data setValue: self.platform forKey: @"mobileDevicePlatform"];
    
    NSString *path = [self.deviceType isEqualToString: @"phone"] ?
        @"rulegrid/mobile/device/registerApplePhone" : @"rulegrid/mobile/device/registerAppleTablet";
    
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: path data: data]];
    
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
        NSObject* object = [self parseRegistration:receivedData errorBlock:errorBlock successBlock:successBlock];
        if(![self handleError:object errorBlock:errorBlock succesBlock:successBlock])
        {

        }    
    } errorHandler:^(NSError *error) {
        [self handleNSError:error errorBlock:errorBlock succesBlock:successBlock];
    }];
}

// unreigster user
- (void) unregisterUser:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{    
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 2];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: self.deviceToken forKey: @"identifier"];
    [data setValue: self.serial forKey: @"apiKey"];
    NSString* path = @"rulegrid/mobile/device/unregisterApple";
    NSLog(@"path unregister = %@",path);
    
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: path data: data]];
    
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
        NSObject* object = [self parseRegistration:receivedData errorBlock:onError successBlock:onSuccess];
        [self handleError:object errorBlock:onError succesBlock:onSuccess];
                    
        
    } errorHandler:^(NSError *error) {
        [self handleNSError:error errorBlock:onError succesBlock:onSuccess];
    }];
}


//get pending messages from server
- (void) getPendingMessages: (void(^)(NSArray* messages)) callback   errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 2];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: self.platform forKey: @"mobileDevicePlatform"];

    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: @"rulegrid/mobile/message/getMessages" data: data]];
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
       
        id object = [self parse: receivedData errorBlock:onError successBlock:onSuccess];
        if(![self handleError:object errorBlock:onError succesBlock:onSuccess]){
            NSMutableArray* messages = [NSMutableArray arrayWithCapacity: 10];
            for(NSDictionary* value in object){
                [messages addObject: [Message messageWithDictionary: value deviceType: self.deviceType]];
            }
            callback(messages);
        }
    } errorHandler:^(NSError *error) {
        [self handleNSError:error errorBlock:onError succesBlock:onSuccess];
    }];
}

//fill all messages with body
- (void) getMessagesHtml: (NSArray*) messages index: (int) index callback: (void(^)(NSArray* messages)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess {
    if(index < messages.count){
        Message* message = [messages objectAtIndex: index];
        [self getMessageHtml: message callback: ^(NSString* html){
            NSLog(@"getMessagesHtml: (NSArray*) messages -> html = %@",html);
            message.html = html;
            [self getMessagesHtml: messages index: (index + 1) callback: callback errorBlock:onError succesBlock:onSuccess];
        } errorBlock:onError succesBlock:onSuccess];
    } else {
        callback(messages);
    }
}

//get html for single message
- (void) getMessageHtml: (Message*) message callback: (void(^)(NSString* html)) callback  errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 3];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: [NSNumber numberWithInt: message.htmlMessageId] forKey: @"htmlMessageId"];
    [data setValue: [NSNumber numberWithInt: message.messageId] forKey: @"messageId"];
    [data setValue: [NSNumber numberWithInt: message.campaignID] forKey: @"campaignId"];
    
    [data setValue: self.platform forKey: @"mobileDevicePlatform"];
    
    NSString* path = [self.deviceType isEqualToString: @"phone"] ? 
        @"rulegrid/mobile/message/getPhoneHTML" : @"rulegrid/mobile/message/getTabletHTML";
    
       OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: path data: data]];
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode)
     {
        callback([[[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding] autorelease]);
    } errorHandler:^(NSError *error) {
        [self handleNSError:error errorBlock:onError succesBlock:onSuccess];
        callback(nil);
    }];
}

-(void)notifyMessageOpened:(NSArray*)array
{
    [self notifyMessageOpened:array errorBlock:nil succesBlock:nil];
}
-(void)removeMessage: (NSNumber*) messageWrapper isPull:(NSNumber*) isPull
{
    [self removeMessage:messageWrapper isPull:isPull errorBlock:nil succesBlock:nil];
}


//remove message from server
- (void) removeMessage: (NSNumber*) messageWrapper isPull:(NSNumber*) isPull errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    int messageId = [messageWrapper intValue];
    int isMesPull = [isPull intValue];
    NSLog(@"removeMessage messageId= %i",messageId);
    [self removeMessage: messageId isMessagePull:isMesPull callback: ^(void){} errorBlock:onError succesBlock:onSuccess];
}

- (void) removeMessage: (int) messageId isMessagePull:(int)isMessagePull callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 2];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    NSString *messageKey = (isMessagePull) ? @"messageId": @"htmlMessageId";
    [data setValue: [NSNumber numberWithInt: messageId] forKey: messageKey];
    [data setValue: self.platform forKey: @"mobileDevicePlatform"];
    
   
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: @"rulegrid/mobile/message/removeMessage" data: data]];
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
        id object = [self parse: receivedData errorBlock:onError successBlock:onSuccess];
        if(![self handleError: object errorBlock:onError succesBlock:onSuccess]){
            callback();
        }
    } errorHandler:^(NSError *error) {
        [self handleNSError: error errorBlock:onError succesBlock:onSuccess];
    }];
}
/*
- (void) notifyMessageOpened: (NSNumber*) messageWrapper htmlMessageID: (NSNumber*)htmlMessageWrapper campaignId: (NSNumber*)campaigIdWrapper{
    int messageId = [messageWrapper intValue];
    int htmlMessageId = [htmlMessageWrapper intValue];
    int camId = [campaigIdWrapper intValue];
    [self notifyMessageOpened: messageId htmlMessageID:htmlMessageId campaignID:camId callback:^{
    }];
}
*/

- (void) notifyMessageOpened: (NSArray *)array errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess {
    if (array.count > 2)
    {
        NSNumber * messageWrapper = [array objectAtIndex:0];
        NSNumber * htmlMessageWrapper = [array objectAtIndex:1];
        NSNumber * campaigIdWrapper = [array objectAtIndex:2];
        int messageId = [messageWrapper intValue];
        int htmlMessageId = [htmlMessageWrapper intValue];
        int camId = [campaigIdWrapper intValue];
        [self notifyMessageOpened: messageId htmlMessageID:htmlMessageId campaignID:camId callback:^{
        } errorBlock:onError succesBlock:onSuccess];
    }
}

- (void) notifyMessageOpened: (int) messageId htmlMessageID:(int)htmlMessageID campaignID:(int)campaignId callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess  {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 3];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: [NSNumber numberWithInt: messageId] forKey: @"messageId"];
    [data setValue: [NSNumber numberWithInt: htmlMessageID] forKey: @"htmlMessageId"];
    [data setValue: self.platform forKey: @"mobileDevicePlatform"];
    
    if (campaignId != -1)
        [data setValue: [NSNumber numberWithInt: campaignId] forKey: @"campaignId"];
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: @"rulegrid/mobile/message/messageOpened" data: data]];
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
        id object = [self parse: receivedData errorBlock:onError successBlock:onSuccess];
        if(![self handleError: object errorBlock:onError succesBlock:onSuccess]){
            callback();
        }
    } errorHandler:^(NSError *error) {
        [self handleNSError: error errorBlock:onError succesBlock:onSuccess];
    }];
}

//send event to the server
- (void) sendEvent: (NSString*) eventName params: (NSDictionary*) params callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess  {
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary: params];
    NSLog(@"data:%@",data);
    [data setValue: eventName forKey: @"eventName"];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    if ([self.email length])
        [data setValue: self.email forKey: @"email"];
    [data setValue: self.locale forKey: @"locale"];
    [data setValue: self.deviceToken forKey: @"mobileDeviceToken"];
    [data setValue: self.platform forKey: @"mobileDevicePlatform"];
    [data setValue: self.deviceType forKey: @"mobileDeviceType"];
    CLLocationCoordinate2D location = (self.useGps && _detectedLocation.latitude != 0 & _detectedLocation.longitude != 0) ? _detectedLocation : _coordinates;
    if(location.latitude != 0 && location.longitude != 0){
        [data setValue: [NSNumber numberWithDouble: location.latitude] forKey: @"latitude"];
        [data setValue: [NSNumber numberWithDouble: location.longitude] forKey: @"longitude"];
    }

    
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest: [self requestWithPath: @"rulegrid/events/process" data: data]];
    [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
        id object = [self parse: receivedData errorBlock:onError successBlock:onSuccess];
        if(![self handleError: object errorBlock:onError succesBlock:onSuccess]){
            callback();
        }
    } errorHandler:^(NSError *error) {
        [self handleNSError: error errorBlock:onError succesBlock:onSuccess];
    }];
}


- (void) setVal:(NSObject*)value withName:(NSString *)name  callback: (void(^)(void)) callback errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 2];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: name forKey: @"name"];
    [data setValue: value forKey: @"value"];
    
    NSMutableURLRequest* r = [self requestWithPath: @"rulegrid/api/userParams/setValue" data: data];
   
    
        OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest:r ];
        [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode) {
            id object = [self parse: receivedData errorBlock:onError successBlock:onSuccess];
            if(![self handleError: object errorBlock:onError succesBlock:onSuccess]){
                callback();
            }
        } errorHandler:^(NSError *error) {
            [self handleNSError: error errorBlock:onError succesBlock:onSuccess];
        }];
   

}

- (void) setStringVal:(NSString*)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    [self setVal:value withName:name callback:^{} errorBlock:onError succesBlock:onSuccess ];
}

- (void) setDoubleVal:(double)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    [self setVal:[NSNumber numberWithDouble:value] withName:name callback:^{} errorBlock:onError succesBlock:onSuccess];
}

- (void) setDateVal:(NSDate*)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* str = [formatter stringFromDate:value];
    [self setVal:str withName:name callback:^{} errorBlock:onError succesBlock:onSuccess];
}

- (void) setBooleanVal:(BOOL)value withName:(NSString *)name errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    [self setVal:[NSNumber numberWithDouble:value] withName:name callback:^{} errorBlock:onError succesBlock:onSuccess];
}

- (void) changeUserId:(NSString*)newUserId  errorBlock:(CMErrorBlock)onError succesBlock:(CMSuccessBlock)onSuccess
{
    NSMutableDictionary* data = [NSMutableDictionary dictionaryWithCapacity: 2];
    [data setValue: self.serial forKey: @"apiKey"];
    [data setValue: self.userId forKey: @"userId"];
    [data setValue: newUserId forKey: @"newUserId"];

    NSMutableURLRequest* r = [self requestWithPath: @"rulegrid/api/user/changeUserId" data: data];
    
       
        OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest:r ];
        [loader startRequestWithCompletion:^(NSData *receivedData, NSInteger httpStatusCode)
        {
            id object = [self parse: receivedData errorBlock:onError successBlock:onSuccess];
            [self handleError: object errorBlock:onError succesBlock:onSuccess];
            /*
            if(![self handleError: object])
            {
                 self.userId = newUserId;
                [self registerUser: ^{}];
            }
             */
        } errorHandler:^(NSError *error)
        {
            [self handleNSError: error errorBlock:onError succesBlock:onSuccess];
        }
         ];
    
}



@end
