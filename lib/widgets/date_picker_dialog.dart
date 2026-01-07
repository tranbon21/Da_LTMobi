import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/constants.dart';

/// Widget dialog chọn ngày với TableCalendar.
/// 
/// Hiển thị calendar dialog với styling màu xanh dương,
/// cho phép user chọn một ngày trong khoảng [firstDay, lastDay].
class HotelDatePickerDialog extends StatefulWidget {
  /// Tiêu đề của dialog (vd: "Chọn ngày nhận phòng")
  final String title;
  
  /// Icon hiển thị bên cạnh tiêu đề
  final IconData icon;
  
  /// Ngày đầu tiên có thể chọn
  final DateTime firstDay;
  
  /// Ngày cuối cùng có thể chọn
  final DateTime lastDay;
  
  /// Ngày được focus ban đầu
  final DateTime focusedDay;
  
  /// Ngày được chọn sẵn (optional)
  final DateTime? selectedDay;

  const HotelDatePickerDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    this.selectedDay,
  });

  @override
  State<HotelDatePickerDialog> createState() => _HotelDatePickerDialogState();
}

class _HotelDatePickerDialogState extends State<HotelDatePickerDialog> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        width: 330,
        constraints: const BoxConstraints(maxHeight: 450),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: TableCalendar(
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              focusedDay: _selectedDate ?? widget.focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDate = selected;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedDate != null) {
              Navigator.pop(context, _selectedDate);
            }
          },
          child: const Text('Chọn'),
        ),
      ],
    );
  }
}
