import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';

const _cities = [
  'القدس', 'رام الله', 'نابلس', 'الخليل', 'بيت لحم',
  'جنين', 'طولكرم', 'قلقيلية', 'أريحا', 'سلفيت',
  'طوباس', 'غزة', 'رفح', 'خان يونس', 'دير البلح',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _city;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          phone: _phoneCtrl.text.trim(),
          city: _city,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AuthProvider>().error ?? 'فشل إنشاء الحساب'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text('🐎', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 8),
              const Text('إنشاء حساب جديد',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('انضم لمجتمع عشاق الخيول',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field(_nameCtrl, 'الاسم الكامل', Icons.person_outline, validator: (v) => v == null || v.length < 2 ? 'أدخل اسمك' : null),
                      const SizedBox(height: 14),
                      _field(_emailCtrl, 'البريد الإلكتروني', Icons.email_outlined,
                          inputType: TextInputType.emailAddress, ltr: true,
                          validator: (v) => v == null || !v.contains('@') ? 'بريد غير صالح' : null),
                      const SizedBox(height: 14),
                      _field(_phoneCtrl, 'رقم الهاتف', Icons.phone_outlined,
                          inputType: TextInputType.phone, ltr: true,
                          validator: (v) => v == null || v.length < 9 ? 'أدخل رقم صالح' : null),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gold),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textMuted),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6 ? 'على الأقل 6 أحرف' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _city,
                        decoration: const InputDecoration(
                          labelText: 'المدينة (اختياري)',
                          prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.gold),
                        ),
                        dropdownColor: AppColors.bg3,
                        items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                        onChanged: (v) => setState(() => _city = v),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          child: auth.loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.bg1, strokeWidth: 2))
                              : const Text('إنشاء الحساب'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('تسجيل الدخول', style: TextStyle(color: AppColors.gold, fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? inputType, bool ltr = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.gold),
      ),
      validator: validator,
    );
  }
}
