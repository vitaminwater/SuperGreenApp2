package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import net.petleo.flutter_matomo.FlutterMatomoPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterMatomoPlugin.registerWith(registry.registrarFor("net.petleo.flutter_matomo.FlutterMatomoPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
