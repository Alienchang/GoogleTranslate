
#import <Foundation/Foundation.h>
@interface GoogleTranslateHelper : NSObject
@property (class) NSString *googleAPIKey;

+ (void)translate:(NSString *)string
   sourceLanguage:(NSString *)source
   targetLanguage:(NSString *)target
       completion:(void (^) (NSString *resultString,BOOL isSuccessed))completion;
@end
