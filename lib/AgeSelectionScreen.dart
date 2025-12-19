import 'package:flutter/material.dart';

class AgeSelectorScreen extends StatefulWidget {
  const AgeSelectorScreen({Key? key}) : super(key: key);

  @override
  State<AgeSelectorScreen> createState() => _AgeSelectorScreenState();
}

class _AgeSelectorScreenState extends State<AgeSelectorScreen> {
  String? _selectedAgeRange;
  bool _isLoading = false;

  final List<String> _ageRanges = [
    'Age: 20-23',
    'Age: 24-27',
    'Age: 28-32',
    'Age: 32-38',
  ];

  Future<void> _continue() async {
    if (_selectedAgeRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your age range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    // Navigate to next screen
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Title - Centered
              const Text(
                "What's your age?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtitle - Centered
              const Text(
                'This help us show you relevant age profiles and find your matches',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color.fromRGBO(0, 0, 0, 1),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              
              // Age range buttons - 3 per row using GridView
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 buttons per row
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5, // Adjust button height
                ),
                itemCount: _ageRanges.length,
                itemBuilder: (context, index) {
                  final ageRange = _ageRanges[index];
                  final isSelected = _selectedAgeRange == ageRange;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAgeRange = ageRange;
                      });
                    },
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF4A5D4F) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25), // Rounded corners
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF4A5D4F) 
                              : const Color(0xFFE0E0E0),
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
                      child: Center(
                        child: Text(
                          ageRange,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected 
                                ? Colors.white 
                                : const Color.fromRGBO(0, 0, 0, 1),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5D4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners for button
                  ),
                  disabledBackgroundColor: const Color(0xFF4A5D4F).withOpacity(0.6),
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
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(230, 201, 122, 1),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
