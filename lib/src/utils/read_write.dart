// ignore: depend_on_referenced_packages
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

//Always retuns String "" if value is null
read(String storageName){
  dynamic result = box.read(storageName)??"";
  return result;
}

write(String storageName,dynamic value){
  box.write(storageName,value??"");
}

remove(String storageName){
  box.remove(storageName);
}