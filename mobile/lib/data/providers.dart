import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_repositories.dart';
import 'api/client.dart';
import 'mock/fixture_loader.dart';
import 'mock/mock_repositories.dart';
import 'mode.dart';
import 'position.dart';
import 'repositories.dart';

// Point de branchement unique des dépôts : API Hydrotic en mode réel, fixtures en mode démo.

final fixtureLoaderProvider = Provider<FixtureLoader>((ref) => FixtureLoader());

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Position GPS de l'appareil (mode réel seulement : aucune demande d'autorisation en démo).
final positionGpsProvider =
    FutureProvider<PositionGps?>((ref) => modeApi ? lirePositionGps() : Future.value(null));

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) => modeApi
    ? ApiZoneRepository(ref.watch(apiClientProvider))
    : MockZoneRepository(ref.watch(fixtureLoaderProvider)));

final riskRepositoryProvider = Provider<RiskRepository>((ref) => modeApi
    ? ApiRiskRepository(ref.watch(apiClientProvider))
    : MockRiskRepository(ref.watch(fixtureLoaderProvider)));

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final fixtures = MockAlertRepository(ref.watch(fixtureLoaderProvider));
  return modeApi ? ApiAlertRepository(ref.watch(apiClientProvider), fixtures) : fixtures;
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) => modeApi
    ? ApiReportRepository(ref.watch(apiClientProvider), () => ref.read(positionGpsProvider.future))
    : MockReportRepository(ref.watch(fixtureLoaderProvider)));

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  final fixtures = MockSosRepository(ref.watch(fixtureLoaderProvider));
  return modeApi
      ? ApiSosRepository(ref.watch(apiClientProvider), () => ref.read(positionGpsProvider.future), fixtures)
      : fixtures;
});

final userRepositoryProvider = Provider<UserRepository>((ref) => modeApi
    ? ApiUserRepository(ref.watch(apiClientProvider), ref.watch(zoneRepositoryProvider))
    : MockUserRepository(ref.watch(fixtureLoaderProvider)));
