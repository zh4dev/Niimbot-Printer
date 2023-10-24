package com.zh4dev.niimbot_print.Utility;

import androidx.annotation.NonNull;
import android.app.Application;
import android.content.Context;
import android.util.Log;
import com.gengcon.www.jcprintersdk.JCPrintApi;
import com.gengcon.www.jcprintersdk.callback.Callback;
import com.gengcon.www.jcprintersdk.callback.PrintCallback;
import com.zh4dev.niimbot_print.Constant.KeyConstant;
import com.zh4dev.niimbot_print.Constant.MessageConstant;
import com.zh4dev.niimbot_print.Helper.LocalDataHelper;
import com.zh4dev.niimbot_print.Model.PrintLabelModel;
import com.zh4dev.niimbot_print.Model.PrinterConfigurationModel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import io.flutter.plugin.common.MethodChannel;

public class PrintUtility {

    private final String TAG = this.getClass().getSimpleName();
    private final Context mContext;
    private final PrinterConfigurationModel model;

    public PrintUtility(Context mContext) {
        this.mContext = mContext;
        LocalDataHelper localDataHelper = new LocalDataHelper(mContext);
        model = localDataHelper.getPrinterModel();
        initPrint();
        initPrintData();
    }

    private int pageCount;
    private int quantity;
    private boolean isError;
    private boolean isCancel;
    private int[] generatedPrintDataPageCount = {0};
    private ArrayList<String> jsonList;
    private ArrayList<String> infoList;

    private static final Callback CALLBACK = new Callback() {
        @Override
        public void onConnectSuccess(String s) {

        }

        @Override
        public void onDisConnect() {

        }

        @Override
        public void onElectricityChange(int i) {

        }

        @Override
        public void onCoverStatus(int i) {

        }

        @Override
        public void onPaperStatus(int i) {

        }

        @Override
        public void onRfidReadStatus(int i) {

        }

        @Override
        public void onPrinterIsFree(int i) {

        }

        @Override
        public void onHeartDisConnect() {

        }

        @Override
        public void onFirmErrors() {

        }
    };

    private static JCPrintApi api;

    public void getInstance() {
        if (api == null) {
            api = JCPrintApi.getInstance(CALLBACK);
            api.init((Application) mContext);
            api.initImageProcessingDefault("", "");
        }
    }


    public int openPrinter(String address) {
        getInstance();
        return api.openPrinterByAddress(address);
    }

    public void close() {
        getInstance();
        api.close();
    }

    public int connectionStatus() {
        getInstance();
        return api.isConnection();
    }

    private void initPrint() {
        pageCount = 1;
        quantity = 1;
        isError = false;
        isCancel = false;
        generatedPrintDataPageCount = new int[]{0};
    }

    private void initPrintData() {
        jsonList = new ArrayList<>();
        infoList = new ArrayList<>();
    }

    private String catchPrintError(int code) {
        String errorMsg = MessageConstant.errorDefault;
        switch (code) {
            case 1 -> errorMsg = "lid open";
            case 2 -> errorMsg = "Out of paper";
            case 3 -> errorMsg = "Not enough power";
            case 4 -> errorMsg = "Battery abnormality";
            case 5 -> errorMsg = "Manual stop";
            case 6 -> errorMsg = "data error";
            case 7 -> errorMsg = "Temperature is too high";
            case 8 -> errorMsg = "Paper ejection abnormality";
            case 9 -> errorMsg = "Printing";
            case 10 -> errorMsg = "No printhead detected";
            case 11 -> errorMsg = "Ambient temperature is too low";
            case 12 -> errorMsg = "The print head is not locked";
            case 13 -> errorMsg = "Ribbon not detected";
            case 14 -> errorMsg = "Mismatched ribbon";
            case 15 -> errorMsg = "Used up ribbon";
            case 16 -> errorMsg = "Unsupported paper types";
            case 17 -> errorMsg = "Paper type setting failed";
            case 18 -> errorMsg = "Print mode setting failed";
            case 19 -> errorMsg = "Failed to set concentration";
            case 20 -> errorMsg = "Failed to write rfid";
            case 21 -> errorMsg = "Margin setting failed";
            case 22 -> errorMsg = "Communication abnormality";
            case 23 -> errorMsg = "Printer disconnected";
            case 24 -> errorMsg = "Artboard parameter error";
            case 25 -> errorMsg = "Wrong rotation angle";
            case 26 -> errorMsg = "json parameter error";
            case 27 -> errorMsg = "Paper ejection abnormality (B3S)";
            case 28 -> errorMsg = "Check paper type";
            case 29 -> errorMsg = "The RFID tag is not being written to";
            case 30 -> errorMsg = "Density setting is not supported";
            case 31 -> errorMsg = "Unsupported print mode";
            default -> {
            }
        }
        return errorMsg;
    }

    public void printLabel(List<PrintLabelModel> printLabelModels, @NonNull MethodChannel.Result result) {
        if (connectionStatus() != 0) {
            result.error(KeyConstant.errorPrint, MessageConstant.printerNotConnected, false);
            return;
        }
        initPrint();
        initPrintData();
        int totalQuantity = pageCount * quantity;
        api.setTotalQuantityOfPrints(totalQuantity);
        api.startPrintJob(model.printDensity, 1, model.printModel, new PrintCallback() {
            @Override
            public void onProgress(int pageIndex, int quantityIndex, HashMap<String, Object> hashMap) {
                Log.d(TAG, "Test | pageIndex: " + pageIndex + " quantityIndex: " + quantityIndex);
                if (pageIndex == pageCount && quantityIndex == quantity) {
                    Log.d(TAG, "Test | onProgress: End printing");
                    if (api.endJob()) {
                        result.success(true);
                        Log.d(TAG, MessageConstant.endPrintingSuccess);
                    } else {
                        result.error(KeyConstant.errorPrint, MessageConstant.endPrintingFailed, false);
                        Log.d(TAG, MessageConstant.endPrintingFailed);
                    }
                }
            }

            @Override
            public void onError(int i) {
                isError = true;
                result.error(KeyConstant.errorPrint, catchPrintError(i), false);
            }

            @Override
            public void onError(int errorCode, int printState) {
                isError = true;
                result.error(KeyConstant.errorPrint, catchPrintError(errorCode), false);
            }

            @Override
            public void onCancelJob(boolean isSuccess) {
                isCancel = true;
            }

            @Override
            public void onBufferFree(int pageIndex, int bufferSize) {
                Log.d(TAG, "Test: Page data sent: " + pageIndex + ", Cache space:" + bufferSize);
                Log.d(TAG, "Test: Generate sequence: " + generatedPrintDataPageCount[0]);
                Log.d(TAG, "Test: Total number of pages: " + pageCount);
                if ((isError || isCancel) || (pageIndex > pageCount)) {
                    return;
                }
                Log.d(TAG, "Test-idle data callback-data generation judgment-total number of pages" + pageCount + ", Number of pages generated:" + generatedPrintDataPageCount[0] + ", Idle callback data length：" + bufferSize);
                if (generatedPrintDataPageCount[0] < pageCount) {
                    int commitDataLength = Math.min((pageCount - generatedPrintDataPageCount[0]), bufferSize);
                    onStartPrintText(printLabelModels, generatedPrintDataPageCount[0], generatedPrintDataPageCount[0] + commitDataLength);
                    api.commitData(
                            jsonList.subList(generatedPrintDataPageCount[0], generatedPrintDataPageCount[0] + commitDataLength),
                            infoList.subList(generatedPrintDataPageCount[0], generatedPrintDataPageCount[0] + commitDataLength));
                    generatedPrintDataPageCount[0] += commitDataLength;
                }

            }
        });
    }

    private void onStartPrintText(List<PrintLabelModel> printLabelModels, int index, int cycleIndex) {
        while (index < cycleIndex) {
            int orientation = 0;
            int width = 50;
            int height = 30;
            api.drawEmptyLabel(width, height, orientation, "");
            for (int i = 0; i < printLabelModels.size(); i++) {
                PrintLabelModel model = printLabelModels.get(i);
                float marginX = 0;
                float marginY = 0;
                float rectangleWidth = width - marginX * 2;
                float rectangleHeight = height - marginY * 2;
                float lineHeight = rectangleHeight / 5.0F;
                float fontSize = (float) (model.getFontSize() / 4.5);
                api.drawLabelText(
                        marginX,
                        marginY + lineHeight * (i + 1),
                        rectangleWidth,
                        lineHeight,
                        model.getText(),
                        KeyConstant.defaultFontName,
                        fontSize,
                        0, 1, 1, 6, 0, 1,
                        new boolean[]{false, false, false, false}
                );
            }
            onStartCommitData(orientation, width, height);
            index++;
        }
    }

    private void onStartCommitData(int orientation, float width, float height) {
        byte[] jsonByte = api.generateLabelJson();
        String jsonStr = new String(jsonByte);
        jsonList.add(jsonStr);
        String jsonInfo = "{  " +
                "\"printerImageProcessingInfo\": " + "{    " +
                "\"orientation\":" + orientation + "," +
                "   \"margin\": [      0,      0,      0,      0    ], " +
                "   \"printQuantity\": " + quantity + ",  " +
                "  \"horizontalOffset\": 0,  " +
                "  \"verticalOffset\": 0,  " +
                "  \"width\":" + width + "," +
                "   \"height\":" + height + "," +
                "\"printMultiple\":" + model.printMultiple + "," +
                "  \"epc\": \"\"  }}";
        infoList.add(jsonInfo);
    }


}
