class PriceFormatter {
  static String formatPrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) {
      return '₹0';
    }

    try {
      final price = double.tryParse(priceString.replaceAll(',', '').trim());
      if (price == null || price < 0) {
        return '₹$priceString';
      }

      if (price >= 10000000) {
        final crores = price / 10000000;
        if (crores % 1 == 0) {
          return '₹${crores.toInt()} Crore';
        }
        return '₹${crores.toStringAsFixed(2)} Crore';
      } else if (price >= 100000) {
        final lakhs = price / 100000;
        if (lakhs % 1 == 0) {
          return '₹${lakhs.toInt()} Lakh';
        }
        return '₹${lakhs.toStringAsFixed(2)} Lakh';
      } else if (price >= 1000) {
        final thousands = price / 1000;
        if (thousands % 1 == 0) {
          return '₹${thousands.toInt()} Thousand';
        }
        return '₹${thousands.toStringAsFixed(2)} Thousand';
      } else {
        return '₹${price.toInt()}';
      }
    } catch (e) {
      return '₹$priceString';
    }
  }

  // Helper method to parse a price string (e.g., "15 Lakh", "1.5 Cr") to a double value
  static double parsePriceToDouble(String? priceString) {
    if (priceString == null || priceString.isEmpty) {
      return 0.0;
    }

    // Clean the string
    String cleanStr = priceString.replaceAll(',', '').trim().toLowerCase();

    // Default multiplier is 1
    double multiplier = 1.0;
    bool hasExplicitUnit = false;

    // Check for Lakh or Cr and adjust multiplier
    if (cleanStr.contains('lakh')) {
      multiplier = 100000.0;
      hasExplicitUnit = true;
      cleanStr = cleanStr.replaceAll('lakh', '').trim();
    } else if (cleanStr.contains('crore') || cleanStr.contains('cr')) {
      multiplier = 10000000.0;
      hasExplicitUnit = true;
      cleanStr = cleanStr.replaceAll('crore', '').replaceAll('cr', '').trim();
    }

    // Parse the remaining number and apply the multiplier
    final baseValue = double.tryParse(cleanStr) ?? 0.0;
    if (!hasExplicitUnit && baseValue > 0 && baseValue < 1000) {
      multiplier = 100000.0; // Numbers under 1000 without unit represent Lakhs
    }
    return baseValue * multiplier;
  }

  static String formatPriceReadable(String? priceString) {
    if (priceString == null || priceString.isEmpty) {
      return '₹0';
    }

    // Attempt to parse string directly if no text (for backwards compatibility)
    double price = 0.0;
    try {
       // if string has no letters, maybe it's raw number
       if (!priceString.toLowerCase().contains(RegExp(r'[a-z]'))) {
           price = double.tryParse(priceString.replaceAll(',', '').trim()) ?? 0.0;
       } else {
           price = parsePriceToDouble(priceString);
       }
    } catch (_) {
       price = parsePriceToDouble(priceString);
    }

    if (price <= 0) {
      return priceString.startsWith('₹') ? priceString : '₹$priceString';
    }

    if (price >= 10000000) {
      final crores = price ~/ 10000000;
      final remaining = price % 10000000;
      if (remaining == 0) {
        return '₹$crores Crore';
      }
      final lakhs = remaining ~/ 100000;
      if (lakhs == 0) {
        return '₹$crores Crore';
      }
      return '₹$crores Crore, $lakhs Lakh';
    } else if (price >= 100000) {
      final lakhs = price ~/ 100000;
      final remaining = price % 100000;
      if (remaining == 0) {
        return '₹$lakhs Lakh';
      }
      final thousands = remaining ~/ 1000;
      if (thousands == 0) {
        return '₹$lakhs Lakh';
      }
      return '₹$lakhs Lakh, $thousands Thousand';
    } else if (price >= 1000) {
      final thousands = price ~/ 1000;
      return '₹$thousands Thousand';
    } else {
      return '₹${price.toInt()}';
    }
  }
}
