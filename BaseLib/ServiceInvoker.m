//
//  ServiceInvoker.m
//  PublicLibUI
//
//  Created by apple on 15/5/15.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceInvoker.h"
#import "RSAUtil.h"
#import "MsgReturn.h"

#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "WGErrorCode.h"
#import "JSONKit.h"
#import "ZipArchive.h"

#import "sys/xattr.h"
#import "GSNetService.h"
#import  "Sql.h"
#import "WebConfig.h"
#import "EncryptAlgorithms.h"

@implementation ServiceInvoker

@synthesize delegate;
@synthesize formName;
@synthesize willDo;

@synthesize sUpdateAction;
@synthesize sUpdateStatus;
@synthesize sConfigUpdateStatus;
@synthesize callServiceFormName;

static int mMsgSeqNo ;

-(void)appSignIn:(NSString*)appId appVersion:(NSString*)appVersion {
    
    
    [self clearService];
    
    RSAUtil *rsaUtil = [RSAUtil shareInstance];
    
    RSA *_rsa=[rsaUtil generateRSA:1024];
    
    //公钥字符
    NSString *publicKeyStringX509=[rsaUtil getPublicKeyStringX509:_rsa];
    //私钥字符
    NSString *privateKeyStringPKCS1=[rsaUtil getPrivateKeyStringPKCS1:_rsa ];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:appId forKey:@"appId"];
    [userDefault setObject:appVersion forKey:@"appVer"];
    [userDefault setObject:publicKeyStringX509 forKey:@"publicKeyStringX509"];
    [userDefault setObject:privateKeyStringPKCS1 forKey:@"privateKeyStringPKCS1"];
    
    [userDefault synchronize];
    
    [self rsaPublicKey];
}

/**
 * 2.2.1获取接入平台RSA公钥
 */
-(void) rsaPublicKey {
    
    self.formName=@"rsaPublicKey";
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSString *appID=[userDefault objectForKey:@"appId"];
    NSString *appVersion=[userDefault objectForKey:@"appVer"];
    
    
    // 获取接入平台RSA公钥报文组装
    NSMutableDictionary *rootParam = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *jsonBusinessParam =  [[NSMutableDictionary alloc ] init];
    [rootParam setValue:@"rsaPublicKeyDeepProc" forKey:@"action"];//rsaPublicKeyDeepProc   rsaPublicKey
    [jsonBusinessParam setValue:appID forKey:@"appId"];// Appid
    [jsonBusinessParam setValue:appVersion forKey:@"appVer"];// App版本
    
    [rootParam setValue:jsonBusinessParam forKey:@"param"];
    
    //NSString *request =[self dic2jsonString:rootParam];
    
    [[[GSNetService alloc] init] sendMsg:rootParam toServerOnFormName:@"rsaPublicKey" withDelegate:self];
    
}


-(void)fileUp:(NSString*)appID map:(NSMutableDictionary*)map
{
    //    参数1：appID唯一标识 取 SysBaseInfo.appID
    //    参数2：map取值如下：
    //
    //    fileName  文件名称 ：取当前文件的文件名
    //    fileSize  文件大小 ：相关api取当前文件大小
    //    fileType  文件类型 ： 01 图片
    //    md5	  文件md5值：计算当前文件md5值
    //    uploadPath 	上传存放路径：空
    //    requestFileData  文件二进制字节流：当前图片文件转换为二进制流
    
    
    
    
    self.formName=@"fileUp";
    
    //    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    //    NSString *appID=[userDefault objectForKey:@"appId"];
    //    NSString *appVersion=[userDefault objectForKey:@"appVer"];
    
    
    // 获取接入平台RSA公钥报文组装
    NSMutableDictionary *rootParam = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *jsonBusinessParam =  [[NSMutableDictionary alloc ] init];
    //[rootParam setValue:@"fileUp" forKey:@"action"];
    
    [jsonBusinessParam setValue:appID forKey:@"appId"];// Appid
    [jsonBusinessParam setValue:[map objectForKey:@"fileName"]  forKey:@"fileName"];// App版本
    [jsonBusinessParam setValue:[map objectForKey:@"fileSize"]  forKey:@"fileSize"];// App版本
    [jsonBusinessParam setValue:[map objectForKey:@"fileType"]  forKey:@"fileType"];// App版本
    [jsonBusinessParam setValue:[map objectForKey:@"md5"]  forKey:@"md5"];// App版本
    [jsonBusinessParam setValue:[map objectForKey:@"uploadPath"] forKey:@"uploadPath"];// App版本
    
    
    [rootParam setValue:jsonBusinessParam forKey:@"requestHeadPara"];
//    [rootParam setValue:[map objectForKey:@"requestFileData"] forKey:@"requestFileData"];

    [rootParam setValue:[map objectForKey:@"requestFileData"]  forKey:@"requestFileData"];
    
    
    NSString *baseUrl=baseUrl;
    
//    NSString *baseUrl=@"http://jycshj.183.gd.cn/chinapost/AppImgUploadServlet";
    NSString *fullUrl = baseUrl ;
    NSURL *url = [NSURL URLWithString:[fullUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:TIMEOUT/1000];
    request.HTTPMethod=@"POST";
    //把拼接后的字符串转换为data，设置请求体
    NSString *sendstr = [rootParam JSONString];
    NSData* tmdata =[sendstr dataUsingEncoding:NSUTF8StringEncoding];
    

    
    request.HTTPBody=tmdata;
//    request.HTTPBody=[[rootParam JSONString] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   
                                   
                                   //交易失败  回调
                                   MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                                   msgReturn.errorCode=ERROR_FAILED;
                                   msgReturn.errorDesc=@"文件上传失败";
                                   msgReturn.formName=@"fileUp";
                                   
                                   [delegate serviceInvokerError:msgReturn];
                                   
                               }else{
                                   
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   
//                                   NSDictionary *returnDataDic=[self jsonString2Dic:[responseString base64DecodedData] ];
                                   NSDictionary *returnDataDic=[self jsonString2Dic:[responseString dataUsingEncoding:NSUTF8StringEncoding] ];

                                   
                                   NSString *code = [returnDataDic objectForKey:@"returnCode"];
                                   
                                   if ([code isEqualToString:@"0000"]) {
                                       
                                       NSString *desc = [returnDataDic objectForKey:@"returnDesc"];
                                       NSMutableDictionary *date = [returnDataDic objectForKey:@"returnDate"];
                                       
                                       NSString *imageId = [date objectForKey:@"imageId"];
                                       
                                       
                                       
                                       
                                       //交易成功  回调
                                       MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                                       msgReturn.errorCode=ERROR_SUCCESS;
                                       msgReturn.errorDesc=@"文件上传成功";
                                       msgReturn.formName=@"fileUp";
                                       msgReturn.map=date;
                                       [delegate serviceInvokerReturnData:msgReturn];
                                   }else
                                   {
                                       //交易失败  回调
                                       MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                                       msgReturn.errorCode=ERROR_FAILED;
                                       msgReturn.errorDesc=@"文件上传失败";
                                       msgReturn.formName=@"fileUp";
                                       
                                       [delegate serviceInvokerError:msgReturn];
                                   }                                   
                                
                               }
                           }];
    
    
    
}



//签到
-(void) appSignIn
{
    self.formName=@"appSignIn";
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSString *appID=[userDefault objectForKey:@"appId"];
    NSString *appVersion=[userDefault objectForKey:@"appVer"];
    NSString *publicKeyStringX509=[userDefault  objectForKey:@"publicKeyStringX509"];
    
    NSString *publicKeyStringX509ServerVer=[userDefault  objectForKey:@"publicKeyStringX509ServerVer"];
    NSString *publicKeyStringX509Server=[userDefault  objectForKey:@"publicKeyStringX509Server"];
    
    
    if (publicKeyStringX509Server==NULL) {
        
        return;
    }
    
    RSAUtil *rsaUtil = [RSAUtil shareInstance];
    
    NSMutableDictionary *rootParam = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *jsonBusinessParam =  [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *message =  [[NSMutableDictionary alloc ] init];
    
    [rootParam setValue:@"appSignIn" forKey:@"action"];
    [jsonBusinessParam setValue:appID forKey:@"appId"];// Appid
    [jsonBusinessParam setValue:appVersion forKey:@"appVer"];// App版本
    [jsonBusinessParam setValue:publicKeyStringX509ServerVer forKey:@"keyVer"];
    
    [message setValue:publicKeyStringX509 forKey:@"appKey"];
    
    NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
    
    NSString *logicId=[userdefalut objectForKey:@"logicId"];
    if(logicId==NULL)
    {
        [message setValue:@"" forKey:@"logicId"];
    }else{
        
        [message setValue:logicId forKey:@"logicId"];
    }
    
    //Rsa只含公钥对象
    RSA *publicRSA=[rsaUtil string2PublickeyFormartX509:publicKeyStringX509Server ];
    
    NSData *encryptData = [rsaUtil encryptLongString:KeyTypePublic rsa:publicRSA paddingType:RSA_PADDING_TYPE_PKCS1 plainText:[self dic2jsonString:message ] usingEncoding:NSUTF8StringEncoding];
    NSString *encryptString =[encryptData base64EncodedString];
    
    
    [jsonBusinessParam setValue:encryptString forKey:@"message"];
    
    [rootParam setValue:jsonBusinessParam forKey:@"param"];
    
    [[[GSNetService alloc] init] sendMsg:rootParam toServerOnFormName:@"appSignIn" withDelegate:self];
    
}



//报文流水重置
-(void) messageIdReset
{
    self.formName=@"messageIdReset";
    
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSString *appID=[userDefault objectForKey:@"appId"];
    NSString *appVersion=[userDefault objectForKey:@"appVer"];
    
    NSString *publicKeyStringX509ServerVer=[userDefault  objectForKey:@"publicKeyStringX509ServerVer"];
    NSString *publicKeyStringX509Server=[userDefault  objectForKey:@"publicKeyStringX509Server"];
    
    
    if (publicKeyStringX509Server==NULL) {
        
        return;
    }
    
    RSAUtil *rsaUtil = [RSAUtil shareInstance];
    
    NSMutableDictionary *rootParam = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *jsonBusinessParam =  [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *message =  [[NSMutableDictionary alloc ] init];
    
    [rootParam setValue:@"messageIdReset" forKey:@"action"];
    [jsonBusinessParam setValue:appID forKey:@"appId"];// Appid
    [jsonBusinessParam setValue:appVersion forKey:@"appVer"];// App版本
    [jsonBusinessParam setValue:publicKeyStringX509ServerVer forKey:@"keyVer"];
    
    
    NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
    NSString *logicId=[userdefalut objectForKey:@"logicId"];
    if(logicId==NULL)
    {
        [message setValue:@"" forKey:@"logicId"];
    }else{
        
        [message setValue:logicId forKey:@"logicId"];
    }
    
    //Rsa只含公钥对象
    RSA *publicRSA=[rsaUtil string2PublickeyFormartX509:publicKeyStringX509Server ];
    
    NSData *encryptData = [rsaUtil encryptLongString:KeyTypePublic rsa:publicRSA paddingType:RSA_PADDING_TYPE_PKCS1 plainText:[self dic2jsonString:message ] usingEncoding:NSUTF8StringEncoding];
    NSString *encryptString =[encryptData base64EncodedString];
    
    
    [jsonBusinessParam setValue:encryptString forKey:@"message"];
    
    [rootParam setValue:jsonBusinessParam forKey:@"param"];
    
    [[[GSNetService alloc] init] sendMsg:rootParam toServerOnFormName:@"messageIdReset" withDelegate:self];
    
}




NSMutableDictionary *cachebusinessParameter;


//交易调用
-(void) callWebservice:(NSMutableDictionary*) businessParameter  formName:(NSString*) _formName {
    
    self.formName=_formName;
    self.callServiceFormName=_formName;
    cachebusinessParameter=businessParameter;
    
    
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSString *appId= [userDefault objectForKey:@"appId"];
    NSString *appVer=[userDefault objectForKey:@"appVer"];
    
    
    
    NSString *publicKeyStringX509Server=  [userDefault  objectForKey:@"publicKeyStringX509Server"];
    NSString *publicKeyStringX509ServerVer= [userDefault objectForKey:@"publicKeyStringX509ServerVer"];
    NSString *logicId= [userDefault objectForKey:@"logicId"];
    
    NSString *tokenType=[userDefault  objectForKey:@"tokenType"];
    NSString *token=[userDefault  objectForKey:@"token"];
    
    
    
    // 签到报文组装
    NSMutableDictionary *rootParam = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *jsonBusinessParam =  [[NSMutableDictionary alloc ] init];
    [rootParam setValue:@"business" forKey:@"action"];
    [jsonBusinessParam setValue:appId forKey:@"appId"];// Appid
    [jsonBusinessParam setValue:appVer forKey:@"appVer"];// App版本
    [jsonBusinessParam setValue:publicKeyStringX509ServerVer forKey:@"keyVer"];// 服务器公钥版本
    
    
    
    NSMutableDictionary *message = [[NSMutableDictionary alloc ] init];
    // 逻辑设备号
    [message setValue:logicId forKey:@"logicId"];
    // 业务类型代号
    [message setValue:formName forKey:@"functionId"];
    // 报文流水号
    mMsgSeqNo=mMsgSeqNo+1;
    NSNumber *seq=[NSNumber numberWithInt:mMsgSeqNo];
    [message setValue:seq  forKey:@"msgId"];
    
    
    
    // token类型
    [message setValue:tokenType forKey:@"tokenType"];
    // token
    [message setValue:token forKey:@"token"];
    // 主体报文
    [message setValue:[businessParameter JSONString] forKey:@"businessParam"];
    
    // NSString *messageString=[message JSONString];
    
    RSAUtil *rsaUtil = [RSAUtil shareInstance];
    
    //Rsa只含公钥对象
    RSA *publicRSA=[rsaUtil string2PublickeyFormartX509:publicKeyStringX509Server ];
    
    NSData *encryptData = [rsaUtil encryptLongString:KeyTypePublic rsa:publicRSA paddingType:RSA_PADDING_TYPE_PKCS1 plainText:[message JSONString] usingEncoding:NSUTF8StringEncoding];
    NSString *encryptString =[encryptData base64EncodedString];
    
    
    [jsonBusinessParam setValue:encryptString forKey:@"message"];
    
    
    [rootParam setValue:jsonBusinessParam forKey:@"param"];
    
    [[[GSNetService alloc] init] sendMsg:rootParam toServerOnFormName:_formName withDelegate:self];
}





-(void)clearService
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"" forKey:@"appId"];
    [userDefault setObject:@"" forKey:@"appVer"];
    [userDefault setObject:@"" forKey:@"publicKeyStringX509"];
    [userDefault setObject:@"" forKey:@"privateKeyStringPKCS1"];
    [userDefault setObject:@"" forKey:@"publicKeyStringX509Server"];
    [userDefault setObject:@"" forKey:@"publicKeyStringX509ServerVer"];
    //[userDefault setObject:@"" forKey:@"logicId"];
    [userDefault setObject:@"" forKey:@"tokenType"];
    [userDefault setObject:@"" forKey:@"token"];
    [userDefault synchronize];
    
    
    mMsgSeqNo = 1;// 报文流水号
    
}

-(void) checkUpdates:(NSString*)appId appVersion:(NSString*)appVersion{
    
    Sql *sql=[[Sql alloc ]init];
    
    NSString *oldConfigFileVersion=[sql selectPM_SIGNSERVICE_CONFIGVERSION];
    
    if(oldConfigFileVersion==nil || [oldConfigFileVersion isEqualToString:@""])
    {
        oldConfigFileVersion=@"19000101.0.1";
    }
    
    self.formName=@"checkUpdates";
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:appId forKey:@"appId"];
    [userDefault setObject:appVersion forKey:@"appVer"];
    
    NSString *appID=appId;//[userDefault objectForKey:@"appId"];
    NSString *appVer=appVersion;//[userDefault objectForKey:@"appVer"];
    
    // 获取接入平台RSA公钥报文组装
    NSMutableDictionary *rootParam = [[NSMutableDictionary alloc ] init];
    
    [rootParam setValue:@"startup" forKey:@"action"];
    [rootParam setValue:appID forKey:@"appId"];// Appid
    [rootParam setValue:appVer forKey:@"appVersion"];// App版本
    [rootParam setValue:oldConfigFileVersion forKey:@"appConfigVersion"];// App版本
    [rootParam setValue:@"" forKey:@"deviceId"];// App版本
    
    NSLog(@"checkupdates request :%@",rootParam);
    
    [[[GSNetService alloc] init] sendMsg:rootParam toServerOnFormName:@"checkUpdates" withDelegate:self];
    
    
    //http://202.105.44.4:8001/services/ChinaPostService?wsdl
    
    
}




#pragma GSNetServiceDelegate
//业务请求返回

-(void)netServiceError:(NSError*)error
{
    
    //1.手机网络不通  ERROR_NOT_NET ERROR_TEXT_NOT_NET
    //2.手机网络通,连不上服务器（服务器网络异常或服务器没开）
    //3.连上服务器，超时无结果返回
    //4.有返回结果，但数据格式错误
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *errortxt = [userDefaultes stringForKey:@"errortxt"];
    NSString *errorcode = [userDefaultes stringForKey:@"errorcode"];
    

    
    
 
    if ( error.code==-1005) {//网络丢失
        
        if(cachebusinessParameter!=nil)
        {
         [self callWebservice:cachebusinessParameter formName:self.callServiceFormName ];
        
          NSLog(@"测试-1005%@",error);
        return;
        }else
        {
            MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
            msgReturn.errorCode=@"D001";
            msgReturn.errorDesc=errortxt;
            msgReturn.formName=self.formName;
            [delegate serviceInvokerError:msgReturn];
           
            return;
        }
    }
    
    if([errorcode isEqualToString:ERROR_DATA_FORMAT_ERROR] || [errorcode isEqualToString:ERROR_SERVICE_IN_ERROR] || [errorcode isEqualToString:ERROR_NOT_NET])
        
    {
        
        
    }
    
    
    MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
    msgReturn.errorCode=@"D001";
    msgReturn.errorDesc=errortxt;
    msgReturn.formName=self.formName;
    [delegate serviceInvokerError:msgReturn];
    
    
    NSLog(@"错误:%@ %@",errortxt,self.formName);
}

int  errorCountFlag=0;

//业务请求返回数据
-(void)netServiceReturnData:(NSDictionary*)rtn
{
    RSAUtil *rsaUtil = [RSAUtil shareInstance];
    
    if (rtn==NULL) {
        
    } else {
        NSString *returnDataStr=[rtn objectForKey:@"return"];
        if(returnDataStr ==NULL)
        {
            
            MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
            msgReturn.errorCode=@"D001";
            msgReturn.errorDesc=@"网络错误";
            msgReturn.formName=@"";
            [delegate serviceInvokerError:msgReturn];
            
            return;
        }
        NSString *formname=[rtn objectForKey:@"formName"];
        NSString *tempString1=[self stringWithoutESCCharater:returnDataStr];
        NSDictionary *returnDataDic = [self jsonString2Dic:[tempString1 dataUsingEncoding:NSUTF8StringEncoding] ];
        
        
        
        NSString *err_code = [returnDataDic objectForKey:@"err_code"];
        NSString *err_msg =  [returnDataDic objectForKey:@"err_msg"];
        
        
        
        
        if([formname isEqualToString:@"rsaPublicKey"])
        {//取服务器公钥
            
            if ([err_code isEqualToString:ERROR_SUCCESS]) {
                
                NSString *param = [returnDataDic objectForKey:@"param"];
                
                if(param==NULL)
                    return;
                
                NSDictionary *paramdic=[self jsonString2Dic:[param base64DecodedData] ];
                
                NSString *publicKeyStringX509Server = [paramdic objectForKey:@"f"];//公钥public_key
                
                if(publicKeyStringX509Server==nil ||[publicKeyStringX509Server isEqualToString:@""])
                {
                    return;
                }
                
                NSString *publicKeyStringX509ServerVer = [paramdic objectForKey:@"b"];//公钥版本号
                
                  NSString *public_key_flag = [paramdic objectForKey:@"g"];//加密标志  0加密 1不加密 public_key_flag
                
                NSString *public_key_string = [paramdic objectForKey:@"c"];//公钥加密对应的秘钥串public_key_string
                
                EncryptAlgorithms *encryptAlgorithms=[[EncryptAlgorithms alloc ] init ];
               
                if ([public_key_flag isEqualToString:@"0"]) {
                    [encryptAlgorithms init:public_key_string];
                    publicKeyStringX509Server= [encryptAlgorithms Decrypt:publicKeyStringX509Server];
                }
                
                
                
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                [userDefault setObject:publicKeyStringX509Server forKey:@"publicKeyStringX509Server"];
                [userDefault setObject:publicKeyStringX509ServerVer forKey:@"publicKeyStringX509ServerVer"];
                [userDefault synchronize];
                
                
                [self appSignIn ];
            }else
            {
            
                MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                msgReturn.errorCode=err_code;
                msgReturn.errorDesc=err_msg;
                msgReturn.formName=@"rsaPublicKey";
                [delegate serviceInvokerError:msgReturn];
            
            }
            
            
        }
        
        
        
        else if([formname isEqualToString:@"appSignIn"])
        {//签到
            if ([err_code isEqualToString:ERROR_SUCCESS]) {
                
                
                NSString *param = [returnDataDic objectForKey:@"param"];
                
                if(param==NULL)
                    return;
                
                
                
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                
                
                NSString *privateKeyStringPKCS1= [userDefault objectForKey:@"privateKeyStringPKCS1"];
                
                RSAUtil *rsaUtil = [RSAUtil shareInstance];
                //Rsa只含私钥对象
                RSA *privateRSA= [rsaUtil string2Privatekey:privateKeyStringPKCS1 ];
                
                
                
                NSData *edata=[param base64DecodedData];
                
                
                NSString *decryptString = [rsaUtil decryptLongString:KeyTypePrivate rsa:privateRSA paddingType:RSA_PADDING_TYPE_PKCS1 encryptText:edata usingEncoding:NSUTF8StringEncoding];
                
                NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                if(decryptString==NULL)
                {
                    //解密失败
                    [userdefalut setObject:ERROR_SINGIN_ERROR forKey:@"errorCode"];
                    [userdefalut setObject:SINGIN_ERROR forKey:@"errorTxt"];
                    [userdefalut synchronize];
                    
                    //签到失败 回调
                    MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                    msgReturn.errorCode=ERROR_SINGIN_ERROR;
                    msgReturn.errorDesc=SINGIN_ERROR;
                    msgReturn.formName=@"appSignIn";
                    [delegate serviceInvokerError:msgReturn];
                    return;
                }
                NSDictionary *paramdic=[self jsonString2Dic:[decryptString dataUsingEncoding:NSUTF8StringEncoding] ];
                
                
                NSString *logicId= [paramdic objectForKey:@"logicId"];
                [userdefalut setObject:logicId forKey:@"logicId"];
                
                [userdefalut synchronize];
                
                mMsgSeqNo=1;
                //签到成功 回调
                MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                msgReturn.errorCode=ERROR_SUCCESS;
                msgReturn.errorDesc=ERROR_TEXT_SUCCESS;
                msgReturn.formName=@"appSignIn";
                [delegate serviceInvokerReturnData:msgReturn];
                
                
                
                if([willDo isEqualToString:@"callWebservice"])
                {
                    [self callWebservice:cachebusinessParameter formName:self.callServiceFormName ];
                    
                    willDo=@"";
                }
                
                errorCountFlag=0;
            }
            
            
            
            if ([err_code  isEqualToString:WG1007 ]
                || [err_code isEqualToString:WG2002]
                || [err_code isEqualToString:WG2003]
                || [err_code isEqualToString:WG2004]
                ) {
                errorCountFlag++;
                
                
                if ([err_code isEqualToString:WG1007] ) {
                    // 如果为“wg1007 设备逻辑号不存在”，则置mLogicID为空
                    
                    NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                    [userdefalut setObject:@"" forKey:@"logicId"];
                    [userdefalut synchronize];
                    
                }
                
                // 签到错误次数最多循环执行3次，超过3次仍然错误则当签到失败处理；
                if (errorCountFlag > 3) {
                    errorCountFlag = 0;
                    
                    NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                    [userdefalut setObject:ERROR_SINGIN_ERROR forKey:@"errorCode"];
                    [userdefalut setObject:SINGIN_ERROR forKey:@"errorTxt"];
                    [userdefalut synchronize];
                    
                    //签到失败 回调
                    MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                    msgReturn.errorCode=err_code;
                    msgReturn.errorDesc=err_msg;
                    msgReturn.formName=@"appSignIn";
                    [delegate serviceInvokerError:msgReturn];
                    willDo=@"";
                    
                } else {
                    //重新 获取服务器公钥 签到
                    NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                    NSString *appID=[userdefalut objectForKey:@"appId"];
                    NSString *appVersion=[userdefalut objectForKey:@"appVer"];
                    
                    [self appSignIn:appID appVersion:appVersion ];
                    
                    
                }
                
            }
        }
        
        else if([formname isEqualToString:@"messageIdReset"])
        {//报文流水重置
            
            if ([err_code isEqualToString:ERROR_SUCCESS]) {
                
                
                
                //重置成功再发次交易请求
                
                if([willDo isEqualToString:@"callWebService"])
                {
                    
                    [self callWebservice:cachebusinessParameter formName:self.callServiceFormName ];
                    willDo=@"";
                    
                }
                
            }
            
            
            // 如果err_code为“wg2002 密钥版本号比较失败”或者“2003 报文解密失败”，则需要重新获取无线网关公钥；
            if ([err_code  isEqualToString:WG2002 ]
                || [err_code isEqualToString:WG2004]
                || [err_code isEqualToString:WG2003]
                ) {
                
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                [userDefault setObject:@"" forKey:@"publicKeyStringX509Server"];
                [userDefault setObject:@"" forKey:@"publicKeyStringX509ServerVer"];
                [userDefault synchronize];
                
                //重新 获取服务器公钥 签到
                NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                NSString *appID=[userdefalut objectForKey:@"appId"];
                NSString *appVersion=[userdefalut objectForKey:@"appVer"];
                
                [self appSignIn:appID appVersion:appVersion ];
                
                willDo=@"callWebService";
                
            }
        }else if([formname isEqualToString:@"checkUpdates"])
        {
            
            NSLog(@"checkupdates respond :%@",returnDataDic);
            
            BOOL success = [returnDataDic objectForKey:@"success"];
            NSDictionary *datadic = [returnDataDic objectForKey:@"data"];
            if(success!=NULL && success && datadic!=NULL)
            {
                
                NSString *appConfigVersion = [datadic objectForKey:@"appConfigVersion"];//配置文件版本号
                
                NSString *appUrl = [datadic objectForKey:@"appUrl"];//app下载地址
                
                NSString *serverAppVersion = [datadic objectForKey:@"appVersion"];//app版本号
                NSString *configPath = [datadic objectForKey:@"configPath"];//配置文件路径
                
                NSString *deviceStatus = [datadic objectForKey:@"deviceStatus"];
                
                BOOL forceUpdate  = [datadic objectForKey:@"oldVersionEnable"];
                NSString *loginStatus = [datadic objectForKey:@"loginStatus"];
                NSString *singleLoginApp = [datadic objectForKey:@"singleLoginApp"];
                
                NSString *configUrl = [datadic objectForKey:@"configUrl"];
                
                
                
                
                Sql *sql=[[Sql alloc ]init];
                
                NSString *oldConfigFileVersion=[sql selectPM_SIGNSERVICE_CONFIGVERSION];
                
                if(oldConfigFileVersion==nil || [oldConfigFileVersion isEqualToString:@""])
                {
                    //配置文件不存在
                    if(  configPath && configUrl && [configUrl hasPrefix:@"http"]
                       ){
                        
                        
                        
                        BOOL downloadAndZipOk= [self downloadFileAndUNZip:configUrl configPath:configPath];
                        if(downloadAndZipOk)
                        {
                            NSLog(@"%@",@"配置文件更新成功");
                            
                            //交易成功  回调
                            MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                            msgReturn.errorCode=ERROR_SUCCESS;
                            msgReturn.errorDesc=@"版本检查成功";
                            msgReturn.formName=@"checkUpdates";
                            msgReturn.map=datadic;
                        
                            [delegate serviceInvokerReturnData:msgReturn];
                        }else
                        {
                            
                            //交易失败  回调
                            MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                            msgReturn.errorCode=ERROR_FAILED;
                            msgReturn.errorDesc=@"配置文件获取失败";
                            msgReturn.formName=@"checkUpdates";
                            
                            [delegate serviceInvokerError:msgReturn];
                        }
                        
                        
                    }else
                    {
                        
                        //交易失败  回调
                        MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                        msgReturn.errorCode=ERROR_FAILED;
                        msgReturn.errorDesc=@"配置文件获取失败";
                        msgReturn.formName=@"checkUpdates";
                        
                        [delegate serviceInvokerError:msgReturn];
                        
                    }
                    
                    
                }else
                {
                    //配置文件已存在
                    
                    
                    if(  configPath && configUrl && [configUrl hasPrefix:@"http"] &&  ![oldConfigFileVersion isEqualToString:appConfigVersion]
                       ){
                        
                        BOOL downloadAndZipOk= [self downloadFileAndUNZip:configUrl configPath:configPath];
                        if(downloadAndZipOk)
                        {
                            NSLog(@"%@",@"配置文件更新成功");
                            //交易成功  回调
                            MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                            msgReturn.errorCode=ERROR_SUCCESS;
                            msgReturn.errorDesc=@"版本检查成功";
                            msgReturn.formName=@"checkUpdates";
                            msgReturn.map=datadic;
                            [delegate serviceInvokerReturnData:msgReturn];
                        }else
                        {
                            NSLog(@"%@",@"配置文件更新失败");
                            //交易失败  回调
                            MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                            msgReturn.errorCode=ERROR_FAILED;
                            msgReturn.errorDesc=@"配置文件获取失败";
                            msgReturn.formName=@"checkUpdates";
                            
                            [delegate serviceInvokerError:msgReturn];
                        }
                        
                      
                        
                    }else
                    {
                        
                        //交易成功  回调
                        MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                        msgReturn.errorCode=ERROR_SUCCESS;
                        msgReturn.errorDesc=@"版本检查成功";
                        msgReturn.formName=@"checkUpdates";
                        msgReturn.map=datadic;
                        [delegate serviceInvokerReturnData:msgReturn];
                    }
                    //  }
                    
                    
                    
                    
                }
                
                
            }}
        else{//调用交易
            
            
            if ([err_code isEqualToString:ERROR_SUCCESS]) {
                
                NSString *param = [returnDataDic objectForKey:@"param"];
                if([param isKindOfClass:[NSNull class]]?true:false)
                {
                   return;
                }
                
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                
                NSString *privateKeyStringPKCS1= [userDefault objectForKey:@"privateKeyStringPKCS1"];
                
                RSA *privateRSA= [rsaUtil string2Privatekey:privateKeyStringPKCS1 ];
                
                
                NSData *edata=[param base64DecodedData];
                
                
                NSString *decryptStringBase64 = [rsaUtil decryptLongString:KeyTypePrivate rsa:privateRSA paddingType:RSA_PADDING_TYPE_PKCS1 encryptText:edata usingEncoding:NSUTF8StringEncoding];
                
                
                NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                NSMutableString*decryptString = [[NSMutableString alloc] initWithData:[decryptStringBase64 base64DecodedData] encoding:gbkEncoding];
                
                
                 NSLog(@"\n respond %@ :%@\n",self.formName,decryptString);
                
                if( decryptString!=nil && ![decryptString isKindOfClass:[NSNull class]]&& [decryptString rangeOfString:@"null"].location !=NSNotFound)
                {
                    MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                    msgReturn.errorCode=@"-8888";
                    msgReturn.errorDesc=[NSString  stringWithFormat:@"%@ %@",self.formName,@"null"] ;
                    msgReturn.formName=self.formName;
                    
                    
                    [delegate serviceInvokerReturnData:msgReturn];
                    
                    return;
                }

                
               
                
                
                NSDictionary *paramdic=[self jsonString2Dic:[decryptString dataUsingEncoding:NSUTF8StringEncoding] ];
                
                NSString *tokenType= [paramdic objectForKey:@"tokenType"];
                
                NSString *token= [paramdic objectForKey:@"token"];
                
                NSMutableString *businessParam= [paramdic objectForKey:@"businessParam"];
                
                if(businessParam==nil)
                {//解密失败
                    if(errorCountFlag==0)
                    {
                        //重新 1获取服务器公钥  2签到
                        
                        
                        NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                        NSString *appID=[userdefalut objectForKey:@"appId"];
                        NSString *appVersion=[userdefalut objectForKey:@"appVer"];
                        
                        [self appSignIn:appID appVersion:appVersion ];
                        self.willDo=@"callWebService";//签到成功后重发调用交易
                        
                        errorCountFlag ++;
                        return;
                    }else
                    {
                        errorCountFlag=0;
                        //重置失败 回调
                        MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                        msgReturn.errorCode=ERROR_RSA_ERROR;
                        msgReturn.errorDesc=ERROR_TEXT_RSA;
                        msgReturn.formName=formName;
                        [delegate serviceInvokerError:msgReturn];
                        willDo=@"";
                        
                        
                    }
                }
                errorCountFlag=0;
                
                [userDefault setObject:tokenType forKey:@"tokenType"];
                [userDefault setObject:token forKey:@"token"];
                [userDefault synchronize];
                
                //交易成功  回调
                MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                msgReturn.errorCode=ERROR_SUCCESS;
                msgReturn.errorDesc=ERROR_TEXT_SUCCESS;
                msgReturn.formName=self.formName;
                msgReturn.map=paramdic;
                [delegate serviceInvokerReturnData:msgReturn];
                
            }
            else
            {
                
                
                
                
                if ([err_code  isEqualToString:WG1002 ]
                    || [err_code isEqualToString:WG1004]) {
                    NSLog(@"%@",err_msg);
                    // 报文流水重置
                    [self messageIdReset];
                    //报文流水重置后重发交易
                    self.willDo=@"callWebService";
                    
                }else if ([err_code  isEqualToString:WG1007]
                          ||[err_code  isEqualToString:WG2002]
                          ||[err_code  isEqualToString:WG2004]
                          ||[err_code  isEqualToString:WG2003]) {
                    
                    
                    if ([err_code  isEqualToString:WG1007]) {
                        // 如果为“wg1007 设备逻辑号不存在”，则置mLogicID为空
                        NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                        [userdefalut setObject:@"" forKey:@"logicId"];
                        [userdefalut synchronize];
                        
                    }
                    
                    
                    //重新 1获取服务器公钥  2签到
                    
                    NSUserDefaults *userdefalut=[NSUserDefaults standardUserDefaults];
                    NSString *appID=[userdefalut objectForKey:@"appId"];
                    NSString *appVersion=[userdefalut objectForKey:@"appVer"];
                    
                    [self appSignIn:appID appVersion:appVersion ];
                    self.willDo=@"callWebService";//签到成功后重发调用交易
                    
                    
                    
                    
                }else
                {
                    //交易失败  回调
                    MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                    msgReturn.errorCode=err_code;
                    msgReturn.errorDesc=err_msg;
                    msgReturn.formName=self.formName;
                    
                    
                    [delegate serviceInvokerReturnData:msgReturn];
                    
                    
                    
                    NSLog(@"%@",err_msg);
                }}
        }
        
    }
    
    
}



//向后台发送的完整报文,debug用
-(void)metaMsgSentToServer:(NSString*)jsonStr
{
    
}

//从后台返回的完整报文,debug用
-(void)metaMsgReceivedFromServer:(id)response
{
    
}


-(BOOL)downloadFileAndUNZip:(NSString*) urlAsString configPath:(NSString*)configPath
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    path = [path stringByAppendingPathComponent:@"securedDirectory"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:path]){
        if ([fileManager createDirectoryAtPath:path
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil]==NO){
            //prevend iClound or iTunes to backup this dire, work on 5.0.1 and later
            [self skipBackupAttributetoDir:path];
        }
    }
    
    
    NSString *localConfigPath = [path stringByAppendingPathComponent:configPath];
    
    
    
    
    
    NSURL    *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT/1000];
    NSError *error = nil;
    NSData   *data =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    
    /* 下载的数据 */
    if (data != nil){
        NSLog(@"下载成功");
        if ([data writeToFile:localConfigPath atomically:YES]) {
            NSLog(@"保存成功.%@",localConfigPath);
            
            BOOL isUNZip=[self expandNormalZipFile:localConfigPath];
            
            if(isUNZip)
            {
                return YES;}
            else{
                return NO;
            }
        }
        else
        {
            NSLog(@"保存失败.");
            return NO;
        }
    } else {
        NSLog(@"%@", error);
    }
    
    return NO;
    
}

- (BOOL) expandNormalZipFile:(NSString*)_zipFile
{
    NSRange range = [_zipFile rangeOfString:@"/" options:NSBackwardsSearch];
    
    NSString * outputDir=[_zipFile substringToIndex:range.location+1];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // unzip normal zip
    NSUInteger count = 0;
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:_zipFile];
    // NSArray* contents = [zip getZipFileContents];
    
    
    
    [zip UnzipFileTo:outputDir overWrite:YES];
    
    NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:outputDir];
    NSString* file;
    NSError* error = nil;
    BOOL isAllZipOk=NO;
    
    while ((file = [dirEnum nextObject])) {
        count += 1;
        
        NSString* fullPath = [outputDir stringByAppendingPathComponent:file];
        NSDictionary* attrs = [fm attributesOfItemAtPath:fullPath error:&error];
        if ([attrs fileSize] > 0)
        {
            //@"file is not zero length
            isAllZipOk=YES;
        }else
        {
            isAllZipOk=NO;
        }
        
    }
    
    if(isAllZipOk)
    {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:outputDir forKey:@"localConfigFilePath"];
        
        [userDefault synchronize];
        return YES;
    }
    //@"files extracted successfully
    return  NO;
}


//prevend iClound or iTunes to backup this dire, work on 5.0.1 and later
-(BOOL)skipBackupAttributetoDir:(NSString *)path{
    NSURL *url = [NSURL fileURLWithPath:path];
    if(IOS51){
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
        return success;
    }else if(IOS501){
        const char* filePath = [[url path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
}


-(NSString*)dic2jsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


// 将JSON串转化为字典或者数组
- (id)jsonString2Dic:(NSDate *)jsonData{
    
    //  NSData *jsonData=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error== nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}


-(void)callUpdateDelegate{
    
    
    
}



//实现一个创建单例对象的类方法

static ServiceInvoker *objName = nil;

+ (ServiceInvoker *) sharedInstance{
    static dispatch_once_t oneToken = 0;
    dispatch_once(&oneToken, ^{
        objName = [[super allocWithZone: NULL] init];
    });
    return objName;
}

//重写几个方法，防止创建单例对象时出现错误
-(id) init{
    if(self = [super init])
    {
        //初始化单例对象的各种属性
    }
    return self;
}

+(id)allocWithZone: (struct _NSZone *) zone{
    return [self sharedInstance];
}

//这是单例对象遵循<NSCopying>协议时需要实现的方法
-(id) copyWithZone: (struct _NSZone *)zone{
    return self;
}


-(NSString*)stringWithoutESCCharater:(NSString*)str{
    if (str==nil) {
        return nil;
    }
    str=[str stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    str=[str stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    str=[str stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    return str;
}

@end