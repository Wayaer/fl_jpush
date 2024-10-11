# HONOR厂商通道接入指南

在国内 Android 生态中，推送通道都是由终端与云端之间的长链接来维持，严重依赖于应用进程的存活状态。如今一些手机厂家会在自家 rom 中做系统级别的推送通道，再由系统分发给各个 app，以此提高在自家 rom 上的推送送达率。

JPush SDK 为了尽可能提高开发者在各类 rom 上的推送送达率，对使用 Magic 的设备推送，自动切换到荣耀通道。同时，为了保证 SDK 的易用性，原本 JPush 的所有接口调用逻辑都不用修改,JPush 会对自身支持的功能做兼容.只需在manifest中配置上荣耀 SDK 必须的配置组件即可.

## 功能描述
+ JPush 初始化的时候可选择是否初始化 Honor Push 通道。
+ 设备要求：荣耀设备 Magic UI 5.0+
+ 在 Magic 设备上 JPush 通道与 Honor 通道共存.
## 主要步骤为：

  * [1. 配置签名摘要信息](#1)

  * [2. SDK集成](#2)

  * [3. 在项目module的build.gradle 中配置在荣耀后台添加的指纹证书对应的签名](#3)
## 配置签名摘要信息

  通过 jdk\bin 目录下的 keytool.jar，获取签名证书指纹
  ```
  1、可以通过签名文件获取签名信息：
   <keystore-file>为签名文件的绝对路径。
   keytool -list -v -keystore <keystore-file>
  2、如果没有签名文件或密钥口令，也可以通过应用 Apk 包获取签名信息：
   <apk-file>为 Apk 文件的绝对路径。
   keytool -list -printcert -jarfile <apk-file>
```
  从结果中找到对应的证书指纹 - SHA256 摘要信息，填入[Honor](https://developer.hihonor.com/cn/home)后台
 ***注***：荣耀 服务必须要求 app 签名才能注册成功。


## SDK集成
### 手动配置集成步骤

#### 1.添加 Honor SDK 到项目中

 + 将third-push目录下找到honor目录，从libs中拷贝其中的jar包至工程的libs目录下。
 + jar包说明：
 	* jpush-android-plugin-honor-v4.x.x.jar : JPush 插件包
 	* HiPushSdk-vxxx.aar  : honor 推送包
  + 在 [Honor](https://developer.hihonor.com/cn/home) 上创建和 JPush 上同包名的待发布应用。


#### 2.清单文件配置如下

```
//Honor所需要的权限
  <queries>
         <intent>
             <action android:name="com.hihonor.push.action.BIND_PUSH_SERVICE" />
         </intent>
     </queries>
     <application>
         <service
             android:name="cn.jpush.android.service.JHonorService"
             android:exported="false">
             <intent-filter>
                 <action android:name="com.hihonor.push.action.MESSAGING_EVENT" />
             </intent-filter>
         </service>
 
         <meta-data
             android:name="com.hihonor.push.app_id"
             android:value="您的应用对应的Honor的APP ID" />
     </application>
```
#### 3. 在项目 module 的 build.gradle 中添加如下配置代码

```
dependencies {
    ...
    implementation(name: 'HiPushSdk-v7.0.1.103', ext: 'aar')
    ...  
}
android {
    ...

    repositories {
        flatDir {
            dirs 'libs'
        }
    }

}
```
### mavenCentral 自动化集成步骤
#### 1.添加 Honor SDK 到项目中   
 + 将third-push目录下找到honor目录，从libs中拷贝其中的jar包至工程的libs目录下。
 + jar包说明：
 	* HiPushSdk-vxxx.aar  : honor 推送包

#### 2.确认项目根目录的 build.gradle中配置了mavenCentral支持。

```
buildscript {
    repositories {
      ...
      mavenCentral()
      ...
    }
}

allprojets {
    repositories {
        ...
        mavenCentral()
        ...
    }
}
```

#### 3.在项目 module 的 build.gradle 中添加如下代码:

```
  defaultConfig {
        ...
        manifestPlaceholders = [
               ...
               HONOR_APPID : "您的应用对应的Honor的APP ID", // Honor平台注册的APP ID
               ...
        ]
        ...
    }
  dependencies {
        ...
        implementation 'cn.jiguang.sdk.plugin:honor:4.7.0' //4.7.0 极光对应插件的版本号
        implementation(name: 'HiPushSdk-v7.0.1.103', ext: 'aar')
        ...
  }
  android {
        ...
        repositories {
            flatDir {
                dirs 'libs'
            }
        }
        ...
  }
```



***注1***：极光集成荣耀通道在 JPush Android SDK 4.7.0 添加，对应测试的荣耀 SDK 版本为：HiPushSdk-v6.0.4.101-release.aar、HiPushSdkCommon-v6.0.4.101-release.aar

***注2***：极光集成荣耀通道在 JPush Android SDK 4.8.1 添加，对应测试的荣耀 SDK 版本为：HiPushSdk-6.0.4.200.aar、HiPushSdkCommon-6.0.4.200.aar

***注3***：极光集成荣耀通道在 JPush Android SDK 4.8.3 添加，对应测试的荣耀 SDK 版本为：HiPushSdk-v7.0.1.103.aar(注意荣耀SDK只保留：HiPushSdk,原来的HiPushSdkCommon需要删掉)

***注4***：极光集成荣耀通道在 JPush Android SDK 5.0.0 添加，对应测试的荣耀 SDK 版本为：HiPushSdk-v7.0.41.301.aar

***注5***：极光集成荣耀通道在 JPush Android SDK 5.2.0 添加，对应测试的荣耀 SDK 版本为：HiPushSdk-v7.0.61.302.aar

***注6***：极光集成荣耀通道在 JPush Android SDK 5.4.0 添加，对应测试的荣耀 SDK 版本为：HiPushSdk-v7.0.61.303.aar

***注*** [荣耀 Push SDK 的官方文档](https://developer.hihonor.com/cn/doc/guides/100223)



##  在项目module的build.gradle 中配置在荣耀后台添加的指纹证书对应的签名

```
      signingConfigs {
          release {
              storeFile file("release.keystore")//签名文件的path
              storePassword "123456"
              keyAlias "android.keystore"
              keyPassword "123456"
          }
      }
  
  	buildTypes {
          release {
              minifyEnabled true
              proguardFiles 'proguard-rules.pro'
              signingConfig signingConfigs.release
          }
          debug{
          	minifyEnabled false
              signingConfig signingConfigs.release
          }
      }
  
```
## 组装服务集成步骤

请在组包服务界面勾选 JPush 后同时勾选 Honor 组包项，组包服务使用方式请参考[JPush组包服务指南](http://docs.jpush.cn/jpush/client/Android/android_guide/#_5)

+ 在应用 module gradle 中添加 Honor 账号配置

```
android {
    ......
    defaultConfig {
        applicationId "com.xxx.xxx" //JPush 上注册的包名.
        ......

        manifestPlaceholders = [
            JPUSH_PKGNAME : applicationId,
            JPUSH_APPKEY : "你的 Appkey ", //JPush 上注册的包名对应的 Appkey.
            JPUSH_CHANNEL : "developer-default", //暂时填写默认值即可.

            HONOR_APPID : "您的应用对应的Honor的APP ID", // Honor平台注册的APP ID

        ]
        ......
    }
    ......
}

dependencies {
    ...
    implementation project(':jiguang')
     // Honor 厂商 aar 需要单独引入
     // 请将 jiguang/libs 下 HiPushSdk-v6.0.4.101-release.aar HiPushSdkCommon-v6.0.4.101-release.aar 单独拷贝一份到应用 module/libs 下
    implementation(name: 'HiPushSdk-v6.0.4.101-release', ext: 'aar')
    implementation(name: 'HiPushSdkCommon-v6.0.4.101-release', ext: 'aar')
    ...
}
```

## 荣耀 SDK的编译混淆问题

  如果使用了 proguard，需要在配置文件中加入,可以防止一个误报的 warning 导致无法成功编译，

```
 -ignorewarnings
 -keepattributes *Annotation*
 -keepattributes Exceptions
 -keepattributes InnerClasses
 -keepattributes Signature
 -keepattributes SourceFile,LineNumberTable
 -keep class com.hihonor.push.**{*; }
  
```

## 成功集成荣耀厂商通道的标志

插件集成成功后，会向荣耀server请求token，拿到这个token即可证明 集成没问题。

token是可以在日志里查到的，观察下列日志输出
```
[HonorPushHelper] get honor token:s18069ps301291893q1ssro2o40s1630-n262n542r9669q62o83s390306179rro-775875632-654-6105326555582-PA-0052993947080949113-5

```

## 点击通知跳转 Activity  

### 支持的版本  

此功能从 JPush Android SDK 3.3.8 开始支持

### 通知跳转的定义  

xiaomi push 允许开发者在推送通知的时候传入自定义的 intent uri 字符串，当用户点击了该通知，系统会根据 uri 的值过滤出匹配的 Activity ，并打开 Activity，达到跳转的目的。

### Push API 推送说明    

在 push api 的 payload 中的 "notification" 的 "android" 节点下添加以下字段：

<div class="table-d" align="center" >
	<table border="1" width = "100%">
		<tr  bgcolor="#D3D3D3" >
			<th >关键字</th>
			<th >类型</th>
			<th >示例</th>
			<th >说明</th>
		</tr>
		<tr >
			<td>uri_activity</td>
			<td>string</td>
			<td>"com.example.jpushdemo.OpenClickActivity"</td>
			<td>该字段用于指定开发者想要打开的 activity，值为activity 节点的 “android:name ” 属性值。</td>
		</tr>
	</table>
</div>
***示例：***  

```
demo manifest配置：
<activity android:name="com.example.jpushdemo.OpenClickActivity"
 android:permission="${applicationId}.permission.JPUSH_MESSAGE"
      android:exported="true">
      <intent-filter>
           <action android:name="android.intent.action.VIEW"/>
           <category android:name="android.intent.category.DEFAULT"/>
      </intent-filter>
</activity>

请求json如下：
{
    "platform": [
        "android"
    ],
    "audience": "all",
    "notification": {
        "android": {
            "alert": "在线alert003",
            "title": "在线title003",
            "uri_activity": "com.example.jpushdemo.OpenClickActivity",
        }
    },
    "message": {
        "msg_content": "自定义消息内容003"
    }
}
```

### SDK 端配置  

#### 1.AndroidManifest.xml中配置点击通知要打开的 activity  
```
<activity android:name="您配置的activity"
 android:permission="${applicationId}.permission.JPUSH_MESSAGE"
      android:exported="true">
      <intent-filter>
           <action android:name="android.intent.action.VIEW"/>
           <category android:name="android.intent.category.DEFAULT"/>
      </intent-filter>
</activity>
```
#### 2.获取通知相关信息
在您配置的 activity 中的onCreate方法中进行处理，获取通知信息。

通过 getIntent().getExtras().getString("JMessageExtra") 获取到数据。获取到的数据是 JSON 字符串，通过解析可以获得通知相关内容。

JSON 示例如下：

```
{
	"msg_id":"123456",
	"n_content":"this is content",
	"n_extras":{"key1":"value1","key2":"value2"},
	"n_title":"this is title",
	"rom_type":0
}
```

JSON 内容字段说明：

字段|取值类型|描述
---|---|---
msg_id|String|通过此key获取到通知的msgid
n_title|String|通过此key获取到通知标题
n_content|String|通过此key获取到通知内容
n_extras|String|通过此key获取到通知附加字段
rom_type| byte|通过此key获取到下发通知的平台。得到值说明：byte类型的整数， 0为极光，1为小米，2为华为，3为魅族，4为 OPPO，5为vivo，6为asus，7为Honor,8为FCM。

***注：*** rom_type 用于点击事件的上报，一般情况下开发者只需要取到该字段的值用于上报，不需要关心具体取值。

#### 3.Activity 示例代码
```
package com.example.jpushdemo;

import android.app.Activity;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.TextView;

import org.json.JSONException;
import org.json.JSONObject;

import cn.jpush.android.api.JPushInterface;

/**
 * Created by jiguang on 17/7/5.
 */

public class OpenClickActivity extends Activity {
    private static final String TAG = "OpenClickActivity";
    /**消息Id**/
    private static final String KEY_MSGID = "msg_id";
    /**该通知的下发通道**/
    private static final String KEY_WHICH_PUSH_SDK = "rom_type";
    /**通知标题**/
    private static final String KEY_TITLE = "n_title";
    /**通知内容**/
    private static final String KEY_CONTENT = "n_content";
    /**通知附加字段**/
    private static final String KEY_EXTRAS = "n_extras";
    private TextView mTextView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mTextView = new TextView(this);
        setContentView(mTextView);
        handleOpenClick();
    }


    /**
     * 处理点击事件，当前启动配置的Activity都是使用
     * Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK
     * 方式启动，只需要在onCreat中调用此方法进行处理
     */
    private void handleOpenClick() {
        Log.d(TAG, "用户点击打开了通知");
        String data = null;
        //获取华为平台附带的jpush信息
        if (getIntent().getData() != null) {
             data = getIntent().getData().toString();
        }

        //获取fcm、oppo、vivo、华硕、小米平台附带的jpush信息
        if(TextUtils.isEmpty(data) && getIntent().getExtras() != null){
            data = getIntent().getExtras().getString("JMessageExtra");
        }

        Log.w(TAG, "msg content is " + String.valueOf(data));
        if (TextUtils.isEmpty(data)) return;
        try {
            JSONObject jsonObject = new JSONObject(data);
            String msgId = jsonObject.optString(KEY_MSGID);
            byte whichPushSDK = (byte) jsonObject.optInt(KEY_WHICH_PUSH_SDK);
            String title = jsonObject.optString(KEY_TITLE);
            String content = jsonObject.optString(KEY_CONTENT);
            String extras = jsonObject.optString(KEY_EXTRAS);
            StringBuilder sb = new StringBuilder();
            sb.append("msgId:");
            sb.append(String.valueOf(msgId));
            sb.append("\n");
            sb.append("title:");
            sb.append(String.valueOf(title));
            sb.append("\n");
            sb.append("content:");
            sb.append(String.valueOf(content));
            sb.append("\n");
            sb.append("extras:");
            sb.append(String.valueOf(extras));
            sb.append("\n");
            sb.append("platform:");
            sb.append(getPushSDKName(whichPushSDK));
            mTextView.setText(sb.toString());
        } catch (JSONException e) {
            Log.w(TAG, "parse notification error");
        }


    }

    private String getPushSDKName(byte whichPushSDK) {
        String name;
        switch (whichPushSDK){
            case 0:
                name = "jpush";
                break;
            case 1:
                name = "xiaomi";
                break;
            case 2:
                name = "huawei";
                break;
            case 3:
                name = "meizu";
                break;
            case 4:
            	name= "oppo";
            	break;
            case 5:
                name = "vivo";
                break;
            case 6:
                name = "asus";
                break; 
            case 7:
                name = "honor";
                break;                  
            case 8:
                name = "fcm";
                break;
            default:
                name = "jpush";
        }
        return name;
    }
}
```











  