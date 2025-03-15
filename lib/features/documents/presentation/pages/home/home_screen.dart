import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/formatters/formatter.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/pages/add_document/add_document_screen.dart';
import 'package:document_manager/features/documents/presentation/pages/view_edit_document/document_details_screen.dart';
import 'package:document_manager/features/documents/presentation/widgets/document_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DocumentBloc>().add(LoadDocuments());
            },
          ),
        ],
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            if (state is DocumentOperationSuccess) {
              DMAppMethods.showSnackBar(context, state.message, Colors.green);
            } else if (state is DocumentError) {
              DMAppMethods.showSnackBar(context, state.message, Colors.red);
            }
          }
        },
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DocumentError && state.previousDocuments == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading documents',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DocumentBloc>().add(LoadDocuments());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final documents = state is DocumentsLoaded
              ? state.documents
              : state is DocumentError && state.previousDocuments != null
                  ? state.previousDocuments!
                  : [];

          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Documents Yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first document by tapping the + button below',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _animation,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return DocumentListItem(
                  document: document,
                  isExpired: DMFormatter.isExpired(document.expiryDate),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentDetailsScreen(documentId: document.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDocumentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
