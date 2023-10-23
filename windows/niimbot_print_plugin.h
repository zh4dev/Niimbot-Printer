#ifndef FLUTTER_PLUGIN_NIIMBOT_PRINT_PLUGIN_H_
#define FLUTTER_PLUGIN_NIIMBOT_PRINT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace niimbot_print {

class NiimbotPrintPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  NiimbotPrintPlugin();

  virtual ~NiimbotPrintPlugin();

  // Disallow copy and assign.
  NiimbotPrintPlugin(const NiimbotPrintPlugin&) = delete;
  NiimbotPrintPlugin& operator=(const NiimbotPrintPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace niimbot_print

#endif  // FLUTTER_PLUGIN_NIIMBOT_PRINT_PLUGIN_H_
