import 'package:flutter/material.dart';

class UserRoleUtils {
  static String getLabel(String type) {
    switch (type) {
      case 'shop_owner':
        return "Shop Owner";
      case 'property_owner':
        return "Property Owner";
      case 'property_owner':
        return "Property Agent";
      case 'hospitality_owner':
         return 'Hospitality Owner';
      case 'customer':
         return 'Customer Account';
      case 'user':
        return "User";
      default:
        return "User";
    }
  }

  static Color getColor(String type) {
    switch (type) {
      case 'shop_owner':
        return Colors.orange;
      case 'property_owner':
        return Colors.blue;
      case 'property_owner':
        return Colors.purple;
      case 'user':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static bool isShopOwner(String? type) {
    return type == 'shop_owner';
  }

  static bool isPropertyUser(String? type) {
    return type == 'property_owner' || type == 'agent';
  }

  static bool isNormalUser(String? type) {
    return type == 'user' || type == null;
  }
}