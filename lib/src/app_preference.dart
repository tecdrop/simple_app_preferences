// Copyright (c) 2018-2024 Tecdrop (https://www.tecdrop.com/). All rights reserved.
// Use of this source code is governed by a user license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

/// An app preference of type [T] that can be loaded and saved to persistent storage.
///
/// The [T] type must be one of the types supported by [SharedPreferences] (bool, int, double,
/// String, or List<String>), otherwise an exception is thrown.
///
/// The [SharedPreferences] instance used to load and save the value of this app preference is
/// assigned when calling [loadValue], so this method must be called before saving the value to
/// persistent storage (using the [saveValue] method or using the [value] setter when the
/// [saveOnSet] property is set to true).
class AppPreference<T> {
  /// Creates a new app preference with the specified [defaultValue].
  AppPreference({
    required T defaultValue,
    required this.key,
    this.saveOnSet = true,
  }) {
    _value = defaultValue;
  }

  /// The key used to identify this preference in persistent storage.
  final String key;

  /// Whether to save the value to persistent storage when it is set.
  final bool saveOnSet;

  /// The [SharedPreferences] instance used to load and save the value of this app preference.
  SharedPreferences? _prefs;

  /// The current value of this app preference.
  late T _value;

  /// Getters and setters for the current value of this app preference.
  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    if (saveOnSet) saveValue();
  }

  /// Loads the value of this app preference from persistent storage.
  ///
  /// This method must be called before saving the value to persistent storage, in order to assign
  /// the [SharedPreferences] instance that will be used to save the value.
  void loadValue(SharedPreferences prefs) {
    _prefs = prefs;
    _value = _getValue<T>(_prefs, key, _value);
  }

  /// Saves the value of this app preference to persistent storage in the background.
  Future<bool?> saveValue() async {
    return await _setValue<T>(_prefs, key, _value);
  }
}

/// An app preference of type [T] that can be loaded and saved to persistent storage.
///
/// [T] can be any type as long as a [valueLoader] and [valueSaver] are provided to convert the
/// value to and from the [S] type that is supported by [SharedPreferences].
///
/// The [SharedPreferences] instance used to load and save the value of this app preference is
/// assigned when calling [loadValue], so this method must be called before saving the value to
/// persistent storage (using the [saveValue] method or using the [value] setter when the
/// [saveOnSet] property is set to true).
class AppPreferenceEx<T, S> extends AppPreference<T> {
  AppPreferenceEx({
    required super.defaultValue,
    required super.key,
    super.saveOnSet,
    required this.valueSaver,
    required this.valueLoader,
  });

  /// A function that converts a value of the [S] type supported by [SharedPreferences] to the
  /// actual [T] type of this app preference.
  ///
  /// This function is used when loading the value from persistent storage.
  final T Function(S value) valueLoader;

  /// A function that converts a value of the actual [T] type of this app preference to the [S]
  /// type supported by [SharedPreferences].
  ///
  /// This function is used when saving the value to persistent storage.
  final S Function(T value) valueSaver;

  /// Loads the value of this app preference from persistent storage.
  ///
  /// The value is read from persistent storage as the [S] type supported by [SharedPreferences]
  /// and then converted to the actual type [T] of this app preference using the [valueLoader]
  /// method.
  @override
  void loadValue(SharedPreferences prefs) {
    _prefs = prefs;
    _value = valueLoader(_getValue<S>(_prefs, key, valueSaver(_value)));
  }

  /// Saves the value of this app preference to persistent storage in the background.
  ///
  /// The value is converted from the actual type [T] of this app preference to the [S] type
  /// supported by [SharedPreferences] using the [valueSaver] method and then saved to persistent
  /// storage.
  @override
  Future<bool?> saveValue() async {
    return await _setValue<S>(_prefs, key, valueSaver(_value));
  }
}

/// Reads a value of the specified type from persistent storage.
///
/// The [T] type must be one of the types supported by [SharedPreferences] (bool, int, double,
/// String, or List<String>), otherwise an exception is thrown.
///
/// If the value is not found, the default value is returned. If the value is found but is not of
/// the specified type, an exception is thrown.
T _getValue<T>(SharedPreferences? prefs, String key, T defaultValue) {
  switch (T) {
    case const (bool):
      return (prefs?.getBool(key) ?? defaultValue) as T;
    case const (int):
      return (prefs?.getInt(key) ?? defaultValue) as T;
    case const (double):
      return (prefs?.getDouble(key) ?? defaultValue) as T;
    case const (String):
      return (prefs?.getString(key) ?? defaultValue) as T;
    case const (List<String>):
      return (prefs?.getStringList(key) ?? defaultValue) as T;
    default:
      throw Exception('Unsupported type: $T');
  }
}

/// Saves a value of the specified type to persistent storage in the background.
///
/// The [T] type must be one of the types supported by [SharedPreferences] (bool, int, double,
/// String, or List<String>), otherwise an exception is thrown.
Future<bool>? _setValue<T>(SharedPreferences? prefs, String key, T value) {
  switch (T) {
    case const (bool):
      return prefs?.setBool(key, value as bool);
    case const (int):
      return prefs?.setInt(key, value as int);
    case const (double):
      return prefs?.setDouble(key, value as double);
    case const (String):
      return prefs?.setString(key, value as String);
    case const (List<String>):
      return prefs?.setStringList(key, value as List<String>);
    default:
      throw Exception('Unsupported type: $T');
  }
}
