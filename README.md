# GoogleTranslate
谷歌翻译封装


                    [GoogleTranslateHelper translate:text
                                        sourceLanguage:sourceLang
                                        targetLanguage:targetLang
                                            completion:^(NSString *resultString, BOOL isSuccessed) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf sendMessage:text
                                    translateText:resultString];
                        });
                    }];
