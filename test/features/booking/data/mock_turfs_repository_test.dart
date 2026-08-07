import 'package:flutter_test/flutter_test.dart';

import 'package:khelam/features/booking/data/mock_turfs_repository.dart';

void main() {
  group('MockTurfsRepository', () {
    test('getTurfs returns the two known turfs', () async {
      final MockTurfsRepository repository = MockTurfsRepository();

      final turfs = await repository.getTurfs();

      expect(turfs, hasLength(2));
      expect(turfs.first.id, MockTurfsRepository.firstTurfId);
      expect(turfs.first.name, 'Turf A');
      expect(turfs.first.address, 'Sector 12, Sports Complex');
      expect(turfs.last.id, MockTurfsRepository.secondTurfId);
      expect(turfs.last.name, 'Turf B');
      expect(turfs.last.address, 'Sector 7, Futsal Court');
    });
  });
}
