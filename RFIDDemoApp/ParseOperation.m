//
//  ParseOperation.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 01/02/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "ParseOperation.h"
#import "StockData.h"

@interface ParseOperation () <NSXMLParserDelegate>

@property (nonatomic) StockData *currentStockdataObject;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (assign) BOOL accumulatingParsedCharacterData;
@property (assign) BOOL didAbortParsing;

@property (assign) NSUInteger parsedStockdatasCounter;

@property (assign) BOOL seekDescription;
@property (assign) BOOL seekTime;
@property (assign) BOOL seekLatitude;
@property (assign) BOOL seekLongitude;

@property (assign) BOOL seekSerial;
@property (assign) BOOL seekIec;
@property (assign) BOOL seekBill;
@property (assign) BOOL seekTruck;
@property (assign) BOOL seekCode;
@property (assign) BOOL seekPort;
@property (assign) BOOL seekDatee;
@property (assign) BOOL seekTimee;
@property (assign) BOOL seekEntryBy;
@property (assign) BOOL seekEseal;

//@property (assign) BOOL seekMagnitude;

// a stack queue containing  elements as they are being parsed, used to detect malformed XML.
@property (nonatomic, strong) NSMutableArray *elementStack;

@end

@implementation ParseOperation

+ (NSString *)AddStockdatasNotificationName
{
    return @"AddStockdatasNotif";
}

+ (NSString *)StockdatasResultsKey
{
    return @"StockdataResultsKey";
}

+ (NSString *)StockdatasErrorNotificationName
{
    return @"StockdataErrorNotif";
}

+ (NSString *)StockdatasMessageErrorKey
{
    return @"StockdatasMsgErrorKey";
}

- (instancetype)init {
    
    NSAssert(NO, @"Invalid use of init; use initWithData to create ParseOperation");
    return [self init];
}

- (instancetype)initWithData:(NSData *)parseData {
    
    self = [super init];
    if (self != nil && parseData != nil) {
        _stockData = [parseData copy];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_IN_POSIX"];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        
        // 2015-09-24T16:01:00.283Z
        
        _currentParseBatch = [[NSMutableArray alloc] init];
        _currentParsedCharacterData = [[NSMutableString alloc] init];
        
        _elementStack = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)addStockdatasToList:(NSArray *)stockdatas {
    
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:ParseOperation.AddStockdatasNotificationName
                                                        object:self
                                                      userInfo:@{ParseOperation.StockdatasResultsKey: _stockData}];
}


- (void)main {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.stockData];
    parser.delegate = self;
    [parser parse];
    
    if (self.currentParseBatch.count > 0) {
        [self performSelectorOnMainThread:@selector(addStockdatasToList:) withObject:self.currentParseBatch waitUntilDone:NO];
    }
}


#pragma mark - Parser constants


static const NSUInteger kMaximumNumberOfStockdatasToParse = 50;

static NSUInteger const kSizeOfStockdataBatch = 10;

static NSString * const kValueKey = @"value";

static NSString * const kEntryElementName = @"event";

static NSString * const kReportDataElementDesc = @"ReportData";
static NSString * const kDescriptionElementDesc = @"description";
static NSString * const kDescriptionElementContent = @"text";

static NSString * const kTimeElementName = @"time";

static NSString * const kLatitudeElementName = @"latitude";
static NSString * const kLongitudeElementName = @"longitude";

static NSString * const kMagitudeValueName = @"mag";

static NSString * const kSerialValueName = @"S1";
static NSString * const kIecValueName = @"S2";
static NSString * const kBillValueName = @"S3";
static NSString * const kTruckValueName = @"S4";
static NSString * const kCodeValueName = @"S5";
static NSString * const kPortValueName = @"S6";
static NSString * const kDateeValueName = @"S7";
static NSString * const kTimeeValueName = @"S8";
static NSString * const kEntryByValueName = @"S9";
static NSString * const kEsealValueName = @"S10";
static NSString * const kcodeeValueName = @"S11";

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
   
    [self.elementStack addObject:elementName];
    
    if (self.parsedStockdatasCounter >= kMaximumNumberOfStockdatasToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kEntryElementName]) {
        StockData *stockdata = [StockData new];
        self.currentStockdataObject = stockdata;
    }
    else if ((self.seekDescription && [elementName isEqualToString:kDescriptionElementContent]) ||  // <description>..<text>
             (self.seekTime && [elementName isEqualToString:kValueKey]) ||                          // <time>..<value>
             (self.seekLatitude && [elementName isEqualToString:kValueKey]) ||              // <latitude>..<value>
             (self.seekLongitude && [elementName isEqualToString:kValueKey]) ||             // <longitude>..<value>
            
         //    (self.seekSerial && [elementName isEqualToString:kValueKey]) ||
             (self.seekIec && [elementName isEqualToString:kValueKey]) ||
             (self.seekBill && [elementName isEqualToString:kValueKey]) ||
             (self.seekTruck && [elementName isEqualToString:kValueKey]) ||
             (self.seekCode && [elementName isEqualToString:kValueKey]) ||
             (self.seekPort && [elementName isEqualToString:kValueKey]) ||
             (self.seekDatee && [elementName isEqualToString:kValueKey]) ||
             (self.seekTimee && [elementName isEqualToString:kValueKey]) ||
             (self.seekEseal && [elementName isEqualToString:kValueKey]) ||
          //   (self.seekLongitude && [elementName isEqualToString:kValueKey]) ||
             (self.seekSerial && [elementName isEqualToString:kValueKey]))
          //   (self.seekMagnitude && [elementName isEqualToString:kValueKey]))               // <mag>..<value>
    {
        // For elements: <text> and <value>, the contents are collected in parser:foundCharacters:
        _accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        self.currentParsedCharacterData = [NSMutableString stringWithString:@""];
    }
    else if ([elementName isEqualToString:kDescriptionElementDesc])
        _seekDescription = YES;
    else if ([elementName isEqualToString:kTimeElementName])
        _seekTime = YES;
    else if ([elementName isEqualToString:kLatitudeElementName])
        _seekLatitude = YES;
    else if ([elementName isEqualToString:kLongitudeElementName])
        _seekLongitude = YES;
   
    else if ([elementName isEqualToString:kSerialValueName])
        _seekSerial = YES;
    else if ([elementName isEqualToString:kIecValueName])
        _seekIec = YES;
    else if ([elementName isEqualToString:kBillValueName])
        _seekBill = YES;
    else if ([elementName isEqualToString:kTruckValueName])
        _seekTruck = YES;
    else if ([elementName isEqualToString:kcodeeValueName])
        _seekCode = YES;
    else if ([elementName isEqualToString:kPortValueName])
        _seekPort = YES;
    else if ([elementName isEqualToString:kDateeValueName])
        _seekDatee = YES;
    else if ([elementName isEqualToString:kTimeeValueName])
        _seekTimee = YES;
    else if ([elementName isEqualToString:kEsealValueName])
        _seekEseal = YES;
    else if ([elementName isEqualToString:kEntryByValueName])
        _seekEntryBy = YES;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // check if the end element matches what's last on the element stack
    if ([elementName isEqualToString:self.elementStack.lastObject]) {
        // they match, remove it
        [self.elementStack removeLastObject];
    }
    else {
        // they don't match, we have malformed XML
        NSLog(@"could not find end element of \"%@\"", elementName);
        [self.elementStack removeAllObjects];
        [parser abortParsing];
    }
    
    if ([elementName isEqualToString:kEntryElementName]) {
        
       
        [self.currentParseBatch addObject:self.currentStockdataObject];
        _parsedStockdatasCounter++;
        
        if (self.currentParseBatch.count >= kSizeOfStockdataBatch) {
            [self performSelectorOnMainThread:@selector(addStockdatasToList:) withObject:self.currentParseBatch waitUntilDone:YES];
            
            [self.currentParseBatch removeAllObjects];
        }
    }
    else if ([elementName isEqualToString:kDescriptionElementContent]) {
        
        if (self.seekDescription) {
            
            // search the entire string for "of ", and extract that last part of that string
            NSRange searchedRange = NSMakeRange(0, self.currentParsedCharacterData.length);
            NSRegularExpression *regExpression = [[NSRegularExpression alloc] initWithPattern:@"of " options:0 error:nil];
            NSTextCheckingResult *match = [regExpression firstMatchInString:self.currentParsedCharacterData options:0 range:searchedRange];
            NSInteger start = match.range.location + match.range.length;
            NSRange extractRange = NSMakeRange(start, self.currentParsedCharacterData.length - start);
            self.currentStockdataObject.location = [self.currentParsedCharacterData substringWithRange:extractRange];
            
            _seekDescription = NO;
        }
    }
    else if ([elementName isEqualToString:kValueKey]) {
        if (self.seekTime) {
            // end date/time
            self.currentStockdataObject.date = [self.dateFormatter dateFromString:self.currentParsedCharacterData];
            _seekTime = NO;
        }
        else if (self.seekLatitude) {
            // end latitude
            self.currentStockdataObject.latitude = self.currentParsedCharacterData.doubleValue;
            _seekLatitude = NO;
        }
        else if (self.seekLongitude) {
            // end longitude
            self.currentStockdataObject.longitude = self.currentParsedCharacterData.doubleValue;
            _seekLongitude = NO;
        }
        
        else if (self.seekSerial) {
            self.currentStockdataObject.serial = self.currentParsedCharacterData;
            _seekSerial = NO;
        }
        else if (self.seekIec) {
            self.currentStockdataObject.iec = self.currentParsedCharacterData;
            _seekIec = NO;
        }
        else if (self.seekBill) {
            self.currentStockdataObject.bill = self.currentParsedCharacterData;
            _seekBill = NO;
        }
        else if (self.seekTruck) {
            self.currentStockdataObject.truck = self.currentParsedCharacterData;
            _seekTruck = NO;
        }
        else if (self.seekCode) {
            self.currentStockdataObject.code = self.currentParsedCharacterData;
            _seekCode = NO;
        }
        else if (self.seekSerial) {
            self.currentStockdataObject.serial = self.currentParsedCharacterData;
            _seekSerial = NO;
        }
        else if (self.seekPort) {
            self.currentStockdataObject.port = self.currentParsedCharacterData;
            _seekPort = NO;
        }
        else if (self.seekDatee) {
            self.currentStockdataObject.datee = self.currentParsedCharacterData;
            _seekDatee = NO;
        }
        else if (self.seekTimee) {
            self.currentStockdataObject.time = self.currentParsedCharacterData;
            _seekTimee = NO;
        }
        else if (self.seekEntryBy) {
            self.currentStockdataObject.entryby = self.currentParsedCharacterData;
            _seekEntryBy = NO;
        }
        else if (self.seekEseal) {
            self.currentStockdataObject.eseal = self.currentParsedCharacterData;
            _seekEseal = NO;
        }
    }
    
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    _accumulatingParsedCharacterData = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (self.accumulatingParsedCharacterData) {
        [self.currentParsedCharacterData appendString:string];
    }
}


- (void)handleEarthquakesError:(NSError *)parseError {
    
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:ParseOperation.StockdatasErrorNotificationName
                                                        object:self
                                                      userInfo:@{ParseOperation.StockdatasMessageErrorKey: parseError}];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    if (parseError.code != NSXMLParserDelegateAbortedParseError && !self.didAbortParsing) {
        [self performSelectorOnMainThread:@selector(handleEarthquakesError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
