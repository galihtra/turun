import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:turun/data/model/nutrition/meal_log_model.dart';
import 'package:turun/data/providers/nutrition/nutrition_provider.dart';
import 'package:turun/data/services/gemini_nutrition_service.dart';
import 'package:turun/pages/nutrition/widgets/meal_result_dialog.dart';
import 'package:turun/resources/colors_app.dart';

/// Screen untuk memotret dan menganalisa makanan dengan AI
class FoodScannerScreen extends StatefulWidget {
  final MealType mealType;
  final int targetCalories;

  const FoodScannerScreen({
    super.key,
    required this.mealType,
    required this.targetCalories,
  });

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final GeminiNutritionService _geminiService = GeminiNutritionService();

  File? _capturedImage;
  bool _isAnalyzing = false;

  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Auto open camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCamera();
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        await _analyzeFood();
      } else {
        // User cancelled, go back
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error opening camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open camera')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _analyzeFood() async {
    if (_capturedImage == null) return;

    setState(() => _isAnalyzing = true);

    final result = await _geminiService.analyzeFoodImage(
      imageFile: _capturedImage!,
      targetCalories: widget.targetCalories,
      mealType: widget.mealType,
    );

    setState(() {
      _isAnalyzing = false;
    });

    if (result != null && mounted) {
      _showResultDialog(result);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to analyze food. Please try again.')),
      );
    }
  }

  void _showResultDialog(FoodAnalysisResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => MealResultDialog(
        result: result,
        mealType: widget.mealType,
        imageFile: _capturedImage,
        onSave: () => _saveMealLog(result),
        onRetake: () {
          Navigator.pop(context);
          _openCamera();
        },
      ),
    );
  }

  Future<void> _saveMealLog(FoodAnalysisResult result) async {
    final provider = Provider.of<NutritionProvider>(context, listen: false);

    final success = await provider.saveMealLog(
      mealType: widget.mealType,
      foodName: result.foodName,
      calories: result.calories,
      aiAnalysis: result.feedback,
    );

    if (mounted) {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Go back to dashboard

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const Gap(12),
                Text('${result.foodName} logged! +10 XP'),
              ],
            ),
            backgroundColor: AppColors.green.shade500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image preview
          if (_capturedImage != null)
            Image.file(
              _capturedImage!,
              fit: BoxFit.cover,
            )
          else
            Container(color: Colors.black),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan ${widget.mealType.displayName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Target: ${widget.targetCalories} kkal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Analyzing overlay
          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated loading
                    RotationTransition(
                      turns: _loadingController,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.blueGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blueLogo.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const Gap(32),
                    const Text(
                      'Analyzing Food...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'AI is estimating calories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom action buttons
          if (!_isAnalyzing && _capturedImage != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  // Retake button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Retake'),
                    ),
                  ),
                  const Gap(12),
                  // Analyze button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _analyzeFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLogo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Analyze with AI',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
