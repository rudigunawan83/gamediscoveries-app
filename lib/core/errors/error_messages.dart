import 'package:dio/dio.dart';

import '../../l10n/app_localizations.dart';
import '../network/api_exception.dart';

const Set<String> _networkErrorTypes = <String>{
  'connectionError',
  'connectionTimeout',
  'receiveTimeout',
  'sendTimeout',
};

String friendlyErrorMessage(AppLocalizations l10n, Object error) {
  if (error is ApiException) {
    if (_networkErrorTypes.contains(error.type)) return l10n.errorOffline;

    return switch (error.statusCode) {
      401 => l10n.errorSessionExpired,
      403 => l10n.errorForbidden,
      404 => l10n.errorNotFound,
      429 => l10n.errorTooManyRequests,
      final int code when code >= 500 => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
  }

  if (error is DioException) return l10n.errorOffline;

  return l10n.errorGeneric;
}
