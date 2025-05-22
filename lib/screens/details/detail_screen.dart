import 'package:flutter/material.dart';
import 'package:plant_app/screens/details/components/body.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}