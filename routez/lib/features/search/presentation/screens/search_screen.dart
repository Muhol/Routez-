import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/glass_app_bar.dart';
import 'package:routez/core/widgets/edge_fade_scroller.dart';
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

  final List<String> _quickDestinations = [
    'CBD Kencom',
    'Westlands Stage',
    'Pipeline Stage',
    'Upper Hill',
    'Ngong Road',
    'Thika Road',
  ];

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

  void _swapLocations() {
    setState(() {
      final temp = _startController.text;
      _startController.text = _destController.text;
      _destController.text = temp;
    });
  }

  void _performSearch(String origin, String dest) {
    final searchOrigin = origin.trim().isNotEmpty ? origin.trim() : 'Pipeline Stage';
    final searchDest = dest.trim().isNotEmpty ? dest.trim() : 'Westlands Stage';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeController = _isStartFocused ? _startController : _destController;
    final searchQuery = activeController.text.trim();

    final stageAutocompleteAsync = ref.watch(stageAutocompleteProvider(searchQuery));
    final placesAutocompleteAsync = ref.watch(googlePlacesAutocompleteProvider(searchQuery));

    final cardBg = isDark ? const Color(0xFF161C23) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB),
      appBar: GlassAppBar(
        title: const Text('Find Matatu Route'),
        actions: [
          if (_startController.text.isNotEmpty || _destController.text.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _startController.clear();
                  _destController.clear();
                });
              },
              child: Text(
                'Clear',
                style: TextStyle(
                  color: isDark ? AppColors.accent : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Input Box ────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p8, AppSizes.p16, AppSizes.p12),
            padding: const EdgeInsets.all(AppSizes.p16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Route Connector Dots
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 38,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.accent : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.p12),

                    // Text Inputs
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _startController,
                            focusNode: _startFocusNode,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : AppColors.textLight,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Current location or stage',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              isDense: true,
                              suffixIcon: _startController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => setState(() => _startController.clear()),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          Divider(
                            height: 14,
                            thickness: 1,
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                          ),
                          TextField(
                            controller: _destController,
                            focusNode: _destFocusNode,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textLight,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Where do you want to go?',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              isDense: true,
                              suffixIcon: _destController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => setState(() => _destController.clear()),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _performSearch(_startController.text, _destController.text),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSizes.p8),

                    // Swap Locations Button
                    GestureDetector(
                      onTap: _swapLocations,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.p8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.swap_vert_rounded,
                          color: isDark ? AppColors.accent : AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.p14),

                // Search Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _performSearch(_startController.text, _destController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus_rounded, size: 18),
                        SizedBox(width: AppSizes.p8),
                        Text(
                          'Search Matatu Routes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Quick Chips Row (Runs edge-to-edge, fading into screen edges) ──
          EdgeFadeScroller(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
            fadeWidth: 28,
            child: Row(
              children: _quickDestinations.map((name) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.p8),
                  child: InkWell(
                    onTap: () {
                      setState(() => _destController.text = name);
                      _performSearch(_startController.text, name);
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E252E) : Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.north_east_rounded,
                            size: 13,
                            color: isDark ? AppColors.accent : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: AppSizes.p12),

          // ── Autocomplete / Suggestions List ────────────────────────────────
          Expanded(
            child: searchQuery.isNotEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Database Stages Section
                      stageAutocompleteAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (stages) {
                          if (stages.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                                child: Text(
                                  'MATATU STAGES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: isDark ? AppColors.accent : AppColors.primary,
                                  ),
                                ),
                              ),
                              ...stages.map((stage) {
                                return _buildResultTile(
                                  context: context,
                                  title: stage.name,
                                  subtitle: stage.area,
                                  icon: Icons.directions_bus_rounded,
                                  isDark: isDark,
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
                              const SizedBox(height: AppSizes.p8),
                            ],
                          );
                        },
                      ),

                      // Google Places Predictions Section
                      placesAutocompleteAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSizes.p24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          child: Center(
                            child: Text(
                              'Places error: $err',
                              style: const TextStyle(fontSize: 12, color: AppColors.error),
                            ),
                          ),
                        ),
                        data: (places) {
                          if (places.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSizes.p32),
                              child: Center(
                                child: Text(
                                  'No matching locations found',
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                                child: Text(
                                  'PLACES & LANDMARKS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                              ...places.map((place) {
                                return _buildResultTile(
                                  context: context,
                                  title: place.mainText,
                                  subtitle: place.secondaryText,
                                  icon: Icons.place_rounded,
                                  isDark: isDark,
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
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                        child: Text(
                          'POPULAR TRANSIT HUBS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      _buildResultTile(
                        context: context,
                        title: 'Kencom House Stage',
                        subtitle: 'Moi Avenue, Nairobi CBD • Routes 23, 46, 111',
                        icon: Icons.directions_bus_rounded,
                        isDark: isDark,
                        onTap: () => _performSearch(_startController.text, 'Kencom Stage'),
                      ),
                      _buildResultTile(
                        context: context,
                        title: 'Westlands Commercial Stage',
                        subtitle: 'Waiyaki Way • Routes 23W, 105, 118',
                        icon: Icons.directions_bus_rounded,
                        isDark: isDark,
                        onTap: () => _performSearch(_startController.text, 'Westlands Stage'),
                      ),
                      _buildResultTile(
                        context: context,
                        title: 'Pipeline Matatu Stage',
                        subtitle: 'Outer Ring Road, Embakasi • Routes 33, 34',
                        icon: Icons.directions_bus_rounded,
                        isDark: isDark,
                        onTap: () => _performSearch(_startController.text, 'Pipeline Stage'),
                      ),
                      _buildResultTile(
                        context: context,
                        title: 'Railways Bus Station',
                        subtitle: 'Haile Selassie Avenue • Routes 125, 126, Ngong',
                        icon: Icons.directions_bus_rounded,
                        isDark: isDark,
                        onTap: () => _performSearch(_startController.text, 'Railways Bus Station'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161C23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.p8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.accent : AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white : AppColors.textLight,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Icon(
          Icons.north_west_rounded,
          size: 16,
          color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}
