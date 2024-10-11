# JPush SDK魅族通道集成指南


## 概述

在国内 Android 生态中，推送通道都是由终端与云端之间的长链接来维持，严重依赖于应用进程的存活状态。如今一些手机厂家会在自家 rom 中做系统级别的推送通道，再由系统分发给各个 app，以此提高在自家 rom 上的推送送达率。

JPush SDK 为了尽可能提高开发者在各类 rom 上的推送送达率，对使用 魅族 的设备推送，自动切换到魅族通道。同时，为了保证 SDK 的易用性，原本 JPush 的所有接口调用逻辑都不用修改,JPush 会对自身支持的功能做兼容.只需在manifest中配置上魅族 SDK 必须的配置组件即可。

## 功能描述

+ JPush 初始化的时候可选择是否初始化魅族通道。 

+ 在 魅族 设备上 JPush 通道与 魅族 通道共存.

+ 魅族通道初始化后支持 tag/alias 这些 JPush 原有的功能,其它的 JPush 未支持的功能目前暂时还不可用 .

***注1：*** 在flyme5.1.11.1及以上才使用 mzpush,因为之前的版本上 mzpush 的通道并非系统通道。



## 手动集成步骤

主要步骤为:

* [4.1. 增加魅族插件包及魅族推送包](#4.1)

* [4.2. 修改 minSdkVersion 的值](#4.2)

* [4.3. 配置魅族推送sdk所需要的权限](#4.3)

* [4.4. 配置JPush接受魅族sdk的消息接受类](#4.4)

* [4.5. 将MEIZUAPPKEY与MEIZUAPPID替换为在魅族后台注册对应该应用 的AppKey/AppID ](#4.5)

####<h3 id="4.1"> 4.1. 增加魅族插件包及魅族推送包 </h3>
- 将third-push目录下找到meizu目录，从libs中拷贝其中的jar包至工程的libs目录下。
- 将third-push目录下找到res目录，从res中所有的资源文件拷贝至工程的res目录下。
- jar包说明：
- jpush-android-plugin-meizu-v4.x.x.jar:插件包
- meizu-push-x.x.x.jar:魅族推送包

***注1：*** 极光集成魅族通道在 JPush Android SDK 3.0.6 添加。

***注2：*** JPush Android SDK 3.2.0添加了魅族推送包，对应的魅族sdk版本为：meizu-push-3.8.1.jar

***注3：*** JPush Android SDK 3.6.0更新了魅族推送包，对应的魅族sdk版本为：meizu-push-3.9.0.jar

***注4：*** JPush Android SDK 3.9.0更新了魅族推送包，对应的魅族sdk版本为：meizu-push-4.0.2.jar

***注5：*** JPush Android SDK 4.1.5更新了魅族推送包，对应的魅族sdk版本为：meizu-push-4.0.7.jar

***注6：*** JPush Android SDK 4.6.0更新了魅族推送包，对应的魅族sdk版本为：meizu-push-4.1.4.jar

***注7：*** JPush Android SDK 5.0.0更新了魅族推送包，对应的魅族sdk版本为：meizu-push-4.2.3.jar

***注8：*** JPush Android SDK 5.2.2更新了魅族推送包，对应的魅族sdk版本为：meizu-push-4.2.7.jar

***注9：*** JPush Android SDK 5.4.0更新了魅族推送包，对应的魅族sdk版本为：meizu-push-4.3.0.jar

***注10：*** JPush Android SDK 5.5.0更新了魅族推送包，对应的魅族sdk版本为：meizu-push-5.0.2.jar
#### <h3 id="4.2"> 4.2. 修改 minSdkVersion 的值</h3>

***注:*** 魅族推送 会强制将 minSdkVersion 修改为 11。如果当前 app 使用的 minSdkVersion 的值小于 11,则需要使用 tools 避免被强制覆盖。

```
	<manifest
		xmlns:android="http://schemas.android.com/apk/res/android"
		xmlns:tools="http://schemas.android.com/tools"
	... >

	<uses-sdk
		android:minSdkVersion="9"
		android:targetSdkVersion="21"
		tools:overrideLibrary="cn.jpush.android.thirdpush.meizu" />

```
#### <h3 id="4.3"> 4.3. 配置魅族推送sdk所需要的权限</h3>

```
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
	<uses-permission android:name="com.meizu.c2dm.permission.RECEIVE" />
	<permission
		android:name="您应用的包名.permission.C2D_MESSAGE"
		android:protectionLevel="signature"></permission>
	<uses-permission android:name="您应用的包名.permission.C2D_MESSAGE" />

```

#### <h3 id="4.4"> 4.4. 配置魅族推送sdk所需要的必要组件</h3>

```
        <service
            android:name="com.meizu.cloud.pushsdk.NotificationService"
            android:exported="true" />

        <receiver
            android:name="com.meizu.cloud.pushsdk.MzPushSystemReceiver"
            android:permission="com.meizu.flyme.permission.PUSH"
            android:exported="true">
            <intent-filter>
                <action android:name="com.meizu.flyme.push.intent.PUSH_SYSTEM" />
            </intent-filter>
        </receiver>


```


#### <h3 id="4.5"> 4.5. 配置JPush接受魅族sdk的消息接受类</h3>

```
	<receiver android:name="cn.jpush.android.service.PluginMeizuPlatformsReceiver"
              android:permission="com.meizu.flyme.permission.PUSH"
              android:exported="true">
		<intent-filter>
			<!-- 接收 push 消息 -->
			<action android:name="com.meizu.flyme.push.intent.MESSAGE" />
			<!-- 接收 register 消息 -->
			<action android:name="com.meizu.flyme.push.intent.REGISTER.FEEDBACK" />
			<!-- 接收 unregister 消息-->
			<action android:name="com.meizu.flyme.push.intent.UNREGISTER.FEEDBACK" />
			<!-- 兼容低版本 Flyme3 推送服务配置 -->
			<action android:name="com.meizu.c2dm.intent.REGISTRATION" />
			<action android:name="com.meizu.c2dm.intent.RECEIVE" />

			<category android:name="您应用的包名"></category>
		</intent-filter>
 	</receiver>

```
***注*** 对于同一个应用集成了多个推送SDK，且其他SDK也使用了魅族通道的用户：
可以将这个极光内置的Receiver，换成自己定义的Receiver。
这个Receiver必须继承魅族的com.meizu.cloud.pushsdk.MzPushMessageReceiver
且在每个回调方法，都回调给极光的PluginMeizuPlatformsReceiver。类似于这样：

```
public class MyMZPushReceiver extends MzPushMessageReceiver {

    final PluginMeizuPlatformsReceiver receiver = new PluginMeizuPlatformsReceiver();

    @Override
    public void onReceive(Context context, Intent intent) {
        receiver.onReceive(context, intent);
    }

    @Override
    public void onRegister(Context context, String s) {
        receiver.onRegister(context, s);
    }

    @Override
    public void onMessage(Context context, String s) {
        receiver.onMessage(context, s);
    }

    @Override
    public void onNotificationArrived(Context context, MzPushMessage mzPushMessage) {
        receiver.onNotificationArrived(context, mzPushMessage);
    }

    @Override
    public void onNotificationClicked(Context context, MzPushMessage mzPushMessage) {
        receiver.onNotificationClicked(context, mzPushMessage);
    }


    @Override
    public void onUnRegister(Context context, boolean b) {
        receiver.onUnRegister(context, b);
    }

    @Override
    public void onPushStatus(Context context, PushSwitchStatus pushSwitchStatus) {
        receiver.onPushStatus(context, pushSwitchStatus);
    }

    @Override
    public void onRegisterStatus(Context context, RegisterStatus registerStatus) {
        receiver.onRegisterStatus(context, registerStatus);
    }

    @Override
    public void onUnRegisterStatus(Context context, UnRegisterStatus unRegisterStatus) {
        receiver.onUnRegisterStatus(context, unRegisterStatus);
    }

    @Override
    public void onSubTagsStatus(Context context, SubTagsStatus subTagsStatus) {
        receiver.onSubTagsStatus(context, subTagsStatus);
    }

    @Override
    public void onSubAliasStatus(Context context, SubAliasStatus subAliasStatus) {
        receiver.onSubAliasStatus(context, subAliasStatus);
    }

    @Override
    public void onUpdateNotificationBuilder(PushNotificationBuilder pushNotificationBuilder) {
        receiver.onUpdateNotificationBuilder(pushNotificationBuilder);
    }
}

```


#### <h3 id="4.6"> 4.6. 将MEIZUAPPKEY与MEIZUAPPID替换为在魅族后台注册对应该应用 的AppKey/AppID </h3>
将应用对应的魅族的 appkey 和 appid 加上前缀“MZ-”,填加在 meta-data 标签中

```
	<meta-data
		android:name="MEIZU_APPKEY"
		android:value="MZ-您的应用对应的魅族的APPKEY" />
	<meta-data
		android:name="MEIZU_APPID"
		android:value="MZ-您的应用对应的魅族的APPID" />

```

## 使用 JCenter 自动化集成步骤
+ 确认android studio的 Project 根目录的主 gradle 中配置了jcenter支持。

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
		compile 'cn.jiguang.sdk.plugin:meizu:4.x.x'
	}

```
+ 在应用 module 的 gradle 中 defaultConfig 节点添加如下代码:

```
	manifestPlaceholders = [
   		// 设置manifest.xml中的变量
   		MEIZU_APPKEY : "MZ-0956b96085d54c6087b85c7994b02ddf", // 魅族平台注册的appkey
   		MEIZU_APPID : "MZ-110443", // 魅族平台注册的appid
   ]

```

## 配置魅族通知栏小图标
通过 MzPush SDK 接收的通知，可设置其通知栏 icon，方法如下：

在应用的工程目录 res/drawable-xxxx/ 几个文件夹中添加对应不同分辨率的通知栏 icon 图标，文件名为 mz\_push\_notification\_small\_icon。如果文件名错误，将无法正确显示该应用的状态栏图标。


魅族手机状态栏 icon 规范请参考 [魅族 PushSDK Demo](https://github.com/MEIZUPUSH/PushDemo/tree/master/PushdemoInternal/src/main/res) 中的图片文件。


**注：**如果没有放入符合规范的 icon 文件，会默认使用应用图标作为通知 icon。而应用图标不符合魅族的通知栏 icon 设计规范的话，则会导致通知栏图标无法正确显示。


## 通知内容长度兼容
### 功能说明
由于魅族官方的通知内容长度限制为100个字符以内（中英文都算一个），当通知内容（极光的“alert”字段的值）长度超过100时，魅族通道会推送失败。此时调用极光api推送通知时，请在payload 中的 "notification" 的 "android" 节点的"extras"节点添加以下字段：
### 使用方式

#### Push API 推送说明
<div class="table-d" align="center" >
	<table border="1" width = "100%">
		<tr  bgcolor="#D3D3D3" >
			<th >关键字</th>
			<th >类型</th>
			<th >示例</th>
			<th >说明</th>
		</tr>
		<tr >
			<td>mzpns_content_forshort</td>
			<td>string</td>
			<td>"short content"</td>
			<td>通知内容（极光的“alert”字段）长度超过100个字符时，可在此字段的值传入不超过100字符的通知内容。</td>
		</tr>
	</table>
</div>


***请求json示例：***

```
{
    "platform": [
        "android"
    ],
    "audience": "all",
    "notification": {
        "android": {
            "alert": "在国内 Android 生态中，推送通道都是由终端与云端之间的长链接来维持，严重依赖于应用进程的存活状态。如今一些手机厂家会在自家 rom 中做系统级别的推送通道，再由系统分发给各个 app，以此提高在自家 rom 上的推送送达率。JPush SDK 为了尽可能提高开发者在各类 rom 上的推送送达率，对使用 ColorOS 的设备推送，自动切换到魅族通道。同时，为了保证 SDK 的易用性，原本 JPush 的所有接口调用逻辑都不用修改,JPush 会对自身支持的功能做兼容.只需在manifest中配置上 魅族 SDK 必须的配置组件即可.",
            "title": "概述",
            "extras": {
                "mzpns_content_forshort": "在国内 Android 生态中，推送通道都是由终端与云端之间的长链接来维持，严重依赖于应用进程的存活状态。"
            }
        }

    },
    "message": {
        "msg_content": "自定义消息内容003"
    }
}

```

##集成错误码

名称|Code|Commen
---|---|--- 
UNKNOWN_ERROR|-1|未知错误
SUCCESS|200|成功
SYSTEM_ERROR|1001|系统错误
SYSTEM_BUSY|1003|服务器忙
PARAMETER_ERROR|1005|参数错误，请参考API文档
INVALID_SIGN|1006|签名认证失败
INVALID_APPLICATION_ID|110000|appId不合法
INVALID_APPLICATION_KEY|110001|appKey不合法
UNSUBSCRIBE_PUSHID|110002|pushId未注册
INVALID_PUSHID|110003|pushId非法
PARAM_BLANK|110004|参数不能为空
APP_IN_BLACK_LIST|110009|应用被加入黑名单
APP_REQUEST_EXCEED_LIMIT|110010|应用请求频率过快
APP_PUSH_TIME_EXCEED_LIMIT|110051|超过该应用的次数限制
APP_REQUEST_PUSH_LIMIT|110019|超过该应用每天推送次数限制
INVALID_APPLICATION_PACKAGENAME|110031|packageName不合法
INVALID_TASK_ID|110032|非法的taskId
INVALID_APPLICATION_SECRET|110033|非法的appSecret

## MeizuPush SDK的编译混淆问题

如果使用了 proguard，需要在配置文件中加入,可以防止一个误报的 warning 导致无法成功编译，

	-dontwarn com.meizu.cloud.**
	-keep class com.meizu.cloud.** { *; }
	
## 点击通知跳转 Activity   

### 支持的版本   

此功能从 JPush Android SDK 4.2.0 开始支持

### 通知跳转的定义   

Meizu push 允许开发者在推送通知的时候传入自定义的 intent uri 字符串，当用户点击了该通知，系统会根据 uri 的值过滤出匹配的 Activity ，并打开 Activity，达到跳转的目的。

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
rom_type| byte|通过此key获取到下发通知的平台。得到值说明：byte类型的整数，0为极光，1为小米，2为华为，3为魅族，4为 OPPO，5为vivo，6为asus，7为Honor,8为FCM。

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
***注：*** 422版本开始，通过中转Activity实现点击行为的上报和统计，对第三方厂商通道的通知点击事件上报接口（JPushInterface.reportNotificationOpened）过期。
***注：*** 点击上报必须传入正确的 whichPushSDK 参数，否则会造成统计数据错误。

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