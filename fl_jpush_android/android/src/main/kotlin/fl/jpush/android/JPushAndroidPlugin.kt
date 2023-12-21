package fl.jpush.android

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** JPushAndroidPlugin */
class JPushAndroidPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(plugin.binaryMessenger, "fl_jpush_android")
        channel.setMethodCallHandler(this)
        context = plugin.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
