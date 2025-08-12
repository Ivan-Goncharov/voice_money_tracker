import 'package:flutter_bloc/flutter_bloc.dart';
import 'date_selection_state.dart';

extension DateUtils on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

/// Simple cubit to manage the date selection UI state inside the date bottom sheet.
/// Keeps selectedDate and displayedMonth so the UI can rebuild via BlocBuilder
/// instead of using setState().
class DateSelectionCubit extends Cubit<DateSelectionState> {
  DateSelectionCubit(DateTime initialDate)
      : super(DateSelectionState(
          selectedDate: initialDate,
          displayedMonth: DateTime(initialDate.year, initialDate.month),
        ));

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void changeMonth(int delta) {
    final next = DateTime(state.displayedMonth.year, state.displayedMonth.month + delta);
    emit(state.copyWith(displayedMonth: next));
  }
}