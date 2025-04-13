import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color buttonColor; // Variable for the button color
  final Color textColor; // Variable for the text color
  final bool isDisabled; // New variable for the disabled state

  const CustomButton({super.key, 
    required this.label,
    required this.onTap,
    this.buttonColor =  Colors.black, // Default button color
    this.textColor = Colors.white, // Default text color
    this.isDisabled = false, // Default to enabled
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap, // Disable interaction if isDisabled is true
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: isDisabled
                ? Color(0xFFE5E7EB) // Grey out the button if disabled
                : buttonColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                 color: Colors.white ,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                  letterSpacing: 0.10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}