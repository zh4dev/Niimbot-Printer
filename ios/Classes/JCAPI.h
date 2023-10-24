//
//  JCAPI.h
//  JCPrinterSDK
//
//  Created by  ydong on 2019/1/29.
//  Copyright © 2019  ydong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 建议在iOS9以上系统使用
 */



typedef NS_ENUM(NSUInteger, JCBarcodeMode){
    //CODEBAR 1D format.
    JCBarcodeFormatCodebar      ,
    
    //Code 39 1D format.
    JCBarcodeFormatCode39       ,
    
    //Code 93 1D format.
    JCBarcodeFormatCode93       ,
    
    //Code 128 1D format.
    JCBarcodeFormatCode128      ,
    
    //EAN-8 1D format.
    JCBarcodeFormatEan8         ,
    
    //EAN-13 1D format.
    JCBarcodeFormatEan13        ,
    
    //ITF (Interleaved Two of Five) 1D format.
    JCBarcodeFormatITF          ,
    
    //UPC-A 1D format.
    JCBarcodeFormatUPCA         ,
    
    //UPC-E 1D format.
    JCBarcodeFormatUPCE
};

typedef NS_ENUM(NSUInteger,JCSDKCacheStatus){
    JCSDKCacheWillPrinting,
    JCSDKCachePrinting,
    JCSDKCacheWillPause,
    JCSDKCachePaused,
    JCSDKCacheWillCancel,
    JCSDKCacheCanceled,
    JCSDKCacheWillDone,
    JCSDKCacheDone,
    JCSDKCacheWillResume,
    JCSDKCacheResumed,
} ;

typedef NS_ENUM(NSUInteger,JCSDKCammodFontType) {
    JCSDKCammodFontTypeStandard = 0,
    JCSDKCammodFontTypeFreestyleScript,
    JCSDKCammodFontTypeOCRA,
    JCSDKCammodFontTypeHelveticaNeueLTPro,
    JCSDKCammodFontTypeTimesNewRoman,
    JCSDKCammodFontTypeMICR,
    JCSDKCammodFontTypeTerU24b,
    JCSDKCammodFontTypeSimpleChinese16Point = 55,
    JCSDKCammodFontTypeSimpleChinese24Point
};

typedef NS_ENUM(NSUInteger,JCSDKCammodRotation) {
    JCSDKCammodRotationDefault = 0,
    JCSDKCammodRotation90 = 90,
    JCSDKCammodRotation180 = 180,
    JCSDKCammodRotation270 = 270
};

typedef NS_ENUM(NSUInteger,JCSDKCammodGraphicsType) {
    JCSDKCammodGraphicsTypeHorizontalExt ,
    JCSDKCammodGraphicsTypeVerticalExt,
    JCSDKCammodGraphicsTypeHorizontalZip,
    JCSDKCammodGraphicsTypeVerticalZip
};

typedef void (^DidOpened_Printer_Block) (BOOL isSuccess)                ;
typedef void (^DidPrinted_Block)        (BOOL isSuccess)                ;
typedef void (^PRINT_INFO)              (NSString * printInfo)          ;
typedef void (^PRINT_STATE)             (BOOL isSuccess)                ;
typedef void (^PRINT_DIC_INFO)          (NSDictionary * printDicInfo)   ;
typedef void (^JCSDKCACHE_STATE)        (JCSDKCacheStatus status)       ;


@interface JCAPI : NSObject


/// @{@"serial":@"V1.0.0",@"date":@"2021/05/06",@"description":@"描述"}
+ (NSDictionary *)version;


/// 设置连接的打印机厂商id,需要在连接之前设置
/// id: 缺省0 ，1-精臣系。 2-B3系。 3-B11系。 4-T2系
/// @param printerFactoryId 厂商id
+ (void)setPrinterFactoryId:(NSInteger)printerFactoryId;


/// 设置第三方接入的对象类名
/// @param className 类名，必须遵守JC_MyPrinterProtocol协议
+ (void)setPrinterFactoryTool:(NSString *)className;



/**
 蓝牙/Wi-Fi获取搜索到的打印机列表。
 wifi回调：  @[@{@"ipAdd":@"ip地址", @"bleName":@"蓝牙名字"}]

 @param   isWifi          YES:为搜索Wi-Fi，NO为搜索蓝牙
 @param   completion      打印机名字数组block(该名字为连接打印机时的printerName参数)
 */
+ (void)scanPrinterNames:(BOOL)isWifi completion:(void(^)(NSArray *scanedPrinterNames))completion;


/**
 蓝牙连接指定名称的打印机。
 
 @param   printerName     打印机名称。
 @param   completion      连接打印机是否成功。（连接状态改变通过该回调返回）
 */
+ (void)openPrinter:(NSString *)printerName
         completion:(DidOpened_Printer_Block)completion;

/**
 打印机类型,连接成功后才能使用,其它厂家打印机返回@“”/@“0”,精臣系打印机返回
 hBit = value/256
 lBit = value%256
 B3S: hBit/lBit = 1
 D11: hBit/lBit = 2
 B21: hBit = 3
 {
  L2B: lBit = 1
  L2W: lBit = 2
  C2B: lBit = 3
  C2W: lBit = 4
  C3B: lBit = 5
  C3W: lBit = 6
 }
 P1: hBit/lBit = 4
 B16: hBit/lBit = 7
 @return 返回打印机类型
 */
+(NSInteger )printerTypeInfo;


/**
 蓝牙关闭打开的打印机连接。
 */
+ (void)closePrinter;


/**
 蓝牙/Wi-Fi获取当前连接的打印机名称（Wi-Fi为ip地址）。
 
 @return  当前连接的打印机名称。
 */
+ (NSString *)connectingPrinterName;

/**
 蓝牙/Wi-Fi连接状态
 
 @return 2表示连接Wi-Fi，1表示连接蓝牙，0表示无连接
 */
+ (int)isConnectingState;

/**
 蓝牙/Wi-Fi设置打印机。
 
 @param   state           参数为20-30      @param type   对应参数如下
                          21-设置打印浓度                 1—淡，2—正常, 3—浓, 4-较浓 5-最浓；（打价器仍只有三挡:1,2,3）
                          22-设置打印速度                 1—慢, 2—稍慢, 3—正常, 4—稍快, 5—快；（打价器速度三挡）
                          23-设置纸张类型                 1—间隙纸, 2—黑标纸, 3—连续纸，4-定孔纸，5-透明纸（4，目前还没有）
                          24-设置马达驱动(预留)            1
                          25-设置自动出纸(预留)            1、2、3
                          26-设置打印机语言；              1-中文，2-英文
                          27-设置自动关机时间              N分钟 1-4(
                                                        1:15min;
                                                        2:30min;
                                                        3:60min(D11为45分钟);
                                                        4:从不(D11为60分钟)
                                                        )
                          28-恢复出厂设置                 1
                          29-纸张类型标定                 1
                          20-打印模式,限T2支持          1-热敏模式。 2-热感应模式(碳带模式)
                          30-音量设置(0-5档)
                          31-设置机器防伪
 @param   completion      是否设置成功。
 */
+ (void)setPrintState:(NSInteger)state type:(NSInteger)type sucess:(PRINT_DIC_INFO)completion;

/**
 蓝牙/Wi-Fi获取打印机信息。b11系列只有9&12
 
 @param   type            1-打印浓度
                          2-打印速度
                          3-纸张类型
                          4-马达驱动（预留）
                          5-自动出纸（预留）
                          6-打印机语言
                          7-自动关机时间
                          8-机器型号
                          9-软件版本（固件版本）
                          10-当前电量
                          11-机器序列号
                          12-硬件版本
                          13-硬件参数信息（如:电池电压等）----(后面去掉该类型支持)
                          14-历史打印信息。
                          15-获取打印机读取成功次数信息(仅支持b21打印机,V2.11支持d11系列3.28以上版本)
                          16-查询打印机配网状态(仅支持b21打印机)
                          19-获取mac地址
                          20-打印模式(1、热敏 2、热感应)
                          21-获取打印机内置地区码
                          
 @param   completion      返回对应的信息。@"UNRESOPN_ERROR"表示获取信息超时
 */
+ (void)getPrintInfo:(NSInteger)type sucess:(PRINT_DIC_INFO)completion;

/**
 根据传入参数获取所有的信息

 @param completion 获取后的回调
 @param arg 参数列表，最大支持10个,必须是+ (void)getPrintInfo:(NSInteger)type sucess:(PRINT_DIC_INFO)completion所支持的type类型，返回结果和传入arg对应的健值对
 */
+ (void)getInfosWithComplete:(PRINT_DIC_INFO)completion fromArgs:(NSInteger)arg, ...NS_REQUIRES_NIL_TERMINATION;


/**
 蓝牙/Wi-Fi是否支持盒盖状态检测
 
 @return  YES:支持、NO:不支持
 */
+ (BOOL)isSupportPrintCoverStatus;

/**
 蓝牙/Wi-Fi盒盖状态改变返回(在连接成功后调用)
 
 @param   completion      盒盖状态：0打开、1关闭
 @param   checkPaperBlock 当前打印机是否有耗材：0没有、1有
 @return  是否支持盒盖状态检测：YES:支持、NO:不支持
 */
+ (BOOL)getPrintCoverStatusChange:(PRINT_INFO)completion withCheckPrinterHavePaperBlock:(PRINT_INFO)checkPaperBlock;

/**
监听打印机状态变化
 
 @param   completion
 @{
    @"1": 盒盖状态-0打开/1关闭
    @"2": 电量等级变化-1/2/3/4
    @"3": 是否装有纸张-0没有/1有
    @"5": 碳带状态-0无碳带/1有碳带
 }
 @return  是否支持监听打印机状态变化：YES:支持、NO:不支持
 */
+ (BOOL)getPrintStatusChange:(PRINT_DIC_INFO)completion;

/**
  蓝牙/Wi-Fi是否支持缺纸检测等功能（目前app没有用到具体功能接口，替换为该接口）

 @return  是否支持：YES:支持、NO:不支持
 */
+ (BOOL)isSupportNOPaper;

/**
 p1打印机打印前传入总打印份数,startDraw:height:orientation:之前调用/startJob之前调用

 @param totalQuantityOfPrints 总份数
 */
+ (void)setTotalQuantityOfPrints:(NSInteger)totalQuantityOfPrints;



/**
 蓝牙/Wi-Fi生成带延长线条码最小宽度,单位像素。
 
 @param   text            条码内容。
 @param   barcodeMode     条码类型。
 @param   isExtension     是否带延长线:YES为带，NO未不带。
 @return  条码最小宽度。
 */
+ (NSInteger)getBarCodeWidth:(NSString *)text codeFormat:(JCBarcodeMode)barcodeMode  isExtension:(BOOL)isExtension;

/**
 蓝牙/Wi-Fi生成二维码最小宽度,单位像素。
 
 @param   text            二维码内容。
 @return  二维码最小宽/高。
 */
+ (NSInteger)getQRCodeWidth:(NSString *)text;


/// 0-正常，1-不支持的类型，2-数据异常，3-长度不符，4-字符不符，5-校验码不符
/// @param barcodeType 条码类型(20-28)
/// @param content 传入的条码数据
+ (int)barcodeFormatCheck:(int)barcodeType content:(NSString*)content ;


/// 0-正常，1-不支持的类型，2-数据异常，3-长度不符，4-字符不符
/// @param qrcodeType 条码类型(31-34)
/// @param content 传入的二维码数据
+ (int)qrcodeFormatCheck:(int)qrcodeType content:(NSString*)content;

/**
 蓝牙/Wi-Fi返回处理后的条码内容。
 
 @param   text            条码内容。
 @param   barcodeMode     条码类型。
 @return  处理后的条码内容（也可用于检查条码内容是否规范，@"":表示出错）
 */
+ (NSString *)dealBarCodeText:(NSString *)text withBarcodeMode:(JCBarcodeMode)barcodeMode;

/**
 蓝牙/Wi-Fi获取第几页预览图(在print:之前获取)。
 
 @param   index           第几页（从0开始）
 @return                  预览图
 */
+ (UIImage *)previewImage:(NSInteger)index;


/// 打印时获取预览图
+ (UIImage *)getPrintPreviewImage;

/**
 蓝牙/Wi-Fi图片直接生成预览图图片。
 
 @param   image           图像对象。
 @param   width           打印对象的尺寸，单位毫米。
 @param   height          打印对象的尺寸，单位毫米。
 @param   orientation     旋转角度：0：不旋转；90：顺时针旋转90度；180：旋转180度；270：逆时针旋转90度。
 @return  预览图
 */
+ (UIImage *)drawpreviewImagFromImage:(UIImage *)image
      width:(CGFloat)width
     height:(CGFloat)height
orientation:(NSInteger)orientation;




/// 图像二期打印json数据
/// @param printData json数据
/// @param printerJson 打印机边距信息
/// @param onePageNumvers 单页要打印的份数
/// @param completion 回调
+ (void)print:(NSString *)printData printAddJson:(NSDictionary *)printerJson withOnePageNumbers:(int)onePageNumvers withComplete:(DidPrinted_Block)completion;

/**
 蓝牙/Wi-Fi取消打印(打印未完成调用)。
 
 @param   completion      打印结束回调（在发生异常后不会返回）
 */
+ (void)cancelJob:(DidPrinted_Block)completion;

/**
 蓝牙/Wi-Fi打印完成(打印完成后调用)。
 
 @param   completion      打印结束回调（在发生异常后不会返回）
 */
+ (void)endPrint:(DidPrinted_Block)completion;

/**
 蓝牙/Wi-Fi打价器打印完成的份数(只对打价器有效，可能部分丢失，app做超时重置状态)。
 
 @param   count           打印完成的份数（在发生异常后不会返回）
 @{
    @"totalCount":@"总打印的张数计数" //返回必带的key
    @"pageCount":@"当前打印第PageNo页的第几份" //非必带
    @"pageNO":@"当前打印第几页"。 //非必带
    @"tid":@"写入rfid返回的tid码"  //非必带
    @"carbonUsed":@"碳带使用量，单位毫米"  //非必带
 }
 */
+ (void)getPrintingCountInfo:(PRINT_DIC_INFO)count;

/**
 蓝牙/Wi-Fi异常接收(连接成功后调用)。
 
 @param   error           打印异常：1:盒盖打开,
                                  2:缺纸,
                                  3:电量不足,
                                  4:电池异常,
                                  5:手动停止,
                                  6:数据错误,
                                    （提交打印数据失败-B3/图像生成失败/发送数据错误,打印机校验不通过打印机返回）
                                  7:温度过高,
                                  8:出纸异常,
 9-打印忙碌(当前正在转动马达(正在打印中或者走纸)/打印机正在升级固件)
 10-没有检测到打印头
 11-环境温度过低
 12.打印头未锁紧
 13-未检测到碳带
 14-不匹配的碳带
 15-用完的碳带
 16-不支持的纸张类型
 17-设置纸张失败
 18-设置打印模式失败
 19-设置打印浓度失败（允许打印,仅上报异常）
 20-写入Rfid失败
 21-边距设置错误
 (边距必须大于0，上边距+下边距必须小于画板高度，左边距+右边距必须小于画板宽度)
 22-通讯异常（超时，打印机指令一直拒绝）
 23-打印机断开
 24-画板参数设置错误
 25-旋转角度参数错误
 26-json参数错误(pc)
 27-出纸异常（关闭上盖检测）
 28-检查纸张类型
 29-RFID标签进行非RFID模式打印时
 30-浓度设置不支持
 31-不支持的打印模式
 32-标签材质设置失败(材质设置超时或者失败，不阻断正常打印)
 33-不支持的标签材质设置(阻断正常打印)
 34-打印机异常(阻断正常打印)
 35-切刀异常(T2阻断正常打印)
 36-缺纸(T2未放纸)
 37-打印机异常(T2无法通过指令恢复，需要手动按打印机)
 */
+ (void)getPrintingErrorInfo:(PRINT_INFO)error;

/**
 蓝牙/Wi-Fi像素转毫米(会对像素进行处理)。
 
 @param   pixel           像素
 @return  绘制参数
 */
+ (CGFloat)pixelToMm:(CGFloat)pixel;

/**
 蓝牙/Wi-Fi毫米转像素(会对毫米进行处理)。

 @param  mm       毫米
 @return  绘制参数
 */
+ (CGFloat)mmToPixel:(CGFloat)mm;

/**
 蓝牙/Wi-Fi打印机分辨率

 @return  返回对应的打印机分辨率(连接打印机后有效)
 */
+ (NSInteger)printerResolution;
+ (float)printerMulityDpiToMm;

/// 设置字体路径
/// @param fontFamilyPath 路径
+(void) initImageProcessing:(NSString *) fontFamilyPath error:(NSError **)error;

/// 准备打印
/// @param blackRules 设置浓度
/// @param paperStyle 设置纸张
/// @param completion 回调
+ (void)startJob:(int)blackRules
  withPaperStyle:(int)paperStyle
  withCompletion:(DidPrinted_Block)completion;


/// 图像二期毫米转像素
/// @param mm 毫米
/// @param scaler 倍率
+ (int) mmToPixel:(float)mm scaler:(float)scaler;

/// 图像二期像素转毫米
/// @param pixel 像素
/// @param scaler  倍率
+ (float) pixelToMm:(int)pixel scaler:(float)scaler;

/// 获取倍率
/// @param templatePhysical 屏幕物理尺寸
/// @param screenDisplaySize 屏幕分辨率
+ (float)getDisplayMultiple:(float)templatePhysical templateDisplayWidth:(int)screenDisplaySize;


/// 毫米转英寸
/// @param mm 毫米
+(float) mmToInch:(float) mm;

/// 英寸转毫米
/// @param inch 英寸
+(float) inchToMm:(float) inch;




+(void)didReadSDKCacheStatus:(JCSDKCACHE_STATE)status;

+(void)setPrintWithCache:(BOOL)startCache;


/// 是否支持RFID写入功能
+(BOOL)isSupportWriteRFID;


/// 绘制画板
/// @param width 宽
/// @param height 高
/// @param horizontalShift 水平偏移
/// @param verticalShift 竖直偏移
/// @param rotate 旋转角度
/// @param font 使用字体路径,缺省输入nil
+(void)initDrawingBoard:(float)width
             withHeight:(float)height
    withHorizontalShift:(float)horizontalShift
      withVerticalShift:(float)verticalShift
                 rotate:(int) rotate
                   font:(NSString*)font;


/// 绘制文本
/// @param x 水平起点
/// @param y 竖直起点
/// @param w 宽
/// @param h 高
/// @param text 内容
/// @param fontFamily 字体
/// @param fontSize 字体大小
/// @param rotate 旋转
/// @param textAlignHorizonral 文本水平对齐方式 0:左对齐 1:居中对齐 2:右对齐
/// @param textAlignVertical 文本竖直对齐方式  0:顶对齐 1:垂直居中 2:底对齐
/// @param lineMode 换行方式
/// @param letterSpacing 字体间隔
/// @param lineSpacing 行间隔
/// @param fontStyles [@1,@1,@1,@1] 斜体,加粗,下划线,删除下划线
+(BOOL)drawLableText:(float)x
               withY:(float)y
           withWidth:(float)w
          withHeight:(float)h
          withString:(NSString *)text
      withFontFamily:(NSString *)fontFamily
        withFontSize:(float)fontSize
          withRotate:(int)rotate
withTextAlignHorizonral:(int)textAlignHorizonral
withTextAlignVertical:(int)textAlignVertical
        withLineMode:(int)lineMode
   withLetterSpacing:(float)letterSpacing
     withLineSpacing:(float)lineSpacing
       withFontStyle:(NSArray <NSNumber *>*)fontStyles;


/// 绘制条码
/// @param x 水平坐标
/// @param y 垂直坐标
/// @param w 标贴宽度,单位mm
/// @param h 标贴高度,单位mm
/// @param text 文本内容
/// @param fontSize 文本字号
/// @param rotate 旋转角度，仅支持0,90,180,270
/// @param codeType 一维码类型 20:CODE128 21:UPC-A 22:UPC-E 23:EAN8 24:EAN13 25:CODE93 26:CODE39 27:CODEBAR 28:ITF25
/// @param textHeight 文本高度
/// @param textPosition 文本位置，int 一维码文字识别码显示位置 0:下方显示 1:上方显示 2:不显示
+(BOOL)drawLableBarCode:(float)x
                  withY:(float)y
              withWidth:(float)w
             withHeight:(float)h
             withString:(NSString *)text
           withFontSize:(float)fontSize
             withRotate:(int)rotate
           withCodeType:(int)codeType
         withTextHeight:(float)textHeight
       withTextPosition:(int)textPosition;


/// 绘制二维码
/// @param x 水平坐标
/// @param y 垂直坐标
/// @param w 标贴宽度,单位mm
/// @param h 标贴高度,单位mm
/// @param text 文本内容
/// @param rotate 旋转角度，仅支持0,90,180,270
/// @param codeType 二维码类型 31:QR_CODE 32:PDF417 33:DATA_MATRIX 34:AZTEC
+(BOOL)drawLableQrCode:(float)x
                 withY:(float)y
             withWidth:(float)w
            withHeight:(float)h
            withString:(NSString *)text
            withRotate:(int)rotate
          withCodeType:(int)codeType;


/// 绘制线条
/// @param x 水平坐标
/// @param y 垂直坐标
/// @param w 标贴宽度,单位mm
/// @param h 标贴高度,单位mm
/// @param rotate 旋转角度，仅支持0,90,180,270
/// @param lineType 线条类型 1:实线 2:虚线类型,虚实比例1:1
/// @param dashWidth 线条为虚线宽度，【实线段长度，空线段长度】
+(BOOL)DrawLableLine:(float)x
               withY:(float)y
           withWidth:(float)w
          withHeight:(float)h
          withRotate:(int)rotate
        withLineType:(int)lineType
       withDashWidth:(NSArray <NSNumber *>*)dashWidth;


/// 绘制形状
/// @param x 水平坐标
/// @param y 垂直坐标
/// @param w 标贴宽度,单位mm
/// @param h 标贴高度,单位mm
/// @param lineWidth 线条类型
/// @param cornerRadius 图像圆角
/// @param rotate 旋转角度，仅支持0,90,180,270
/// @param graphType 图形类型
/// @param lineType 线条类型 1:实线 2:虚线类型,虚实比例1:1
/// @param dashWidth 线条为虚线宽度，【实线段长度，空线段长度】
+(BOOL)DrawLableGraph:(float)x
                withY:(float)y
            withWidth:(float)w
           withHeight:(float)h
        withLineWidth:(float)lineWidth
     withCornerRadius:(float)cornerRadius
           withRotate:(int)rotate
        withGraphType:(int)graphType
         withLineType:(int)lineType
        withDashWidth:(NSArray <NSNumber *>*)dashWidth;


/// 绘制图片
/// @param x 水平坐标
/// @param y 垂直坐标
/// @param w 标贴宽度,单位mm
/// @param h 标贴高度,单位mm
/// @param imageData 图像base64数据
/// @param rotate 旋转角度，仅支持0,90,180,270
/// @param imageProcessingType 处理算法
/// @param imageProcessingValue 阈值
+(BOOL)DrawLableImage:(float)x
                withY:(float)y
            withWidth:(float)w
           withHeight:(float)h
        withImageData:(NSString *)imageData
           withRotate:(int)rotate
withImageProcessingType:(int)imageProcessingType
withImageProcessingValue:(float)imageProcessingValue;

+(NSString *)GenerateLableJson;


/// 获取预览图
/// @param displayScale 倍率
/// @param error 出错返回的错误码
+(UIImage *)generateImagePreviewImage:(float)displayScale error:(NSError **)error;


/// 开始打印
/// @param printData 打印数据
/// @param onePageNumvers 打印份数
/// @param completion 回调
+ (void)commit:(NSString *)printData
withOnePageNumbers:(int)onePageNumvers
  withComplete:(DidPrinted_Block)completion;


#pragma mark   ###################双色打印##################

/// 是否是双色打印机，需要连接成功之后调用
+(int) getPrinterColorType;


/// 准备打印
/// @param blackRules 设置浓度
/// @param paperStyle 设置纸张
/// @param completion 回调
+ (void)startJob:(int)blackRules
  withPaperStyle:(int)paperStyle
   withColorType:(int)colorType
  withCompletion:(DidPrinted_Block)completion;

@end

