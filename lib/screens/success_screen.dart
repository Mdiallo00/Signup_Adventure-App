import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';

class SuccessScreen extends StatefulWidget {
  final String userName;
  final String avatar;
  final List<bool> badges;

  const SuccessScreen({
    Key? key,
    required this.userName,
    required this.avatar,
    required this.badges,
  }) : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> badgeNames = [
    "Strong Password Master",
    "The Early Bird Special", 
    "Profile Completer"
  ];

  final List<IconData> badgeIcons = [
    Icons.security,
    Icons.wb_sunny,
    Icons.assignment_turned_in
  ];

  final List<Color> badgeColors = [
    Colors.green,
    Colors.orange,
    Colors.blue
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _confettiController.play();
    _animationController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -1.0,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.deepPurple, Colors.purpleAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.avatar,
                          style: TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  
                  // Welcome message
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome, ${widget.userName}!',
                        textStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your adventure begins now!',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple.shade700),
                  ),
                  SizedBox(height: 40),
                  
                  // Earned Badges
                  Text('Achievements Unlocked:', 
                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Column(
                    children: List.generate(widget.badges.length, (index) {
                      if (widget.badges[index]) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 500 + (index * 200)),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: badgeColors[index].withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ],
                            border: Border.all(color: badgeColors[index], width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcons[index], color: badgeColors[index]),
                              SizedBox(width: 12),
                              Text(badgeNames[index], 
                                   style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }
                      return SizedBox();
                    }),
                  ),
                  SizedBox(height: 40),
                  
                  // Continue Button - FIXED NAVIGATION
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the initial route (WelcomeScreen)
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Start New Adventure', 
                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}