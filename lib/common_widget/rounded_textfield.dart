import 'package:flutter/material.dart';
import 'package:untitled/common/color_extension.dart';

class RoundedTextField extends StatelessWidget {

  final String title;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextAlign? titleAlign;



  const RoundedTextField({super.key, required this.title,  this.controller, this.keyboardType, this.obscureText = false, this.titleAlign,});



  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: TColor.gray,fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: TColor.gray10),
              color: TColor.white,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: TextField(

              controller: controller,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 16,
              ),
              decoration: const InputDecoration(
                isCollapsed: true, // Avoid extra padding
                contentPadding: EdgeInsets.symmetric(vertical: 14,horizontal: 8),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Type here .....",
                hintStyle: TextStyle(color: Colors.grey),

              ),
              keyboardType: keyboardType,
              obscureText: obscureText,
            ),
          ),



        ],
      );

  }
}
