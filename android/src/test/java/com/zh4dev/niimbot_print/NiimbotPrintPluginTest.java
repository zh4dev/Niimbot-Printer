package com.zh4dev.niimbot_print;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import android.os.Build;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import org.junit.Test;

/**
 * Unit tests for the Android method channel implementation.
 */

public class NiimbotPrintPluginTest {
  @Test
  public void onMethodCall_getAndroidSdkInt_returnsExpectedValue() {
    NiimbotPrintPlugin plugin = new NiimbotPrintPlugin();

    final MethodCall call = new MethodCall("getAndroidSdkInt", null);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    plugin.onMethodCall(call, mockResult);

    verify(mockResult).success(Build.VERSION.SDK_INT);
  }

  @Test
  public void onMethodCall_unknownMethod_returnsNotImplemented() {
    NiimbotPrintPlugin plugin = new NiimbotPrintPlugin();
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);

    plugin.onMethodCall(new MethodCall("unknown", null), mockResult);

    verify(mockResult).notImplemented();
  }
}
