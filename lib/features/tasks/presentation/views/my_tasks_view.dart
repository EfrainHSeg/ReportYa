import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/tasks/data/models/task.dart';
import 'package:reportya/features/tasks/presentation/viewmodels/my_tasks_viewmodel.dart';

class MyTasksView extends StatefulWidget {
  const MyTasksView({super.key});

  @override
  State<MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends State<MyTasksView> {
  final _vm = MyTasksViewModel();

  @override
  void initState() {
    super.initState();
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) _vm.load(uid);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.naranjaFerreyros),
          );
        }
        if (_vm.error != null) {
          return Center(child: Text('Error: ${_vm.error}'));
        }
        if (_vm.tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined,
                    size: 64, color: AppColors.textoGris),
                SizedBox(height: 12),
                Text(
                  'No tienes tareas asignadas',
                  style: TextStyle(fontSize: 16, color: AppColors.textoGris),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _vm.tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _TaskCard(task: _vm.tasks[i]),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  Color get _statusColor => switch (task.status) {
        'completed'   => AppColors.aprobado,
        'in_progress' => AppColors.naranjaFerreyros,
        _             => AppColors.pendiente,
      };

  String get _statusLabel => switch (task.status) {
        'completed'   => 'Completado',
        'in_progress' => 'En progreso',
        _             => 'Pendiente',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.negro,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (task.description != null) ...[
            const SizedBox(height: 6),
            Text(
              task.description!,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textoGrisOscuro),
            ),
          ],
          if (task.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textoGris),
                const SizedBox(width: 4),
                Text(
                  task.dueDate!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textoGris),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
