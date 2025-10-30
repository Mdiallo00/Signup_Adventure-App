import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  int _selectedAvatar = 0;
  double _progress = 0.0;
  String _passwordStrength = 'Weak';
  Color _passwordColor = Colors.red;
  List<bool> _completedFields = [false, false, false];
  List<bool> _earnedBadges = [false, false, false];
  List<String> _milestoneMessages = [
    "Great start! 🚀",
    "Halfway there! ✨", 
    "Almost done! 🌟",
    "Ready for adventure! 🎉"
  ];
  int _currentMilestone = 0;

  final List<String> avatars = ['🚀', '🌟', '🦄', '🐉', '🎯'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );
    
    // Add listeners to controllers
    _nameController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
    _passwordController.addListener(_updateProgress);
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _updateProgress() {
    int completed = 0;
    if (_nameController.text.isNotEmpty) completed++;
    if (_emailController.text.isNotEmpty && _isValidEmail(_emailController.text)) completed++;
    if (_passwordController.text.isNotEmpty && _passwordStrength != 'Weak') completed++;
    
    double newProgress = (completed / 3) * 100;
    
    // Check for milestones
    if (newProgress >= 25 && _progress < 25) _celebrateMilestone(0);
    if (newProgress >= 50 && _progress < 50) _celebrateMilestone(1);
    if (newProgress >= 75 && _progress < 75) _celebrateMilestone(2);
    if (newProgress >= 100 && _progress < 100) _celebrateMilestone(3);
    
    setState(() {
      _progress = newProgress;
      _completedFields = [
        _nameController.text.isNotEmpty,
        _emailController.text.isNotEmpty && _isValidEmail(_emailController.text),
        _passwordController.text.isNotEmpty && _passwordStrength != 'Weak'
      ];
      
      // Award Profile Completer badge
      if (completed == 3) _earnedBadges[2] = true;
    });
    
    _animationController.forward(from: 0.0);
  }

  void _celebrateMilestone(int milestone) {
    setState(() {
      _currentMilestone = milestone;
    });
    // Haptic feedback would go here
    // SystemSound.play(SystemSoundType.click);
  }

  void _checkPasswordStrength() {
    String password = _passwordController.text;
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    setState(() {
      if (strength == 0) {
        _passwordStrength = 'Weak';
        _passwordColor = Colors.red;
      } else if (strength <= 2) {
        _passwordStrength = 'Fair';
        _passwordColor = Colors.orange;
      } else if (strength <= 3) {
        _passwordStrength = 'Good';
        _passwordColor = Colors.yellow;
      } else {
        _passwordStrength = 'Strong';
        _passwordColor = Colors.green;
        _earnedBadges[0] = true; // Award Strong Password Master badge
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _submitForm() {
    // Check if signed up before 12 PM for Early Bird badge
    DateTime now = DateTime.now();
    if (now.hour < 12) _earnedBadges[1] = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SuccessScreen(
          userName: _nameController.text,
          avatar: avatars[_selectedAvatar],
          badges: _earnedBadges,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text('Create Your Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Adventure Progress Tracker
            ProgressTracker(
              progress: _progress,
              milestoneMessage: _milestoneMessages[_currentMilestone],
              animation: _progressAnimation,
            ),
            SizedBox(height: 30),
            
            // Avatar Selection
            Text('Choose Your Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(avatars.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = index;
                    });
                  },
                  child: AvatarGlow(
                    glowColor: _selectedAvatar == index ? Colors.deepPurple : Colors.transparent,
                    endRadius: 30.0,
                    duration: Duration(milliseconds: 2000),
                    repeat: true,
                    showTwoGlows: true,
                    repeatPauseDuration: Duration(milliseconds: 100),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _selectedAvatar == index ? Colors.deepPurple : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          avatars[index],
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            
            // Signup Form
            _buildAnimatedFormField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              isCompleted: _completedFields[0],
              index: 0,
            ),
            SizedBox(height: 20),
            _buildAnimatedFormField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              isCompleted: _completedFields[1],
              index: 1,
            ),
            SizedBox(height: 20),
            _buildAnimatedFormField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              isCompleted: _completedFields[2],
              index: 2,
              isPassword: true,
            ),
            
            // Password Strength Meter
            if (_passwordController.text.isNotEmpty) ...[
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password Strength: $_passwordStrength', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _passwordStrength == 'Weak' ? 0.25 : 
                            _passwordStrength == 'Fair' ? 0.5 :
                            _passwordStrength == 'Good' ? 0.75 : 1.0,
                      backgroundColor: Colors.grey[300],
                      color: _passwordColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox(height: 40),
            // Submit Button
            ElevatedButton(
              onPressed: _progress == 100 ? _submitForm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: Text(
                'Complete Adventure',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isCompleted,
    required int index,
    bool isPassword = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.black12,
            blurRadius: isCompleted ? 10 : 5,
            offset: Offset(0, 2),
          )
        ],
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isCompleted ? Colors.green : Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                suffixIcon: isCompleted ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ProgressTracker extends StatelessWidget {
  final double progress;
  final String milestoneMessage;
  final Animation<double> animation;

  const ProgressTracker({
    Key? key,
    required this.progress,
    required this.milestoneMessage,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(milestoneMessage, 
             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        SizedBox(height: 10),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * (animation.value / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progress > 50 ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}