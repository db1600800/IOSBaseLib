
#import <Foundation/Foundation.h>
#import "ServiceInvoker.h"

#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
+ (__class *)sharedInstance \
{ \
    static dispatch_once_t once; \
    static __class * __singleton__; \
    dispatch_once( &once, ^{ __singleton__ = [[__class alloc] init]; } ); \
    return __singleton__; \
}

#define WEB_SERVICE_ERROR_OR_SOAPFAULT [response isKindOfClass:[NSError class]]||[response isKindOfClass:[SoapFault class]]
#define PUSH_FILE_PATH [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"push_info.plist"]
#define DeviceTokenStringKEY @"deviceToken"



@protocol GSNetServiceDelegate;


@interface GSNetService : NSObject
//AS_SINGLETON(GSNetService)

@property (nonatomic,strong) id<GSNetServiceDelegate> delegate;

@property (nonatomic,assign,setter = requestTimeOut:) NSInteger requestTimeout;



-(void)sendMsg:(NSMutableDictionary*)prama toServerOnFormName:(NSString*)formName withDelegate:(id)delegate;



/**
 *	设置超时时间
 *
 *	@param	timeoutInSeconds	时间
 */
-(void)requestTimeOut:(NSInteger)timeoutInSeconds;

@end


@protocol GSNetServiceDelegate <NSObject>

@required

//业务请求返回错误
-(void)netServiceError:(MsgReturn*)msgReturn;

//业务请求返回数据
-(void)netServiceReturnData:(MsgReturn*)msgReturn;


@end





