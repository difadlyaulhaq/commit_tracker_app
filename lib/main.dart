import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

// Import services
import 'services/github_service.dart';
import 'services/firestore_service.dart';

// Import blocs
import 'blocs/auth_bloc.dart';
import 'blocs/streak_bloc.dart';

// Import screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Initialize services as repositories
        RepositoryProvider<GitHubService>(
          create: (context) => GitHubService(),
        ),
        RepositoryProvider<FirestoreService>(
          create: (context) => FirestoreService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Initialize AuthBloc
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              // Pass your auth service here
            ),
          ),
          
          // Initialize StreakBloc with dependencies
          BlocProvider<StreakBloc>(
            create: (context) => StreakBloc(
              context.read<GitHubService>(),
              context.read<FirestoreService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Commit Tracker',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
            scaffoldBackgroundColor: Color(0xFF0D1117),
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return HomeScreen();
              }
              return LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}

// Service Locator Pattern (alternatif untuk dependency injection)
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final GitHubService _githubService = GitHubService();
  final FirestoreService _firestoreService = FirestoreService();

  GitHubService get githubService => _githubService;
  FirestoreService get firestoreService => _firestoreService;
}

// Extension untuk mempermudah akses service
extension BuildContextExtension on BuildContext {
  GitHubService get githubService => read<GitHubService>();
  FirestoreService get firestoreService => read<FirestoreService>();
}

// Error Handler untuk Bloc
class BlocErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Log error ke crash analytics (seperti Firebase Crashlytics)
    print('Bloc Error: $error');
    print('Stack Trace: $stackTrace');
    
    // Kirim ke crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

// Custom BlocObserver untuk monitoring
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    BlocErrorHandler.handleError(error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }
}

// Setup Bloc Observer di main function
void setupBlocObserver() {
  Bloc.observer = AppBlocObserver();
}