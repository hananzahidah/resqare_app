import 'package:flutter/material.dart';

IconData iconForm(String namaIcon) {
  switch (namaIcon) {
    case "name":
      return Icons.person;
    case "email":
      return Icons.mail_outline;
    case "phone":
      return Icons.phone;
    case "password":
      return Icons.lock_outline;
    case "confirm password":
      return Icons.lock_outline;
    case "city":
      return Icons.location_on_outlined;
    case "location":
      return Icons.location_on;
    case "role":
      return Icons.category_outlined;
    default:
      return Icons.keyboard;
  }
}
