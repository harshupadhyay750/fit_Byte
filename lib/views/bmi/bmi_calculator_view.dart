import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BMICalculatorView extends StatefulWidget {
  const BMICalculatorView({super.key});

  @override
  State<BMICalculatorView> createState() => _BMICalculatorViewState();
}

class _BMICalculatorViewState extends State<BMICalculatorView> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double? _bmiResult;
  String _bmiCategory = '';

  void _calculateBMI() {
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      double heightInMeters = height / 100;
      setState(() {
        _bmiResult = weight / (heightInMeters * heightInMeters);
        if (_bmiResult! < 18.5) {
          _bmiCategory = 'Underweight';
        } else if (_bmiResult! < 25) {
          _bmiCategory = 'Normal';
        } else if (_bmiResult! < 30) {
          _bmiCategory = 'Overweight';
        } else {
          _bmiCategory = 'Obese';
        }
      });
    } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid height and weight')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Check your Body Mass Index', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            _buildInputCard(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Calculate BMI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_bmiResult != null) ...[
              const SizedBox(height: 40),
              _buildResultSection().animate().fadeIn().scale(curve: Curves.easeOutBack),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Height',
              hintText: 'in cm',
              prefixIcon: const Icon(Icons.height),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Weight',
              hintText: 'in kg',
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getCategoryColor().withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('YOUR BMI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(
            _bmiResult!.toStringAsFixed(1),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _getCategoryColor()),
          ),
          Text(
            _bmiCategory.toUpperCase(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _getCategoryColor()),
          ),
          const SizedBox(height: 24),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_bmiCategory) {
      case 'Normal': return Colors.green;
      case 'Underweight': return Colors.orange;
      case 'Overweight': return Colors.orange;
      case 'Obese': return Colors.red;
      default: return Colors.black;
    }
  }

  Widget _buildSuggestions() {
    String suggestion = '';
    switch (_bmiCategory) {
      case 'Normal': suggestion = 'You have a healthy body weight. Keep it up!'; break;
      case 'Underweight': suggestion = 'You may need to eat more frequently and choose nutrient-rich foods.'; break;
      case 'Overweight': suggestion = 'Focus on a balanced diet and increasing physical activity.'; break;
      case 'Obese': suggestion = 'Consider consulting a healthcare professional for a tailored weight management plan.'; break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        suggestion,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }
}
