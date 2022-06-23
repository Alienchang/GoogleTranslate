//
//  SpeechRecognitionService_v2.h
//  KMCommon
//
//  Created by 刘畅 on 2022/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpeechRecognitionService_v2 : NSObject
@property (nonatomic ,copy) NSString *sourceLang;
+ (instancetype) sharedInstance;
- (void)startRecord;
- (void)startTranslateCompletion:(void(^)(BOOL success ,NSString *result))completion;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
