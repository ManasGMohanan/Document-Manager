import 'package:document_manager/core/utils/app_methods/app_methods.dart';
import 'package:document_manager/features/documents/presentation/bloc/category/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String? _selectedCategoryId;
  bool _isAddingCategory = false;
  final _categoryNameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.folder;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final List<IconData> _availableIcons = [
    Icons.folder,
    Icons.description,
    Icons.picture_as_pdf,
    Icons.image,
    Icons.video_library,
    Icons.audiotrack,
    Icons.article,
    Icons.attach_file,
    Icons.book,
    Icons.receipt,
    Icons.assignment,
    Icons.sticky_note_2,
    Icons.note,
    Icons.text_snippet,
    Icons.inventory,
    Icons.work,
    Icons.school,
    Icons.medical_services,
    Icons.home,
    Icons.car_rental,
    Icons.flight,
    Icons.shopping_bag,
    Icons.credit_card,
    Icons.account_balance,
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _addCategory() {
    if (_categoryNameController.text.trim().isEmpty) {
      DMAppMethods.showSnackBar(
          context, 'Please enter a category name', Colors.red);
      return;
    }

    context.read<CategoryBloc>().add(
          AddCategory(
            name: _categoryNameController.text.trim(),
            colorValue: _selectedColor.value,
            iconData: _selectedIcon.codePoint,
          ),
        );

    _categoryNameController.clear();
    setState(() {
      _isAddingCategory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final categories = state is CategoriesLoaded
            ? state.categories
            : state is CategoryError && state.previousCategories != null
                ? state.previousCategories!
                : [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isAddingCategory) ...[
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select a category',
                  prefixIcon: Icon(Icons.category),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    hint: const Text('Select a category'),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                      if (value != null) {
                        widget.onCategorySelected(value);
                      }
                    },
                    items: [
                      ...categories.map((category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Row(
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingCategory = true;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Category'),
              ),
            ] else ...[
              // Add new category form
              TextFormField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 20,
                          child: _selectedColor == color
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Icon',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: _selectedIcon == icon
                              ? _selectedColor
                              : Colors.grey.shade200,
                          radius: 20,
                          child: Icon(
                            icon,
                            color: _selectedIcon == icon
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isAddingCategory = false;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addCategory,
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
