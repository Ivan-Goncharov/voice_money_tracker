import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Modern bottom sheet for date selection
class DateSelectionBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelectionBottomSheet({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelectionBottomSheet> createState() => _DateSelectionBottomSheetState();
}

class _DateSelectionBottomSheetState extends State<DateSelectionBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.textLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Select Date',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          // Quick date options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _QuickDateButton(
                    label: 'Today',
                    date: DateTime.now(),
                    isSelected: _isSameDay(_selectedDate, DateTime.now()),
                    onTap: () => _selectDate(DateTime.now()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickDateButton(
                    label: 'Yesterday',
                    date: DateTime.now().subtract(const Duration(days: 1)),
                    isSelected: _isSameDay(_selectedDate, DateTime.now().subtract(const Duration(days: 1))),
                    onTap: () => _selectDate(DateTime.now().subtract(const Duration(days: 1))),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  _getMonthYearString(_displayedMonth),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    foregroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildCalendar(),
          ),

          const SizedBox(height: 24),

          // Confirm button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_selectedDate);
                  Navigator.of(context).pop();
                },
                style: AppTheme.primaryButtonStyle,
                child: Text(
                  'Select ${_getFormattedDate(_selectedDate)}',
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }

              final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final isFuture = date.isAfter(DateTime.now());

              return Expanded(
                child: GestureDetector(
                  onTap: isFuture ? null : () => _selectDate(date),
                  child: Container(
                    height: 48,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : isToday
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.textLight
                              : isFuture
                                  ? AppTheme.textSecondary.withOpacity(0.5)
                                  : isToday
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textPrimary,
                          fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateButton({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryBlue,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppTheme.textLight : AppTheme.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
