import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State for locale management.
class L10nState extends Equatable {
  /// The current locale.
  final Locale locale;

  const L10nState({
    required this.locale,
  });

  /// Initial state with default locale.
  factory L10nState.initial() {
    return const L10nState(locale: Locale('en', ''));
  }

  /// Copy with method for immutable updates.
  L10nState copyWith({
    Locale? locale,
  }) {
    return L10nState(
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [locale];
}

