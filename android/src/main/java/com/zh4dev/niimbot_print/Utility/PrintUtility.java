package com.zh4dev.niimbot_print.Utility;

import android.app.Application;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;

import com.gengcon.www.jcprintersdk.JCPrintApi;
import com.gengcon.www.jcprintersdk.callback.Callback;
import com.gengcon.www.jcprintersdk.callback.PrintCallback;
import com.zh4dev.niimbot_print.Constant.KeyConstant;
import com.zh4dev.niimbot_print.Constant.MessageConstant;
import com.zh4dev.niimbot_print.Helper.LocalDataHelper;
import com.zh4dev.niimbot_print.Model.PrintLabelModel;
import com.zh4dev.niimbot_print.Model.LabelLayoutModel;
import com.zh4dev.niimbot_print.Model.PrintQrCodeModel;
import com.zh4dev.niimbot_print.Model.PrintElementModel;
import com.zh4dev.niimbot_print.Model.PrinterConfigurationModel;

import java.nio.charset.StandardCharsets;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodChannel;

public class PrintUtility {

    private static final String TAG = "PrintUtility";
    private static final int LABEL_WIDTH_MM = 50;
    private static final int LABEL_HEIGHT_MM = 30;
    private static final int QR_CODE_TYPE = 31;

    private final Application application;
    private final LocalDataHelper localDataHelper;
    private static final AtomicBoolean PRINT_IN_PROGRESS = new AtomicBoolean(false);

    private static JCPrintApi api;

    public PrintUtility(Context context) {
        application = (Application) context.getApplicationContext();
        localDataHelper = new LocalDataHelper(context);
    }

    private static final Callback CALLBACK = new Callback() {
        @Override
        public void onConnectSuccess(String name, int status) {
        }

        @Override
        public void onDisConnect() {
        }

        @Override
        public void onElectricityChange(int electricity) {
        }

        @Override
        public void onCoverStatus(int status) {
        }

        @Override
        public void onPaperStatus(int status) {
        }

        @Override
        public void onRfidReadStatus(int status) {
        }

        @Override
        public void onRibbonStatus(int status) {
        }

        @Override
        public void onRibbonRfidReadStatus(int status) {
        }

        @Override
        public void onFirmErrors() {
        }
    };

    private void ensureApi() {
        synchronized (PrintUtility.class) {
            if (api == null) {
                api = JCPrintApi.getInstance(CALLBACK);
                api.initSdk(application);
            }
        }
    }

    public int openPrinter(String address) {
        ensureApi();
        return api.connectBluetoothPrinter(address);
    }

    public void close() {
        ensureApi();
        api.close();
    }

    public int connectionStatus() {
        ensureApi();
        return api.isConnection();
    }

    public void printLabel(
            List<PrintLabelModel> models,
            LabelLayoutModel layout,
            @NonNull MethodChannel.Result result
    ) {
        startPrint(result, () -> {
            float canvasWidth = layout.getCanvasWidth();
            float canvasHeight = layout.getCanvasHeight();
            float padding = (float) Math.max(layout.padding, 0.0);
            float availableWidth = Math.max(canvasWidth - padding * 2.0F, 1.0F);
            float availableHeight = Math.max(canvasHeight - padding * 2.0F, 1.0F);
            api.drawEmptyLabel(canvasWidth, canvasHeight, layout.getRotation(), "");

            float maxBoxHeight = availableHeight / Math.max(models.size(), 1);
            float[] fontSizes = new float[models.size()];
            float[] boxHeights = new float[models.size()];
            float contentHeight = 0.0F;
            float sharedAutoFontSize = resolveSharedAutoFontSize(
                    models,
                    availableWidth,
                    maxBoxHeight
            );
            for (int i = 0; i < models.size(); i++) {
                PrintLabelModel model = models.get(i);
                float fontSize = model.isAutoFit()
                        ? (float) (sharedAutoFontSize + model.getFontSizeOffset())
                        : (float) Math.max(model.getFontSize(), 1.0);
                int lines = estimatedLineCount(model, fontSize, availableWidth);
                float height = Math.min(maxBoxHeight, Math.max(fontSize / 4.5F * 1.35F * lines, 2.0F));
                fontSizes[i] = fontSize;
                boxHeights[i] = height;
                contentHeight += height;
            }
            float currentY;
            if ("start".equals(layout.verticalAlignment)) {
                currentY = padding;
            } else if ("end".equals(layout.verticalAlignment)) {
                currentY = canvasHeight - padding - contentHeight;
            } else {
                currentY = (canvasHeight - contentHeight) / 2.0F;
            }

            for (int i = 0; i < models.size(); i++) {
                PrintLabelModel model = models.get(i);
                api.drawLabelText(
                        padding,
                        currentY,
                        availableWidth,
                        boxHeights[i],
                        model.getText(),
                        model.getFontFamily(),
                        fontSizes[i] / 4.5F,
                        0,
                        layout.getHorizontalAlignment(),
                        1,
                        6,
                        0,
                        1,
                        model.getFontStyles()
                );
                currentY += boxHeights[i];
            }
            return createPrintData(canvasWidth, canvasHeight, layout.getRotation());
        });
    }

    public void printElements(
            List<String> values,
            LabelLayoutModel layout,
            @NonNull MethodChannel.Result result
    ) {
        startPrint(result, () -> renderElements(values, layout));
    }

    public void generatePreview(
            List<String> values,
            LabelLayoutModel layout,
            @NonNull MethodChannel.Result result
    ) {
        try {
            ensureApi();
            PrintData data = renderElements(values, layout);
            Bitmap bitmap = api.generatePreviewImage(data.labelJson, data.printInfoJson);
            if (bitmap == null) {
                result.error(KeyConstant.errorPrint, "Unable to generate print preview", null);
                return;
            }
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, output);
            result.success(output.toByteArray());
        } catch (Exception error) {
            Log.e(TAG, "Unable to generate print preview", error);
            result.error(KeyConstant.errorPrint, error.getMessage(), null);
        }
    }

    private PrintData renderElements(List<String> values, LabelLayoutModel layout) {
        List<PrintElementModel> elements = new ArrayList<>();
        boolean textFlowOnly = true;
        for (String value : values) {
            PrintElementModel element = new PrintElementModel(value);
            elements.add(element);
            if (!"text".equals(element.type()) || element.hasFrame()) textFlowOnly = false;
        }
        if (textFlowOnly) {
            List<PrintLabelModel> models = new ArrayList<>();
            for (PrintElementModel element : elements) {
                models.add(new PrintLabelModel().fromMap(element.source()));
            }
            return renderTextFlow(models, layout);
        }

        float canvasWidth = layout.getCanvasWidth();
        float canvasHeight = layout.getCanvasHeight();
        float padding = (float) Math.max(layout.padding, 0.0);
        api.drawEmptyLabel(canvasWidth, canvasHeight, layout.getRotation(), "");
        for (PrintElementModel element : elements) {
            PrintElementModel.ResolvedFrame frame =
                    element.resolveFrame(canvasWidth, canvasHeight, padding);
            switch (element.type()) {
                case "text": {
                    PrintLabelModel text = new PrintLabelModel().fromMap(element.source());
                    float fontSize = text.isAutoFit()
                            ? resolveElementFontSize(text, frame.width, frame.height)
                            : (float) Math.max(text.getFontSize(), 1.0);
                    api.drawLabelText(
                            frame.x, frame.y, frame.width, frame.height,
                            text.getText(), text.getFontFamily(), fontSize / 4.5F,
                            element.integer("rotation", 0), 1, 1, 6, 0, 1,
                            text.getFontStyles()
                    );
                    break;
                }
                case "qrCode":
                    api.drawLabelQrCode(
                            frame.x, frame.y, frame.width, frame.height,
                            element.string("data", ""), element.integer("codeType", 31),
                            element.integer("rotation", 0)
                    );
                    break;
                case "barcode":
                    api.drawLabelBarCode(
                            frame.x, frame.y, frame.width, frame.height,
                            element.integer("barcodeType", 20), element.string("data", ""),
                            element.number("fontSize", 3), element.integer("rotation", 0),
                            element.number("textHeight", 3), element.integer("textPosition", 0)
                    );
                    break;
                case "line":
                    api.drawLabelLine(
                            frame.x, frame.y, frame.width, frame.height,
                            element.integer("rotation", 0), element.integer("lineType", 1),
                            element.numbers("dashWidth", new float[]{1, 1})
                    );
                    break;
                case "image":
                    api.drawLabelImage(
                            element.string("imageData", ""), frame.x, frame.y,
                            frame.width, frame.height, element.integer("rotation", 0),
                            element.integer("processingType", 1), element.number("threshold", 127)
                    );
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported print element: " + element.type());
            }
        }
        return createPrintData(canvasWidth, canvasHeight, layout.getRotation());
    }

    private PrintData renderTextFlow(List<PrintLabelModel> models, LabelLayoutModel layout) {
        float canvasWidth = layout.getCanvasWidth();
        float canvasHeight = layout.getCanvasHeight();
        float padding = (float) Math.max(layout.padding, 0.0);
        float availableWidth = Math.max(canvasWidth - padding * 2.0F, 1.0F);
        float availableHeight = Math.max(canvasHeight - padding * 2.0F, 1.0F);
        api.drawEmptyLabel(canvasWidth, canvasHeight, layout.getRotation(), "");
        float maxBoxHeight = availableHeight / Math.max(models.size(), 1);
        float[] fontSizes = new float[models.size()];
        float[] boxHeights = new float[models.size()];
        float contentHeight = 0.0F;
        float sharedAutoFontSize = resolveSharedAutoFontSize(models, availableWidth, maxBoxHeight);
        for (int i = 0; i < models.size(); i++) {
            PrintLabelModel model = models.get(i);
            float fontSize = model.isAutoFit()
                    ? (float) (sharedAutoFontSize + model.getFontSizeOffset())
                    : (float) Math.max(model.getFontSize(), 1.0);
            int lines = estimatedLineCount(model, fontSize, availableWidth);
            float height = Math.min(maxBoxHeight, Math.max(fontSize / 4.5F * 1.35F * lines, 2.0F));
            fontSizes[i] = fontSize;
            boxHeights[i] = height;
            contentHeight += height;
        }
        float currentY = "start".equals(layout.verticalAlignment)
                ? padding
                : ("end".equals(layout.verticalAlignment)
                ? canvasHeight - padding - contentHeight
                : (canvasHeight - contentHeight) / 2.0F);
        for (int i = 0; i < models.size(); i++) {
            PrintLabelModel model = models.get(i);
            api.drawLabelText(padding, currentY, availableWidth, boxHeights[i], model.getText(),
                    model.getFontFamily(), fontSizes[i] / 4.5F, 0,
                    layout.getHorizontalAlignment(), 1, 6, 0, 1, model.getFontStyles());
            currentY += boxHeights[i];
        }
        return createPrintData(canvasWidth, canvasHeight, layout.getRotation());
    }

    private float resolveElementFontSize(PrintLabelModel model, float width, float height) {
        float candidate = (float) model.getMaxFontSize();
        float minimum = (float) model.getMinFontSize();
        while (candidate > minimum && !textFits(model, candidate, width, height)) candidate -= 0.5F;
        if (!textFits(model, Math.max(candidate, minimum), width, height)) {
            throw new IllegalArgumentException("Text does not fit within its frame");
        }
        return Math.max(candidate, minimum);
    }

    private float resolveSharedAutoFontSize(
            List<PrintLabelModel> models,
            float widthMm,
            float heightMm
    ) {
        float minimumBase = 1.0F;
        float maximumBase = Float.MAX_VALUE;
        boolean hasAutoFit = false;
        for (PrintLabelModel model : models) {
            if (!model.isAutoFit()) continue;
            hasAutoFit = true;
            minimumBase = Math.max(
                    minimumBase,
                    (float) (model.getMinFontSize() - model.getFontSizeOffset())
            );
            maximumBase = Math.min(
                    maximumBase,
                    (float) (model.getMaxFontSize() - model.getFontSizeOffset())
            );
        }
        if (!hasAutoFit) return 0.0F;
        if (maximumBase < minimumBase) maximumBase = minimumBase;

        float candidate = maximumBase;
        while (candidate > minimumBase &&
                !allAutoTextFits(models, candidate, widthMm, heightMm)) {
            candidate -= 0.5F;
        }
        if (!allAutoTextFits(models, minimumBase, widthMm, heightMm)) {
            throw new IllegalArgumentException(
                    "Text does not fit within the label at the minimum font size"
            );
        }
        return Math.max(candidate, minimumBase);
    }

    private boolean allAutoTextFits(
            List<PrintLabelModel> models,
            float baseFontSize,
            float widthMm,
            float heightMm
    ) {
        for (PrintLabelModel model : models) {
            if (!model.isAutoFit()) continue;
            float fontSize = (float) (baseFontSize + model.getFontSizeOffset());
            if (fontSize < model.getMinFontSize() ||
                    fontSize > model.getMaxFontSize() ||
                    !textFits(model, fontSize, widthMm, heightMm)) {
                return false;
            }
        }
        return true;
    }

    private boolean textFits(PrintLabelModel model, float fontSize, float widthMm, float heightMm) {
        int lines = estimatedLineCount(model, fontSize, widthMm);
        float fontMm = fontSize / 4.5F;
        return lines <= model.getMaxLines() && fontMm * 1.35F * lines <= heightMm;
    }

    private int estimatedLineCount(PrintLabelModel model, float fontSize, float widthMm) {
        String[] explicitLines = model.getText().split("\\r?\\n", -1);
        float fontMm = fontSize / 4.5F;
        int lineCount = 0;
        for (String line : explicitLines) {
            double weightedCharacters = 0.0;
            for (int offset = 0; offset < line.length();) {
                int codePoint = line.codePointAt(offset);
                weightedCharacters += codePoint > 0x7f ? 1.0 : 0.58;
                offset += Character.charCount(codePoint);
            }
            float estimatedWidth = (float) weightedCharacters * fontMm;
            lineCount += Math.max(1, (int) Math.ceil(estimatedWidth / Math.max(widthMm, 1.0F)));
        }
        return lineCount;
    }

    public void printQrCode(
            PrintQrCodeModel qrCode,
            @NonNull MethodChannel.Result result
    ) {
        startPrint(result, () -> {
            float size = (float) qrCode.getSize();
            float x = (LABEL_WIDTH_MM - size) / 2.0F;
            float y = (LABEL_HEIGHT_MM - size) / 2.0F;
            api.drawEmptyLabel(LABEL_WIDTH_MM, LABEL_HEIGHT_MM, 0, "");
            api.drawLabelQrCode(
                    x,
                    y,
                    size,
                    size,
                    qrCode.getData(),
                    QR_CODE_TYPE,
                    0
            );
            return createPrintData(LABEL_WIDTH_MM, LABEL_HEIGHT_MM, 0);
        });
    }

    private void startPrint(
            @NonNull MethodChannel.Result result,
            LabelRenderer renderer
    ) {
        if (connectionStatus() != 0) {
            result.error(KeyConstant.errorPrint, MessageConstant.printerNotConnected, null);
            return;
        }
        if (!PRINT_IN_PROGRESS.compareAndSet(false, true)) {
            result.error(KeyConstant.errorPrint, "Another print job is in progress", null);
            return;
        }

        AtomicBoolean completed = new AtomicBoolean(false);
        PrinterConfigurationModel configuration = localDataHelper.getPrinterModel();
        api.setTotalPrintQuantity(1);
        api.startPrintJob(
                configuration.printDensity,
                1,
                configuration.printModel,
                new PrintCallback() {
                    private boolean dataCommitted;

                    @Override
                    public void onProgress(
                            int pageIndex,
                            int quantityIndex,
                            HashMap<String, Object> details
                    ) {
                        if (pageIndex == 1 && quantityIndex == 1) {
                            boolean ended = api.endPrintJob();
                            complete(result, completed, ended, MessageConstant.endPrintingFailed);
                        }
                    }

                    @Override
                    public void onError(int errorCode) {
                        complete(result, completed, false, printError(errorCode));
                    }

                    @Override
                    public void onError(int errorCode, int printState) {
                        complete(result, completed, false, printError(errorCode));
                    }

                    @Override
                    public void onCancelJob(boolean success) {
                        complete(result, completed, false, "Print job was cancelled");
                    }

                    @Override
                    public void onPause(boolean success) {
                        Log.d(TAG, "Print pause completed: " + success);
                    }

                    @Override
                    public void onPausing() {
                        Log.d(TAG, "Print job is pausing");
                    }

                    @Override
                    public void onResume(boolean success) {
                        Log.d(TAG, "Print resume completed: " + success);
                    }

                    @Override
                    public void onBufferFree(int pageIndex, int bufferSize) {
                        if (completed.get() || dataCommitted || bufferSize < 1) {
                            return;
                        }
                        try {
                            PrintData data = renderer.render();
                            api.commitData(
                                    Collections.singletonList(data.labelJson),
                                    Collections.singletonList(data.printInfoJson)
                            );
                            dataCommitted = true;
                        } catch (Exception error) {
                            Log.e(TAG, "Unable to prepare print data", error);
                            complete(result, completed, false, error.getMessage());
                        }
                    }
                }
        );
    }

    private PrintData createPrintData(float width, float height, int orientation) {
        String labelJson = new String(api.generateLabelJson(), StandardCharsets.UTF_8);
        float multiple = localDataHelper.getPrinterModel().printMultiple;
        String printInfoJson = "{\"printerImageProcessingInfo\":{" +
                "\"orientation\":" + orientation + "," +
                "\"margin\":[0,0,0,0]," +
                "\"printQuantity\":1," +
                "\"horizontalOffset\":0," +
                "\"verticalOffset\":0," +
                "\"width\":" + width + "," +
                "\"height\":" + height + "," +
                "\"printMultiple\":" + multiple + "," +
                "\"epc\":\"\"}}";
        return new PrintData(labelJson, printInfoJson);
    }

    private void complete(
            MethodChannel.Result result,
            AtomicBoolean completed,
            boolean success,
            String errorMessage
    ) {
        if (!completed.compareAndSet(false, true)) {
            return;
        }
        PRINT_IN_PROGRESS.set(false);
        if (success) {
            result.success(true);
        } else {
            result.error(KeyConstant.errorPrint, errorMessage, null);
        }
    }

    private String printError(int code) {
        switch (code) {
            case 1:
                return "Lid open";
            case 2:
                return "Out of paper";
            case 3:
                return "Not enough power";
            case 4:
                return "Battery abnormality";
            case 5:
                return "Manual stop";
            case 6:
                return "Data error";
            case 7:
                return "Temperature is too high";
            case 8:
                return "Paper ejection abnormality";
            case 9:
                return "Printer is busy";
            case 10:
                return "No printhead detected";
            case 11:
                return "Ambient temperature is too low";
            case 12:
                return "The print head is not locked";
            case 13:
                return "Ribbon not detected";
            case 14:
                return "Mismatched ribbon";
            case 15:
                return "Ribbon is used up";
            case 16:
                return "Unsupported paper type";
            case 17:
                return "Paper type setting failed";
            case 18:
                return "Print mode setting failed";
            case 19:
                return "Failed to set density";
            case 20:
                return "Failed to write RFID";
            case 21:
                return "Margin setting failed";
            case 22:
                return "Communication error";
            case 23:
                return "Printer disconnected";
            case 24:
                return "Artboard parameter error";
            case 25:
                return "Wrong rotation angle";
            case 26:
                return "JSON parameter error";
            case 27:
                return "Paper ejection abnormality (B3S)";
            case 28:
                return "Check paper type";
            case 29:
                return "RFID tag is not writable";
            case 30:
                return "Density setting is not supported";
            case 31:
                return "Unsupported print mode";
            default:
                return "Unknown print error (" + code + ")";
        }
    }

    private interface LabelRenderer {
        PrintData render();
    }

    private static class PrintData {
        final String labelJson;
        final String printInfoJson;

        PrintData(String labelJson, String printInfoJson) {
            this.labelJson = labelJson;
            this.printInfoJson = printInfoJson;
        }
    }
}
