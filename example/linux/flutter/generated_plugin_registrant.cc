//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <niimbot_print/niimbot_print_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) niimbot_print_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NiimbotPrintPlugin");
  niimbot_print_plugin_register_with_registrar(niimbot_print_registrar);
}
