//
//  Protocols.h
//  VK320
//
//  Created by Roman Silin on 06.07.14.
//  Copyright (c) 2014 Roman Silin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSAlertView.h"

#define kDownloadPath @"Download Path"
#define kRequestLimit @"Request Limit"
#define kMyMusicLimit @"My Music Limit"
#define kStreamLimit @"Stream Limit"
#define kFilterKbps @"Filter Kbps"
#define kUseFullPaths @"Use Full Paths"
#define kSaveDownloadHistory @"Save Downloads History"
#define kDoubleClickDownload @"Download on Double Click / or Play"
#define kAutoPlayNextTrack @"Auto Play Next Track"
#define kSortDescriptorColumn @"Sort Descriptor Column"
#define kSortDescriptorAscending @"Sort Descriptor Ascending"
#define kDownloadsHistory @"Downloads History"
#define kCorrector @"Corrector for search request"
#define kCheckUpdates @"Check updates on program start"
#define kVolumeLevel @"Volume Default Level"
#define kShuffle @"Shuffle"
#define kBroadcast @"Broadcast"
#define kTopFrame @"Top Frame Rect"
#define kBottomFrame @"Bottom Frame Rect"

#define VK_API_VERSION @"5.24"
#define VK_SCOPE @"audio,status"
#define METHOD_SEARCH_URL @"https://api.vk.com/method/audio.search"
#define METHOD_RECOMMEND_URL @"https://api.vk.com/method/audio.getRecommendations"
#define METHOD_AUDIOGET_URL @"https://api.vk.com/method/audio.get"
#define METHOD_WALLGET_URL @"https://api.vk.com/method/wall.get"
#define METHOD_POSTGET_URL @"https://api.vk.com/method/wall.getById"
#define METHOD_TRACKING_URL @"https://api.vk.com/method/stats.trackVisitor"

#define THANX_URL @"http://vk320.ru/donate/"
#define UPDATES_URL @"http://vk320.ru/download/"
#define LAST_VERSION_URL @"http://vk320.ru/version.last"
#define VK320_URL @"http://vk320.ru"

#define REQUEST_MAX_LIMIT @"300"
#define MYMUSIC_MAX_LIMIT @"6000"
#define STREAMS_MAX_LIMIT @"50"
#define REQUEST_DEFAULT_LIMIT @"30"
#define MYMUSIC_DEFAULT_LIMIT @"100"
#define STREAMS_DEFAULT_LIMIT @"5"
#define FILTER_KBPS_DEFAULT @"32"
#define FILTER_KBPS_STEP 32
#define VOLUME_DEFAULT_LEVEL 80

#define TRACKING_VK YES
#define MAX_NETWORK_CONCURRENT_OPERATION_COUNT 1
#define SPLIT_SUBVIEW_MIN_HEIGHT 130.0f
#define TIME_FOR_REWARD 3
#define SEARCH_CODE_MYMUSIC @"%mymusic%"
#define SEARCH_CODE_RECOMMEND @"%recommend%"


#define COLOR_BUTTON_BLUE @"0099DC"
#define COLOR_BUTTON_GRAY @"9DABB4"
#define COLOR_BAR_BLUE @"0099DC"
#define COLOR_BAR_YELLOW @"CEDC00"
#define COLOR_BAR_GREEN @"4CDC00"
#define COLOR_BAR_GRAY @"CDD5DA"
#define COLOR_HIGHLIGHT @"c8e6f4"
#define COLOR_HIGHLIGHT_LITE @"e9f0f4"
#define COLOR_ALERT_BLUE @"0099DC"
#define COLOR_ALERT_RED @"E83425"
#define COLOR_ALERT_YELLOW @"FF9900"


#define ALERT_CONNECTION_OFF @"Проверьте подключение к интернету"
#define ALERT_CONNECTION_OFF_UNKNOWN @"Неизвестная ошибка подключения"
#define ALERT_CONNECTION_TRY_API @"Авторизация через VK API..."
#define ALERT_CONNECTION_TRY @"Соединение..."
#define ALERT_LOGOUT @"Сброс авторизации..."
#define ALERT_CONNECTION_ON @"Соединение установлено"
#define ALERT_CONNECTION_VK_DENIED @"Ошибка авторизации: нет разрешения доступа к аудиозаписям"
#define ALERT_CONNECTION_VK_ERROR @"Неизвестная ошибка авторизации"
#define ALERT_CONNECTION_VK_LOGGEDOUT @"Ошибка: необходима авторизация"
#define ALERT_CONNECTION_SEARCH_ERROR @"Ошибка поискового запроса"
#define ALERT_CONNECTION_FILESIZE_ERROR @"Ошибка получения размера файла"
#define ALERT_VK_OFF @"Не удалось подключиться к VK API"
#define ALERT_DOWNLOAD_ERROR @"Ошибка загрузки аудиозаписи"
#define ALERT_CHECK_UPDATES_FAIL @"Не удалось проверить обновления"
#define ALERT_CHECK_UPDATES_ACTUAL @"Вы используете актуальную версию VK320"
#define ALERT_CHECK_UPDATES_BETA @"Ваша версия VK320 новее общедоступной актуальной версии"

#define ALERT_ADDTOVK_SUCCESS @"Аудиозапись добавлена в ВК"
#define ALERT_ADDTOVK_FAILURE @"Не удалось добавить аудиозапись в ВК"
#define ALERT_BROADCAST_ON @"Трансляция музыки в статус включена"
#define ALERT_BROADCAST_OFF @"Трансляция музыки в статус отключена"

#define PROCESS_SEARCH_MESSAGE_LINK @"Запрос аудиозаписей по ссылке..."
#define PROCESS_SEARCH_MESSAGE_MYMUSIC @"Запрос аудиозаписей профиля..."
#define PROCESS_SEARCH_MESSAGE_RECOMMEND @"Запрос рекомендованных аудиозаписей..."
#define PROCESS_SEARCH_MESSAGE_OTHER @"Запрос результатов поиска..."
#define PROCESS_SEARCH_FIN_TEXT @"Получено аудиозаписей:"
#define PROCESS_SEARCH_FIN_FILTER @"отфильтровано:"
#define PROCESS_SEARCH_EMPTY_TEXT @"Ничего не найдено!"
#define ALERT_DOWNLOADS_PATH @"Не удается найти папку загрузок, проверьте настройки"
#define UNKNOWN_USERNAME @"Не авторизирован"


typedef NS_ENUM(NSUInteger, RSDownloadStatus) {
    RSDownloadAddedJustNow = 0, // В очереди (из-за лимита или проблем с сетью)
    RSDownloadReady = 1, // Только что иницилизированый объект, далее автоматом превращается либо в 0 либо в 2.
    RSDownloadInProgress = 2, // В процессе загрузки
    RSDownloadPause = 3, // На паузе
    RSDownloadCompleted = 4 // Загрузка завершена
};

typedef NS_ENUM(NSUInteger, RSAutoscrollStatus) {
    RSAutoscrollPause = 0,
    RSAutoscrollToRight = 1,
    RSAutoscrollToLeft = 2
};

typedef NS_ENUM(NSUInteger, RSErrorType) {
    RSErrorVK = 0,
    RSErrorNetwork = 1
};

@class RSMainWindow;
@class RSAudioItem;
@class RSActionsCell;
@class RSDownloadItem;
@class AFHTTPRequestOperationManager;
@class RSRowView;

@protocol RSPlayer <NSObject>
@property (strong, nonatomic) AFHTTPRequestOperationManager *networkManager;
@property (weak) IBOutlet RSAlertView *alertView;
@property (nonatomic) BOOL internetAvailable;
- (void)playFromActionsCell:(RSActionsCell *)actionsCell;
- (void)stopMusic;
- (void)addDownloadFromAudioItem:(RSAudioItem *)audioItem;
- (void)updateDownloadItem:(RSDownloadItem *)downloadItem;
- (BOOL)readyForStartDownload;
- (void)downloadCompleted;
- (void)updateDownloadsButtons;
- (BOOL)isCurrentAudioRow:(RSRowView*)rowView;
- (void)showError:(NSError *)error withType:(RSErrorType)errorType;
@end