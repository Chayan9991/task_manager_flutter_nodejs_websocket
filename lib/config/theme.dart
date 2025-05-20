import 'package:flutter/material.dart';

class AppTheme {
  
  static ThemeData lightTheme = ThemeData(
    
    scaffoldBackgroundColor: Colors.white,

  
    primaryColor: const Color(0xFF4CAF50), 
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE8F5E9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF388E3C),
          width: 2,
        ), 
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    ),

    
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Color(0xFF212121), 
        fontSize: 16,
      ),
      headlineSmall: TextStyle(
        color: Color(0xFF212121),
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      bodySmall: TextStyle(
        color: Colors.black54,
        fontSize: 16,
      ), 
    ),

  
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50), 
        foregroundColor: Colors.white, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),

  
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF388E3C), 
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),

    
    iconTheme: const IconThemeData(
      color: Color(0xFF388E3C), 
    ),

   
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black54,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
