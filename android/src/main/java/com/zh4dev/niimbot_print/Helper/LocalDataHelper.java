package com.zh4dev.niimbot_print.Helper;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.annotation.NonNull;
import com.zh4dev.niimbot_print.Constant.LocalDataConstant;
import com.zh4dev.niimbot_print.Model.PrinterConfigurationModel;

public class LocalDataHelper {

    private final SharedPreferences preferences;

    public LocalDataHelper(Context mContext) {
        preferences = mContext.getSharedPreferences(LocalDataConstant.printConfiguration, Context.MODE_PRIVATE);
    }

    public void setPrinterModel(@NonNull String printerName) {
        SharedPreferences.Editor editor = preferences.edit();
        PrinterConfigurationModel model;
        if (printerName.matches("^(B32|Z401|B50|T6|T7|T8).*")) {
            model = new PrinterConfigurationModel(
                    2, 8, 11.81F
            );
        } else {
            model = new PrinterConfigurationModel(
                    1, 3, 8
            );
        }
        editor.putString(LocalDataConstant.printConfiguration, model.toMap());
        editor.apply();
    }

    public PrinterConfigurationModel getPrinterModel() {
        String json = preferences.getString(LocalDataConstant.printConfiguration, "");
        PrinterConfigurationModel model = new PrinterConfigurationModel(
                1, 3, 8.0f
        );
        if (!json.isEmpty()) {
            return model.fromMap(json);
        }
        return model;
    }

}
