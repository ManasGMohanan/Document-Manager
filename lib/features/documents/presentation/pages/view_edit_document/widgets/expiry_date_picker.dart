import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpiryDatePicker extends StatelessWidget {
  final DateTime? expiryDate;
  final Function(DateTime?) onDateChanged;
  final String? labelText;
  final bool useBoxDecoration;

  const ExpiryDatePicker({
    super.key,
    required this.expiryDate,
    required this.onDateChanged,
    this.labelText = 'Expiry Date',
    this.useBoxDecoration = false,
  });

  Future<void> _selectExpiryDate(BuildContext context) async {
    final initialDate = expiryDate; // issue solved

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (pickedDate != null) {
      onDateChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (useBoxDecoration) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => _selectExpiryDate(context),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelText ?? 'Expiry Date',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expiryDate != null
                            ? DateFormat('MMMM dd, yyyy').format(expiryDate!)
                            : 'No expiry date',
                        style: TextStyle(
                          fontSize: 12,
                          color: expiryDate != null
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (expiryDate != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => onDateChanged(null),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _selectExpiryDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText != null
              ? '$labelText (Optional)'
              : 'Expiry Date (Optional)',
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              expiryDate != null
                  ? DateFormat('MMM dd, yyyy').format(expiryDate!)
                  : 'No expiry date',
            ),
            if (expiryDate != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onDateChanged(null),
              ),
          ],
        ),
      ),
    );
  }
}
