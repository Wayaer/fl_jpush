# fl_jpush_android

### JPush integrated vendor push channel

### 如需集成极光推送厂商通道请安装次插件

[具体查看极光原生文档](https://docs.jiguang.cn/jpush/client/Android/android_3rd_guide)

- 此插件仅添加原生sdk依赖和配置 `AndroidManifest.xml` 以及 `consumer-rules.pro` 混淆规则,其他配置信息需自行配置
- 此插件未集成 FCM SDk，[fl_jpush_android_fcm](https://pub.dev/packages/fl_jpush_android_fcm)
  需要添加的请查看[极光文档](https://docs.jiguang.cn/jpush/client/Android/android_3rd_guide#fcm-%E9%80%9A%E9%81%93%E9%9B%86%E6%88%90%E6%8C%87%E5%8D%97)

### 集成 oppo 配置

复制 `example/android/heytap_msp_push` 目录至 `${your project}/android/`
目录下，并在 `${your project}/android/settings.gradle` 中添加 `include ':heytap_msp_push'`

### 集成 honor 配置

复制 `example/android/hi_push` 目录至 `${your project}/android/`
目录下，并在 `${your project}/android/settings.gradle` 中添加 `include ':hi_push'`

* 不要修改目录和aar名字

添加以下内容至 `android/app/build.gradle` 中

```groovy
android {
    defaultConfig {
        ...
        manifestPlaceholders = [
                JPUSH_PKGNAME : applicationId,
                JPUSH_APPKEY  : '',

                JPUSH_CHANNEL : 'developer-default',
                // 下面是多厂商配置，如需要开通使用请联系技术支持
                // 如果不需要使用，预留空字段即可
                MEIZU_APPKEY  : "MZ-",
                MEIZU_APPID   : "MZ-",
                XIAOMI_APPID  : "MI-",
                XIAOMI_APPKEY : "MI-",
                OPPO_APPKEY   : "OP-",
                OPPO_APPID    : "OP-",
                OPPO_APPSECRET: "OP-",
                VIVO_APPKEY   : "",
                VIVO_APPID    : "",
                HUAWEI_APPID  : "配置文件里的appid",
                HUAWEI_CPID   : "配置文件里的cp_id",
                HONOR_APPID   : "Honor平台注册的APP ID"
        ]
        ...
    }
}
```

- 常见问题
    - 如直接通过Android studio 拷贝 oppo和 honor 集成的aar
      ,会自动添加 `package ***.heytap_msp_push`、`package ***.hi_push`，要移除
      这行，保证 `build.gradle` 中只有 `configurations.maybeCreate("default")`
      和 `artifacts.add("default", file('**.aar'))`,具体参考 example中的android目录
