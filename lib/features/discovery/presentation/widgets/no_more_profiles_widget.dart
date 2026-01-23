import 'package:flutter/material.dart';

class NoMoreProfilesWidget extends StatelessWidget {
  final VoidCallback? onAdjustFilters;
  final VoidCallback? onNotifyMe;

  const NoMoreProfilesWidget({
    super.key,
    this.onAdjustFilters,
    this.onNotifyMe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    // Using a placeholder image or icon as per plan since we don't have the exact asset ready in code imports yet
                    // Ideally: Image.asset('assests/static/no_feed_screen.png'), but I'll use a semantic icon for now
                    // user provided path: f:\Projects\Blindly\blindly-dating-app\assests\static\no_feed_screen.png
                    // which seems to be the design reference, NOT the asset to use.
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Image.asset(
                        'assets/static/no_feed_screen.png', // Trying to use the uploaded image if it exists in assets, otherwise fallback
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons
                                .mobile_friendly_rounded, // Placeholder for the phone interaction illustration
                            size: 150,
                            color: colorScheme.onSurface.withOpacity(0.2),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      "Lets Discover!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      "You’re viewed all the profiles matching your current preference. Expand your search or check back soon for new peoples.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // "Adjust Your Filters" Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onAdjustFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme
                              .primary, // Dark Olive/Green from design
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Adjust Your Filters",
                          style: TextStyle(
                            color: colorScheme.onPrimary, // Goldish text
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // "Notify Me About New People" Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onNotifyMe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface, // Light grey
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Notify Me About New People",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Poppins',
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
      ),
    );
  }
}