//
//  ErrorMsg.h
//  PublicLibUI
//
//  Created by apple on 15/5/15.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#ifndef PublicLibUI_ErrorMsg_h
#define PublicLibUI_ErrorMsg_h



// ============错误码============//
/************* <成功:0000> *****************/
static const NSString * ERROR_SUCCESS = @"0000";
/************* <失败:1111> *****************/
static const NSString * ERROR_FAILED = @"1111";
/************* <网络错误:D001> *****************/
static const NSString * ERROR_NOT_NET = @"D001";
/************* <xml报文格式错误:D002> *****************/
static const NSString * ERROR_FORMAT = @"D002";
/************* <服务器地址错误:D003> *****************/
static const NSString * ERROR_SERVICE = @"D003";
/************* <其它错误错误:D004> *****************/
static const NSString * ERROR_OTHER = @"D004";
/************* <数据格式不正确:D008> *****************/
static const NSString * ERROR_DATA_FORMAT_ERROR = @"D008";
/************* <服务器内部错误:D009> *****************/
static const NSString * ERROR_SERVICE_IN_ERROR = @"D009";
/************* <签到失败:D0010> *****************/
static const NSString * ERROR_SINGIN_ERROR = @"D010";
//请求超时
static const NSString * ERROR_TIMEOUT_ERROR = @"D011";
static const NSString * ERROR_REQUEST_ERROR = @"D013";

//RSA加密解密失败
static const NSString * ERROR_RSA_ERROR = @"D012";


static const NSString * ERROR_TEXT_SUCCESS = @"成功";

static const NSString * ERROR_TEXT_FAILED = @"交易失败.";

static const NSString * ERROR_TEXT_SERVICE_FAILED = @"服务器内部错误";

static const NSString * ERROR_TEXT_SERVICE_ADDRESS_FAILED = @"服务器地址错误";

static const NSString * ERROR_TEXT_NOT_NET = @"网络不可用";

static const NSString * ERROR_TEXT_RSA = @"RSA加密解密出错.";

static const NSString * ERROR_DATA_FORMAT_ERROR_STRING = @"数据格式错误";

static const NSString * ERROR_TIMEOUT = @"请求超时.";
static const NSString * ERROR_REQUEST = @"请求失败.";

static const NSString * SINGIN_ERROR = @"签到失败.";

@interface ErrorMsg : NSObject

@end




#endif
