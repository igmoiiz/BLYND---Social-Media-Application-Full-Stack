import 'package:flutter/material.dart';
import 'package:social_media/Utils/size.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.secondary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Center(
        child:
            isLoading
                ? CircularProgressIndicator(color: color.primary)
                : Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                    fontSize: screenHeight(context) * .018,
                  ),
                ),
      ),
    );
  }
}
