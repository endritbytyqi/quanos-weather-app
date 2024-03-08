import 'package:flutter/material.dart';

class WeatherDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;
  final Widget? trailing;

  const WeatherDetailCard({
    Key? key,
    required this.title,
    required this.value,
    required this.iconData,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Icon(iconData, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(value),
        trailing: trailing,
      ),
    );
  }
}
