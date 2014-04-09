//
//  DitoSDK.h
//  DitoSDK
//
//  Created by Joao Pedro Melo on 3/11/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DitoConstants.h"

static NSString const *kDitoSocialNetworkTwitter = @"tw";
static NSString const *kDitoSocialNetworkFacebook = @"fb";
static NSString const *kDitoSocialNetworkGooglePlus = @"pl";
static NSString const *kDitoSocialNetworkPortal = @"pt";

/* Base URLs */
static NSString *kLoginBaseURL = @"login.dev.plataformasocial.com.br";
static NSString *kEventsBaseURL = @"events.dev.plataformasocial.com.br";
static NSString *kShareBaseURL = @"share.dev.plataformasocial.com.br";
static NSString *kReferralBaseURL = @"referral.dev.plataformasocial.com.br";
static NSString *kRankingBaseURL = @"ranking.dev.plataformasocial.com.br";
static NSString *kBadgeBaseURL = @"badge.dev.plataformasocial.com.br";
static NSString *kNotificationBaseURL = @"notification.dev.plataformasocial.com.br";

typedef void(^FacebookCompletionBlock)(NSString *accessToken, NSString *userId, NSError *err);
typedef void(^TwitterCompletionBlock)(NSString *userId, NSString *token, NSString *tokenSecret, NSError *error);
typedef void(^GooglePlusCompletionBlock)(NSString *accessToken, NSString *userID, NSError *error);
/**
 Block de callback de todos os requests.
 @param response   Resposta retornada pelo servidor, pode ser ```NSDictionary``` ou ```NSArray```
 @param error      ```nil``` se nenhum erro ocorreu
 */
typedef void(^RequestBlock)(id response, NSError *error);

typedef NS_ENUM(NSInteger, DitoSDKSorting) {
    DitoSDKSortingAscending,
    DitoSDKSortingDescending
};

/** Classe base do SDK Dito.
 
 Primeiro você deve preencher os valores no arquivo ```DitoConstants.h```
 
 ```API_KEY```            API key do GraphMonitor
 
 ```API_SECRET```         API secret do GraphMonitor
 
 ```ORIGIN_DOMAIN```      Domínio configurado no painel do GraphMonitor
 
 ```TW_CONSUMER_KEY```    Consumer key do Twitter
 
 ```TW_CONSUMER_SECRET``` Consumer secret do Twitter
 
 ```GP_CLIENT_ID```       Client ID do Google+
 
 Você deve configurar 3 URLs Schemes no seu Info.plist.
 
 ```fb12345``` substituindo ```12345``` pelo App ID do seu app no Facebook
 
 ```tw12345``` substituindo ```12345``` pela consumer key do seu app no Twitter
 
 ```com.dito.ditosdk``` deverá ser o bundle ID do seu app como configurado no Google+
 
 Além disso, adicione também a chave ```FacebookAppID``` no seu Info.plist, com o App ID do seu app no Facebook.
 
 No seu ```AppDelegate.m``` implemente o seguinte método
 
     - (BOOL)application:(UIApplication *)application 
                 openURL:(NSURL *)url 
       sourceApplication:(NSString *)sourceApplication 
              annotation:(id)annotation
     {
        return [DitoSDK handleURL:url sourceApplication:sourceApplication annotation:annotation];
     }
 
 Definição de ```requestBlock```
 
     typedef void(^RequestBlock)(id response, NSError *error);
 
 */
@interface DitoSDK : NSObject

+ (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation;

#pragma mark - Social Login
#pragma mark - Facebook

/**---------------------------------------------------------------------------------------
 * @name Social Login
 *  ---------------------------------------------------------------------------------------
 */

/** Faz o login no Facebook.
 @param completion   Callback block
*/
- (void)doFacebookLoginWithPermissions:(NSArray *)permissions completionHandler:(RequestBlock)completion;

#pragma mark - Twitter

/** Faz o login no Twitter.
    @param completion  Callback block.
*/
- (void)doTwitterLoginWithCompletionHandler:(RequestBlock)completion;

#pragma mark - Google+

/** Faz login no Google+
 @param completion  Callback block
 */
- (void)doGooglePlusLoginWithCompletionHandler:(RequestBlock)completion;

#pragma mark - User

/**---------------------------------------------------------------------------------------
 * @name Usuário
 *  ---------------------------------------------------------------------------------------
 */

/** Retorna perfil do usuário
 @param reference   Reference do usuário
 @param completion  Callback block
 */
- (void)getDataForUserReference:(NSString *)reference
                     completion:(RequestBlock)block;

/** Atualiza dados do perfil do usuário
 @param data        Os dados a serem atualizados
 @param reference   Reference do usuário
 @param completion  Callback block
 */
- (void)putData:(NSDictionary *)data
inUserReference:(NSString *)reference
     completion:(RequestBlock)block;

#pragma mark - Events

/**---------------------------------------------------------------------------------------
 * @name Evento
 *  ---------------------------------------------------------------------------------------
 */
/** Cria um evento.
 @param eventData   Os dados do evento
 @param reference   Reference do usuário
 @param network     A rede social do evento
 @param completion  Callback block
 */
- (void)createEventWithData:(NSDictionary *)eventData
           forUserReference:(NSString *)reference
                    network:(NSString *)network
                 completion:(RequestBlock)block;

/** Retorna lista de amigos que fizeram certos eventos
 @param events      Eventos a serem verificados
 @param reference   Reference do usuário
 @param completion  Callback block
 */
- (void)friendsWhoDidEvents:(NSArray *)events
              userReference:(NSString *)reference
                 completion:(RequestBlock)block;

/** Retorna o feed de eventos
 @param reference   Reference do usuário
 @param limit       Máximo de resultados para retornar. Use ```nil``` para o padrão
 @param page        Página para retornar. Use ```nil``` para o padrão
 @param order       Um de DitoSDKSortingAscending ou DitoSDKSortingDescending
 @param completion  Callback block
 */
- (void)eventsFeedWithLimit:(NSNumber *)limit
                       page:(NSNumber *)page
              userReference:(NSString *)reference
                      order:(DitoSDKSorting)_sorting
                 completion:(RequestBlock)block;

#pragma mark - Notifications
/**---------------------------------------------------------------------------------------
 * @name Notificações
 *  ---------------------------------------------------------------------------------------
 */

/** Registra um aparelho no serviço de push
 @param tokenData       NSData do token do aparelho
 @param reference       Reference do usuário
 */
- (void)registerDeviceWithToken:(NSData *)tokenData
                  userReference:(NSString *)reference;

@end
