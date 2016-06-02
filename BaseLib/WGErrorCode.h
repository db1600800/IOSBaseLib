//
//  WGErrorCode.h
//  PublicLibUI
//
//  Created by gdpost on 15/5/18.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#ifndef PublicLibUI_WGErrorCode_h
#define PublicLibUI_WGErrorCode_h

/**
 * 接口返回错误代码说明
 */

    /**接入平台数据库错误*/
    FOUNDATION_EXPORT NSString *const WG1001 = @"WG1001";
    
    /**报文流水重复*/
     FOUNDATION_EXPORT NSString *const WG1002 = @"WG1002";
    
    /**业务系统返回超时*/
     FOUNDATION_EXPORT NSString *const WG1003 = @"WG1003";
    
    /**获取报文流水号失败*/
     FOUNDATION_EXPORT NSString *const WG1004 = @"WG1004";
    
    /**上传报文格式不正确*/
     FOUNDATION_EXPORT NSString *const WG2001 = @"WG2001";
    
    /**密钥版本号比较失败*/
     FOUNDATION_EXPORT NSString *const WG2002 = @"WG2002";
    
    /**报文解密失败*/
     FOUNDATION_EXPORT NSString *const WG2003 = @"WG2003";
    
    /**获取接入平台密钥失败*/
     FOUNDATION_EXPORT NSString *const WG2004 = @"WG2004";
    
    /**解析上传报文参数失败*/
     FOUNDATION_EXPORT NSString *const WG2007 = @"WG2007";
    
    /**设备逻辑号不存在*/
     FOUNDATION_EXPORT NSString *const WG1007 = @"WG1007";
    
    /**无法处理请求*/
     FOUNDATION_EXPORT NSString *const WG2006 = @"WG2006";
    
    /**APP密钥不存在*/
     FOUNDATION_EXPORT NSString *const WG1005 = @"WG1005";
    
    /**路由网关信息不存在*/
     FOUNDATION_EXPORT NSString *const WG1006 = @"WG1006";
    
    /**版本无效，请升级有效的版本*/
     FOUNDATION_EXPORT NSString *const WG2008 = @"WG2008";
    
    /**设备逻辑无效*/
     FOUNDATION_EXPORT NSString *const WG2005 = @"WG2005";
    
#endif
