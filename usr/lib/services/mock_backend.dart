import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'project.dart';

// Service simulant le Backend Node+Express + Grok + GitHub
class MockBackendService extends ChangeNotifier {
  // Simulation de la base de données GitHub (fichiers JSON)
  final Map<String, Project> _projects = {};
  String _currentProjectName = "default";
  
  // États du système
  bool _isListening = false;
  bool _isProcessing = false;
  String _lastRecognizedText = "";
  String _systemResponse = "";
  
  // Outils vocaux
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Getters
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String get currentProjectName => _currentProjectName;
  Project get currentProject => _projects[_currentProjectName]!;
  String get lastRecognizedText => _lastRecognizedText;
  String get systemResponse => _systemResponse;

  MockBackendService() {
    _initProjects();
    _initTts();
  }

  void _initProjects() {
    // Création du projet par défaut si vide (comme demandé)
    _projects['default'] = Project(name: 'default', history: [], summary: "Projet par défaut initialisé.");
    _projects['labs'] = Project(name: 'labs', history: [], summary: "Espace d'expérimentation.");
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setPitch(1.0);
  }

  // Démarrer/Stop le micro (Toggle)
  Future<void> toggleRecording() async {
    if (_isListening) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (errorNotification) => print('Error: $errorNotification'),
    );

    if (available) {
      _isListening = true;
      notifyListeners();
      
      // Écoute continue
      _speech.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          notifyListeners();
          
          // Si l'utilisateur fait une pause ou termine une phrase (simulation de chunks/VAD)
          if (result.finalResult) {
            _processAudioInput(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: "fr_FR",
      );
    }
  }

  Future<void> stopRecording() async {
    _isListening = false;
    await _speech.stop();
    notifyListeners();
  }

  // Simulation de l'appel API Grok et de la logique Backend
  Future<void> _processAudioInput(String text) async {
    if (text.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    // Simulation latence réseau
    await Future.delayed(const Duration(seconds: 1));

    String responseText = "";
    String lowerText = text.toLowerCase();

    // Logique du Prompt Système Grok simulée
    if (lowerText.contains("projet") || lowerText.contains("passons à")) {
      // Extraction du nom du projet (très basique pour la démo)
      String newProject = "default";
      if (lowerText.contains("labs")) newProject = "labs";
      else if (lowerText.contains("alpha")) newProject = "alpha"; // Exemple
      
      if (!_projects.containsKey(newProject)) {
        // Création dynamique si n'existe pas
        _projects[newProject] = Project(name: newProject, history: [], summary: "Nouveau projet créé.");
      }
      
      _currentProjectName = newProject;
      responseText = "OK, sur $newProject.";
    } 
    else if (lowerText.contains("liste mes projets") || lowerText.contains("quels projets")) {
      String projectList = _projects.keys.join(", ");
      responseText = "Vous avez les projets suivants : $projectList.";
    } 
    else {
      // Réponse générique Grok
      responseText = "J'ai bien reçu : \"$text\". Je mets à jour le résumé du projet $_currentProjectName.";
    }

    // Mise à jour JSON (Historique + Résumé)
    _projects[_currentProjectName]?.history.add("User: $text");
    _projects[_currentProjectName]?.history.add("Grok: $responseText");
    _projects[_currentProjectName]?.summary = "Mise à jour après échange sur $text";

    // Simulation Push GitHub
    print("Simulating GitHub Push for $_currentProjectName.json...");

    _systemResponse = responseText;
    _isProcessing = false;
    notifyListeners();

    // Jouer la voix (Grok Voice via WebSocket simulé par TTS local)
    await _speak(responseText);
    
    // Si on est en mode continu, on pourrait relancer l'écoute ici
    // Pour la démo, on demande à l'utilisateur de réappuyer ou on laisse le stream ouvert
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }
}
