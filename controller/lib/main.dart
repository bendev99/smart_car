import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const CarControlApp());
  });
}

class CarControlApp extends StatelessWidget {
  const CarControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const SteeringWheelScreen(),
    );
  }
}

class SteeringWheelScreen extends StatefulWidget {
  const SteeringWheelScreen({super.key});

  @override
  State<SteeringWheelScreen> createState() => _SteeringWheelScreenState();
}

class _SteeringWheelScreenState extends State<SteeringWheelScreen>
    with SingleTickerProviderStateMixin {
  final String espIpAddress = '192.168.4.1';

  double _visualAngle = 0.0;
  double _lastSentAngle = 90.0;
  String _statusMessage = "Prêt";

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 0.0).animate(_animationController)
          ..addListener(() {
            setState(() {
              _visualAngle = _animation.value;
            });
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> sendCommand(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('http://$espIpAddress/cmd/$endpoint'))
          .timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        setState(() => _statusMessage = response.body);
      }
    } catch (e) {
      setState(() => _statusMessage = "Erreur de connexion !");
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      double sensitivity = 1.5;
      _visualAngle += details.delta.dx * sensitivity;
      _visualAngle = _visualAngle.clamp(-90.0, 90.0);
    });

    double currentServoAngle = 90.0 + _visualAngle;

    if ((currentServoAngle - _lastSentAngle).abs() > 5.0) {
      _lastSentAngle = currentServoAngle;
      sendCommand('steer?angle=${currentServoAngle.toInt()}');
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _animation = Tween<double>(begin: _visualAngle, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0.0);

    _lastSentAngle = 90.0;
    sendCommand('steer?angle=90');
    setState(() => _statusMessage = "Recentrage...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(38.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Indicateur de statut
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LE VOLANT INTERACTIF ---
                  GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.rotate(
                      angle: _visualAngle * (pi / 180),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF333333), Color(0xFF111111)],
                          ),
                          border: Border.all(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.cyanAccent,
                                size: 25,
                              ),
                            ),
                            Positioned(
                              top: 10,
                              child: Container(
                                width: 6,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 15,
                              right: 15,
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 40),

              // --- BOUTONS DE MOUVEMENT (AVANCER / RECULER) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MotorButton(
                    label: 'RECULER',
                    icon: Icons.arrow_downward,
                    color: Colors.orange,
                    commandOn: 'reverse',
                    commandOff: 'stop',
                    onSendCommand: sendCommand,
                  ),
                  SizedBox(width: 40),
                  MotorButton(
                    label: 'AVANCER',
                    icon: Icons.arrow_upward,
                    color: Colors.green,
                    commandOn: 'forward',
                    commandOff: 'stop',
                    onSendCommand: sendCommand,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET PERSONNALISÉ POUR LES BOUTONS MOTEUR ---
class MotorButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String commandOn;
  final String commandOff;
  final Function(String) onSendCommand;

  const MotorButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.commandOn,
    required this.commandOff,
    required this.onSendCommand,
  });

  @override
  State<MotorButton> createState() => _MotorButtonState();
}

class _MotorButtonState extends State<MotorButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Quand on appuie dessus
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onSendCommand(widget.commandOn);
      },
      // Quand on relâche le doigt
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onSendCommand(widget.commandOff);
      },
      // Quand on glisse le doigt hors du bouton en restant appuyé (sécurité)
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onSendCommand(widget.commandOff);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: _isPressed ? widget.color.withOpacity(0.8) : widget.color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _isPressed
              ? [] // Pas d'ombre quand appuyé (effet d'enfoncement)
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
