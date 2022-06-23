
#import "GoogleTranslateHelper.h"

static NSString *goolgeAPIKey = nil;
@implementation GoogleTranslateHelper

+ (void)setGoogleAPIKey:(NSString *)googleAPIKey {
//    AIzaSyB89di3mzga553lwBF3PQt-sF4heY5cLD
    goolgeAPIKey = googleAPIKey;
}
+ (void)translate:(NSString *)string
   sourceLanguage:(NSString *)source
   targetLanguage:(NSString *)target
       completion:(void (^) (NSString *resultString,BOOL isSuccessed))completion {
    if (string.length == 0) {
        if (completion) {
            completion(nil,NO);
        }
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    /// https://cloud.google.com/translate/docs/advanced/quickstart?hl=zh-CN google翻译文档
#if 1
    NSString *encodedStringUrl = [[NSString stringWithFormat:@"https://www.googleapis.com/language/translate/v2?key=%@&source=%@&target=%@&q=%@&format=text",goolgeAPIKey,source,target,string] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
#else
    NSString *encodedStringUrl = [[NSString stringWithFormat:@"https://translation.googleapis.com/language/translate/v2?key=%@&source=%@&target=%@&q=%@&format=text",goolgeAPIKey,source,target,string] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
#endif
    
    // 追加参数:默认处理特殊语言  &format=text
    NSURL *url = [NSURL URLWithString:encodedStringUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 超时时间
    request.timeoutInterval = 10.0f;
    // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            if (data == nil || data.length <= 0) {
                if (completion) {
                    completion(nil,NO);
                }
            } else {
                NSError *serializationError = nil;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializationError];
                if (error) {
                    if (completion) {
                        completion(nil,NO);
                    }
                } else {
                    NSArray *arr = [[dic valueForKey:@"data"] valueForKey:@"translations"];
                    if (arr && [arr isKindOfClass:[NSArray class]] && arr.count > 0) {
                        if (completion) {
                            completion(arr[0][@"translatedText"],YES);
                        }
                    } else {
                        if (completion) {
                            completion(nil,NO);
                        }
                    }
                }
            }
        } else {
            if (completion) {
                completion(nil,NO);
            }
        }
    }];
    // 启动任务
    [task resume];
}

@end
