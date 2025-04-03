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
          Text(title, style: TextStyle(color: TColor.gray10,fontSize: 18),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: TColor.gray70),
              color: TColor.gray60.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Type here .....",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                keyboardType: keyboardType,
                obscureText: obscureText,
              ),
            ),
          ),


        ],
      );

  }
}
