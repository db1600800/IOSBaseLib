//
//  RSAUtilTest.m
//  PublicLibUI
//
//  Created by gdpost on 15/5/13.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RSAUtil.h"
#import "RSAUtilTest.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

@implementation RSAUtilTest

-(void) test
{
    RSAUtil *rsaUtil = [RSAUtil shareInstance];
    
    RSA *_rsa=[rsaUtil generateRSA:1024];
    
    //公钥字符
    NSString *publicKeyStringX509=[rsaUtil getPublicKeyStringX509:_rsa];
    //私钥字符
    NSString *privateKeyStringPKCS1=[rsaUtil getPrivateKeyStringPKCS1:_rsa ];
    
    
    
    //Rsa只含公钥对象
    NSString *tempPublicKeyStringX509=publicKeyStringX509;
    tempPublicKeyStringX509=@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCHmu8dVoea6nUbGqSCoWGPE1cbQoFpm4ifLywke8P4i5Wb6Qq3vjVby8Mek5Ricd41bP4sCEiOKUZZcziUKA82q/pdVFYO7EL+Z6R7BrZ7A1pqg9yjCMBGzMk4Ush/eeEXut4egYCcktg6WpNMUvmNHOhbGmh8ZRTT+YGnbe5oUwIDAQAB";
    
    RSA *publicRSA=[rsaUtil string2PublickeyFormartX509:tempPublicKeyStringX509 ];
    
    //Rsa只含私钥对象
    NSString *tempPrivateKeyStringPKCS1=privateKeyStringPKCS1;
    tempPrivateKeyStringPKCS1=@"MIICXAIBAAKBgQDpNpgnu3fderrhrBi2eGcKOHWZEPplF42V9f76v1gjqfPL1XcpSHvNpHtAYmKljBdYKg3NMpHldXje+G7s4/QrFuY/yKtyN/LNO4RlzsqWe3XnR8j2Xo2YzKfMksNOMdarJ5Ur60TbFEcqno4p1IshlmFYRq35BUxn3FctQ0TRcQIDAQABAoGAHr+9BhgYsNIay+CGDaEIbPeOwdTUPvoBCBG8QdFyzJj+9RQ7Nu1ArZePTKjsOsmi1lQNJ84QIIIBotx8u60+pyNZScsJ69J6t1ZVcfHkAjelUhUnMnCgaqfDj06ddlKb0ZtJ3/jhToAsvRplAn66T3s2V5qfuKUY6QVQAeMEGnECQQD2ZxAn1ZAe8K74HQb11JPlVtLdwTLr4FWjOBdueqH8bUuWIRL7+5jcnzGMmS7cHGgiXpOV1CJplF38Y4Qx+/RtAkEA8kwEdAT+M3pn8TKRf5SBz8IPv7N1mHRXkaerXCLXhSGr6WZBFeF/FcG1udDPXlKh8bC9IxwLfxVjIcfHMlkGlQJAAxBvC//E5g2aL220+3OkTzLQNn/DkVld10TITdBqmUgGq5xHryiG0x+LrzLseUJFLUA915wmvWdh79SQ/Uoj1QJANOEwS53XWKbLTpGpvX1Mw2noA/+Hl6k0f15ngKk9/hk2Kq8dX0gicz4eihovV7eTDmtzK9lwDOE/DF1MdQmG7QJBALf/oSq1dJz4Ds8ADlqCtm6OdCERun6u7BgchzkqYxS5Lo2Mv0nryuRW0xT749T1nEu/2yMFz9Gx6NGaS9dxQQ4=";
    RSA *privateRSA= [rsaUtil string2Privatekey:tempPrivateKeyStringPKCS1 ];
    
    
    
    NSString *plainText = @"{\"error\":0,\"status\":\"success\",\"date\":\"2015-05-24\",\"results\":[{\"currentCity\":\"北京\",\"pm25\":\"137\",\"index\":[{\"title\":\"穿衣\",\"zs\":\"炎热\",\"tipt\":\"穿衣指数\",\"des\":\"天气炎热，建议着短衫、短裙、短裤、薄型T恤衫等清凉夏季服装。\"},{\"title\":\"洗车\",\"zs\":\"较适宜\",\"tipt\":\"洗车指数\",\"des\":\"较适宜洗车，未来一天无雨，风力较小，擦洗一新的汽车至少能保持一天。\"},{\"title\":\"旅游\",\"zs\":\"较适宜\",\"tipt\":\"旅游指数\",\"des\":\"天气较好，较热，还好有风，能缓解不适感，总体来说还是好天气。较适宜旅游，尽情出去撒欢吧！\"},{\"title\":\"感冒\",\"zs\":\"少发\",\"tipt\":\"感冒指数\",\"des\":\"各项气象条件适宜，发生感冒机率较低。但请避免长期处于空调房间中，以防感冒。\"},{\"title\":\"运动\",\"zs\":\"较适宜\",\"tipt\":\"运动指数\",\"des\":\"阴天，较适宜进行各种户内外运动。\"},{\"title\":\"紫外线强度\",\"zs\":\"弱\",\"tipt\":\"紫外线强度指数\",\"des\":\"紫外线强度较弱，建议出门前涂擦SPF在12-15之间、PA+的防晒护肤品。\"}],\"weather_data\":[{\"date\":\"周日 05月24日 (实时：31℃)\",\"dayPictureUrl\":\"http://api.map.baidu.com/images/weather/day/yin.png\",\"nightPictureUrl\":\"http://api.map.baidu.com/images/weather/night/yin.png\",\"weather\":\"阴\",\"wind\":\"南风3-4级\",\"temperature\":\"33 ~ 21℃\"},{\"date\":\"周一\",\"dayPictureUrl\":\"http://api.map.baidu.com/images/weather/day/qing.png\",\"nightPictureUrl\":\"http://api.map.baidu.com/images/weather/night/duoyun.png\",\"weather\":\"晴转多云\",\"wind\":\"南风3-4级\",\"temperature\":\"34 ~ 22℃\"},{\"date\":\"周二\",\"dayPictureUrl\":\"http://api.map.baidu.com/images/weather/day/duoyun.png\",\"nightPictureUrl\":\"http://api.map.baidu.com/images/weather/night/duoyun.png\",\"weather\":\"多云\",\"wind\":\"微风\",\"temperature\":\"34 ~ 22℃\"},{\"date\":\"周三\",\"dayPictureUrl\":\"http://api.map.baidu.com/images/weather/day/duoyun.png\",\"nightPictureUrl\":\"http://api.map.baidu.com/images/weather/night/duoyun.png\",\"weather\":\"多云\",\"wind\":\"微风\",\"temperature\":\"33 ~ 22℃\"}]}]}Openssl实现了 实现了ssl/tls协议，采用 语言开发，支 协议， 语言开发， 实现了 协议 采用c语言开发 等常见操作系统。 持windows/linux/unix等常见操作系统。 等常见操作系统 Openssl当前版本为 当前版本为0.9.8e，完全实现了对 当前版本为 ，完全实现了对sslv1、 、 sslv2、 sslv3、 tls的支持。 Openssl的源代码 的支持。 、 、 的支持 的源代码 库可以从Openssl的官方网站 的官方网站www.openssl.org 库可以从 的官方网站 自由下载。 自由下载。 Openssl包括 部分：ssl协议、密码算法库和应 包括3部分 协议、 包括 部分： 协议 用程序。密码算法库是基础， 用程序。密码算法库是基础，应用程序把密码算 法库和ssl协议应用于实际开发中 协议应用于实际开发中， 法库和 协议应用于实际开发中，也是丰富的 Openssl指令集。 指令集。 指令集";
    plainText=[plainText base64EncodedString];
    
    NSData *encryptData = [rsaUtil encryptLongString:KeyTypePublic rsa:publicRSA paddingType:RSA_PADDING_TYPE_PKCS1 plainText:plainText usingEncoding:NSUTF8StringEncoding];
    
  // NSData *encryptData = [rsaUtil encryptLongString2:KeyTypePublic rsa:publicRSA rsaprivate:privateRSA  paddingType:RSA_PADDING_TYPE_PKCS1 plainText:plainText usingEncoding:NSUTF8StringEncoding];
    
    
    NSString *encryptString =[encryptData base64EncodedString];
    
    
    
    NSString *e=@"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";
    NSData *edata=[e base64DecodedData];
    
    // NSString *decryptString = [rsaUtil decryptRSAKeyWithType:KeyTypePrivate rsa:privateRSA paddingType:RSA_PADDING_TYPE_PKCS1 plainTextData:encryptData usingEncoding:NSUTF8StringEncoding];
    
    NSString *decryptString = [rsaUtil decryptLongString:KeyTypePrivate rsa:privateRSA paddingType:RSA_PADDING_TYPE_PKCS1 encryptText:edata usingEncoding:NSUTF8StringEncoding];
    
    NSString *aa=[decryptString base64DecodedString];
   // NSLog(@"\n respond :%@",aa);
    
    

}

@end
