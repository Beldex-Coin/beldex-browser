import 'package:flutter/material.dart';
import 'ai_model_service.dart';

class AIModelProvider with ChangeNotifier {
  String _selectedModel = '';

  String get selectedModel => _selectedModel;

  // Load the model when the app starts
  Future<void> initializeModel() async {
    _selectedModel = await AIModelService.loadSelectedModel();
    notifyListeners();
  }
}
