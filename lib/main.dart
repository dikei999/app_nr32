import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'core/supabase_client.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'services/demo_mode_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final demoEnabled = await DemoModeService.isEnabled();
  if (!demoEnabled) {
    await SupabaseConfig.initialize();
  }

  runApp(const MeuAppNR());
}

class MeuAppNR extends StatelessWidget {
  const MeuAppNR({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}
