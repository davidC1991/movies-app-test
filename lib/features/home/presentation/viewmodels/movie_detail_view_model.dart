import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/remote/error_message.dart';
import '../../../../core/state/ui_state.dart';
import '../../domain/entities/movie_detail.dart';
import '../providers/home_providers.dart';

/// ViewModel (MVVM) del detalle de una película. Familia por `id`: cada
/// película tiene su propia instancia/estado. Carga al construirse y expone
/// `UIState<MovieDetail>`.
final movieDetailViewModelProvider =
    NotifierProvider.family<MovieDetailViewModel, UIState<MovieDetail>, int>(
        MovieDetailViewModel.new);

class MovieDetailViewModel extends FamilyNotifier<UIState<MovieDetail>, int> {
  @override
  UIState<MovieDetail> build(int arg) {
    _load(arg);
    return const UILoading();
  }

  Future<void> _load(int id) async {
    state = const UILoading();
    try {
      final detail = await ref.read(movieUseCasesProvider).getDetail(id);
      state = UISuccess(detail);
    } catch (e) {
      state = UIFail(messageFromError(e));
    }
  }

  /// Reintenta la carga del detalle (tras un error).
  Future<void> retry() => _load(arg);
}
