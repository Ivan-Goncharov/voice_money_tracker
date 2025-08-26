0) Границы и безопасность для агента

Не менять pubspec.yaml, CI, .melos, android/, ios/, web/ без явной задачи.

Работать только в пределах текущей фичи: lib/features/<feature>/**.

Не добавлять новые зависимости без явного указания.

Всегда использовать подход BLoC → Interactor → Repository из этого файла.

1) Слои и обязанности

Presentation (BLoC/Cubit)

Принимает события, хранит UI-состояние (Equatable, immutable).

Делегирует бизнес-логику только в Interactor.

Побочные эффекты (диалоги/навигация/snackbar) — через BlocListener.

Interactor (Application layer / use cases)

Оркестрирует бизнес-правила, агрегирует несколько репозиториев/сервисов.

Предоставляет потоки (например, users$) для подписки блоками.

Нормализует ошибки в тип Failure.

Repository

Интерфейсы для данных (remote/local/cache). Имплементации скрыты за интерфейсами.

Не знает о UI; возвращает доменные сущности/DTO.

Структура фичи (пример):

lib/features/users/
  presentation/  # blocs, views, widgets
  domain/   # interactor(s), use-cases, entities, failures,
  data/     #  repository interfaces


2) Состояние (State) — единая модель со статусами операций

Правило: не плодить isLoading/isRefreshing/.... Для каждой операции — статус и ошибка.

enum Op { load, refresh, create, update, delete, paginate, search }
enum Status { idle, loading, success, failure }

class Failure {
  final String message;
  const Failure(this.message);
}

class UserState extends Equatable {
  final List<User> users;
  final Map<Op, Status> status;        // ex: {Op.load: Status.loading}
  final Map<Op, Failure?> errors;      // ex: {Op.load: NetworkFailure(...)}
  final String query;
  final int page;
  final bool hasMore;

  const UserState({
    this.users = const [],
    this.status = const {},
    this.errors = const {},
    this.query = '',
    this.page = 0,
    this.hasMore = true,
  });

  bool busy(Op op) => status[op] == Status.loading;
  Failure? errorOf(Op op) => errors[op];

  UserState copyWith({
    List<User>? users,
    Map<Op, Status>? status,
    Map<Op, Failure?>? errors,
    String? query,
    int? page,
    bool? hasMore,
  }) => UserState(
    users: users ?? this.users,
    status: status ?? this.status,
    errors: errors ?? this.errors,
    query: query ?? this.query,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
  );

  @override
  List<Object?> get props => [users, status, errors, query, page, hasMore];
}

3) События (Events) — прошедшее время, конкретные действия

Именование: UsersLoadRequested, UsersLoadMoreRequested, UserCreated, UserUpdated, UserDeleted, UserSearchChanged, UserErrorCleared(Op).

Запреты:

Нельзя: LoadData, ApplyFilter, ChangeSearch.

События не должны содержать UI-детали (например, ShowSnackbar).

4) BLoC — только координация, конкурентность через трансформеры

Использовать bloc_concurrency:

загрузка/пагинация — droppable();

поиск — debounce(Duration(milliseconds: 300–500));

долгие операции — не блокировать другие события.

Подписки на потоки интерактора в конструкторе BLoC; отписка в close().

Шаблон:

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserInteractor _interactor;
  late final StreamSubscription _sub;

  UserBloc(this._interactor) : super(const UserState()) {
    on<UsersLoadRequested>(_onLoadRequested, transformer: droppable());
    on<UsersLoadMoreRequested>(_onLoadMoreRequested, transformer: droppable());
    on<UserSearchChanged>(_onSearchChanged, transformer: debounce(const Duration(milliseconds: 400)));
    on<_UsersSynced>(_onUsersSynced);

    _sub = _interactor.users$.listen((list) => add(_UsersSynced(list)));
  }

  Future<void> _onLoadRequested(UsersLoadRequested e, Emitter<UserState> emit) async {
    emit(_setStatus(Op.load, Status.loading));
    final r = await _interactor.loadPage(page: 0, q: state.query);
    r.fold(
      (f)  => emit(_fail(Op.load, f)),
      (ok) => emit(state.copyWith(users: ok.users, page: 0, hasMore: ok.hasMore)
                      .copyWith(status: {...state.status, Op.load: Status.success})),
    );
  }

  Future<void> _onLoadMoreRequested(UsersLoadMoreRequested e, Emitter<UserState> emit) async {
    if (!state.hasMore || state.busy(Op.paginate)) return;
    emit(_setStatus(Op.paginate, Status.loading));
    final r = await _interactor.loadPage(page: state.page + 1, q: state.query);
    r.fold(
      (f)  => emit(_fail(Op.paginate, f)),
      (ok) => emit(state.copyWith(
              users: [...state.users, ...ok.users],
              page: state.page + 1,
              hasMore: ok.hasMore,
            ).copyWith(status: {...state.status, Op.paginate: Status.success})),
    );
  }

  void _onSearchChanged(UserSearchChanged e, Emitter<UserState> emit) {
    emit(state.copyWith(query: e.query));
    add(const UsersLoadRequested());
  }

  void _onUsersSynced(_UsersSynced e, Emitter<UserState> emit) {
    emit(state.copyWith(users: e.users));
  }

  @override
  Future<void> close() { _sub.cancel(); return super.close(); }

  // helpers
  UserState _setStatus(Op op, Status s) =>
    state.copyWith(status: {...state.status, op: s}, errors: {...state.errors, op: null});

  UserState _fail(Op op, Failure f) =>
    state.copyWith(status: {...state.status, op: Status.failure}, errors: {...state.errors, op: f});
}


_UsersSynced — внутреннее событие, создаётся только из подписки на interactor.users$.

5) Interactor — единая точка бизнес-правил

Обязанности:

Агрегировать несколько репозиториев.

Нормализовать исключения → Failure.

Давать потоки доменных сущностей (Stream<List<User>> users$).

Шаблон:

abstract interface class UserInteractor {
  Stream<List<User>> get users$;
  Future<Either<Failure, ({List<User> users, int totalCount, bool hasMore})>> loadPage({required int page, String? q});
  Future<Either<Failure, User>> create({required String name, required String email});
  Future<Either<Failure, User>> update({required int id, String? name, String? email});
  Future<Either<Failure, void>> delete(int id);
}

6) Repository — чистые контракты
abstract interface class UserRepository {
  Stream<List<User>> watchAll();
  Future<({List<User> users, int totalCount, bool hasMore})> fetch({required int page, String? q});
  Future<User> create({required String name, required String email});
  Future<User> update({required int id, String? name, String? email});
  Future<void> delete({required int id});
}

7) UI-слой

BlocBuilder с buildWhen и BlocSelector для минимизации перестроений.

Любые side-effects — только BlocListener.

Производные вычисления (фильтрация/сортировка) делать в интеракторе или селекторах, а не в геттерах State.

8) Взаимодействие между блоками

Только через Interactor/streams. Запрещено напрямую читать состояние других блоков.

Общие события приложения — через отдельный поток (шина событий) в application-слое.

9) DI и жизненный цикл

Регистрация: Repo → Interactor → Bloc.
GetIt.registerSingleton<UserRepository>(...);
GetIt.registerSingleton<UserInteractor>(UserInteractorImpl(repo: GetIt<UserRepository>()));
GetIt.registerFactory(() => UserBloc(GetIt<UserInteractor>()));

Все подписки закрывать в bloc.close().
