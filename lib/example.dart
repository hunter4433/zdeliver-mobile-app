import 'package:flutter/material.dart';

/// Interface that all example widgets must implement
abstract class Example {
  /// Icon to display in the example list
  Widget get leading;

  /// Title of the example
  String get title;

  /// Optional subtitle for additional explanation
  String? get subtitle;
}

/// A widget that displays all available examples in a list
class ExampleNavigator extends StatelessWidget {
  final List<Example> examples;
  final String title;

  const ExampleNavigator({
    super.key,
    required this.examples,
    this.title = 'Mapbox Examples',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: examples.length,
        itemBuilder: (context, index) {
          final example = examples[index];
          return ListTile(
            leading: example.leading,
            title: Text(example.title),
            subtitle: example.subtitle != null ? Text(example.subtitle!) : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(example.title),
                    ),
                    body: example as Widget,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}