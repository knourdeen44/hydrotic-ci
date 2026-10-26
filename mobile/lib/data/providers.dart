import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock/fixture_loader.dart';
import 'mock/mock_repositories.dart';
import 'repositories.dart';

// Point de branchement unique des dépôts : en phase 2, remplacer les Mock* par les dépôts API ici.

final fixtureLoaderProvider = Provider<FixtureLoader>((ref) => FixtureLoader());

final zoneRepositoryProvider =
    Provider<ZoneRepository>((ref) => MockZoneRepository(ref.watch(fixtureLoaderProvider)));

final riskRepositoryProvider =
    Provider<RiskRepository>((ref) => MockRiskRepository(ref.watch(fixtureLoaderProvider)));

final alertRepositoryProvider =
    Provider<AlertRepository>((ref) => MockAlertRepository(ref.watch(fixtureLoaderProvider)));

final reportRepositoryProvider =
    Provider<ReportRepository>((ref) => MockReportRepository(ref.watch(fixtureLoaderProvider)));

final sosRepositoryProvider =
    Provider<SosRepository>((ref) => MockSosRepository(ref.watch(fixtureLoaderProvider)));

final userRepositoryProvider =
    Provider<UserRepository>((ref) => MockUserRepository(ref.watch(fixtureLoaderProvider)));
