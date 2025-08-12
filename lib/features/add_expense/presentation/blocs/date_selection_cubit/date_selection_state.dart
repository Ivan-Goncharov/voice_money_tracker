import 'package:equatable/equatable.dart';

class DateSelectionState extends Equatable {
  final DateTime selectedDate;
  final DateTime displayedMonth;

  const DateSelectionState({
    required this.selectedDate,
    required this.displayedMonth,
  });

  DateSelectionState copyWith({
    DateTime? selectedDate,
    DateTime? displayedMonth,
  }) {
    return DateSelectionState(
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
    );
  }

  @override
  List<Object?> get props => [selectedDate, displayedMonth];

  @override
  String toString() =>
      'DateSelectionState(selectedDate: $selectedDate, displayedMonth: $displayedMonth)';
}