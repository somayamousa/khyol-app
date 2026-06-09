import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final int centerId;
  final Map<String, dynamic> package;
  const BookingScreen({super.key, required this.centerId, required this.package});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesCtrl = TextEditingController();
  bool _booking = false;

  final List<String> _timeSlots = [
    '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00',
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
            surface: AppColors.bg2,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('اختر تاريخ الحجز', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('اختر وقت الحجز', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _booking = true);
    final res = await CenterService.book({
      'center_id': widget.centerId,
      'package_id': widget.package['id'],
      'booking_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'booking_time': _selectedTime,
      'notes': _notesCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _booking = false);

    final messenger = ScaffoldMessenger.of(context);
    if (res.success) {
      messenger.showSnackBar(const SnackBar(
        content: Text('تم الحجز بنجاح ✅', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.success,
      ));
      Navigator.pop(context);
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text(res.message ?? 'فشل الحجز', style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(widget.package['price']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(title: const Text('تأكيد الحجز')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ملخص الباقة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الباقة المختارة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text(widget.package['title'] ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  if (widget.package['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(widget.package['description'], style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 8),
                  Text('${price.toInt()} ₪', style: const TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // اختيار التاريخ
            const Text('تاريخ الحجز', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedDate != null ? AppColors.gold : AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.gold, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDate!)
                          : 'اختر تاريخاً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: _selectedDate != null ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // اختيار الوقت
            const Text('وقت الحجز', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((t) {
                final selected = _selectedTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.gold : AppColors.bg2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selected ? AppColors.gold : AppColors.border),
                    ),
                    child: Text(t,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.bg1 : AppColors.textSecondary,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // ملاحظات
            const Text('ملاحظات (اختياري)', style: TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'أي طلبات أو ملاحظات خاصة...'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _booking ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _booking
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                    : const Text('تأكيد الحجز 📅', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
