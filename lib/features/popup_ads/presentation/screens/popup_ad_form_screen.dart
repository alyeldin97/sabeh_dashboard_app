import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/helpers/app_border.dart';
import '../../../../core/styling/colors.dart';
import '../../../../core/styling/text_styles.dart';
import 'package:sabeh_dashboard_app/l10n/app_localizations.dart';
import '../../data/model/popup_ad_model.dart';
import '../cubits/popup_ads_cubit.dart';

class PopupAdFormScreen extends StatefulWidget {
  const PopupAdFormScreen({super.key, this.ad});
  final PopupAdModel? ad;

  @override
  State<PopupAdFormScreen> createState() => _PopupAdFormScreenState();
}

class _PopupAdFormScreenState extends State<PopupAdFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _btnText;
  late final TextEditingController _btnUrl;
  late final TextEditingController _imageUrl;
  late bool _isActive;
  late PopupDisplayFrequency _frequency;
  DateTime? _startsAt;
  DateTime? _endsAt;
  DateTime? _countdownEndsAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final ad = widget.ad;
    _title     = TextEditingController(text: ad?.title ?? '');
    _body      = TextEditingController(text: ad?.bodyText ?? '');
    _btnText   = TextEditingController(text: ad?.buttonText ?? '');
    _btnUrl    = TextEditingController(text: ad?.buttonUrl ?? '');
    _imageUrl  = TextEditingController(text: ad?.imageUrl ?? '');
    _isActive  = ad?.isActive ?? true;
    _frequency = ad?.displayFrequency ?? PopupDisplayFrequency.everySession;
    _startsAt         = ad?.startsAt;
    _endsAt           = ad?.endsAt;
    _countdownEndsAt  = ad?.countdownEndsAt;
  }

  @override
  void dispose() {
    _title.dispose(); _body.dispose(); _btnText.dispose();
    _btnUrl.dispose(); _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null || !mounted) return;

    dev.log('[PopupAds] upload → picked file: ${file.name}', name: 'PopupAds');
    setState(() => _saving = true);
    try {
      final bytes = await file.readAsBytes();
      // imageQuality always re-encodes to JPEG regardless of source format (incl. AVIF)
      final path = 'popup_ads/${DateTime.now().millisecondsSinceEpoch}.jpg';
      dev.log('[PopupAds] upload → uploading to bucket app-assets/$path', name: 'PopupAds');
      await Supabase.instance.client.storage
          .from('app-assets')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: false, contentType: 'image/jpeg'));
      final url = Supabase.instance.client.storage.from('app-assets').getPublicUrl(path);
      dev.log('[PopupAds] upload → success, url=$url', name: 'PopupAds');
      setState(() => _imageUrl.text = url);
    } catch (e, st) {
      dev.log('[PopupAds] upload → ERROR: $e', name: 'PopupAds', error: e, stackTrace: st);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.popupAdFormUploadFailed(e.toString())), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = {
      'title':             _title.text.trim(),
      'image_url':         _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      'body_text':         _body.text.trim().isEmpty     ? null : _body.text.trim(),
      'button_text':       _btnText.text.trim().isEmpty  ? null : _btnText.text.trim(),
      'button_url':        _btnUrl.text.trim().isEmpty   ? null : _btnUrl.text.trim(),
      'is_active':           _isActive,
      'starts_at':           _startsAt?.toIso8601String(),
      'ends_at':             _endsAt?.toIso8601String(),
      'countdown_ends_at':   _countdownEndsAt?.toIso8601String(),
      'display_frequency':   _frequency.toDbValue(),
    };
    dev.log('[PopupAds] save → data=$data', name: 'PopupAds');
    final cubit = context.read<PopupAdsCubit>();
    try {
      if (widget.ad != null) {
        await cubit.update(id: widget.ad!.id, data: data);
      } else {
        await cubit.create(data: data);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.ad != null;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(isEdit ? l10n.popupAdFormEditTitle : l10n.popupAdFormNewTitle,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12, top: 8.h, bottom: 8.h),
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.r8),
                elevation: 0,
              ),
              child: _saving
                  ? SizedBox(width: 18.r, height: 18.r, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.popupAdFormSave),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            _section(l10n.popupAdFormBasicInfo),
            SizedBox(height: 10.h),
            TextFormField(
              controller: _title,
              decoration: _deco(l10n.popupAdFormTitleField),
              validator: (v) => v == null || v.trim().isEmpty ? l10n.popupAdFormTitleRequired : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _body,
              decoration: _deco(l10n.popupAdFormBody),
              maxLines: 3,
            ),
            SizedBox(height: 20.h),

            _section(l10n.popupAdFormImage),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _imageUrl,
                    decoration: _deco(l10n.popupAdFormImageUrl),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _pickAndUploadImage,
                  icon: const Icon(Icons.upload),
                  label: Text(l10n.popupAdFormUpload),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMid,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            _section(l10n.popupAdFormButton),
            SizedBox(height: 10.h),
            TextFormField(controller: _btnText, decoration: _deco(l10n.popupAdFormButtonLabel)),
            SizedBox(height: 12.h),
            TextFormField(controller: _btnUrl, decoration: _deco(l10n.popupAdFormButtonUrl)),
            SizedBox(height: 20.h),

            _section(l10n.popupAdFormSchedule),
            SizedBox(height: 10.h),
            _DateField(
              label: l10n.popupAdFormStartDate,
              value: _startsAt,
              onPicked: (d) => setState(() => _startsAt = d),
              onCleared: () => setState(() => _startsAt = null),
            ),
            SizedBox(height: 12.h),
            _DateField(
              label: l10n.popupAdFormEndDate,
              value: _endsAt,
              onPicked: (d) => setState(() => _endsAt = d),
              onCleared: () => setState(() => _endsAt = null),
            ),
            SizedBox(height: 20.h),

            _section(l10n.popupAdFormCountdown),
            SizedBox(height: 10.h),
            _DateTimeField(
              label: l10n.popupAdFormCountdownAt,
              value: _countdownEndsAt,
              onPicked: (dt) => setState(() => _countdownEndsAt = dt),
              onCleared: () => setState(() => _countdownEndsAt = null),
            ),
            SizedBox(height: 20.h),

            _section(l10n.popupAdFormFrequency),
            SizedBox(height: 10.h),
            _FrequencySelector(
              value: _frequency,
              onChanged: (f) => setState(() => _frequency = f),
              l10n: l10n,
            ),
            SizedBox(height: 20.h),

            Row(
              children: [
                Text(l10n.popupAdFormActive, style: AppTextStyles.body(context)),
                const Spacer(),
                Switch(
                  value: _isActive,
                  activeColor: AppColors.primaryDeep,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Text(
        label,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textLight),
      );

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppBorderRadius.r12, borderSide: BorderSide(color: AppColors.primaryMid, width: 2)),
      );
}

class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.value, required this.onChanged, required this.l10n});
  final PopupDisplayFrequency value;
  final ValueChanged<PopupDisplayFrequency> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final options = [
      (PopupDisplayFrequency.everySession, l10n.popupAdFreqEverySession, Icons.repeat_rounded),
      (PopupDisplayFrequency.oncePerDay,   l10n.popupAdFreqOncePerDay,   Icons.today_rounded),
      (PopupDisplayFrequency.onceEver,     l10n.popupAdFreqOnceEver,     Icons.looks_one_rounded),
    ];
    return Column(
      children: options.map((opt) {
        final (freq, label, icon) = opt;
        final selected = value == freq;
        return GestureDetector(
          onTap: () => onChanged(freq),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12.h),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryMist : AppColors.white,
              borderRadius: AppBorderRadius.r12,
              border: Border.all(
                color: selected ? AppColors.primaryDeep : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.r, color: selected ? AppColors.primaryDeep : AppColors.textLight),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primaryDeep : AppColors.textCharcoal,
                    ),
                  ),
                ),
                if (selected) Icon(Icons.check_circle_rounded, size: 20.r, color: AppColors.primaryDeep),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, this.value, required this.onPicked, required this.onCleared});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final VoidCallback onCleared;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (d != null) onPicked(d);
      },
      borderRadius: AppBorderRadius.r12,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: AppBorderRadius.r12,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 16.r, color: AppColors.textLight),
            SizedBox(width: 8.w),
            Text(
              value != null ? '${value!.year}-${value!.month.toString().padLeft(2,'0')}-${value!.day.toString().padLeft(2,'0')}' : label,
              style: TextStyle(color: value != null ? AppColors.textCharcoal : AppColors.textLight),
            ),
            const Spacer(),
            if (value != null)
              GestureDetector(
                onTap: onCleared,
                child: Icon(Icons.clear, size: 16.r, color: AppColors.textLight),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.label, this.value, required this.onPicked, required this.onCleared});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final VoidCallback onCleared;

  String _format(DateTime dt) {
    final date = '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
    final time = '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return '$date  $time';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (d == null) return;
        final t = await showTimePicker(
          context: context,
          initialTime: value != null ? TimeOfDay.fromDateTime(value!) : TimeOfDay.now(),
        );
        if (t == null) return;
        onPicked(DateTime(d.year, d.month, d.day, t.hour, t.minute));
      },
      borderRadius: AppBorderRadius.r12,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: AppBorderRadius.r12,
        ),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, size: 16.r, color: AppColors.textLight),
            SizedBox(width: 8.w),
            Text(
              value != null ? _format(value!) : label,
              style: TextStyle(color: value != null ? AppColors.textCharcoal : AppColors.textLight),
            ),
            const Spacer(),
            if (value != null)
              GestureDetector(
                onTap: onCleared,
                child: Icon(Icons.clear, size: 16.r, color: AppColors.textLight),
              ),
          ],
        ),
      ),
    );
  }
}
