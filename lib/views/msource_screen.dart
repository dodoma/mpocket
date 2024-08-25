import 'package:flutter/material.dart';

class MsourceScreen extends StatefulWidget {
  const MsourceScreen({
    super.key,
  });

  @override
  State<MsourceScreen> createState() => _MsourceScreenState();
}

class _MsourceScreenState extends State<MsourceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('M source page'),
      )
    );
  }
}
