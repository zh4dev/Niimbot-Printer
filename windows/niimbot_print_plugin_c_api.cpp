#include "include/niimbot_print/niimbot_print_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "niimbot_print_plugin.h"

void NiimbotPrintPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  niimbot_print::NiimbotPrintPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
