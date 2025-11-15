import 'package:flutter/material.dart';

// ==============================
// Utilidades de paginación para listas en Dashboard
// ==============================

class PagedResult<T> {
  final List<T> items;
  final int currentPage; // página ya normalizada (clamped)
  final int totalPages;
  const PagedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
  });
}

/// Pagina una lista arbitraria devolviendo el slice, la página normalizada y total de páginas.
PagedResult<T> paginateList<T>(
  List<T> source, {
  required int page,
  required int pageSize,
}) {
  if (pageSize <= 0) {
    return PagedResult(items: source, currentPage: 0, totalPages: 1);
  }
  final totalPages = source.isEmpty ? 1 : (source.length / pageSize).ceil();
  int current = page;
  if (current >= totalPages) current = totalPages - 1;
  if (current < 0) current = 0;
  if (source.isEmpty) {
    return PagedResult(
        items: const [], currentPage: current, totalPages: totalPages);
  }
  final start = current * pageSize;
  final end =
      (start + pageSize) > source.length ? source.length : (start + pageSize);
  final slice = source.sublist(start, end);
  return PagedResult(
      items: slice, currentPage: current, totalPages: totalPages);
}

class PaginationControls extends StatelessWidget {
  final int currentPage; // 0-indexed
  final int totalPages; // >= 1
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Página ${totalPages == 0 ? 0 : currentPage + 1} de $totalPages'),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Anterior',
          onPressed: currentPage > 0 ? onPrev : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Siguiente',
          onPressed: (currentPage < totalPages - 1) ? onNext : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
