import 'package:flutter_test/flutter_test.dart';
import 'package:ecoshop/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('email validator returns null for valid email', () {
      expect(Validators.email('test@example.com'), null);
      expect(Validators.email('user.name+tag@domain.co'), null);
    });

    test('email validator returns error for invalid email', () {
      expect(Validators.email('test@domain'), 'Please enter a valid email address');
      expect(Validators.email('test.com'), 'Please enter a valid email address');
      expect(Validators.email(''), 'Email is required');
    });

    test('password validator returns null for strong password', () {
      expect(Validators.password('Password123!'), null);
    });

    test('password validator returns error for short password', () {
      expect(Validators.password('Pass1'), 'Password must be at least 8 characters');
    });

    test('name validator returns error for empty name', () {
      expect(Validators.name(''), 'Name is required');
      expect(Validators.name(' '), 'Name is required');
    });
  });
}
