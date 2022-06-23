//
//  SpeechRecognitionService_v2.m
//  KMCommon
//
//  Created by 刘畅 on 2022/3/25.
//

#import "SpeechRecognitionService_v2.h"
#import "AudioController.h"
@interface SpeechRecognitionService_v2()
@property (nonatomic ,strong) NSMutableData *data;

@end

@implementation SpeechRecognitionService_v2

+ (instancetype) sharedInstance {
    static SpeechRecognitionService_v2 *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [[AudioController sharedInstance] prepareWithSampleRate:44100.0];
    });
    return instance;
}

- (void)startRecord {
    [AudioController sharedInstance].delegate = self;
    [[AudioController sharedInstance] start];
}
- (void)startTranslateCompletion:(void(^)(BOOL success ,NSString *result))completion {
    NSString *service = @"https://speech.googleapis.com/v1/speech:recognize";
    service = [service stringByAppendingString:@"?key="];
    service = [service stringByAppendingString:@"AIzaSyB89di3mzga553lwBF3PQt-sF4heY5cLDk"];

    NSData *audioData = self.data;
    NSDictionary *configRequest = @{@"encoding":@"LINEAR16",
                                    @"sampleRateHertz":@(44100.0),
                                    @"languageCode":self.sourceLang,
                                    @"maxAlternatives":@30};
    NSDictionary *audioRequest = @{@"content":[audioData base64EncodedStringWithOptions:0]};
    NSDictionary *requestDictionary = @{@"config":configRequest,
                                        @"audio":audioRequest};
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestDictionary
                                                          options:0
                                                            error:&error];

    NSString *path = service;
    NSURL *URL = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    // if your API key has a bundle ID restriction, specify the bundle ID like this:
    [request addValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];
    NSString *contentType = @"application/json";
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestData];
    [request setHTTPMethod:@"POST"];

    NSURLSessionTask *task =
    [[NSURLSession sharedSession]
     dataTaskWithRequest:request
     completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
       dispatch_async(dispatch_get_main_queue(),
                      ^{
           if (!error) {
               NSError *error = nil;
               NSArray *resultArray = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:NSJSONReadingAllowFragments
                                                                              error:&error][@"results"];
               NSDictionary *resultDic2 = ((NSArray *)resultArray.firstObject[@"alternatives"]).firstObject;
               NSString *result = resultDic2[@"transcript"];
               completion(YES ,result);
           } else {
               completion(NO ,nil);
           }
       });
     }];
    [task resume];
    [self stop];
}

- (void)stop {
    [[AudioController sharedInstance] stop];
    [AudioController sharedInstance].delegate = nil;
    self.data = nil;
}

#pragma mark -- getter
- (NSMutableData *)data {
    if (!_data) {
        _data = [NSMutableData new];
    }
    return _data;
}

- (NSString *)sourceLang {
    if (!_sourceLang) {
        _sourceLang = @"en-US";
    }
    return _sourceLang;
}

#pragma mark -- AudioControllerDelegate
- (void) processSampleData:(NSData *)data {
    [self.data appendData:data];
}
@end
