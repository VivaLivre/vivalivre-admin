import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'features/approvals/domain/repositories/admin_repository.dart';
import 'features/approvals/presentation/bloc/admin_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_shell_page.dart';
import 'features/dashboard/presentation/pages/dashboard_overview_page.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/moderation/presentation/pages/moderation_page.dart';
import 'features/moderation/domain/repositories/i_admin_moderation_repository.dart';
import 'features/moderation/data/repositories/admin_moderation_repository_impl.dart';
import 'features/moderation/presentation/bloc/admin_moderation_bloc.dart';
import 'features/users/presentation/pages/users_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/token_interceptor.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Inicializamos uma instância simples do Dio e adicionamos o interceptor de JWT
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
    dio.interceptors.add(TokenInterceptor(prefs: prefs));

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>(
          create: (context) => AuthRepositoryImpl(dio: dio, prefs: prefs),
        ),
        RepositoryProvider(create: (context) => AdminRepository()),
        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepositoryImpl(dio: dio),
        ),
        RepositoryProvider<IAdminModerationRepository>(
          create: (context) => AdminModerationRepositoryImpl(dio: dio),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              repository: context.read<IAuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AdminBloc(
              repository: context.read<AdminRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              repository: context.read<DashboardRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AdminModerationBloc(
              repository: context.read<IAdminModerationRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'VivaLivre Admin',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
            useMaterial3: true,
          ),
          initialRoute: '/admin/login',
          routes: {
            '/admin/login': (context) => const LoginPage(),
            '/admin/dashboard': (context) => const DashboardShellPage(
                  currentPath: '/admin/dashboard',
                  child: DashboardOverviewPage(),
                ),
            '/admin/moderacao': (context) => const DashboardShellPage(
                  currentPath: '/admin/moderacao',
                  child: ModerationPage(),
                ),
            '/admin/usuarios': (context) => const DashboardShellPage(
                  currentPath: '/admin/usuarios',
                  child: UsersPage(),
                ),
            '/admin/configuracoes': (context) => const DashboardShellPage(
                  currentPath: '/admin/configuracoes',
                  child: SettingsPage(),
                ),
          },
        ),
      ),
    );
  }
}
