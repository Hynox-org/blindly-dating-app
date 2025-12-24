import 'package:flutter/material.dart';
import './../../../generated/l10n.dart';
import '../../auth/screens/authentication_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onLocaleChanged,
  });

  // Callback coming from MyApp to change the app locale
  final void Function(Locale locale) onLocaleChanged;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  // Language switcher state
  final List<Locale> _supportedLocales = [
    const Locale('en'),
    const Locale('ta'),
  ];
  int _selectedLanguageIndex = 0;

  void _changeLanguage(int index) {
    setState(() {
      _selectedLanguageIndex = index;
    });
    // Notify parent (MyApp) about language change
    widget.onLocaleChanged(_supportedLocales[index]);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context); // Localization instance

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              // Top section with logo, title, and language switcher
              Column(
                children: [
                  const SizedBox(height: 40),
                  const SizedBox(height: 8),
                  Image.asset(
                    'assests/images/blindly-text-logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(height: 8),

                  // LANGUAGE SWITCHER BUTTON
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedLanguageIndex,
                        icon: Icon(
                          Icons.language,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: _supportedLocales.asMap().entries.map((entry) {  
                          final index = entry.key;
                          final locale = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  locale.languageCode.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  locale.languageCode == 'en'
                                      ? 'English'
                                      : 'தமிழ்',
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _changeLanguage(value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              const Spacer(),

              // Center text (localized)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  s.welcomeTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),

              const Spacer(),

              // Bottom buttons section (localized)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/auth'),
                          builder: (context) =>
                              const AuthenticationScreen(isNewUser: true),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      shadowColor: Colors.black.withOpacity(0.05),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white.withOpacity(0.1);
                          }
                          return null;
                        },
                      ),
                    ),
                    child: Text(
                      s.createAccount,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: '/auth'),
                          builder: (context) =>
                              const AuthenticationScreen(isNewUser: false),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.12),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.transparent,
                    ).copyWith(
                      foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.black.withOpacity(0.03);
                          }
                          return null;
                        },
                      ),
                    ),
                    child: Text(
                      s.haveAccount,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: s.bySigningUp),
                          TextSpan(
                            text: s.termsAgreement,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: s.dataUsage),
                          TextSpan(text: s.privacyPolicy),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
