import 'package:flutter/material.dart';
import 'screens/tela_inicial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/tela_setores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox('checklistBox');
  await Hive.openBox('relatoriosBox');

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
      home: const TelaSetores(),
    );
  }
}
