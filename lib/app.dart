import 'package:document_manager/core/theme/theme.dart';
import 'package:document_manager/core/utils/constants/text_strings.dart';
import 'package:document_manager/features/documents/data/models/category_model.dart';
import 'package:document_manager/features/documents/data/models/document_model.dart';
import 'package:document_manager/features/documents/data/repositories/category_repository_impl.dart';
import 'package:document_manager/features/documents/data/repositories/document_repository_impl.dart';
import 'package:document_manager/features/documents/domain/repositories/category_repository.dart';
import 'package:document_manager/features/documents/domain/repositories/document_repository.dart';
import 'package:document_manager/features/documents/presentation/bloc/category/category_bloc.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/pages/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DocumentRepository>(
          create: (context) =>
              DocumentRepositoryImpl(Hive.box<DocumentModel>('documents')),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) =>
              CategoryRepositoryImpl(Hive.box<CategoryModel>('categories')),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DocumentBloc(
              repository: context.read<DocumentRepository>(),
            )..add(LoadDocuments()),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              repository: context.read<CategoryRepository>(),
            )..add(LoadCategories()),
          ),
        ],
        child: MaterialApp(
          title: DMTexts.appName,
          themeMode: ThemeMode.light,
          theme: DMAppTheme.lightTheme,
          // darkTheme: DMAppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
