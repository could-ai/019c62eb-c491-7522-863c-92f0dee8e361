import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_backend.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<MockBackendService>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Grok Voice Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration API Keys (Grok/GitHub) via Supabase requise')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Indicateur de Projet Actuel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.blueAccent.withOpacity(0.1),
            child: Column(
              children: [
                const Text(
                  "Projet Actif",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  "${backend.currentProjectName}.json",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  backend.currentProject.summary,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: backend.currentProject.history.length,
              itemBuilder: (context, index) {
                final item = backend.currentProject.history[index];
                final isUser = item.startsWith("User:");
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      item.replaceFirst(isUser ? "User: " : "Grok: ", ""),
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),

          // Zone de Status
          if (backend.isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              backend.isListening ? "Écoute en cours... ${backend.lastRecognizedText}" : "Appuyez pour parler",
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),

          // Bouton Toggle Principal
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: GestureDetector(
              onTap: backend.toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: backend.isListening ? Colors.redAccent : Colors.blueAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (backend.isListening ? Colors.redAccent : Colors.blueAccent).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  backend.isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
