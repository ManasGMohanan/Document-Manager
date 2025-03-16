import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/core/utils/constants/colors.dart';
import 'package:document_manager/core/utils/constants/text_strings.dart';
import 'package:document_manager/core/utils/formatters/document_grouper.dart';
import 'package:document_manager/features/documents/domain/entities/document.dart';
import 'package:document_manager/features/documents/presentation/bloc/document/document_bloc.dart';
import 'package:document_manager/features/documents/presentation/pages/add_document/add_document_screen.dart';
import 'package:document_manager/features/documents/presentation/pages/home/widgets/document_grid_itesm.dart';
import 'package:document_manager/features/documents/presentation/pages/view_edit_document/document_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<DocumentBloc>().add(LoadDocuments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Manager'),
      ),
      body: BlocConsumer<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            if (state is DocumentOperationSuccess) {
              DMAppMethods.showSnackBar(
                  context, state.message, DMColors.success);
            } else if (state is DocumentError) {
              DMAppMethods.showSnackBar(context, state.message, DMColors.error);
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
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.folder_open,
                        size: 80,
                        color: DMColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        DMTexts.noDoc,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          DMTexts.addFirst,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Group documents by date
          final groupedDocuments =
              DocumentGrouper.groupDocumentsByDate(documents.cast<Document>());

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedDocuments.length,
              itemBuilder: (context, sectionIndex) {
                final sectionTitle =
                    groupedDocuments.keys.elementAt(sectionIndex);
                final sectionDocuments =
                    groupedDocuments.values.elementAt(sectionIndex);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        sectionTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                  color: DMColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: sectionDocuments.length,
                      itemBuilder: (context, index) {
                        final document = sectionDocuments[index];
                        final isExpired = document.expiryDate != null &&
                            DateTime.now().isAfter(document.expiryDate!);

                        return DocumentGridItem(
                          document: document,
                          isExpired: isExpired,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocumentDetailsScreen(
                                    documentId: document.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
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
