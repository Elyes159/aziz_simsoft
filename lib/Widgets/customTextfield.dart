import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final bool? enabled;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final String? defaultValue;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters; // ✅ Ajout des input formatters

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.isPassword,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSaved,
    this.defaultValue,
    this.enabled,
    this.onChanged,
    this.inputFormatters, // ✅ Ajout du paramètre
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;
  String? _errorMessage;
  bool _isTouched = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _errorMessage = widget.validator?.call(widget.controller.text);
      });
    }

    if (widget.onChanged != null) {
      widget.onChanged!(widget.controller.text);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.defaultValue != null && widget.defaultValue!.isNotEmpty) {
      widget.controller.text = widget.defaultValue!;
    }
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: TextFormField(
              enabled: widget.enabled ?? true,
              onSaved: widget.onSaved,
              controller: widget.controller,
              obscureText: widget.isPassword ? _obscureText : false,
              keyboardType: widget.keyboardType,
              cursorColor: Colors.grey,
              
              style: const TextStyle(fontFamily: 'Raleway'),
              inputFormatters: widget.inputFormatters, // ✅ Ajout des formatteurs
              onChanged: (value) => _onTextChanged(),
              onTap: () {
                setState(() {
                  _isTouched = true;
                });
              },
              decoration: InputDecoration(
                suffixIcon: widget.isPassword
                    ? GestureDetector(
                        onTap: _togglePasswordVisibility,
                        child: SvgPicture.asset(
                          _obscureText
                              ? "assets/icons/eye-slash.svg"
                              : "assets/icons/eye.svg",
                          height: 24,
                          width: 24,
                        ),
                      )
                    : null,
                labelText: widget.label,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0.5,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 10),
              ),
            ),
          ),
          if (_isTouched && _errorMessage != null && _errorMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: "Raleway",
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}