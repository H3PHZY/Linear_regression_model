import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEI Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE3F2FD),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MyHomePage(title: 'WEI Prediction'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String apiBaseUrl = 'https://linear-regression-model-noqn.onrender.com';
  static const String predictPath = '/predict';

  static const List<String> womenEmpowermentOptions = [
    'High',
    'Low',
    'Lower-middle',
    'Upper-middle',
  ];
  static const List<String> genderParityOptions = [
    'High',
    'Low',
    'Lower-middle',
    'Upper-middle',
  ];
  static const List<String> humanDevelopmentOptions = [
    'Very high',
    'High',
    'Medium',
    'Low',
  ];
  static const List<String> sddRegionsOptions = [
    'Australia and New Zealand',
    'Central Asia and Southern Asia',
    'Eastern Asia and South-Eastern Asia',
    'Europe and Northern America',
    'Latin America and the Caribbean',
    'Northern Africa and Western Asia',
    'Sub-Saharan Africa',
  ];

  final _womenEmpowermentGroupCtrl = TextEditingController();
  final _ggpiCtrl = TextEditingController();
  final _genderParityGroupCtrl = TextEditingController();
  final _humanDevelopmentGroupCtrl = TextEditingController();
  final _sddRegionsCtrl = TextEditingController();

  String? _resultText;
  String? _errorText;
  bool _isLoading = false;

  @override
  void dispose() {
    _womenEmpowermentGroupCtrl.dispose();
    _ggpiCtrl.dispose();
    _genderParityGroupCtrl.dispose();
    _humanDevelopmentGroupCtrl.dispose();
    _sddRegionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (_isLoading) return;

    setState(() {
      _resultText = null;
      _errorText = null;
      _isLoading = true;
    });

    final womenEmpowermentGroup = _womenEmpowermentGroupCtrl.text.trim();
    final ggpiRaw = _ggpiCtrl.text.trim();
    final genderParityGroup = _genderParityGroupCtrl.text.trim();
    final humanDevelopmentGroup = _humanDevelopmentGroupCtrl.text.trim();
    final sddRegions = _sddRegionsCtrl.text.trim();

    if (womenEmpowermentGroup.isEmpty ||
        ggpiRaw.isEmpty ||
        genderParityGroup.isEmpty ||
        humanDevelopmentGroup.isEmpty ||
        sddRegions.isEmpty) {
      setState(() {
        _errorText = 'Please fill in all fields.';
        _isLoading = false;
      });
      return;
    }

    final ggpi = double.tryParse(ggpiRaw);
    if (ggpi == null) {
      setState(() {
        _errorText = 'GGPI must be a number (e.g., 0.72).';
        _isLoading = false;
      });
      return;
    }
    if (ggpi < 0.0 || ggpi > 1.0) {
      setState(() {
        _errorText = 'GGPI must be between 0.0 and 1.0.';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$apiBaseUrl$predictPath');
    final body = {
      'women_empowerment_group': womenEmpowermentGroup,
      'ggpi': ggpi,
      'gender_parity_group': genderParityGroup,
      'human_development_group': humanDevelopmentGroup,
      'sdd_regions': sddRegions,
    };

    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (resp.statusCode != 200) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final detail = decoded['detail']?.toString() ?? 'Request failed.';
        setState(() => _errorText = detail);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final predictedWei = decoded['predicted_wei'];

      setState(() {
        _resultText = predictedWei == null
            ? 'No prediction returned.'
            : 'Predicted WEI: ${predictedWei.toString()}';
      });
    } catch (_) {
      setState(() {
        _errorText = 'Prediction failed. Check your API URL/network.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const formFill = Color(0xFFF5F7FF);
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
                Color(0xFFE3F2FD),
              ],
            ),
          ),
          child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  "WEI Predictor",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Predict a country's Women's Empowerment Index score using 5 indicators.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xEBFFFFFF),
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 7,
                  color: const Color(0xF7FFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue:
                              _womenEmpowermentGroupCtrl.text.isEmpty
                                  ? null
                                  : _womenEmpowermentGroupCtrl.text.trim(),
                          items: womenEmpowermentOptions
                              .map(
                                (v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _womenEmpowermentGroupCtrl.text = v ?? '';
                            });
                          },
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Women's Empowerment Group",
                            filled: true,
                            fillColor: formFill,
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ggpiCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Global Gender Parity Index (GGPI)',
                            hintText: 'e.g., 0.87',
                            filled: true,
                            fillColor: formFill,
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue:
                              _genderParityGroupCtrl.text.isEmpty
                                  ? null
                                  : _genderParityGroupCtrl.text.trim(),
                          items: genderParityOptions
                              .map(
                                (v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _genderParityGroupCtrl.text = v ?? '';
                            });
                          },
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Gender Parity Group',
                            filled: true,
                            fillColor: formFill,
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue:
                              _humanDevelopmentGroupCtrl.text.isEmpty
                                  ? null
                                  : _humanDevelopmentGroupCtrl.text.trim(),
                          items: humanDevelopmentOptions
                              .map(
                                (v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _humanDevelopmentGroupCtrl.text = v ?? '';
                            });
                          },
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Human Development Group',
                            filled: true,
                            fillColor: formFill,
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _sddRegionsCtrl.text.isEmpty
                              ? null
                              : _sddRegionsCtrl.text.trim(),
                          items: sddRegionsOptions
                              .map(
                                (v) => DropdownMenuItem<String>(
                                  value: v,
                                  child: Text(v),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _sddRegionsCtrl.text = v ?? '';
                            });
                          },
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Sustainable Development Goal regions',
                            filled: true,
                            fillColor: formFill,
                            border: OutlineInputBorder(
                              borderRadius: borderRadius,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _predict,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Predict',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (_errorText != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(244, 67, 54, 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromRGBO(244, 67, 54, 0.32),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFFD32F2F)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_resultText != null)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(76, 175, 80, 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromRGBO(76, 175, 80, 0.32),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    color: Color(0xFF2E7D32)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _resultText!,
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
