import 'package:flutter/material.dart';

// class DynamicTextSizeWidget extends StatelessWidget {
//   final String text;
//   final double baseTextSize;

//   DynamicTextSizeWidget({required this.text, required this.baseTextSize});

//   @override
//   Widget build(BuildContext context) {
//     // Get the screen width
//     double screenWidth = MediaQuery.of(context).size.width;

//     // Calculate the scaling factor based on a reference width (you can adjust this as needed)
//     double scaleFactor = screenWidth / 360; // Adjust the reference width as needed

//     // Calculate the final text size
//     double finalTextSize = baseTextSize * scaleFactor;

//     return Text(
//       text,
//       style: TextStyle(fontSize: finalTextSize),
//     );
//   }
// }

class DynamicTextSizeWidget{

 double dynamicFontSize(double baseTextSize ,BuildContext context){

    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 360;
     double finalTextSize = baseTextSize * scaleFactor;
   return finalTextSize;
 }

}
