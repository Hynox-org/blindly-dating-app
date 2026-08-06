import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/compatibility_report_model.dart';
import '../../repository/compatibility_repository.dart';

/// Opened from the compatibility button on a profile card. Watching the
/// provider here is what triggers the scoring call -- nothing is computed for
/// profiles the user never asks about.
class CompatibilityExplanationScreen extends ConsumerWidget {
  final String targetProfileId;
  final String targetName;

  const CompatibilityExplanationScreen({
    super.key,
    required this.targetProfileId,
    required this.targetName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(compatibilityProvider(targetProfileId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'You and $targetName',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: report.when(
        loading: () => const _Working(),
        error: (e, _) => _Failed(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.invalidate(compatibilityProvider(targetProfileId)),
        ),
        data: (data) => _Report(report: data, targetName: targetName),
      ),
    );
  }
}

class _Working extends StatelessWidget {
  const _Working();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Working out what you have in common…',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Failed({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.black38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class _Report extends StatelessWidget {
  final CompatibilityReport report;
  final String targetName;

  const _Report({required this.report, required this.targetName});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _BandCard(band: report.band, headline: report.headline),
        const SizedBox(height: 24),

        if (report.points.isNotEmpty) ...[
          const _SectionTitle('Why'),
          const SizedBox(height: 8),
          ...report.points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 10),
                    child: Icon(Icons.circle, size: 6, color: Colors.black45),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (report.dimensions.isNotEmpty) ...[
          const _SectionTitle('Breakdown'),
          const SizedBox(height: 8),
          ...report.dimensions.map((d) => _DimensionRow(dimension: d)),
          const SizedBox(height: 8),
        ],

        // Reciprocity is the half most compatibility screens leave out, and
        // it is the half users actually care about: does this go both ways.
        _MutualFit(band: report.reciprocityBand, name: targetName),

        if (report.caveat.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            report.caveat,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _BandCard extends StatelessWidget {
  final CompatibilityBand band;
  final String headline;

  const _BandCard({required this.band, required this.headline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: band.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: band.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            band.label,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: band.color,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: band.fill,
              minHeight: 8,
              backgroundColor: band.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(band.color),
            ),
          ),
          if (headline.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              headline,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _DimensionRow extends StatelessWidget {
  final CompatibilityDimension dimension;

  const _DimensionRow({required this.dimension});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dimension.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: dimension.band.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dimension.band.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dimension.band.color,
                  ),
                ),
              ),
            ],
          ),
          if (dimension.shared.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: dimension.shared
                  .take(8)
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2EE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MutualFit extends StatelessWidget {
  final CompatibilityBand band;
  final String name;

  const _MutualFit({required this.band, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.swap_horiz, color: band.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Does it go both ways?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'You each fit what the other is looking for: ${band.label.toLowerCase()}.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: Colors.black45,
      ),
    );
  }
}
