import 'dart:math';

class RandomService {
  final Random _random;
  RandomService({Random? random}) : _random = random ?? Random.secure();
  int select(int count) {
    if (count < 2) {
      throw ArgumentError('At least two choices are required');
    }
    return _random.nextInt(count);
  }

  /// Segments begin at 12 o'clock; pointer is fixed at 12 o'clock.
  static double targetRotation(double current, int winner, int count) {
    final turn = 2 * pi;
    final normalized = ((current % turn) + turn) % turn;
    final target = (turn - (winner + .5) * turn / count) % turn;
    return current + 6 * turn + (target - normalized + turn) % turn;
  }

  static int indexAtPointer(double rotation, int count) =>
      (((-rotation) % (2 * pi)) / (2 * pi / count)).floor().clamp(0, count - 1);
}
