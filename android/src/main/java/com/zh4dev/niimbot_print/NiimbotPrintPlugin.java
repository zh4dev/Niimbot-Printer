package com.zh4dev.niimbot_print;

import android.content.Context;
import android.os.Build;
import androidx.annotation.NonNull;
import com.zh4dev.niimbot_print.Constant.PluginConstant;
import com.zh4dev.niimbot_print.Helper.PrintHelper;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NiimbotPrintPlugin */
public class NiimbotPrintPlugin implements FlutterPlugin, MethodCallHandler {

  private MethodChannel channel;
  private PrintHelper printHelper;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Context mContext = flutterPluginBinding.getApplicationContext();
    printHelper = new PrintHelper(mContext);
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), PluginConstant.niimbotPrint);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String callMethod = call.method;
    switch (callMethod) {
      case PluginConstant.onStartScan:
        printHelper.onStartScan(call, result);
        break;
      case PluginConstant.onStartConnect:
        printHelper.onStartConnect(call, result);
        break;
      case PluginConstant.onStartPrint:
        printHelper.onStartPrint(call, result);
        break;
      case PluginConstant.generatePreview:
        printHelper.generatePreview(call, result);
        break;
      case PluginConstant.onDisconnect:
        printHelper.onDisconnect(result);
        break;
      case PluginConstant.isConnected:
        printHelper.isConnected(result);
        break;
      case PluginConstant.getAndroidSdkInt:
        result.success(Build.VERSION.SDK_INT);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    printHelper.dispose();
    printHelper = null;
    channel = null;
  }
}
