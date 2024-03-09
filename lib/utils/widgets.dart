import 'package:flutter/material.dart';

class WeatherDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;
  final Widget? trailing;
  final Widget? details;

  const WeatherDetailCard({
    Key? key,
    required this.title,
    required this.value,
    required this.iconData,
    this.trailing,
    this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(iconData, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(value),
        trailing: trailing,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: details ?? Container(), // Display additional details here
          ),
        ],
      ),
    );
  }
}
