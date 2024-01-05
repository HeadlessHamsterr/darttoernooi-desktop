import 'package:flutter/material.dart';

class CheckboxWidget extends StatefulWidget {
  const CheckboxWidget(
      {super.key, required this.initialState, required this.onChange});
  final bool initialState;
  final Function(bool) onChange;

  @override
  State<CheckboxWidget> createState() => _CheckboxWidgetState();
}

class _CheckboxWidgetState extends State<CheckboxWidget> {
  bool isChecked = false;

  @override
  void initState() {
    isChecked = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: isChecked,
        onChanged: (bool? newState) {
          setState(() {
            widget.onChange(newState!);
            isChecked = newState;
          });
        });
  }
}
