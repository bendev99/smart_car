#include <WiFi.h>
#include <WebServer.h>
#include <ESP32Servo.h>

const char* ssid = "ESP32 AP";
const char* password = "1234567890";

WebServer server(80);
Servo servo;

const int IN1 = 19;
const int IN2 = 18;
const int ENA = 21;

const int SERVO_PIN = 13;
int currentAngle = 90;

// Configuration du PMW
const int freq = 5000;
const int resolution = 8;

void stopMotor() {
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  ledcWrite(ENA, 0);
}

void setMotorSpeed(int speed) {
  if (speed > 0) {
    // Marche avant
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    ledcWrite(ENA, speed);
  } else if (speed < 0) {
    // Marche arrière (on inverse les broches et on rend la vitesse positive pour le PWM)
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    ledcWrite(ENA, -speed);
  } else {
    stopMotor();
  }
}

void setup() {
  Serial.begin(115200);

  // Configuration du Servomoteur
  servo.attach(SERVO_PIN);
  servo.write(currentAngle);

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  ledcAttach(ENA, freq, resolution);
  
  stopMotor();

  // Démarrage du Wi-Fi en mode Point d'Accès
  WiFi.softAP(ssid, password);
  Serial.println("------------------------------------------------");
  Serial.print("Connectez-vous au Wi-Fi : ");
  Serial.println(ssid);
  Serial.print("Mot de passe : ");
  Serial.println(password);
  Serial.print("IP de l'ESP32 : ");
  Serial.println(WiFi.softAPIP().toString()); // 192.168.4.1
  Serial.println("------------------------------------------------");

  // Route HTTP pour la direction
  server.on("/cmd/steer", HTTP_GET, []() {
    if (server.hasArg("angle")) {
      int newAngle = server.arg("angle").toInt();
      // Sécurité : on limite l'angle entre 0 et 180 degrés
      currentAngle = constrain(newAngle, 0, 180); 
      servo.write(currentAngle);
      
      Serial.print("Nouvel angle du servo : ");
      Serial.println(currentAngle);
      
      server.send(200, "text/plain", "Direction: " + String(currentAngle) + " degres");
    } else {
      server.send(400, "text/plain", "Erreur: argument 'angle' manquant");
    }
  });

  // Marche Avant
  server.on("/cmd/forward", HTTP_GET, []() {
    setMotorSpeed(150); // Vitesse à 200/255 (ajustez entre 100 et 255 selon vos besoins)
    server.send(200, "text/plain", "Marche Avant");
  });

  // Marche Arrière
  server.on("/cmd/reverse", HTTP_GET, []() {
    setMotorSpeed(-150); // Vitesse à -200/255
    server.send(200, "text/plain", "Marche Arriere");
  });

  // Arrêt d'urgence / Relâchement
  server.on("/cmd/stop", HTTP_GET, []() {
    stopMotor();
    server.send(200, "text/plain", "Arret Moteur");
  });

  server.begin();
}

void loop() {
  // Cette fonction doit rester libre pour écouter les requêtes HTTP en temps réel
  server.handleClient();
}