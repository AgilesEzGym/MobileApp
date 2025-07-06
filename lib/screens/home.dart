// ignore_for_file: prefer_const_constructors

//import 'package:ezgym/services/routineApi.dart';
import 'package:ezgym/widgets/favs.dart';
import 'package:ezgym/widgets/latest.dart';
import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../widgets/recommended.dart';

class Home extends StatefulWidget {
  final String? welcomeMessage;

  const Home({Key? key, this.welcomeMessage}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Routine> rutinas = [];

  @override
  void initState() {
    super.initState();
    if (widget.welcomeMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.welcomeMessage!),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EzGym', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '¡Bienvenido, Usuario!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            Text(
              "🔁 Recomendaciones",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Recommended(),
            SizedBox(height: 30),
            Divider(thickness: 1.2),
            SizedBox(height: 20),
            Text(
              "🆕 Últimos agregados",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Latest(),
          ],
        ),
      ),
    );
  }
}
