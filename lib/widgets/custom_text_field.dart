import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTextField(
    IconData icon, String hintText, TextEditingController controllername,
    {bool isPassword = false, Function(String)? onChanged, bool clearable = false}) {
  return TextField(
    controller: controllername,
    obscureText: isPassword,
    onChanged: onChanged,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF9f86c0)),
      hintText: hintText,
      hintStyle: GoogleFonts.lato(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9f86c0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5e548e)),
      ),
      suffixIcon: clearable
          ? IconButton(
              icon: Icon(Icons.clear, color: const Color(0xFF9f86c0)),
              onPressed: () {
                controllername.clear();
                if (onChanged != null) {
                  onChanged('');
                }
              },
            )
          : null,
    ),
  );
}
