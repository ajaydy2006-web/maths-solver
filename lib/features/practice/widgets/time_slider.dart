import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class CalcupTimeSlider extends StatelessWidget {
  final int selectedSeconds;
  final ValueChanged<int> onTimeChanged;

  const CalcupTimeSlider({
    Key? key,
    required this.selectedSeconds,
    required this.onTimeChanged,
  }) : super(key: key);

  static const int minSeconds = 15;
  static const int maxSeconds = 600; // 10 minutes
  static const int stepSeconds = 15;

  static const List<Map<String, dynamic>> quickOptions = [
    {'label': '30s', 'seconds': 30},
    {'label': '1m', 'seconds': 60},
    {'label': '2m', 'seconds': 120},
    {'label': '5m', 'seconds': 300},
    {'label': '10m', 'seconds': 600},
  ];

  String _formatMmSs(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatVerbose(int seconds) {
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    if (m > 0 && s > 0) {
      return '$m min $s sec';
    } else if (m > 0) {
      return '$m min${m > 1 ? 's' : ''}';
    } else {
      return '$s seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clamp to valid range and round to nearest 15-second increment
    final clamped = selectedSeconds.clamp(minSeconds, maxSeconds);
    final sliderVal = (clamped / stepSeconds).round() * stepSeconds;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and MM:SS Display Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primaryOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Practice Duration",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMmSs(sliderVal),
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "(${_formatVerbose(sliderVal)})",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Draggable Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryOrange,
              inactiveTrackColor: const Color(0xFFE5E7EB),
              trackHeight: 8,
              thumbColor: AppColors.primaryOrange,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 13,
                elevation: 4,
              ),
              overlayColor: AppColors.primaryOrange.withOpacity(0.18),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: sliderVal.toDouble(),
              min: minSeconds.toDouble(),
              max: maxSeconds.toDouble(),
              divisions: (maxSeconds - minSeconds) ~/ stepSeconds,
              onChanged: (val) {
                final rounded = (val / stepSeconds).round() * stepSeconds;
                if (rounded != selectedSeconds) {
                  HapticFeedback.selectionClick();
                  onTimeChanged(rounded);
                }
              },
            ),
          ),

          // Slider Range Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("00:15 (Quick)", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text("05:00", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text("10:00 (Marathon)", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Select Buttons
          Row(
            children: [
              const Text(
                "Presets:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: quickOptions.map((opt) {
                      final optSecs = opt['seconds'] as int;
                      final isSelected = sliderVal == optSecs;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(opt['label'] as String),
                          selected: isSelected,
                          selectedColor: AppColors.highlightYellow,
                          backgroundColor: AppColors.backgroundCream,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          onSelected: (val) {
                            if (val) {
                              HapticFeedback.selectionClick();
                              onTimeChanged(optSecs);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
