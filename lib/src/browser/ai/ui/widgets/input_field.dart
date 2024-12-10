
import 'package:flutter/material.dart';

class InputFieldWidget extends StatefulWidget {
  const InputFieldWidget({super.key});

  @override
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Color(0xff3D4354),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 22),
                    
                  ),

                ],
              ) ,
            )
          )
        ],
       ),
    );
  }
}
