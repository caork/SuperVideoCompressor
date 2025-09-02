#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

int main(int argc, char** argv) {
  // Only present for headless mode.
  gtk_init(&argc, &argv);

  g_autoptr(FlutterEngine) engine = flutter_engine_new();
  g_autoptr(GError) engine_error = flutter_engine_run(engine, argc, argv);
  if (engine_error) {
    g_error("Failed to run Flutter engine: %s", engine_error->message);
    return EXIT_FAILURE;
  }

  g_autoptr(FlutterView) view = flutter_view_new(engine);
  g_autoptr(GError) view_error = flutter_view_run(view);
  if (view_error) {
    g_error("Failed to run Flutter view: %s", view_error->message);
    return EXIT_FAILURE;
  }

  gtk_main();

  return EXIT_SUCCESS;
}