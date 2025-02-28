import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class AIModelService {
  static final List<String> models = ['gemini', 'mistral','openai','deepseek'];

  // Get a random model
  static String getRandomModel() {
    final random = Random();
    return models[random.nextInt(models.length)];
  }

  // Save selected model in SharedPreferences
  static Future<void> saveSelectedModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ai_model', model);
  }

  // Always pick a new model on app start
  static Future<String> loadSelectedModel() async {
    String newModel = getRandomModel(); // Always pick a new random model
    await saveSelectedModel(newModel); // Save new model in SharedPreferences
    return newModel;
  }



   Future<String> loadNewModel(String modelType)async{
     
     String newModel = getRandomModel();
     if(newModel != modelType){
      await saveSelectedModel(newModel);
      return newModel;
     }else{
      await loadNewModel(newModel);
     }
     return newModel;
  }
}
