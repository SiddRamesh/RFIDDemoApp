//
//  StockDataSource.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "StockDataSource.h"
#import "ParseOperation.h"

static NSString *feedURLString = @"http://atm-india.in/RFIDDemoservice.asmx";

@interface StockDataSource ()

@property (nonatomic, strong) NSMutableArray *stockdatas;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@property (assign) id addStockdatasObserver;
@property (assign) id stockdatasErrorObserver;

// queue that manages our NSOperation for parsing earthquake data
@property (nonatomic, strong) NSOperationQueue *parseQueue;

@end

@implementation StockDataSource


- (instancetype)init {
    
    self = [super init];
    if (self != nil) {
        _stockdatas = [NSMutableArray array];
        
        // Our NSNotification callback from the running NSOperation to add the earthquakes
        _addStockdatasObserver = [[NSNotificationCenter defaultCenter] addObserverForName:ParseOperation.AddStockdatasNotificationName
                                                                                    object:nil
                                                                                     queue:nil
                                                                                usingBlock:^(NSNotification *notification) {
                                                                                    NSArray *incomingEarthquakes = [notification.userInfo valueForKey:ParseOperation.StockdatasResultsKey];
                                                                                    
                                                                                    [self willChangeValueForKey:@"stockdatas"];
                                                                                    [self.stockdatas addObjectsFromArray:incomingEarthquakes];
                                                                                    [self didChangeValueForKey:@"stockdatas"];
                                                                                }];
        
        _stockdatasErrorObserver = [[NSNotificationCenter defaultCenter] addObserverForName:ParseOperation.StockdatasErrorNotificationName
                                                                                      object:nil
                                                                                       queue:nil
                                                                                  usingBlock:^(NSNotification *notification) {
                                                                                      [self willChangeValueForKey:@"error"];
                                                                                      self.error = [notification.userInfo valueForKey:ParseOperation.StockdatasMessageErrorKey];
                                                                                      [self didChangeValueForKey:@"error"];
                                                                                  }];
        
        _parseQueue = [NSOperationQueue new];
    }
    
    return self;
}

- (void)startStockdataLookup {
    
    NSURLRequest *earthquakeURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:earthquakeURLRequest
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                       
                                                       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                           
                                                           if (error != nil && response == nil) {
                                                               if (error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection) {
                                                                   
                                                                   NSAssert(NO, @"NSURLErrorAppTransportSecurityRequiresSecureConnection");
                                                               }
                                                               else {
                                                                   // use KVO to notify our client of this error
                                                                   [self willChangeValueForKey:@"error"];
                                                                   self.error = error;
                                                                   [self didChangeValueForKey:@"error"];
                                                               }
                                                           }
                                                           
                                                           if (response != nil) {
                                                               
                                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                               if (((httpResponse.statusCode/100) == 2) && [response.MIMEType isEqual:@"application/xml"]) {
                                                                   
                                                                   ParseOperation *parseOperation = [[ParseOperation alloc] initWithData:data];
                                                                   [self.parseQueue addOperation:parseOperation];
                                                               }
                                                               else {
                                                                   NSString *errorString =
                                                                   NSLocalizedString(@"HTTP Error", @"Error message displayed when receiving an error from the server.");
                                                                   NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
                                                                   
                                                                   // use KVO to notify our client of this error
                                                                   [self willChangeValueForKey:@"error"];
                                                                   self.error = [NSError errorWithDomain:@"HTTP"
                                                                                                    code:httpResponse.statusCode
                                                                                                userInfo:userInfo];
                                                                   [self didChangeValueForKey:@"error"];
                                                               }
                                                           }
                                                       }];
                                                   }];
    
    [self.sessionTask resume];
}

- (void)dealloc {
    
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self.addStockdatasObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.stockdatasErrorObserver];
}



@end
