import 'package:flutter/material.dart';
import '../../domain/entities/bathroom.dart';

class BathroomCard extends StatelessWidget {
  final Bathroom bathroom;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BathroomCard({
    super.key,
    required this.bathroom,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status color
    Color statusColor;
    String statusText;
    switch (bathroom.status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Aprovado';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendente';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejeitado';
        break;
      default:
        statusColor = Colors.grey;
        statusText = bathroom.status;
    }

    // Photo URL check
    // If we have an implementation of bathroom.photoUrl, we'd use it here.
    // However, the current Bathroom model might not have photoUrl yet.
    // Let's assume bathroom has a photoUrl, we need to add it to the entity if not present.
    // For now, I'll use a placeholder if null.

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (bathroom.photoUrl != null && bathroom.photoUrl!.isNotEmpty)
                  Image.network(
                    bathroom.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF232634)
                          : Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF232634)
                        : Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
                // Status Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bathroom.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bathroom.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8891A8)
                          : Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF2563EB)),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: 'Excluir',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
