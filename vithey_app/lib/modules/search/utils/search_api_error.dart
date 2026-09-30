import 'package:aub_connect_app/data/services/post_search_service.dart';
import 'package:aub_connect_app/data/services/user_search_service.dart';

String searchApiErrorMessage(Object error) {
  if (error is UserSearchServiceException) return error.message;
  if (error is PostSearchServiceException) return error.message;
  return 'Search failed. Please try again.';
}
