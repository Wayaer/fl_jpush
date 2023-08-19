# FlJVerify Flutter Plugin

### 安装

在工程 pubspec.yaml 中加入 dependencies

### 配置

##### Android:

在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android:
{

    defaultConfig {
        applicationId "替换成自己应用 ID"

        manifestPlaceholders = [
                JPUSH_PKGNAME: applicationId,
                JPUSH_APPKEY : "appkey", // NOTE: JPush 上注册的包名对应的 Appkey.
                JPUSH_CHANNEL: "developer-default", //暂时填写默认值即可.
        ]
    }
}
```
