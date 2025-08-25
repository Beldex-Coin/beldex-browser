import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
const fiatApiAuthority = 'api.coingecko.com';
const apiString = 'api/v3/simple/price?ids=beldex&vs_currencies=';
class ApiService {
Future<double> fetchPriceFor() async {
  var price = 0.0;
try{
String fiat = 'usd';
  final uri = Uri.parse('https://$fiatApiAuthority/$apiString${fiat.toString()}');

   final response = await http.get(uri);
    print('responsejson ---> $response');
   if(response.statusCode == 200){
     final responseJSON = json.decode(response.body) as Map<String, dynamic>;
   final data = responseJSON['beldex'] as Map<String,dynamic>;
  final covToLower = fiat.toString().toLowerCase();
     price = data['$covToLower'] as double;
    print('data ---> $data');
    print('fist vaue of pice $data');
    print('price value is the $price');
    print('fiatprice ---> $price');

   }
    return price;
}catch(e){
 return price;
}

}

}


class PriceValueProvider with ChangeNotifier {
  double _value = 0.0000;
  double get value => _value;

  final ApiService _apiService = ApiService();

  PriceValueProvider() {
    _loadValue();
  }

  Future<void> _loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    _value = prefs.getDouble('value') ?? 0.0000;
    notifyListeners();
    _fetchValue();
  }

  Future<void> _fetchValue() async {
    try {
      double newValue = await _apiService.fetchPriceFor();
      _value = newValue;
      print('Updated Fiat value  $newValue');
      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble('value', newValue);
      notifyListeners();
    } catch (e) {
      // Handle the error gracefully, keeping the last updated value
    }
  }

  void startFetching() {
     // _fetchValue();
    // Call _fetchValue at regular intervals
    Future.doWhile(() async {
      await _fetchValue();
      await Future.delayed(const Duration(seconds: 20)); // Adjust the duration as needed
      return true;
    });
  }
}






class VpnStatusNotifier with ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void update(bool newStatus) {
    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      notifyListeners();
    }
  }


/// counter flag

int _count = 0;

int get count => _count;

void updateCount(int value){
  _count = value;
  notifyListeners();
}


  bool _isRunning = false;

  bool get isRunning => _isRunning;

  void updateIsRunning(bool newStatus) {
    //if (_isConnected != newStatus) {
      _isRunning = newStatus;
      notifyListeners();
    //}
  }

}
