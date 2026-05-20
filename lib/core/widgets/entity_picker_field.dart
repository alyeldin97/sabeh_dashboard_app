import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/app_border.dart';
import '../helpers/responsive.dart';
import '../styling/colors.dart';

class EntityPickerItem {
  final String id;
  final String name;
  const EntityPickerItem({required this.id, required this.name});
}

/// Tap-to-search picker that opens a bottom sheet and integrates with [Form].
class EntityPickerField extends StatefulWidget {
  const EntityPickerField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.fetchItems,
    required this.onSelected,
    this.selectedId,
    this.selectedName,
    this.sheetTitle,
    this.requiredMessage,
  });

  final IconData icon;
  final String placeholder;
  final Future<List<EntityPickerItem>> Function() fetchItems;
  final void Function(EntityPickerItem) onSelected;
  final String? selectedId;
  final String? selectedName;
  final String? sheetTitle;
  final String? requiredMessage;

  @override
  State<EntityPickerField> createState() => _EntityPickerFieldState();
}

class _EntityPickerFieldState extends State<EntityPickerField> {
  Future<void> _open() async {
    final result = await showModalBottomSheet<EntityPickerItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: widget.sheetTitle ?? widget.placeholder,
        fetchItems: widget.fetchItems,
      ),
    );
    if (result != null) widget.onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.selectedId != null;
    return FormField<String>(
      key: ValueKey(widget.selectedId),
      initialValue: widget.selectedId,
      validator: widget.requiredMessage != null
          ? (v) => (v == null || v.isEmpty) ? widget.requiredMessage : null
          : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _open,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppBorderRadius.r12,
                  border: Border.all(
                    color: field.hasError
                        ? AppColors.error
                        : hasValue
                            ? AppColors.primaryMid
                            : AppColors.border,
                    width: hasValue || field.hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(widget.icon,
                      size: 18.r,
                      color: hasValue ? AppColors.primaryMid : AppColors.textLight),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      hasValue
                          ? (widget.selectedName ?? widget.selectedId!)
                          : widget.placeholder,
                      style: GoogleFonts.nunito(
                        fontSize: Responsive.sp(context, 14),
                        color: hasValue ? AppColors.textDark : AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: AppColors.textLight, size: 20.r),
                ]),
              ),
            ),
            if (field.hasError) ...[
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.only(left: 14.w),
                child: Text(
                  field.errorText!,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 11), color: AppColors.error),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({required this.title, required this.fetchItems});
  final String title;
  final Future<List<EntityPickerItem>> Function() fetchItems;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late final Future<List<EntityPickerItem>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = widget.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: AppBorderRadius.full),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(widget.title,
                  style: GoogleFonts.nunito(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textCharcoal)),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                style: GoogleFonts.nunito(
                    fontSize: Responsive.sp(context, 14), color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: GoogleFonts.nunito(color: AppColors.textLight),
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 18.r, color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: AppBorderRadius.r12,
                      borderSide: BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.r12,
                      borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: AppBorderRadius.r12,
                      borderSide:
                          BorderSide(color: AppColors.primaryMid, width: 2)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: FutureBuilder<List<EntityPickerItem>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryDeep));
                  }
                  if (snap.hasError || !snap.hasData) {
                    return Center(
                        child: Text('Failed to load',
                            style:
                                GoogleFonts.nunito(color: AppColors.textLight)));
                  }
                  final items = snap.data!
                      .where((e) => e.name.toLowerCase().contains(_query))
                      .toList();
                  if (items.isEmpty) {
                    return Center(
                        child: Text('No results',
                            style:
                                GoogleFonts.nunito(color: AppColors.textLight)));
                  }
                  return ListView.separated(
                    controller: controller,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.border, height: 1),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        title: Text(item.name,
                            style: GoogleFonts.nunito(
                                fontSize: Responsive.sp(context, 14),
                                color: AppColors.textDark)),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.textLight, size: 18.r),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
