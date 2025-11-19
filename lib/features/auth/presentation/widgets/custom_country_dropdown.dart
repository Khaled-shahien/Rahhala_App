import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rahhala_app/core/theme/app_theme.dart';

class CustomCountryDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const CustomCountryDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<CustomCountryDropdown> createState() => _CustomCountryDropdownState();
}

class _CustomCountryDropdownState extends State<CustomCountryDropdown> {
  late TextEditingController _searchController;
  late List<String> _filteredItems;

  Color _borderColor = const Color(0xFFCDCDCD);
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _updateBorderColor(widget.value);
  }

  @override
  void didUpdateWidget(covariant CustomCountryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateBorderColor(widget.value);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateBorderColor(String? value) {
    final error = widget.validator?.call(value);
    setState(() {
      _errorText = error;
      if (error != null && error.isNotEmpty) {
        _borderColor = Colors.red; 
      } else if (value != null && value.isNotEmpty) {
        _borderColor = Colors.green; 
      } else {
        _borderColor = const Color(0xFFCDCDCD); 
      }
    });
  }

  void _openCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4.h,
                width: 40.w,
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _filteredItems = widget.items
                        .where((item) =>
                            item.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search country...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: _filteredItems.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 0,
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _filteredItems[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              widget.onChanged?.call(_filteredItems[index]);
                              _updateBorderColor(_filteredItems[index]);
                              Navigator.pop(context);
                            },
                          );
                        },
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: const Text(
                          "No countries found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openCountryPicker(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: ThemeColor.primaryColor)
                  : null,
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: _borderColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
            child: Text(
              widget.value ?? widget.hint,
              style: TextStyle(
                color: widget.value == null
                    ? Colors.grey.shade500
                    : Colors.black87,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 5.h),
        if (_errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              _errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}
