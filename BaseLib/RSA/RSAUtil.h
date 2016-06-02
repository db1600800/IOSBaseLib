

#import <Foundation/Foundation.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>

typedef enum {
    KeyTypePublic,
    KeyTypePrivate
}KeyType;

typedef enum {
    RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
}RSA_PADDING_TYPE;

@interface RSAUtil : NSObject{
    RSA *_rsa;
}






/**
 Generate rsa key pair by the key size.
 
 @param keySize RSA key bits . The value could be `512`,`1024`,`2048` and so on.
 Normal is `1024`.
 */

+ (id)shareInstance;

-(RSA*)generateRSA:(int)keySize;

-(NSString*)getPublicKeyStringX509:(RSA*) rsa;

-(NSString*)getPublicKeyStringPKCS1:(RSA*) rsa;

-(NSString*)getPrivateKeyStringPKCS1:(RSA*) rsa;

-(RSA*) string2PublickeyFormartX509:(NSString*) publicKeyString;

-(RSA*) string2PublickeyFormartPKCS1:(NSString*) publicKeyString;

-(RSA*) string2Privatekey:(NSString*) privateKeyString;

- (NSData*)encryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding plainText:(NSString*)text usingEncoding:(NSStringEncoding)encoding;


- (NSData*)encryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding data:(NSData*)data;


- (NSString*)decryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding plainTextData:(NSData*)data usingEncoding:(NSStringEncoding)encoding;


- (NSData*)decryptRSAKeyWithType:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding encryptedData:(NSData*)data;


- (NSData*)encryptLongString:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding plainText:(NSString*)plainText usingEncoding:(NSStringEncoding)encode;

- (NSData*)encryptLongString2:(KeyType)keyType rsa:(RSA*)rsa rsaprivate:(RSA*)rsaprivate paddingType:(RSA_PADDING_TYPE)padding plainText:(NSString*)plainText usingEncoding:(NSStringEncoding)encode;

- (NSString*)decryptLongString:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding encryptText:(NSData*)encryptText usingEncoding:(NSStringEncoding)encode;


- (NSString*)decryptLongString2:(KeyType)keyType rsa:(RSA*)rsa paddingType:(RSA_PADDING_TYPE)padding encryptText:(NSData*)encryptText usingEncoding:(NSStringEncoding)encode;

//没用



@end

@interface RSAUtil (C_Base)

/**
 RSA encrypt
 
 @param from Input value.
 @param flen Input data length.
 @param to  Output value.
 @return status of the encrypted.
 error code:
 -1 : `from` or `to` is NULL;rsa key is not presented.
 Otherwise,the openssl's rsa encrypted status will be presented.
 */
- (int)encryptRSAKeyWithType:(KeyType)keyType from:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to padding:(RSA_PADDING_TYPE)padding;

/**
 RSA decrypt
 
 @param from Input value.
 @param flen Input data length.
 @param to  Output value.
 @return status of the decrypted
 error code:
 -1 : `from` or `to` is NULL;rsa key is not presented.
 Otherwise,the openssl's rsa decrypted status will be presented.
 */
- (int)decryptRSAKeyWithType:(KeyType)keyType from:(const unsigned char *)from flen:(int)flen to:(unsigned char *)to padding:(RSA_PADDING_TYPE)padding ;

@end
