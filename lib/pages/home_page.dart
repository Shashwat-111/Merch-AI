import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'questionnaire_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEE8F7),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          title: Text(
            'Merch AI',
            style: GoogleFonts.pacifico(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Color(0xFF121218),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          elevation: 12,
          highlightElevation: 16,
          backgroundColor: const Color(0xFF11111C),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          splashColor: const Color(0xFF9C74EB),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QuestionnairePage()),
            );
          },
          child: const Icon(Icons.add_rounded, size: 28),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/websiteBG.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.white.withValues(alpha: 0.36),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: 0.22,
                        child: Image.asset(
                          'assets/cotton-polo-shirt.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Lets design your first merch.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF121218),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create cool merch conepts in minutes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF5B5963),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
