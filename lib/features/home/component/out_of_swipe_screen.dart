import 'package:flutter/material.dart';
import 'dart:async';

class OutOfSwipeScreen extends StatefulWidget {
  const OutOfSwipeScreen({super.key});

  @override
  State<OutOfSwipeScreen> createState() => _OutOfSwipeScreenState();
}

class _OutOfSwipeScreenState extends State<OutOfSwipeScreen> {
  int selectedPlanIndex = 0;
  late Timer _timer;
  Duration timeLeft = Duration(hours: 12, minutes: 4, seconds: 3);

  final List<Map<String, String>> plans = [
    {'duration': '12 months', 'price': '\$107.88', 'perMonth': '\$8.99/month', 'badge': 'most popular'},
    {'duration': '6 months', 'price': '\$77.88', 'perMonth': '\$12.99/month', 'badge': 'best value'},
    {'duration': '1 months', 'price': '\$24.88', 'perMonth': '', 'badge': ''},
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft.inSeconds > 0) {
        setState(() {
          timeLeft = timeLeft - Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Color.fromRGBO(0, 0, 0, 1)),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header illustration
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/static/subscribe_illustration.png',
                      height: 120,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Out of swipes for\ntoday',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'More swipes in',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Time boxes - numbers only inside, labels below
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeBoxNumber(timeLeft.inHours.toString().padLeft(2, '0')),
                            SizedBox(width: 72),
                            _buildTimeBoxNumber((timeLeft.inMinutes % 60).toString().padLeft(2, '0')),
                            SizedBox(width: 72),
                            _buildTimeBoxNumber((timeLeft.inSeconds % 60).toString().padLeft(2, '0')),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeLabel('Hours'),
                            SizedBox(width: 72),
                            _buildTimeLabel('Minutes'),
                            SizedBox(width: 72),
                            _buildTimeLabel('Seconds'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sent and see all\nthe likes you want',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(0, 0, 0, 1),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Subscription plans
              ...List.generate(3, (index) {
                final plan = plans[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _buildPlanOption(
                    index,
                    plan['duration']!,
                    plan['price']!,
                    plan['perMonth']!,
                    plan['badge']!,
                  ),
                );
              }),
              SizedBox(height: 24),
              // Features with outlined icons
              _buildFeature(Icons.all_inclusive_outlined, 'Send unlimited swipes'),
              _buildFeature(Icons.filter_alt_outlined, 'Advanced search filter'),
              _buildFeature(Icons.favorite_outline, 'See everyone who like you'),
              _buildFeature(Icons.phone_outlined, 'Set more dating preference'),
              SizedBox(height: 24),
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A5F4F),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get with ${plans[selectedPlanIndex]['duration']!} for ${plans[selectedPlanIndex]['price']!}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color.fromRGBO(230, 201, 122, 1),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Offers ends in ${timeLeft.inHours}:${(timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromRGBO(0, 0, 0, 1),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Time box - numbers only
  Widget _buildTimeBoxNumber(String value) {
    return Container(
      width: 60,
      height: 60,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFE8C17D),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 0, 0, 1),
          ),
        ),
      ),
    );
  }

  // Time labels below boxes
  Widget _buildTimeLabel(String label) {
    return SizedBox(
      width: 60,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color.fromRGBO(0, 0, 0, 1),
        ),
      ),
    );
  }

  Widget _buildPlanOption(int index, String duration, String price, String perMonth, String badgeText) {
    bool isSelected = selectedPlanIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4A5F4F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF4A5F4F) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Badge at top-right (between border lines)
           if (badgeText.isNotEmpty)
  Positioned(
    top: -12,
    right: 18,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        badgeText.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
    ),
  ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, badgeText.isNotEmpty ? 22 : 16, 16, 16),
              child: Row(
  children: [
    // LEFT — fixed width
    SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            duration,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Color.fromRGBO(230, 201, 122, 1)
                  : Colors.black,
            ),
          ),
          if (perMonth.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                perMonth,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Color.fromRGBO(230, 201, 122, 1)
                      : Colors.black,
                ),
              ),
            ),
        ],
      ),
    ),

    // CENTER — PRICE (true center)
    Expanded(
      child: Center(
        child: Text(
          price,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Color.fromRGBO(230, 201, 122, 1)
                : Colors.black,
          ),
        ),
      ),
    ),

    // RIGHT — fixed width
    SizedBox(
      width: 40,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Color.fromRGBO(230, 201, 122, 1)
                : Colors.grey,
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check,
                size: 20,
                color: Color.fromRGBO(230, 201, 122, 1))
            : null,
      ),
    ),
  ],
),
            ),

          ],
        ),
      ),
    );
  }

  // Features with outlined icons
  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(0xFFE8C17D),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Color.fromRGBO(0, 0, 0, 1)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
