import 'dart:developer';
import 'package:beldex_browser/src/browser/ai/enums/view_state.dart';
import 'package:flutter/foundation.dart';


class BaseModel with ChangeNotifier {
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  set state(ViewState viewState) {
    log('Open AI Chat - State: $viewState');
    _state = viewState;
    notifyListeners();
  }

  set stateWithoutUpdate(ViewState viewState) {
    log('Open AI Chat - State: $viewState');
    _state = viewState;
  }

  void updateUI() {
    notifyListeners();
  }
}
