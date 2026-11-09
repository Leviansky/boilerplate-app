import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:testing_boilerplate/core/theme/app_colors.dart";
import "package:testing_boilerplate/core/theme/spacing.dart";
import "package:testing_boilerplate/core/theme/typography.dart";

class CustomPinPad extends StatefulWidget {
  final int pinLength;
  final ValueChanged<Uint8List> onPinCompleted;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const CustomPinPad({
    super.key,
    this.pinLength = 6,
    required this.onPinCompleted,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  State<CustomPinPad> createState() => _CustomPinPadState();
}

class _CustomPinPadState extends State<CustomPinPad> {
  // In-Memory Secure Byte Buffer (Zero-Trust)
  late final Uint8List _pinBuffer;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _pinBuffer = Uint8List(widget.pinLength);
  }

  @override
  void dispose() {
    _scrubBuffer();
    super.dispose();
  }

  /// In-memory scrubbing: overwrite all bytes with zeroes
  void _scrubBuffer() {
    _pinBuffer.fillRange(0, _pinBuffer.length, 0);
    _currentLength = 0;
  }

  void _onDigitPressed(int digit) {
    if (_currentLength < widget.pinLength) {
      HapticFeedback.lightImpact();
      _pinBuffer[_currentLength] = digit + 48; // ASCII code of digit
      _currentLength++;
      setState(() {});

      if (_currentLength == widget.pinLength) {
        // Create an isolated copy to pass to callback, then scrub original immediately
        final completedCopy = Uint8List.fromList(_pinBuffer);
        _scrubBuffer();
        setState(() {});
        widget.onPinCompleted(completedCopy);
      }
    }
  }

  void _onDeletePressed() {
    if (_currentLength > 0) {
      HapticFeedback.lightImpact();
      _currentLength--;
      _pinBuffer[_currentLength] = 0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (index) {
            final isFilled = index < _currentLength;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              width: 16.0,
              height: 16.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isFilled ? AppColors.primary : AppColors.border,
                  width: 2.0,
                ),
              ),
            );
          }),
        ),
        AppGaps.vGap32,

        // Keypad Grid 3x4
        _buildKeypadRow([1, 2, 3]),
        AppGaps.vGap16,
        _buildKeypadRow([4, 5, 6]),
        AppGaps.vGap16,
        _buildKeypadRow([7, 8, 9]),
        AppGaps.vGap16,
        _buildKeypadBottomRow(),
      ],
    );
  }

  Widget _buildKeypadRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _buildDigitButton(digit);
      }).toList(),
    );
  }

  Widget _buildKeypadBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Biometric Button or Empty Spacer
        if (widget.showBiometric && widget.onBiometricPressed != null)
          _buildActionButton(
            icon: Icons.fingerprint,
            onPressed: widget.onBiometricPressed!,
          )
        else
          const SizedBox(width: 72.0, height: 72.0),

        _buildDigitButton(0),

        // Backspace Button
        _buildActionButton(
          icon: Icons.backspace_outlined,
          onPressed: _onDeletePressed,
        ),
      ],
    );
  }

  Widget _buildDigitButton(int digit) {
    return SizedBox(
      width: 72.0,
      height: 72.0,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.border, width: 1.0),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onDigitPressed(digit),
          child: Center(
            child: Text(
              digit.toString(),
              style: AppTypography.headingMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 72.0,
      height: 72.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 28.0,
            ),
          ),
        ),
      ),
    );
  }
}
