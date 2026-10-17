import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/glass_app_bar.dart';
import 'package:routez/core/widgets/primary_button.dart';
import 'package:routez/core/widgets/empty_state_widget.dart';
import 'package:routez/core/services/location_service.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  final FocusNode _startFocusNode = FocusNode();
  final FocusNode _destFocusNode = FocusNode();

  bool _isStartFocused = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();

    _startFocusNode.addListener(() {
      if (_startFocusNode.hasFocus) {
        setState(() => _isStartFocused = true);
      }
    });

    _destFocusNode.addListener(() {
      if (_destFocusNode.hasFocus) {
        setState(() => _isStartFocused = false);
      }
    });
  }

  @override
  void dispose() {
    _startFocusNode.dispose();
    _destFocusNode.dispose();
    _startController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final pos = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _startController.text = pos != null
          ? 'My Current Location'
          : 'Pipeline Stage (default)';
    });
  }

  final List<String> _recentSearches = [];

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

  void _performSearch(String origin, String dest) {
    final searchOrigin = origin.isNotEmpty ? origin : 'Pipeline Stage';
    final searchDest = dest.isNotEmpty ? dest : 'Westlands Stage';
    context.push(
      '/route-results',
      extra: {
        'origin': searchOrigin,
        'destination': searchDest,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get query based on whichever field user is currently editing
    final activeController = _isStartFocused ? _startController : _destController;
    final searchQuery = activeController.text.trim();

    final stageAutocompleteAsync = ref.watch(stageAutocompleteProvider(searchQuery));
    final placesAutocompleteAsync = ref.watch(googlePlacesAutocompleteProvider(searchQuery));

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
                            focusNode: _startFocusNode,
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
                            focusNode: _destFocusNode,
                            autofocus: true,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search destination or landmark',
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
                    IconButton(
                      icon: const Icon(Icons.swap_vert, color: AppColors.primary),
                      onPressed: _swapLocations,
                      tooltip: 'Swap locations',
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p16),
                PrimaryButton(
                  text: 'Search Matatu Routes',
                  onPressed: () => _performSearch(
                    _startController.text,
                    _destController.text,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Autocomplete or Recent Searches List
          Expanded(
            child: searchQuery.isNotEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                    children: [
                      // --- Database Stages Section ---
                      stageAutocompleteAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (stages) {
                          if (stages.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.p16,
                                  vertical: AppSizes.p4,
                                ),
                                child: Text(
                                  'Matatu Stages',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              ...stages.map((stage) {
                                return ListTile(
                                  leading: const Icon(Icons.directions_bus, color: AppColors.primary),
                                  title: Text(stage.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(stage.area),
                                  trailing: const Icon(Icons.north_west, size: 16, color: AppColors.textSecondaryLight),
                                  onTap: () {
                                    if (_isStartFocused) {
                                      _startController.text = stage.name;
                                    } else {
                                      _destController.text = stage.name;
                                    }
                                    _performSearch(_startController.text, _destController.text);
                                  },
                                );
                              }),
                              const Divider(),
                            ],
                          );
                        },
                      ),

                      // --- Google Places Predictions Section ---
                      placesAutocompleteAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSizes.p16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          child: Center(child: Text('Places error: $err')),
                        ),
                        data: (places) {
                          if (places.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(AppSizes.p24),
                              child: Center(
                                child: Text(
                                  'No places found matching search',
                                  style: TextStyle(color: AppColors.textSecondaryLight),
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.p16,
                                  vertical: AppSizes.p4,
                                ),
                                child: Text(
                                  'Google Places & Landmarks',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent,
                                      ),
                                ),
                              ),
                              ...places.map((place) {
                                return ListTile(
                                  leading: const Icon(Icons.place_outlined, color: AppColors.accent),
                                  title: Text(
                                    place.mainText,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    place.secondaryText.isNotEmpty ? place.secondaryText : place.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.north_west, size: 16, color: AppColors.textSecondaryLight),
                                  onTap: () {
                                    if (_isStartFocused) {
                                      _startController.text = place.mainText;
                                    } else {
                                      _destController.text = place.mainText;
                                    }
                                    _performSearch(_startController.text, _destController.text);
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  )
                : _recentSearches.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.search_off_outlined,
                        title: 'No Recent Searches',
                        message: 'Type a destination, stage, or landmark above to search for matatu routes.',
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p16,
                              vertical: AppSizes.p8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TextButton(
                                  onPressed: _clearRecentSearches,
                                  child: const Text('Clear All'),
                                ),
                              ],
                            ),
                          ),
                          ...List.generate(_recentSearches.length, (index) {
                            final item = _recentSearches[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.history,
                                color: AppColors.textSecondaryLight,
                              ),
                              title: Text(item),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => _removeRecentSearch(index),
                              ),
                              onTap: () {
                                _destController.text = item;
                                _performSearch(_startController.text, item);
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
