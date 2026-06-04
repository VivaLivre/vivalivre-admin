import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bathroom.dart';
import '../bloc/bathroom_crud_bloc.dart';
import '../widgets/bathroom_card.dart';
import '../widgets/bathroom_form_dialog.dart';

class ManageBathroomsPage extends StatefulWidget {
  const ManageBathroomsPage({super.key});

  @override
  State<ManageBathroomsPage> createState() => _ManageBathroomsPageState();
}

class _ManageBathroomsPageState extends State<ManageBathroomsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Inicia a primeira busca assim que entra
    context.read<BathroomCrudBloc>().add(FetchBathroomsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<BathroomCrudBloc>().add(FetchBathroomsEvent(search: query, page: 1));
    });
  }

  Future<void> _showFormDialog({Bathroom? bathroom}) async {
    // Capture bloc before async gap to avoid use_build_context_synchronously
    final bloc = context.read<BathroomCrudBloc>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BathroomFormDialog(bathroom: bathroom),
    );

    if (result != null) {
      if (bathroom == null) {
        // Create
        bloc.add(CreateBathroomEvent(result));
      } else {
        // Update
        bloc.add(UpdateBathroomEvent(bathroom.id, result));
      }
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Excluir Banheiro'),
          content: const Text('Tem certeza de que deseja excluir este banheiro? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                context.read<BathroomCrudBloc>().add(DeleteBathroomEvent(id));
                Navigator.of(ctx).pop();
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestão de Banheiros',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome ou endereço...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<BathroomCrudBloc, BathroomCrudState>(
              builder: (context, state) {
                if (state is BathroomCrudLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BathroomCrudError) {
                  return Center(
                    child: Text('Erro: ${state.message}', style: const TextStyle(color: Colors.red)),
                  );
                } else if (state is BathroomCrudLoaded) {
                  final bathrooms = state.bathrooms;
                  final meta = state.meta;

                  if (bathrooms.isEmpty) {
                    return const Center(child: Text('Nenhum banheiro encontrado.'));
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisExtent: 320,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: meta.page == 1 ? bathrooms.length + 1 : bathrooms.length,
                          itemBuilder: (context, index) {
                            if (meta.page == 1 && index == 0) {
                              return Card(
                                color: Colors.blue.shade50,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.blue.shade200, width: 2, style: BorderStyle.solid),
                                ),
                                child: InkWell(
                                  onTap: () => _showFormDialog(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_circle_outline, size: 48, color: Colors.blue),
                                        SizedBox(height: 8),
                                        Text('Novo Banheiro', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final bathroomIndex = meta.page == 1 ? index - 1 : index;
                            final b = bathrooms[bathroomIndex];

                            return BathroomCard(
                              bathroom: b,
                              onEdit: () => _showFormDialog(bathroom: b),
                              onDelete: () => _showDeleteDialog(b.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pagination Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: meta.page > 1
                                ? () {
                                    context.read<BathroomCrudBloc>().add(
                                          FetchBathroomsEvent(
                                            page: meta.page - 1,
                                            limit: meta.limit,
                                            search: state.searchQuery,
                                          ),
                                        );
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            label: const Text('Anterior'),
                          ),
                          const SizedBox(width: 16),
                          Text('Página ${meta.page} de ${meta.totalPages}'),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: meta.page < meta.totalPages
                                ? () {
                                    context.read<BathroomCrudBloc>().add(
                                          FetchBathroomsEvent(
                                            page: meta.page + 1,
                                            limit: meta.limit,
                                            search: state.searchQuery,
                                          ),
                                        );
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            label: const Text('Próxima'),
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
