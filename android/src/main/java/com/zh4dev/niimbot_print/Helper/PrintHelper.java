package com.zh4dev.niimbot_print.Helper;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.common.util.concurrent.ThreadFactoryBuilder;
import com.zh4dev.niimbot_print.Constant.KeyConstant;
import com.zh4dev.niimbot_print.Constant.MessageConstant;
import com.zh4dev.niimbot_print.Constant.PrintConstant;
import com.zh4dev.niimbot_print.Model.BlueDeviceInfoModel;
import com.zh4dev.niimbot_print.Model.PrintLabelModel;
import com.zh4dev.niimbot_print.Utility.PrintUtility;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class PrintHelper {

    private final String TAG = "PrintHelper";
    private final LocalDataHelper localDataHelper;
    private final PrintUtility printUtility;
    private final BluetoothAdapter mBluetoothAdapter;
    private final ExecutorService executorService;
    private final Context mContext;
    List<String> blueDeviceList = new ArrayList<>();

    public PrintHelper(Context mContext) {
        this.mContext = mContext;
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        localDataHelper = new LocalDataHelper(mContext);
        printUtility = new PrintUtility(mContext);
        ThreadFactory threadFactory = new ThreadFactoryBuilder().setNameFormat(PrintConstant.threadNameFormat).build();
        executorService = new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingDeque<>(1024), threadFactory, new ThreadPoolExecutor.AbortPolicy());
        blueDeviceList.clear();
    }

    private void onCheckBluetoothDiscovery() {
        if (mBluetoothAdapter.isDiscovering()) {
            if (mBluetoothAdapter.cancelDiscovery()) {
                mBluetoothAdapter.startDiscovery();
            }
        } else {
            mBluetoothAdapter.startDiscovery();
        }
    }

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                if (device != null) {
                    boolean isSupportBluetoothType = device.getType() == BluetoothDevice.DEVICE_TYPE_CLASSIC
                            || device.getType() == BluetoothDevice.DEVICE_TYPE_DUAL;
                    if (isSupportBluetoothType) {
                        String model = new BlueDeviceInfoModel(
                                device.getName(),
                                device.getAddress(),
                                device.getBondState()
                        ).toMap();
                        Log.d(TAG, "Result: " + model);
                        if (!blueDeviceList.contains(model)) {
                            blueDeviceList.add(model);
                        }
                    }
                }
            }
        }
    };

    public void onDisconnect(@NonNull Result result) {
        if (printUtility.connectionStatus() != 0) {
            result.error(KeyConstant.errorPrint, MessageConstant.printerNotConnected, false);
        } else {
            try {
                executorService.submit(() -> {
                    printUtility.close();
                    result.success(true);
                });
            } catch (Exception e) {
                Log.e(TAG, "onDisconnect: " + e.getMessage());
                result.error(KeyConstant.failedDisconnect, e.getMessage(), false);
            }
        }
    }

    public void onStartScan(@NonNull MethodCall call, @NonNull Result result) {
        int scanDuration = (int) call.arguments;
        onCheckBluetoothDiscovery();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(BluetoothDevice.ACTION_FOUND);
        intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_STARTED);
        intentFilter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        intentFilter.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        intentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        intentFilter.addAction(BluetoothDevice.ACTION_PAIRING_REQUEST);
        mContext.registerReceiver(mReceiver, intentFilter);
        new Handler().postDelayed(() -> executorService.submit(() -> {
            onCheckBluetoothDiscovery();
            mContext.unregisterReceiver(mReceiver);
            result.success(blueDeviceList);
        }), scanDuration);

    }

    public void onStartConnect(@NonNull MethodCall call, @NonNull Result result) {
        String arguments = call.arguments.toString();
        onCheckBluetoothDiscovery();
        BlueDeviceInfoModel blueDeviceInfoModel = new BlueDeviceInfoModel(
                "",
                "",
                PrintConstant.NO_BOND
        ).fromMap(arguments);
        BluetoothDevice bluetoothDevice = mBluetoothAdapter.getRemoteDevice(
                blueDeviceInfoModel.getDeviceHardwareAddress()
        );
        Log.d(TAG, "Connection State: " + blueDeviceInfoModel.getConnectionState());
        switch (blueDeviceInfoModel.getConnectionState()) {
            case PrintConstant.NO_BOND -> executorService.submit(() -> {
                try {
                    boolean isSuccessPairing = bluetoothDevice.createBond();
                    Log.d(TAG, "Pairing Result: " + isSuccessPairing);
                    if (isSuccessPairing) {
                        onConnectPrinter(result, bluetoothDevice);
                    } else {
                        result.error(KeyConstant.failedPairing, MessageConstant.failedPairing, false);
                    }
                } catch (Exception e) {
                    String message = MessageConstant.connectionFailed + ": " + e.getMessage();
                    result.error(KeyConstant.connectionFailed, message, false);
                    Log.e(TAG, message);
                }
            });
            case PrintConstant.BONDED ->
                    executorService.submit(() -> onConnectPrinter(result, bluetoothDevice));
            default -> {
            }
        }
    }

    private void onConnectPrinter(@NonNull Result result, BluetoothDevice bluetoothDevice) {
        localDataHelper.setPrinterModel(bluetoothDevice.getName());
        int connectionResult = printUtility.openPrinter(bluetoothDevice.getAddress());
        switch (connectionResult) {
            case 0: {
                result.success(KeyConstant.connectionSuccess);
            }
            case -1: {
                result.error(KeyConstant.connectionFailed, MessageConstant.connectionFailed, false);
            }
            default: {
                result.error(KeyConstant.unsupportedModels, MessageConstant.unsupportedModels, false);
            }
        }
    }

    public void onStartPrintText(@NonNull MethodCall call, @NonNull Result result) {
        List<String> stringList = (List<String>) call.arguments;
        List<PrintLabelModel> printLabelModels = new ArrayList<>();
        if (!stringList.isEmpty()) {
            for (int i = 0; i < stringList.size(); i++) {
                printLabelModels.add(new PrintLabelModel().fromMap(stringList.get(i)));
                if (i == stringList.size() - 1) {
                    printUtility.printLabel(printLabelModels, result);
                }
            }
        } else {
            result.error(KeyConstant.emptyText, MessageConstant.pleaseInputText, false);
        }
    }


}
