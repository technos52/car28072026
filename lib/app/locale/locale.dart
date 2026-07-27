import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:subol/core/locale/arabic.dart';

// import 'english.dart';

class AppLanguage {
  AppLanguage(
      {required this.name,
      required this.values,
      required this.flagImage,
      required this.locale,
      required this.shortName});
  final String name;
  final Map<String, String> values;
  final String flagImage;
  final Locale locale;
  final String shortName;
}

class LocalizationService extends Translations {
  // Default locale
  static final locale = languagesSupported.first.locale;

  // fallbackLocale saves the day when the locale gets in trouble
  static final fallbackLocale = languagesSupported.length > 1 ? languagesSupported[1].locale : locale;

  // Supported locales
  // Needs to be same order with langs
  static final List<AppLanguage> languagesSupported = [
    // AppLanguage(
    //     name: "English",
    //     values: english(),
    //     flagImage: 'assets/flags/us.png',
    //     locale: const Locale('en'),
    //     shortName: "Eng"),
    // AppLanguage(
    //     name: "Arabic",
    //     values: arabic(),
    //     flagImage: 'assets/flags/eg.png',
    //     locale: const Locale('ar'),
    //     shortName: "Arb"),
  ];

  static get locales => languagesSupported.map((e) => e.locale).toList();

  // Keys and their translations
  // Translations are separated maps in `translations` folder
  @override
  Map<String, Map<String, String>> get keys =>
      languagesSupported.asMap().map((key, value) => MapEntry(value.locale.toString(), value.values));
}

extension TranslateText on String {
  Map<String, String>? get getSimilarLanguageTranslation {
    final translationsWithNoCountry = Get.translations.map((key, value) => MapEntry(key.split("_").first, value));
    final containsKey = translationsWithNoCountry.containsKey(Get.locale?.languageCode.split("_").first);

    if (!containsKey) {
      return null;
    }

    return translationsWithNoCountry[Get.locale?.languageCode.split("_").first];
  }

  String get translate {
    // Translating the text using custom extension
    if (Get.locale?.languageCode == null) return this;

    bool fullLocaleAndKey = Get.translations.containsKey("${Get.locale?.languageCode}_${Get.locale?.countryCode}") &&
        Get.translations["${Get.locale?.languageCode}_${Get.locale?.countryCode}"]!.containsKey(this);

    if (fullLocaleAndKey) {
      return Get.translations["${Get.locale?.languageCode}_${Get.locale?.countryCode}"]![this]!;
    }
    final similarTranslation = getSimilarLanguageTranslation;
    if (similarTranslation != null && similarTranslation.containsKey(this)) {
      return similarTranslation[this]!;
      // If there is no corresponding language or corresponding key, return
      // the key.
    } else if (Get.fallbackLocale != null) {
      final fallback = Get.fallbackLocale!;
      final key = "${fallback.languageCode}_${fallback.countryCode}";

      if (Get.translations.containsKey(key) && Get.translations[key]!.containsKey(this)) {
        return Get.translations[key]![this]!;
      }
      if (Get.translations.containsKey(fallback.languageCode) &&
          Get.translations[fallback.languageCode]!.containsKey(this)) {
        return Get.translations[fallback.languageCode]![this]!;
      }
      return hardcoded;
    } else {
      return hardcoded;
    }
  }

  String get hardcoded {
    // Used for showing hardcoded text in the app
    return kDebugMode ? "$this📌" : this;
  }
}
