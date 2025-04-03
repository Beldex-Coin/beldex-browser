import 'package:beldex_browser/src/browser/ai/repositories/openai_repository.dart';
import 'package:beldex_browser/src/browser/ai/view_models/chat_view_model.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setUpLocator() {
  locator.registerLazySingleton(() => OpenAIRepository());
  locator.registerLazySingleton(() => ChatViewModel());
}
