import 'package:flutter/material.dart';

// opted to do this instead of pulling in a whole dep to do this, esp. since we only
// use a few langs and they're readily available on the main repo.
// Português Brasileiro is defined twice as pt_BR is the "correct" version, but for
// some reason, when we ask for a stream language pt_br is returned - this should
// probably be fixed in GlimeshWeb
const Map<String, String> languages = {
  "en": "English",
  "es": "Español",
  "es_AR": "Español rioplatense",
  "es_MX": "Español mexicano",
  "de": "Deutsch",
  "ja": "日本語",
  "nb": "Norsk Bokmål",
  "nn": "Norsk Nynorsk",
  "fr": "Français",
  "sv": "Svenska",
  "vi": "Tiếng Việt",
  "ru": "Русский",
  "ko": "한국어",
  "it": "Italiano",
  "bg": "български",
  "nl": "Nederlands",
  "fi": "Suomi",
  "pl": "Polski",
  "ro": "Limba Română",
  "pt_br": "Português Brasileiro",
  "pt_BR": "Português Brasileiro",
  "pt": "Português",
  "zh_Hans": "中文 (简体)",
  "zh_Hant": "中文 (繁体)",
  "ar_eg": "العامية المصرية",
  "cs": "čeština",
  "da": "Dansk",
  "hu": "Magyar Nyelv",
  "ga": "Gaeilge",
  "sl": "slovenščina",
  "tr": "Türkçe",
};

const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('cs'),
  Locale('da'),
  Locale('de'),
  Locale('es'),
  Locale('es', 'AR'),
  Locale('es', 'MX'),
  Locale('fr'),
  Locale('hu'),
  Locale('it'),
  Locale('ja'),
  Locale('ko'),
  Locale('nb'),
  Locale('nl'),
  Locale('no'),
  Locale('pl'),
  Locale('pt'),
  Locale('pt', 'BR'),
  Locale('ru'),
  Locale('sv'),
  Locale('tr'),
  Locale('vi'),
  // the two below are broken for some reason, getttext can see them, and the Material
  // translations work, but trying to use them results in English text
  /* Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), */
  /* Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), */
];
