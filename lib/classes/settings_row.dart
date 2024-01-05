import 'package:flutter/material.dart';
import 'package:darttoernooi/classes/setting.dart';
import 'package:darttoernooi/classes/checkbox.dart';

class SettingsRow extends StatelessWidget {
  SettingsRow({super.key, required this.setting, required this.onChange});
  final Setting setting;
  final Function(Setting) onChange;

  Widget settingEditor = TextFormField();

  @override
  Widget build(context) {
    switch (setting.type) {
      case "checkbox":
        settingEditor = CheckboxWidget(
            initialState: setting.defaultValue == 'false' ? false : true,
            onChange: (bool newState) {
              onChange(Setting(
                  name: setting.name,
                  friendlyName: setting.friendlyName,
                  type: setting.type,
                  defaultValue: newState.toString()));
            });
        break;
      case "textfield":
        settingEditor = SizedBox(
          width: 40,
          child: TextField(
            onChanged: (value) {
              onChange(Setting(
                  name: setting.name,
                  friendlyName: setting.friendlyName,
                  type: setting.type,
                  defaultValue: value == "" ? setting.defaultValue : value));
            },
            decoration: InputDecoration(hintText: setting.defaultValue),
          ),
        );
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text("${setting.friendlyName.toString()}:"), settingEditor],
    );
  }
}
