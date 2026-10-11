import 'package:flutter/material.dart';

class CategoryMetadata {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const CategoryMetadata({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class AppConstants {
  static const String appName = 'CALCUP';
  static const String tagline = 'Think Fast. Calculate Faster.';
  
  static const int defaultWrongAnswerThreshold = 3;
  static const int maxWrongAnswerThreshold = 10;
  
  static const List<String> categories = [
    'Arithmetic',
    'Random Calculations',
    'BODMAS Challenge',
    'Number Series',
    'Inequalities',
    'Mental Maths',
    'Missing Number',
    'Number Puzzles',
    'Mixed Practice',
    'Custom Practice',
  ];

  static const Map<String, CategoryMetadata> categoryDetails = {
    'Arithmetic': CategoryMetadata(
      title: 'Arithmetic',
      description: 'Master addition, subtraction, multiplication & division',
      icon: Icons.calculate_rounded,
      color: Color(0xFFA7BFFF), // Pastel Blue
    ),
    'Random Calculations': CategoryMetadata(
      title: 'Random Calculations',
      description: 'Rapid-fire squares, percentages & multi-step calculations',
      icon: Icons.shuffle_rounded,
      color: Color(0xFFBCE8A3), // Pastel Green
    ),
    'BODMAS Challenge': CategoryMetadata(
      title: 'BODMAS Challenge',
      description: 'Order of operations with brackets & operator precedence',
      icon: Icons.functions_rounded,
      color: Color(0xFFFFB7B0), // Pastel Pink
    ),
    'Number Series': CategoryMetadata(
      title: 'Number Series',
      description: 'Identify number patterns, arithmetic steps & sequence rules',
      icon: Icons.format_list_numbered_rounded,
      color: Color(0xFFD6B8FF), // Pastel Purple
    ),
    'Inequalities': CategoryMetadata(
      title: 'Inequalities',
      description: 'Compare expressions & determine relative relationships',
      icon: Icons.compare_arrows_rounded,
      color: Color(0xFFFFC928), // Highlight Yellow
    ),
    'Mental Maths': CategoryMetadata(
      title: 'Mental Maths',
      description: 'Flash sequence calculation without pencil and paper',
      icon: Icons.psychology_rounded,
      color: Color(0xFFA7BFFF), // Pastel Blue
    ),
    'Missing Number': CategoryMetadata(
      title: 'Missing Number',
      description: 'Deduce unknown operands, equation values & sequence terms',
      icon: Icons.help_outline_rounded,
      color: Color(0xFFBCE8A3), // Pastel Green
    ),
    'Number Puzzles': CategoryMetadata(
      title: 'Number Puzzles',
      description: 'Solve tricky algebraic rules, operators & number logic',
      icon: Icons.extension_rounded,
      color: Color(0xFFFFB7B0), // Pastel Pink
    ),
    'Mixed Practice': CategoryMetadata(
      title: 'Mixed Practice',
      description: 'Multi-category speed drill for competitive exam readiness',
      icon: Icons.category_rounded,
      color: Color(0xFFD6B8FF), // Pastel Purple
    ),
    'Custom Practice': CategoryMetadata(
      title: 'Custom Practice',
      description: 'Tailor operations, difficulty & save reusable presets',
      icon: Icons.tune_rounded,
      color: Color(0xFFFFC928), // Highlight Yellow
    ),
  };
}
