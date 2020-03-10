
# Analysys iOS SDK [![License](https://img.shields.io/github/license/analysys/ans-ios-sdk.svg)](https://github.com/analysys/ans-ios-sdk/blob/master/LICENSE) [![GitHub release](https://img.shields.io/github/release/analysys/ans-ios-sdk.svg)](https://github.com/analysys/ans-ios-sdk/releases)

========

This is the official iOS SDK for Analysys.

# iOS SDK目录说明：
* Example——API调用演示
* AnalysysSDK——SDK源码

# iOS 基础说明：

iOS SDK 用于使用Objective C和Swift开发的App，集成前请先下载SDK

## 快速集成
如果您是第一次使用易观方舟产品，可以通过阅读本文快速了解此产品
1. 选择集成方式
目前我们提供了源码集成和Cocoapods集成两种方式
    * 源码集成：请将`AnalysysSDK`目录下文件拖入工程
    * Cocoapods集成
        
        ```
        pod 'AnalysysAgent'
        ```
2. 设置初始化接口
通过初始化代码的配置参数配置您的 AppKey
3. 设置上传地址
通过初始化代码的配置参数 uploadURL 设置您上传数据的地址。
4. 设置需要采集的页面或事件
通过手动埋点，设置需要采集的页面或事件。
5. 打开Debug模式查看日志
通过设置 Ddebug 模式，开/关 log 查看日志。
通过以上5步您即可验证 SDK 是否已经集成成功。更多接口说明请您查看 API 文档。

更多Api使用方法参考：https://docs.analysys.cn/ark/integration/sdk/ios


## License

[gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.txt)

# 讨论
* 微信号：nlfxwz
* 钉钉群：30099866
* 邮箱：nielifeng@analysys.com.cn
