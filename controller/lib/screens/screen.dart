import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Screen extends StatefulWidget {
  const new({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  // Adresse IP par défaut de l'ESP32
  final String espIpAddress = "192.168.4.1";

  bool isLoading = false;
  String statusMessage = "En attente...";

  // Fonction pour envoyer la commande à l'ESP32
  Future<void> sendCommand(String command) async {
    setState(() {
      isLoading = true;
      statusMessage = "";
    });

    try {
      // Envoi de la requête HTTP GET
      final response = await http
          .get(Uri.parse('http://$espIpAddress/cmd/$command'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = "Etat du LED : ${response.body}";
        });
      } else {
        setState(() {
          statusMessage = "Etat du LED : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Erreur de connexion : Vérifiez le Wi-Fi !";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrôle ESP32')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => sendCommand('on'),
                  onLongPress: isLoading ? null : () => sendCommand("avance"),
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('ALLUMER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => sendCommand('off'),
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('ÉTEINDRE'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
