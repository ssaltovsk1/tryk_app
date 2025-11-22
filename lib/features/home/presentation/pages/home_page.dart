import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/lesson.dart';
import '../widgets/module_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final modules = _getDemoModules();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Привет, юный Защитник!',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выбери модуль для обучения и борьбы с мошенничеством!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  return ModuleCard(module: modules[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Module> _getDemoModules() {
    return [
      const Module(
        id: '1',
        title: 'Введение',
        description: 'Основы кибербезопасности',
        iconName: 'lightbulb',
        color: '#4ECDC4',
        badgeCount: 1,
      ),
      const Module(
        id: '2',
        title: 'Модели Мошенничества',
        description: 'Изучаем схемы мошенников',
        iconName: 'brain',
        color: '#9B59B6',
        badgeCount: 2,
      ),
      const Module(
        id: '3',
        title: 'Тренировка',
        description: 'Практические задания',
        iconName: 'trophy',
        color: '#E74C3C',
        badgeCount: 1,
      ),
      const Module(
        id: '4',
        title: 'Детективный Квест',
        description: 'Расследуй кибер-преступления',
        iconName: 'search',
        color: '#F39C12',
        badgeCount: 3,
      ),
      const Module(
        id: '5',
        title: 'Образование',
        description: 'Учись безопасности',
        iconName: 'school',
        color: '#3498DB',
        badgeCount: 1,
      ),
    ];
  }
}
