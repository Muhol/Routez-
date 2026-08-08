import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_app_bar.dart';
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

  final List<String> _recentSearches = [
    'Westlands, Nairobi',
    'CBD, Kencom Stage',
    'Upperhill, Hospital Road',
    'Yaya Centre, Kilimani',
  ];

  final List<Map<String, String>> _allSuggestions = [
    {'title': 'Westlands Stage', 'sub': 'Waiyaki Way, Nairobi'},
    {'title': 'CBD, Kencom', 'sub': 'City Hall Way, Nairobi'},
    {'title': 'Upperhill', 'sub': 'Hospital Road, Nairobi'},
    {'title': 'Yaya Centre', 'sub': 'Argwings Kodhek Rd'},
    {'title': 'Karen Shopping Centre', 'sub': 'Ngong Road, Nairobi'},
  ];

  void _swapLocations() {
    setState(() {
      final temp = _startController.text;
      _startController.text = _destController.text;
      _destController.text = temp;
    });
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _removeRecentSearch(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _destController.text.toLowerCase();
    final suggestions = _allSuggestions.where((item) {
      return item['title']!.toLowerCase().contains(query) ||
          item['sub']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: const GlassAppBar(
        title: Text('Find Route'),
      ),
      body: Column(
        children: [
          // Input Header Section
          Container(
            padding: const EdgeInsets.all(AppSizes.p16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Row(
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
                          height: 28,
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
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Starting location',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p16,
                                vertical: AppSizes.p12,
                              ),
                              suffixIcon: _startController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _startController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p12),
                          TextField(
                            controller: _destController,
                            autofocus: true,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Destination',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p16,
                                vertical: AppSizes.p12,
                              ),
                              suffixIcon: _destController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          _destController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.p8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _swapLocations,
                        icon: const Icon(Icons.swap_vert, color: AppColors.primary),
                        tooltip: 'Swap locations',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),
                // Action tile: Pick on Map
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pin location on map selected'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: AppSizes.p10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: AppSizes.p8),
                        Text(
                          'Choose location on map',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
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
          const Divider(height: 1),
          // Suggestions or Recent Searches
          Expanded(
            child: _destController.text.isNotEmpty
                ? ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final item = suggestions[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(item['title']!),
                        subtitle: Text(item['sub']!),
                        trailing: const Icon(Icons.north_west, size: 16),
                        onTap: () {
                          _destController.text = item['title']!;
                          context.push('/route-results');
                        },
                      );
                    },
                  )
                : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p16,
                          vertical: AppSizes.p8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            if (_recentSearches.isNotEmpty)
                              GestureDetector(
                                onTap: _clearRecentSearches,
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_recentSearches.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSizes.p32),
                          child: Center(
                            child: Text(
                              'No recent searches',
                              style: TextStyle(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(_recentSearches.length, (index) {
                          final item = _recentSearches[index];
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(item),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => _removeRecentSearch(index),
                            ),
                            onTap: () {
                              _destController.text = item;
                              context.push('/route-results');
                            },
                          );
                        }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
