import 'package:flutter/material.dart';
import './icon_list.dart' show iconDataMap;

/// Method to transform icon name to camel case
String _camelize(String text) {
  String newString = text.replaceAllMapped(RegExp(r'[-_\s.]+(.)?'),
          (Match match) => match.group(1)?.toUpperCase() ?? '');
  return newString.substring(0, 1).toLowerCase() + newString.substring(1);
}

/// Main class to transform a text to icon data
class IconConverter {

  static final IconConverter _iconConverter = IconConverter._internal();

  factory IconConverter() {
    return _iconConverter;
  }

  IconConverter._internal();

  /// Method to transform a text to icon data
  static IconData? stringToIcon(String iconName) {
    String iconNameTransformed = _camelize(iconName.replaceAll('mdi', ''));
    return iconDataMap[iconNameTransformed];
  }

  /// Method to transform icon data to a text
  static String iconToString(IconData iconData) {
    String iconName = iconData.toString();
    String iconNameTransformed = iconName.substring(8, iconName.length - 1);
    return 'mdi-$iconNameTransformed';
  }
}