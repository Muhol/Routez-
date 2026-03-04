import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _startController = TextEditingController(
    text: 'Current Location',
  );
  final TextEditingController _destController = TextEditingController();

  void _swapLocations() {
    final temp = _startController.text;
    _startController.text = _destController.text;
    _destController.text = temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Route'), elevation: 0),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    Container(
                      width: 2,
                      height: 24,
                      color: AppColors.dividerLight,
                    ),
                    const Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _startController,
                        decoration: const InputDecoration(
                          hintText: 'Starting location',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p8,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.p12),
                      TextField(
                        controller: _destController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Destination',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.p8),
                IconButton(
                  onPressed: _swapLocations,
                  icon: const Icon(Icons.swap_vert),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: PrimaryButton(
              text: 'Search Routes',
              onPressed: () {
                if (_destController.text.isNotEmpty) {
                  context.push('/route-results');
                }
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p8,
                  ),
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Westlands'),
                  subtitle: const Text('Nairobi'),
                  onTap: () {
                    _destController.text = 'Westlands';
                    context.push('/route-results');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('CBD, Kencom'),
                  subtitle: const Text('Nairobi City'),
                  onTap: () {
                    _destController.text = 'CBD, Kencom';
                    context.push('/route-results');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
