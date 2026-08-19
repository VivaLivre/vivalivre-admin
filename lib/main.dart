import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

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
import 'features/crowdsource/domain/repositories/i_crowdsource_repository.dart';
import 'features/crowdsource/data/repositories/crowdsource_repository_impl.dart';
import 'features/crowdsource/presentation/bloc/crowdsource_bloc.dart';
import 'features/crowdsource/presentation/pages/crowdsource_moderation_page.dart';
import 'features/bathroom_management/domain/repositories/i_bathroom_management_repository.dart';
import 'features/bathroom_management/data/repositories/bathroom_management_repository_impl.dart';
import 'features/bathroom_management/presentation/bloc/bathroom_crud_bloc.dart';
import 'features/bathroom_management/presentation/pages/manage_bathrooms_page.dart';
import 'features/users/domain/repositories/i_admin_user_repository.dart';
import 'features/users/data/repositories/admin_user_repository_impl.dart';
import 'features/users/presentation/bloc/users_bloc_impl.dart';
import 'core/theme/app_themes.dart';
import 'core/theme/theme_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/token_interceptor.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

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
    String baseUrl = const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://vivalivre-backend-production.up.railway.app',
    );
    final dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(TokenInterceptor(prefs: prefs));

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IAuthRepository>(
          create: (context) => AuthRepositoryImpl(dio: dio, prefs: prefs),
        ),

        RepositoryProvider<DashboardRepository>(
          create: (context) => DashboardRepositoryImpl(dio: dio),
        ),
        RepositoryProvider<IAdminModerationRepository>(
          create: (context) => AdminModerationRepositoryImpl(dio: dio),
        ),
        RepositoryProvider<ICrowdsourceRepository>(
          create: (context) => CrowdsourceRepositoryImpl(dio: dio),
        ),
        RepositoryProvider<IBathroomManagementRepository>(
          create: (context) => BathroomManagementRepositoryImpl(dio),
        ),
        RepositoryProvider<IAdminUserRepository>(
          create: (context) => AdminUserRepositoryImpl(dio: dio),
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
            create: (context) => DashboardBloc(
              repository: context.read<DashboardRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AdminModerationBloc(
              repository: context.read<IAdminModerationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CrowdsourceBloc(
              repository: context.read<ICrowdsourceRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BathroomCrudBloc(
              repository: context.read<IBathroomManagementRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => UsersBlocImpl(
              repository: context.read<IAdminUserRepository>(),
            ),
          ),
          BlocProvider<ThemeBloc>(
            create: (_) => ThemeBloc(prefs: prefs),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) => MaterialApp(
            title: 'VivaLivre Admin',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: themeState.mode,
            navigatorKey: globalNavigatorKey,
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
            '/admin/crowdsource': (context) => const DashboardShellPage(
                  currentPath: '/admin/crowdsource',
                  child: CrowdsourceModerationPage(),
                ),
            '/admin/locais': (context) => const DashboardShellPage(
                  currentPath: '/admin/locais',
                  child: ManageBathroomsPage(),
                ),
            },
          ),
        ),
      ),
    );
  }
}
