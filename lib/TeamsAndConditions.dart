import 'package:flutter/material.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _isLoading = false;

  Future<void> _proceed() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushNamed(context, '/age-selector');
  }

  @override
/*************  ✨ Windsurf Command ⭐  *************/
/// Builds the screen for the guideline screen.
///
/// This screen is shown after the user has entered their phone number and OTP.
/// It shows the community guidelines and asks the user to agree to them.
/// If the user agrees, they are taken to the age selector screen.
/*******  810de743-8461-4c8d-8d20-40b023619fc4  *******/  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true, 
        title: const Text(
          'Community guidelines',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 0, 0, 1),
          )
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Welcome text
                  const Text(
                    'Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Each guideline in separate container
                  _buildGuidelineBox(
                    'Be kind and respectful',
                    'Treat others as you would like to be treated. We\'re all in together to create welcoming environment.',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGuidelineBox(
                    'Stay authentic',
                    'Be genuine in your profile and interactions. We value authenticity and real connections.',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGuidelineBox(
                    'Prioritize safety',
                    'Do not share sensitive and personal information. Protect your self and others in the community.',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGuidelineBox(
                    'No hate speech',
                    'Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGuidelineBox(
                    'Help keep us safe',
                    'If you see something that violate our guideline. Please report it. Your help is invaluable.',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGuidelineBox(
                    'Date with genuine intentions',
                    'We\'re here for real connections. We don\'t allow catfish or coercion. We don\'t allow scams, impersonation, or any kind of manipulation for personal or financial gain.',
                  ),
                  const SizedBox(height: 12),
                  
                  _buildGuidelineBox(
                    'Adults only',
                    'You must be 18 years of age or older to use Blindly. This also means we don\'t allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Bottom button section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5D4F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Agree & Continue',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(230, 201, 122, 1),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color.fromRGBO(0, 0, 0, 1),
                    ),
                    children: const [
                      TextSpan(text: 'By Continue, you agree to our '),
                      TextSpan(
                        text: 'terms',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                           color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      TextSpan(text: '. See how we use your data in our '),
                      TextSpan(
                        text: 'privacy policy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(0, 0, 0, 1),
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineBox(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color.fromRGBO(0, 0, 0, 1),
            ),
          ),
        ],
      ),
    );
  }
}
