import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/merch_provider.dart';

class MerchAiApp extends StatelessWidget {
  const MerchAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MerchProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MerchAi',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const HomePage(),
      ),
    );
  }
}
