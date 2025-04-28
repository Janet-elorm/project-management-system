import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_flutter/api_service/dashboard_service.dart';
import 'package:http/http.dart' as http;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Important line for async stuff

  setUp(() {
    // Fake empty SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('DashboardService', () {
    test('fetchDashboardData returns a Map', () async {
      final service = DashboardService();

      final metrics = await service.fetchDashboardData();

      expect(metrics, isA<Map>());
      expect(metrics?.containsKey('totalProjects'), true);
      expect(metrics?.containsKey('completedTasks'), true);
    });
  });
}
