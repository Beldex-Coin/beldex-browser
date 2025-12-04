import 'package:flutter/material.dart';

class TtsProvider extends ChangeNotifier {
  bool _isPlaying = false;
  double _speechProgress = 0.0;

  bool get isPlaying => _isPlaying;
  double get speechProgress => _speechProgress;

  void setPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  void setSpeechProgress(double value) {
    _speechProgress = value;
    notifyListeners();
  }

  void reset() {
    _isPlaying = false;
    _speechProgress = 0.0;
    notifyListeners();
  }



 bool _canTTSDisplay = false;
  bool get canTTSDisplay => _canTTSDisplay;

    void updateTTSDisplayStatus(bool newvalue){
      _canTTSDisplay = newvalue;
      notifyListeners();
    }

bool _isPlayerOpen = false;
bool get isPlayerOpen => _isPlayerOpen;

void updatePlayerStatus(bool value){
  _isPlayerOpen = value;
  notifyListeners();
}



bool _isContentTranslating = false;
bool get isContentTranslating => _isContentTranslating;

void updateContentTranslateloader(bool value){
  _isContentTranslating = value;
  notifyListeners();
}


bool _hasVoiceResult = false; // the voice search result
bool get hasVoiceResult => _hasVoiceResult;

void updateHasResult(bool value){
  _hasVoiceResult = value;
  notifyListeners();
}







}




