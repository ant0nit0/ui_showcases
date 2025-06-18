import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ui_showcases/5_Shaders/shader_wave_animator.dart';

class ShadersShowcasePage extends HookWidget {
  const ShadersShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final waveSpeed = useState(0.5);
    final waveIntensity = useState(0.05);
    final waveFrequency = useState(2.0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(width: double.infinity, height: 20),
            const WaveAnimator(
              child: Text(
                'Wave Animator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            WaveAnimator(
              waveSpeed: waveSpeed.value,
              waveIntensity: waveIntensity.value,
              waveFrequency: waveFrequency.value,
              child: Image.asset(
                'assets/images/user_avatar.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Wave Speed: '),
                      Expanded(
                        child: Slider(
                          value: waveSpeed.value,
                          min: 0.1,
                          max: 2.0,
                          onChanged: (value) => waveSpeed.value = value,
                        ),
                      ),
                      Text(waveSpeed.value.toStringAsFixed(2)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Wave Intensity: '),
                      Expanded(
                        child: Slider(
                          value: waveIntensity.value,
                          min: 0.01,
                          max: 0.2,
                          onChanged: (value) => waveIntensity.value = value,
                        ),
                      ),
                      Text(waveIntensity.value.toStringAsFixed(2)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Wave Frequency: '),
                      Expanded(
                        child: Slider(
                          value: waveFrequency.value,
                          min: 0.5,
                          max: 5.0,
                          onChanged: (value) => waveFrequency.value = value,
                        ),
                      ),
                      Text(waveFrequency.value.toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
