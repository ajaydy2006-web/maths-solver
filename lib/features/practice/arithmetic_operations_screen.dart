import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class ArithmeticOperationInfo {
  final String title;
  final String symbol;
  final String subtitle;
  final Color color;
  final IconData icon;

  const ArithmeticOperationInfo({
    required this.title,
    required this.symbol,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}

class ArithmeticOperationsScreen extends StatefulWidget {
  const ArithmeticOperationsScreen({Key? key}) : super(key: key);

  @override
  State<ArithmeticOperationsScreen> createState() => _ArithmeticOperationsScreenState();
}

class _ArithmeticOperationsScreenState extends State<ArithmeticOperationsScreen> {
  bool _isNavigating = false;

  static const List<ArithmeticOperationInfo> operations = [
    ArithmeticOperationInfo(
      title: 'Addition',
      symbol: '+',
      subtitle: 'Practice sums with custom digits & operand counts',
      color: AppColors.pastelBlue,
      icon: Icons.add_circle_outline_rounded,
    ),
    ArithmeticOperationInfo(
      title: 'Subtraction',
      symbol: '−',
      subtitle: 'Sharpen mental differences & multi-digit borrowing',
      color: AppColors.pastelGreen,
      icon: Icons.remove_circle_outline_rounded,
    ),
    ArithmeticOperationInfo(
      title: 'Multiplication',
      symbol: '×',
      subtitle: 'Speed drills for tables, double digits & products',
      color: AppColors.pastelPink,
      icon: Icons.clear_rounded,
    ),
    ArithmeticOperationInfo(
      title: 'Division',
      symbol: '÷',
      subtitle: 'Clean integer quotients & rapid inverse multiplication',
      color: AppColors.pastelPurple,
      icon: Icons.safety_divider_rounded,
    ),
    ArithmeticOperationInfo(
      title: 'Mixed Operations',
      symbol: '±×÷',
      subtitle: 'Dynamic mix of all four fundamental math operations',
      color: AppColors.highlightYellow,
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  void _onOperationSelected(String operationTitle) {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.selectionClick();

    context.push('/config/Arithmetic?operation=${Uri.encodeComponent(operationTitle)}').then((_) {
      if (mounted) setState(() => _isNavigating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        title: Text("Arithmetic", style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Header Intro Card
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: AppColors.surfacePrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.pastelBlue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.calculate_rounded, color: AppColors.textPrimary, size: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Operation",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Choose an operation to customize digits, operands & timer",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Operation Cards
            ...operations.map((op) => _buildOperationCard(context, op)).toList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, ArithmeticOperationInfo op) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onOperationSelected(op.title),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: op.color.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Symbol Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: op.color,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: op.color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      op.symbol,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        op.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        op.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
