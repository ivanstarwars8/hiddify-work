import 'package:hiddify/features/profile/data/profile_data_providers.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/utils/link_parsers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final hasValidGoBullSubscriptionProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(profileRepositoryProvider).requireValue;
  return repo.watchAll().map(
        (event) => event
            .map(
              (profiles) => profiles.any((p) {
                if (p is! RemoteProfileEntity) return false;
                if (!isAllowedSubscriptionUrl(p.url)) return false;
                final sub = p.subInfo;
                // If subscription info is present, it must not be expired.
                return sub == null || !sub.isExpired;
              }),
            )
            .getOrElse((l) => throw l),
      );
});


