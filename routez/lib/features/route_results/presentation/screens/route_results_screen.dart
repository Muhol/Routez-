import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/empty_state_widget.dart';
import 'package:routez/features/search/presentation/providers/search_provider.dart';
import 'package:routez/features/search/data/models/journey_leg_model.dart';

class RouteResultsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? searchArgs;

  const RouteResultsScreen({super.key, this.searchArgs});

  @override
  ConsumerState<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends ConsumerState<RouteResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? extra = widget.searchArgs;
    if (extra == null) {
      try {
        extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      } catch (_) {}
    }

    final origin = extra?['origin'] as String? ?? 'Pipeline Stage';
    final destination = extra?['destination'] as String? ?? 'Westlands Stage';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final searchParams = RouteSearchQuery(origin: origin, destination: destination);
    final journeysAsync = ref.watch(journeySearchResultsProvider(searchParams));

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: journeysAsync.when(
        loading: () => _buildLoadingState(origin, destination, isDark),
        error: (err, __) => _buildErrorState(origin, destination, isDark),
        data: (rawJourneys) {
          if (rawJourneys.isEmpty) {
            return _buildEmptyState(origin, destination, isDark);
          }
          final recommended = rawJourneys.first;
          final alternatives =
              rawJourneys.length > 1 ? rawJourneys.sublist(1) : <JourneyOption>[];
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: _buildResultsView(
                context: context,
                origin: origin,
                destination: destination,
                isDark: isDark,
                recommended: recommended,
                alternatives: alternatives,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Loading / Error / Empty states ────────────────────────────────────

  Widget _buildLoadingState(String origin, String destination, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, origin, destination, isDark),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p20),
                  Text(
                    'Finding the best route…',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

  Widget _buildErrorState(String origin, String destination, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, origin, destination, isDark),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.cloud_off_outlined,
              title: 'Could Not Load Routes',
              message: 'Unable to compute transit paths. Check your connection and try again.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String origin, String destination, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, origin, destination, isDark),
          const Expanded(
            child: EmptyStateWidget(
              icon: Icons.search_off_outlined,
              title: 'No Routes Found',
              message: "We couldn't find a route between these stages within 3 matatu transfers.",
            ),
          ),
        ],
      ),
    );
  }

  // ── Top header bar ────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, String origin, String destination, bool isDark) {
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final subColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.p4, AppSizes.p8, AppSizes.p16, AppSizes.p16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textColor),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: AppSizes.p4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Route',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSizes.p2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        origin,
                        style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p6),
                      child: Icon(Icons.arrow_forward_rounded, size: 12, color: subColor),
                    ),
                    Flexible(
                      child: Text(
                        destination,
                        style: TextStyle(fontSize: 12, color: subColor, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Main results view ─────────────────────────────────────────────────

  Widget _buildResultsView({
    required BuildContext context,
    required String origin,
    required String destination,
    required bool isDark,
    required JourneyOption recommended,
    required List<JourneyOption> alternatives,
  }) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, origin, destination, isDark),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.p16, 0, AppSizes.p16, AppSizes.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Recommended" badge
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.p12, left: AppSizes.p4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p10, vertical: AppSizes.p4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 13, color: AppColors.accent),
                        const SizedBox(width: AppSizes.p4),
                        Text(
                          'Recommended',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Recommended Hero Card ──
                  _RecommendedCard(
                    journey: recommended,
                    origin: origin,
                    destination: destination,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom: Alternative Routes button ──
          if (alternatives.isNotEmpty)
            _buildAlternativesButton(
                context, alternatives, origin, destination, isDark),
        ],
      ),
    );
  }

  Widget _buildAlternativesButton(
    BuildContext context,
    List<JourneyOption> alternatives,
    String origin,
    String destination,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.p20,
        AppSizes.p12,
        AppSizes.p20,
        AppSizes.p12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => _showAlternativesSheet(
              context, alternatives, origin, destination, isDark),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          ),
          icon: const Icon(Icons.alt_route_rounded, size: 18),
          label: Text(
            'Alternative Routes  ·  ${alternatives.length}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }

  void _showAlternativesSheet(
    BuildContext context,
    List<JourneyOption> alternatives,
    String origin,
    String destination,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlternativesSheet(
        alternatives: alternatives,
        origin: origin,
        destination: destination,
        isDark: isDark,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Recommended Route Hero Card
// ═══════════════════════════════════════════════════════════════════════════

class _RecommendedCard extends StatelessWidget {
  final JourneyOption journey;
  final String origin;
  final String destination;
  final bool isDark;

  const _RecommendedCard({
    required this.journey,
    required this.origin,
    required this.destination,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fare + stats header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.p20, AppSizes.p20, AppSizes.p20, AppSizes.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KES ${journey.totalCheapestFare}',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p2),
                      Text(
                        'estimated fare',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatPill(
                      icon: Icons.schedule_rounded,
                      label: '~${journey.totalMinutes} min',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    _StatPill(
                      icon: Icons.directions_bus_rounded,
                      label: journey.matatuCountLabel,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: borderColor),

          // ── Leg-by-leg timeline ──
          Padding(
            padding: const EdgeInsets.all(AppSizes.p20),
            child: _LegTimeline(legs: journey.legs, isDark: isDark),
          ),

          Divider(height: 1, color: borderColor),

          // ── Action buttons ──
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/route-detail', extra: {
                        'journey': journey,
                        'origin': origin,
                        'destination': destination,
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor, width: 1.2),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p14,
                        horizontal: AppSizes.p10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      foregroundColor: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text(
                      'View Path',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/active-trip'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p14,
                        horizontal: AppSizes.p10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 16),
                    label: const Text(
                      'Start Trip',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Leg-by-leg timeline
// ═══════════════════════════════════════════════════════════════════════════

class _LegTimeline extends StatelessWidget {
  final List<JourneyLegModel> legs;
  final bool isDark;

  const _LegTimeline({required this.legs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(legs.length, (i) {
        final leg = legs[i];
        final isLast = i == legs.length - 1;
        final lineColor = leg.isWalk
            ? (isDark ? AppColors.dividerDark : AppColors.dividerLight)
            : AppColors.primary.withValues(alpha: 0.35);

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.p16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timeline indicator with custom painted line (no IntrinsicHeight needed) ──
              CustomPaint(
                painter: _TimelineLinePainter(
                  lineColor: lineColor,
                  isLast: isLast,
                ),
                child: SizedBox(
                  width: 24,
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: leg.isWalk
                            ? AppColors.textSecondaryLight
                            : AppColors.primary,
                        border: Border.all(
                          color: leg.isWalk
                              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                              : AppColors.primaryLight,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p12),
              // ── Leg content ──
              Expanded(
                child: leg.isWalk
                    ? _WalkLegRow(leg: leg, isDark: isDark)
                    : _MatatuLegRow(leg: leg, isDark: isDark),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TimelineLinePainter extends CustomPainter {
  final Color lineColor;
  final bool isLast;

  _TimelineLinePainter({required this.lineColor, required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isLast) {
      final paint = Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      // Start slightly below the dot (top 15) and draw down past the bottom to connect to next dot
      canvas.drawLine(
        Offset(size.width / 2, 16),
        Offset(size.width / 2, size.height + AppSizes.p16 + 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) {
    return oldDelegate.lineColor != lineColor || oldDelegate.isLast != isLast;
  }
}

class _MatatuLegRow extends StatelessWidget {
  final JourneyLegModel leg;
  final bool isDark;

  const _MatatuLegRow({required this.leg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p8, vertical: AppSizes.p2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                'Route ${leg.routeNumber ?? '?'}',
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSizes.p8),
            Text(
              '~${leg.estimatedMinutes} min',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          '${leg.fromStage.name}  →  ${leg.toStage.name}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        if (leg.cheapestFare > 0) ...[
          const SizedBox(height: AppSizes.p2),
          Text(
            'KES ${leg.cheapestFare}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _WalkLegRow extends StatelessWidget {
  final JourneyLegModel leg;
  final bool isDark;

  const _WalkLegRow({required this.leg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.directions_walk_rounded,
            size: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        const SizedBox(width: AppSizes.p6),
        Text(
          'Walk ${leg.durationMinutes} min',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Stat pill (duration / matatu count)
// ═══════════════════════════════════════════════════════════════════════════

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatPill({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p10, vertical: AppSizes.p6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          const SizedBox(width: AppSizes.p4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Alternatives Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════════

class _AlternativesSheet extends StatefulWidget {
  final List<JourneyOption> alternatives;
  final String origin;
  final String destination;
  final bool isDark;

  const _AlternativesSheet({
    required this.alternatives,
    required this.origin,
    required this.destination,
    required this.isDark,
  });

  @override
  State<_AlternativesSheet> createState() => _AlternativesSheetState();
}

class _AlternativesSheetState extends State<_AlternativesSheet> {
  String _sort = 'Default';

  List<JourneyOption> get _sorted {
    final list = List<JourneyOption>.from(widget.alternatives);
    if (_sort == 'Cheapest') {
      list.sort((a, b) => a.totalCheapestFare.compareTo(b.totalCheapestFare));
    } else if (_sort == 'Fastest') {
      list.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    } else if (_sort == 'Least Walking') {
      list.sort((a, b) {
        final wa = a.walkLegs.fold(0, (s, l) => s + l.durationMinutes);
        final wb = b.walkLegs.fold(0, (s, l) => s + l.durationMinutes);
        return wa.compareTo(wb);
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final sheetBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final handleColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusLarge)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sheet handle ──
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSizes.p12, bottom: AppSizes.p4),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                ),
              ),

              // ── Title row ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.p20, AppSizes.p12, AppSizes.p20, AppSizes.p4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alternative Routes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      '${widget.alternatives.length} options',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Sort chips ──
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16, vertical: AppSizes.p4),
                  children: ['Default', 'Cheapest', 'Fastest', 'Least Walking']
                      .map((s) => _SortChip(
                            label: s,
                            selected: _sort == s,
                            isDark: isDark,
                            onTap: () => setState(() => _sort = s),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSizes.p4),

              // ── Route cards list ──
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.p16, AppSizes.p4, AppSizes.p16, AppSizes.p24),
                  itemCount: _sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p10),
                  itemBuilder: (context, index) {
                    final journey = _sorted[index];
                    return _AlternativeRouteCard(
                      journey: journey,
                      index: index,
                      origin: widget.origin,
                      destination: widget.destination,
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Alternative Route Card (compact)
// ═══════════════════════════════════════════════════════════════════════════

class _AlternativeRouteCard extends StatelessWidget {
  final JourneyOption journey;
  final int index;
  final String origin;
  final String destination;
  final bool isDark;

  const _AlternativeRouteCard({
    required this.journey,
    required this.index,
    required this.origin,
    required this.destination,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.backgroundLight;
    final borderColor = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final matatuLegs = journey.matatuLegs;
    final routeSummary =
        matatuLegs.map((l) => 'Route ${l.routeNumber ?? '?'}').join(' → ');

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push('/route-detail', extra: {
          'journey': journey,
          'origin': origin,
          'destination': destination,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            // ── Index circle ──
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 2}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.p12),
            // ── Route info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeSummary,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      const SizedBox(width: AppSizes.p4),
                      Text(
                        '~${journey.totalMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Icon(Icons.directions_bus_rounded,
                          size: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      const SizedBox(width: AppSizes.p4),
                      Text(
                        journey.matatuCountLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Fare + arrow ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'KES ${journey.totalCheapestFare}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sort Chip
// ═══════════════════════════════════════════════════════════════════════════

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.p8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p14, vertical: AppSizes.p6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : (isDark ? AppColors.textDark : AppColors.textLight),
            ),
          ),
        ),
      ),
    );
  }
}
