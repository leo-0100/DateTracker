/// Validation utilities for form inputs

class Validators {
  /// Validates email format
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // RFC 5322 compliant email regex (simplified)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  /// Requires: 12+ chars, uppercase, lowercase, number, special char
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 12) {
      return 'Password must be at least 12 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates name field
  /// Returns null if valid, error message if invalid
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Allow only letters, spaces, hyphens, and apostrophes
    if (!RegExp(r'^[a-zA-Z\s\-\']+$').hasMatch(value)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  /// Validates product name
  /// Returns null if valid, error message if invalid
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter product name';
    }

    if (value.length > 100) {
      return 'Product name must be less than 100 characters';
    }

    return null;
  }

  /// Validates product quantity
  /// Returns null if valid, error message if invalid
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }

    final quantity = int.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity < 1) {
      return 'Quantity must be at least 1';
    }

    if (quantity > 10000) {
      return 'Quantity must be less than 10,000';
    }

    return null;
  }

  /// Validates barcode format
  /// Accepts standard barcode formats: EAN-13, UPC-A, EAN-8
  /// Returns null if valid, error message if invalid
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter barcode';
    }

    // Remove any whitespace
    final cleanValue = value.replaceAll(RegExp(r'\s'), '');

    // Check if it's numeric
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Barcode must contain only numbers';
    }

    // Check length for standard formats
    final length = cleanValue.length;
    if (length != 8 && length != 12 && length != 13) {
      return 'Invalid barcode length (must be 8, 12, or 13 digits)';
    }

    return null;
  }

  /// Validates notes/description field
  /// Returns null if valid, error message if invalid
  static String? validateNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }

    if (value.length > 500) {
      return 'Notes must be less than 500 characters';
    }

    return null;
  }

  /// Sanitizes text input to prevent injection attacks
  /// Removes potentially harmful characters
  static String sanitizeInput(String input) {
    // Remove HTML/script tags and potentially harmful characters
    return input
        .replaceAll(RegExp(r'[<>"\']'), '')
        .trim();
  }

  /// Checks password strength level
  /// Returns strength level: 0 (weak) to 4 (very strong)
  static int getPasswordStrength(String password) {
    int strength = 0;

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    return strength > 4 ? 4 : strength;
  }

  /// Gets human-readable password strength text
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }
}
