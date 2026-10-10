import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// A time option model representing practice duration.
class CalcupTimeOption {
  final int seconds;
  final String topLabel;
  final String displayValue;
  final String label;

  const CalcupTimeOption({
    required this.seconds,
    required this.topLabel,
    required this.displayValue,
    required this.label,
  });
}

/// Calendar-inspired time selector with smooth sliding animation,
/// elongated pill capsules, inverted triangle pointer, and red highlighted selection.
class CalendarTimeSelector extends StatefulWidget {
  final int selectedSeconds;
  final ValueChanged<int> onTimeChanged;
  final List<CalcupTimeOption>? options;

  const CalendarTimeSelector({
    Key? key,
    required this.selectedSeconds,
    required this.onTimeChanged,
    this.options,
  }) : super(key: key);

  static const List<CalcupTimeOption> defaultOptions = [
    CalcupTimeOption(
      seconds: 3,
      topLabel: '3s',
      displayValue: '3',
      label: '3 Seconds • Instant Flash',
    ),
    CalcupTimeOption(
      seconds: 5,
      topLabel: '5s',
      displayValue: '5',
      label: '5 Seconds • Ultra Speed',
    ),
    CalcupTimeOption(
      seconds: 10,
      topLabel: '10s',
      displayValue: '10',
      label: '10 Seconds • Quick Blitz',
    ),
    CalcupTimeOption(
      seconds: 15,
      topLabel: '15s',
      displayValue: '15',
      label: '15 Seconds • Blitz',
    ),
    CalcupTimeOption(
      seconds: 30,
      topLabel: '30s',
      displayValue: '30',
      label: '30 Seconds • Rapid',
    ),
    CalcupTimeOption(
      seconds: 45,
      topLabel: '45s',
      displayValue: '45',
      label: '45 Seconds • Speed',
    ),
    CalcupTimeOption(
      seconds: 60,
      topLabel: '60s',
      displayValue: '60',
      label: '60 Seconds • 1 Minute',
    ),
    CalcupTimeOption(
      seconds: 90,
      topLabel: '90s',
      displayValue: '90',
      label: '90 Seconds • 1.5 Mins',
    ),
    CalcupTimeOption(
      seconds: 120,
      topLabel: '2m',
      displayValue: '120',
      label: '120 Seconds • 2 Minutes',
    ),
    CalcupTimeOption(
      seconds: 180,
      topLabel: '3m',
      displayValue: '180',
      label: '180 Seconds • 3 Minutes',
    ),
    CalcupTimeOption(
      seconds: 240,
      topLabel: '4m',
      displayValue: '240',
      label: '240 Seconds • 4 Minutes',
    ),
    CalcupTimeOption(
      seconds: 300,
      topLabel: '5m',
      displayValue: '300',
      label: '300 Seconds • 5 Minutes',
    ),
  ];

  @override
  State<CalendarTimeSelector> createState() => _CalendarTimeSelectorState();
}

class _CalendarTimeSelectorState extends State<CalendarTimeSelector> {
  late final ScrollController _scrollController;
  final GlobalKey _containerKey = GlobalKey();
  final Map<int, GlobalKey> _itemKeys = {};

  List<CalcupTimeOption> get _options =>
      widget.options ?? CalendarTimeSelector.defaultOptions;

  static const double _itemWidth = 56.0;
  static const double _itemSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (int i = 0; i < _options.length; i++) {
      _itemKeys[i] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveIndex(animated: false);
    });
  }

  @override
  void didUpdateWidget(covariant CalendarTimeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSeconds != widget.selectedSeconds) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveIndex(animated: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int get _selectedIndex {
    final idx = _options.indexWhere((opt) => opt.seconds == widget.selectedSeconds);
    return idx >= 0 ? idx : 0;
  }

  void _scrollToActiveIndex({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final targetIndex = _selectedIndex;
    final viewportWidth = _scrollController.position.viewportDimension;
    final totalItemWidth = _itemWidth + _itemSpacing;

    // Center the target item in the scrollable view
    final targetOffset = (targetIndex * totalItemWidth + _itemWidth / 2) - (viewportWidth / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animated) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
    final option = _options[index];
    widget.onTimeChanged(option.seconds);
    _scrollToActiveIndex(animated: true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _options[_selectedIndex];

    return Container(
      key: _containerKey,
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active label badge (smooth feedback)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey<int>(selectedOption.seconds),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          selectedOption.label,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Sliding Picker List
          SizedBox(
            height: 148,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _options.length,
              separatorBuilder: (context, index) => const SizedBox(width: _itemSpacing),
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = index == _selectedIndex;

                return _CalendarTimeItem(
                  key: _itemKeys[index],
                  option: option,
                  isSelected: isSelected,
                  onTap: () => _onItemTapped(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// An individual item in the calendar-inspired time selector
class _CalendarTimeItem extends StatelessWidget {
  final CalcupTimeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarTimeItem({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Inverted Black Triangle Pointer (visible only on active selection)
          SizedBox(
            height: 10,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: isSelected ? 1.0 : 0.0,
              child: CustomPaint(
                size: const Size(10, 7),
                painter: _InvertedTrianglePainter(color: const Color(0xFF1E2022)),
              ),
            ),
          ),
          const SizedBox(height: 3),

          // Top label (e.g. 15s, 30s, 1m)
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF1E2022) : const Color(0xFFA0A5B1),
              letterSpacing: 0.3,
            ),
            child: Text(option.topLabel),
          ),
          const SizedBox(height: 8),

          // Elongated Capsule Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 54,
            height: isSelected ? 96 : 90,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(27),
              border: Border.all(
                color: isSelected
                    ? Colors.black.withOpacity(0.04)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 1.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFE53935)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.transparent,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.4,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(0.40),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.nunitoSans(
                        fontSize: option.displayValue.length > 2 ? 15 : 18,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                      ),
                      child: Text(option.displayValue),
                    ),
                  ),
                ),
                // Smooth rounded lower pill body (matches image design)
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the inverted downward-pointing triangle indicator
class _InvertedTrianglePainter extends CustomPainter {
  final Color color;

  const _InvertedTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InvertedTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
