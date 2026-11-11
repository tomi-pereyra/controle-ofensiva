import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String title;
  final String description;
  final int requiredDays;
  final IconData icon;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredDays,
    required this.icon,
  });

  /// Catálogo padrão de insígnias pré-definidas
  static const List<BadgeModel> defaultBadges = [
    BadgeModel(
      id: 'badge_3',
      title: 'Faísca Inicial',
      description: 'Mantenha 3 dias consecutivos',
      requiredDays: 3,
      icon: Icons.local_fire_department_rounded,
    ),
    BadgeModel(
      id: 'badge_7',
      title: 'Uma Semana Firme',
      description: 'Conquiste 7 dias seguidos de foco',
      requiredDays: 7,
      icon: Icons.bolt_rounded,
    ),
    BadgeModel(
      id: 'badge_14',
      title: 'Hábito em Construção',
      description: 'Alcance 14 dias de consistência',
      requiredDays: 14,
      icon: Icons.shield_rounded,
    ),
    BadgeModel(
      id: 'badge_30',
      title: 'Mestre do Mês',
      description: 'Complete 30 dias de ofensiva ininterrupta',
      requiredDays: 30,
      icon: Icons.emoji_events_rounded,
    ),
    BadgeModel(
      id: 'badge_60',
      title: 'Inabalável',
      description: 'Supere 60 dias de disciplina diária',
      requiredDays: 60,
      icon: Icons.military_tech_rounded,
    ),
    BadgeModel(
      id: 'badge_100',
      title: 'Centenário Lendário',
      description: 'Atingiu a épica marca de 100 dias',
      requiredDays: 100,
      icon: Icons.workspace_premium_rounded,
    ),
    BadgeModel(
      id: 'badge_365',
      title: 'Lenda Anual',
      description: '1 ano inteiro sem falhar um único dia',
      requiredDays: 365,
      icon: Icons.diamond_rounded,
    ),
  ];
}
