import 'package:flutter/material.dart';

class ControllerScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Titre / En-tête
              const Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Text(
                  'TABLEAU DE BORD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),

              // --- CORPS DE L'INTERFACE EN ROW (POUR LE MODE PAYSAGE) ---
              Expanded(
                child: Row(
                  children: [
                    // --- SECTION GAUCHE : DIRECTION ---
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'DIRECTION',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ControlButton(
                                  icon: Icons.arrow_back_ios_new,
                                  color: Colors.cyanAccent,
                                  label: 'Gauche',
                                ),
                                // Icône de voiture au centre
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                  child: const Icon(
                                    Icons.directions_car_filled,
                                    color: Colors.white70,
                                    size: 50,
                                  ),
                                ),
                                ControlButton(
                                  icon: Icons.arrow_forward_ios,
                                  color: Colors.cyanAccent,
                                  label: 'Droite',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- SECTION DROITE : MOUVEMENT ---
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'CONDUITE',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ControlButton(
                                  icon: Icons.arrow_downward,
                                  color: Colors.orangeAccent,
                                  label: 'Reculer',
                                ),
                                ControlButton(
                                  icon: Icons.arrow_upward,
                                  color: Colors.greenAccent,
                                  label: 'Accélérer',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET PERSONNALISÉ POUR LES BOUTONS ---
class ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const ControlButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              print('$label appuyé');
            },
            borderRadius: BorderRadius.circular(20),
            splashColor: color.withValues(alpha: 0.3),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                border: Border.all(color: color, width: 2.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 35),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
