import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';

enum ProfilesSort {
  lastUpdate,
  name;

  String present(TranslationsEn t) {
    return switch (this) {
      lastUpdate => t.profile.sortBy.lastUpdate,
      name => t.profile.sortBy.name,
    };
  }

  IconData get icon => switch (this) {
        lastUpdate => Icons.history_rounded,
        name => Icons.sort_by_alpha_rounded,
      };
}

enum SortMode { ascending, descending }
