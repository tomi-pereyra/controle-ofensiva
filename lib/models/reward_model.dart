import 'package:flutter/material.dart';

class RewardModel {
  final String id;
  final String title;
  final int targetDays;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;

  RewardModel({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
  });

  static const List<IconData> availableIcons = [
    Icons.card_giftcard_rounded,
    Icons.restaurant_rounded,
    Icons.sports_esports_rounded,
    Icons.movie_rounded,
    Icons.shopping_bag_rounded,
    Icons.coffee_rounded,
    Icons.flight_takeoff_rounded,
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.star_rounded,
    Icons.beach_access_rounded,
    Icons.headphones_rounded,
  ];

  IconData get iconData {
    for (final icon in availableIcons) {
      if (icon.codePoint == iconCodePoint) {
        return icon;
      }
    }
    return Icons.card_giftcard_rounded;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'iconFontPackage': iconFontPackage,
    };
  }

  factory RewardModel.fromMap(Map<String, dynamic> map) {
    return RewardModel(
      id: map['id'] as String,
      title: map['title'] as String,
      targetDays: map['targetDays'] as int,
      iconCodePoint: map['iconCodePoint'] as int,
      iconFontFamily: map['iconFontFamily'] as String?,
      iconFontPackage: map['iconFontPackage'] as String?,
    );
  }
}
