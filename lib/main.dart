import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart';

void main() {
  runApp(const MeuAppNR());
}

class MeuAppNR extends StatelessWidget {
  const MeuAppNR({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App NR',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaInicial(),
    );
  }
}
