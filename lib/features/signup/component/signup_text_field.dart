import 'package:flutter/material.dart';

class SignupTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final TextEditingController? controller;

  const SignupTextField({
    Key? key,
    required this.label,
    required this.validator,
    required this.onSaved,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<SignupTextField> createState() => _SignupTextFieldState();
}

class _SignupTextFieldState extends State<SignupTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onBackground),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          onSaved: widget.onSaved,
          validator: widget.validator,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          obscuringCharacter: '*',
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: inputTheme.hintStyle ?? theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.6)),
            filled: true,
            fillColor: inputTheme.fillColor ?? (theme.brightness == Brightness.dark ? cs.surface : cs.surfaceVariant),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: theme.iconTheme.color),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
                : null,
          ),
        ),
      ],
    );
  }
}
