import 'package:flutter/material.dart';

class MuscleDiagramWidget extends StatelessWidget {
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;

  const MuscleDiagramWidget({
    Key? key,
    required this.primaryMuscles,
    required this.secondaryMuscles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1B3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: Color(0xFF6C5CE7), size: 20),
              SizedBox(width: 8),
              Text(
                'Target Muscles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Primary muscles
          if (primaryMuscles.isNotEmpty) ...[
            Text(
              'Primary:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: primaryMuscles.map((muscle) {
                return _buildMuscleChip(muscle, isPrimary: true);
              }).toList(),
            ),
            SizedBox(height: 12),
          ],
          
          // Secondary muscles
          if (secondaryMuscles.isNotEmpty) ...[
            Text(
              'Secondary:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: secondaryMuscles.map((muscle) {
                return _buildMuscleChip(muscle, isPrimary: false);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMuscleChip(String muscle, {required bool isPrimary}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary 
            ? Colors.red.withOpacity(0.2)
            : Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary ? Colors.red : Colors.amber,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isPrimary ? Colors.red : Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            _formatMuscleName(muscle),
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMuscleName(String muscle) {
    // Convert snake_case or lowercase to Title Case
    return muscle
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
