import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/map_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/user_profile_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  LatLng _userLocation = LocationService.defaultLocation;

  /// Horizontal padding is applied by each sheet component individually
  /// (not by the ListView), so scrollable rows can run edge to edge.
  static const _sheetHPad = EdgeInsets.symmetric(horizontal: AppSizes.p20);

  @override
  bool get wantKeepAlive => true;

  CameraPosition get _initialCameraPosition => CameraPosition(
        target: _userLocation,
        zoom: 14.5,
      );

  bool _resolveIsDark() {
    final themeMode = ref.read(themeModeProvider);
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
  }

  void _applyMapStyle() {
    final style = _resolveIsDark() ? kMapStyleDark : kMapStyleLight;
    _mapController?.setMapStyle(style);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMapStyle();
  }

  @override
  void initState() {
    super.initState();
    _fetchLocationAndCenter();
  }

  Future<void> _fetchLocationAndCenter() async {
    final latLng = await LocationService.getCurrentLatLng();
    if (!mounted) return;
    setState(() => _userLocation = latLng);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15),
      ),
    );
  }

  void _recenterMap() async {
    final latLng = await LocationService.getCurrentLatLng();
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 15.5),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
            SizedBox(width: AppSizes.p8),
            Text('Centered on your location'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeMode = ref.watch(themeModeProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformBrightness == Brightness.dark);

    final authUser = ref.watch(authStateProvider).asData?.value;
    final userProfile = ref.watch(userProfileProvider).asData?.value;
    final userName = userProfile?.displayName ?? authUser?.displayName ?? 'Commuter';
    final initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    final glassBg = isDark ? const Color(0xDD181E24) : const Color(0xF2FFFFFF);
    final glassBorder = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. Google Map ───────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: const {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (controller) {
              _mapController = controller;
              final style = isDark ? kMapStyleDark : kMapStyleLight;
              controller.setMapStyle(style);
              _fetchLocationAndCenter();
            },
          ),

          // ── 2. Draggable Bottom Sheet (Rendered before top controls) ─────────
          DraggableScrollableSheet(
            initialChildSize: 0.24,
            minChildSize: 0.12,
            maxChildSize: 0.52,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  // Pitch black in dark mode
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  // Vertical only: each child below owns its horizontal padding
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSizes.p16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        ),
                      ),
                    ),

                    // Quick Explore label
                    Padding(
                      padding: _sheetHPad,
                      child: Row(
                        children: [
                          Text(
                            'Quick Explore',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),

                    // Quick Explore chips: run edge to edge, fading out at both
                    // sides as they scroll toward the screen edges
                    _EdgeFadeScroller(
                      padding: _sheetHPad,
                      fadeWidth: 28,
                      child: Row(
                        children: [
                          _buildQuickChip(context, 'CBD Kencom', Icons.location_city_rounded, isDark),
                          _buildQuickChip(context, 'Westlands', Icons.business_rounded, isDark),
                          _buildQuickChip(context, 'Pipeline Stage', Icons.directions_bus_rounded, isDark),
                          _buildQuickChip(context, 'Upper Hill', Icons.apartment_rounded, isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSizes.p16),
                    Padding(
                      padding: _sheetHPad,
                      child: Divider(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p14),

                    // Nearby Stages header
                    Padding(
                      padding: _sheetHPad,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby Matatu Stages',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/search'),
                            child: Text(
                              'Search all',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.p12),

                    // Nearby stage card
                    Padding(
                      padding: _sheetHPad,
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.p14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B222B) : const Color(0xFFF7F9FB),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.p10),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.accent : AppColors.primary)
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_bus_rounded,
                                size: 20,
                                color: isDark ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kencom & Ambassador Stages',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                      color: isDark ? Colors.white : AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Nairobi CBD  •  Routes 23, 111, 46, 33',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 100 + MediaQuery.of(context).padding.bottom), // padding for floating pills & safe area
                  ],
                ),
              );
            },
          ),

          // ── 3. Floating Re-center Button ────────────────────────────────────
          Positioned(
            right: AppSizes.p16,
            bottom: AppSizes.p200 + 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _recenterMap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: glassBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: glassBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 4. Top Bar: Search Bar + Profile Avatar Button (Drawn strictly on top) ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p12, AppSizes.p16, 0),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      behavior: HitTestBehavior.opaque,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p16,
                              vertical: AppSizes.p12,
                            ),
                            decoration: BoxDecoration(
                              color: glassBg,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                              border: Border.all(color: glassBorder, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: isDark ? AppColors.accent : AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSizes.p12),
                                Expanded(
                                  child: Text(
                                    'Where to in Nairobi?',
                                    style: TextStyle(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.p8,
                                    vertical: AppSizes.p4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.accent : AppColors.primary)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                                  ),
                                  child: Text(
                                    'Routes',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.accent : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSizes.p10),

                  // Profile Avatar Button (Tapping opens /profile)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () {
                            context.push('/profile');
                          },
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: glassBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.accent.withValues(alpha: 0.4) : glassBorder,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: (isDark ? AppColors.accent : AppColors.primary)
                                    .withValues(alpha: 0.18),
                                child: Text(
                                  initialLetter,
                                  style: TextStyle(
                                    color: isDark ? AppColors.accent : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.p8),
      child: ActionChip(
        avatar: Icon(
          icon,
          size: 15,
          color: isDark ? AppColors.accent : AppColors.primary,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textLight,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2630) : const Color(0xFFF1F4F8),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusFull)),
        onPressed: () {
          context.push('/search');
        },
      ),
    );
  }
}

/// A horizontal scroller that runs edge to edge and fades its content out
/// at the left/right screen edges.
///
/// The fade only appears on a side once there is content hidden beyond it:
/// at rest the first item sits fully visible at [padding].left, and the left
/// fade grows in as the user scrolls. The right fade disappears once the end
/// of the list is reached.
class _EdgeFadeScroller extends StatefulWidget {
  final EdgeInsets padding;
  final double fadeWidth;
  final Widget child;

  const _EdgeFadeScroller({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.fadeWidth = 28,
  });

  @override
  State<_EdgeFadeScroller> createState() => _EdgeFadeScrollerState();
}

class _EdgeFadeScrollerState extends State<_EdgeFadeScroller> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Rebuild once after the first layout so scroll extents are known
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 0 = no fade on that side, 1 = full fade
        double left = 0;
        double right = 1;
        if (_controller.hasClients &&
            _controller.position.hasContentDimensions) {
          final pos = _controller.position;
          left = (pos.pixels / widget.fadeWidth).clamp(0.0, 1.0);
          right = ((pos.maxScrollExtent - pos.pixels) / widget.fadeWidth)
              .clamp(0.0, 1.0);
        }

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            final fade = (widget.fadeWidth / rect.width).clamp(0.0, 0.5);
            return LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 1 - left),
                Colors.black,
                Colors.black,
                Colors.black.withValues(alpha: 1 - right),
              ],
              stops: [0.0, fade, 1.0 - fade, 1.0],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}