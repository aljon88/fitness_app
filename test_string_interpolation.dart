void main() {
  // Test string interpolation
  double cost = 125.50;
  
  // This should work correctly
  String correctFormat = '\$${cost.toStringAsFixed(0)}';
  print('Correct format: $correctFormat');
  
  // This would show as literal text (what we had before)
  String incorrectFormat = '\${cost.toStringAsFixed(0)}';
  print('Incorrect format: $incorrectFormat');
}