# JPush SDK VIVO通道集成指南

## 概述

在国内 Android 生态中，推送通道都是由终端与云端之间的长链接来维持，严重依赖于应用进程的存活状态。如今一些手机厂家会在自家 rom 中做系统级别的推送通道，再由系统分发给各个 app，以此提高在自家 rom 上的推送送达率。

JPush SDK 为了尽可能提高开发者在各类 rom 上的推送送达率，对使用 Funtouch 的设备推送，自动切换到 VIVO 通道。同时，为了保证 SDK 的易用性，原本 JPush 的所有接口调用逻辑都不用修改，JPush 会对自身支持的功能做兼容。只需在 manifest 中配置上 VIVO SDK 必须的配置组件即可。

## 功能描述

+ JPush 初始化的时候可选择是否初始化 VIVO 通道。

+ 在 Funtouch 设备上 JPush 通道与 VIVO 通道共存。

+ VIVO 通道初始化后支持 tag/alias这些 JPush 原有的功能，其它的 JPush 未支持的功能目前暂时还不可用。

+ 通知效果：

	* VIVO 通道不支持 ACTION\_NOTIFICATION\_RECEIVED 

*注：* JPush 通过 PushClient.getInstance(context).isSupport() 接口进行判断，对支持的机型，通知走 VIVO 通道，不支持则走极光通道。目前 VIVO 通道支持的机型X23、NEX S 、NEX A、X21i、X21、X20、Y81s、Y83A、x9sp_8.1、x9s_8.1、Z1、Y71、X20 Plus、Y85、x9_8.1、x9Plus_8.1、Y75A、Y79A、Y66i A、X9、x9s、x9P、x9sp。[详细可参考](https://dev.vivo.com.cn/documentCenter/doc/156)


## 手动配置集成步骤

主要步骤为：

* [1. 增加VIVO插件包及VIVO推送包](#1)

* [2. 配置VIVO必须的组件](#3)

* [3. 将VIVO\_APPKEY、VIVO\_APPID 替换为在VIVO后台注册对应该应用的AppKey/AppID](#4)


### 1. 增加VIVO插件包及VIVO推送包
+ 将third-push目录下找到vivo目录，从libs中拷贝其中的jar包至工程的libs目录下。
+ jar包说明：
	* jpush-android-plugin-vivo-v4.x.x.jar : JPush 插件包
	* pushsdk_v2.x.x.jar : VIVO 推送包

***注1***：极光集成 VIVO 通道在 JPush Android SDK 3.2.0 添加,vivo sdk版本为：pushsdk_v2.3.1.jar
***注2***：JPush Android SDK 3.5.8 更新vivo sdk版本为：push_sdk_v2.9.0.jar。
***注3***：JPush Android SDK 3.9.1 更新vivo sdk版本为：push_sdk_v3.0.0.jar。
***注4***：JPush Android SDK 4.6.0 更新vivo sdk版本为：push_sdk_v3.0.0.4_484.aar。
***注4***：JPush Android SDK 5.2.0 更新vivo sdk版本为：push_sdk_v3.0.0.7_488.aar。
***注5***：JPush Android SDK 5.4.0 更新vivo sdk版本为：push_sdk_v4.0.0.0_500.aar。
***注6***：JPush Android SDK 5.5.0 更新vivo sdk版本为：push_sdk_v4.0.4.0_504.aar。

### 2. 配置VIVO必须的组件

```
<receiver android:name="cn.jpush.android.service.PluginVivoMessageReceiver"
          android:exported="false">
        <intent-filter>
            <!-- 接收 push 消息 -->
            <action android:name="com.vivo.pushclient.action.RECEIVE" />
        </intent-filter>
</receiver>
<service
    android:name="com.vivo.push.sdk.service.CommandClientService"
 android:permission="com.push.permission.UPSTAGESERVICE"
    android:exported="true" />

```


### 3. 将VIVO应用的 appkey 、appid 填入meta-data 标签中


```
<meta-data
    android:name="com.vivo.push.api_key"
    android:value="您的应用对应的VIVO的APPKEY" />
<meta-data
    android:name="com.vivo.push.app_id"
    android:value="您的应用对应的VIVO的APPID" />

```

## mavenCentral 自动化集成步骤

+ 确认 android studio 的 Project 根目录的主 gradle 中配置了 mavenCentral 支持。

```
	buildscript {
		repositories {
			jcenter()
            mavenCentral()
		}
            ......
	}

	allprojets {
		repositories {
			jcenter()
            mavenCentral()
		}
	}

```

+ 在应用 module 的 gradle 中 dependencies 节点添加如下代码:


```
    dependencies {
        compile 'cn.jiguang.sdk.plugin:vivo:4.x.x' 
    }

```

+ 在应用 module 的 gradle 中 defaultConfig 节点添加如下代码:


```
    manifestPlaceholders = [

        // 设置manifest.xml中的变量
        VIVO_APPKEY : "您的应用对应的VIVO的APPKEY", // VIVO平台注册的appkey
        VIVO_APPID : "您的应用对应的VIVO的APPID", // VIVO平台注册的appid

    ]


```

## 组包服务集成步骤
请在组包服务界面勾选 JPush 后同时勾选 VIVO 组包项，组包服务使用方式请参考[JPush组包服务指南]https://docs.jiguang.cn//jpush/client/Android/android_guide/#_5)

+ 在应用 module gradle 中添加 VIVO 账号配置

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

            VIVO_APPKEY   : "VIVO的APPKEY",
            VIVO_APPID    : "VIVO的APPID",

        ]
        ......
    }
    ......
}

dependencies {
    ......

    implementation project(':jiguang')
    ......
}
```


## VIVO SDK的编译混淆问题

若需要混淆 app，请在混淆文件中添加以下说明，防止 SDK 内容被二次混淆.

	-dontwarn com.vivo.push.**
	-keep class com.vivo.push.**{*; }
	-keep class com.vivo.vms.**{*; }


## 点击通知跳转 Activity   

### 支持的版本   

此功能从 JPush Android SDK 3.3.8 开始支持

### 通知跳转的定义   

vivo push 允许开发者在推送通知的时候传入自定义的 intent uri 字符串，当用户点击了该通知，系统会根据 uri 的值过滤出匹配的 Activity ，并打开 Activity，达到跳转的目的。

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
      android:exported="true">
      <intent-filter>
           <action android:name="android.intent.action.VIEW"/>
           <category android:name="android.intent.category.DEFAULT"/>
      </intent-filter>
</activity>
```
***注：*** android:exported 属性必须设置为 true，并增加示例中的 intent-filter，否则会导致无法收到通知。

#### 2.获取通知相关信息  
目前启动配置的 activity 都是使用 Intent.FLAG\_ACTIVITY\_CLEAR\_TOP | Intent.FLAG\_ACTIVITY\_NEW\_TASK 方式启动，只需要在您配置的 activity 中的onCreate方法中进行处理，获取通知信息。

通过 getIntent().getExtras().getString("JMessageExtra"); 获取到Intent 数据。获取到的数据是 JSON 字符串，通过解析可以获得通知相关内容。

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


#### 3.通知点击上报
解析通知内容后，需主动调用接口来进行通知点击上报，上报接口如下：

```
/**
* context 上下文
* msgId 消息ID
* whichPushSDK 收到推送的平台，即 rom_type 字段的取值。
**/
JPushInterface.reportNotificationOpened(Context context, String msgId, byte whichPushSDK);
```
***注：*** 点击上报必须传入正确的 whichPushSDK 参数，否则会造成统计数据错误。

***注：*** 422版本开始，通过中转Activity实现点击行为的上报和统计，对第三方厂商通道的通知点击事件上报接口（JPushInterface.reportNotificationOpened）过期。

#### 4.Activity 示例代码
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

            //上报点击事件
            JPushInterface.reportNotificationOpened(this, msgId, whichPushSDK);
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

