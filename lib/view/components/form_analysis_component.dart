import 'package:flutter/material.dart';

class FormAnalysisComponent extends StatelessWidget {
  final List<Map<String, String>> formElements;

  const FormAnalysisComponent({
    super.key,
    required this.formElements,
  });

  @override
  Widget build(BuildContext context) {
    if (formElements.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade100, Colors.indigo.shade200],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.web_asset_rounded,
                  size: 64,
                  color: Colors.indigo.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Form bulunamadı',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu sayfada HTML form elemanı bulunamadı',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        
        return ListView.builder(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          itemCount: formElements.length,
          itemBuilder: (context, index) {
            final form = formElements[index];
            return Container(
              margin: EdgeInsets.only(bottom: isWide ? 20 : 16),
              child: _buildFormCard(form, index, isWide),
            );
          },
        );
      },
    );
  }

  Widget _buildFormCard(Map<String, String> form, int index, bool isWide) {
    final name = form['name'] ?? 'Bilinmeyen Form';
    final action = form['action'] ?? '';
    final method = form['method'] ?? 'GET';
    final inputs = form['inputs'] ?? '';
    final inputCount = int.tryParse(form['input_count'] ?? '0') ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.indigo.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(isWide ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.indigo.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getMethodColor(method),
                        _getMethodColor(method).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _getMethodColor(method).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getMethodIcon(method),
                    color: Colors.white,
                    size: isWide ? 24 : 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: isWide ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getMethodColor(method).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          method.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getMethodColor(method),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade200],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.input_rounded,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$inputCount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (action.isNotEmpty && action != 'Belirtilmemiş') ...[
              _buildInfoSection(
                'Form Action',
                action,
                Icons.send_rounded,
                Colors.green,
                isWide,
              ),
              const SizedBox(height: 16),
            ],
            
            if (inputs.isNotEmpty) ...[
              _buildInfoSection(
                'Input Elemanları',
                inputs,
                Icons.widgets_rounded,
                Colors.purple,
                isWide,
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(isWide ? 20 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bu formda input elemanı bulunamadı',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: isWide ? 15 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon, MaterialColor color, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.shade800,
                fontSize: isWide ? 15 : 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isWide ? 16 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SelectableText(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: isWide ? 14 : 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Icons.download_rounded;
      case 'POST':
        return Icons.upload_rounded;
      case 'PUT':
        return Icons.edit_rounded;
      case 'DELETE':
        return Icons.delete_rounded;
      case 'PATCH':
        return Icons.build_rounded;
      default:
        return Icons.web_rounded;
    }
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green.shade600;
      case 'POST':
        return Colors.blue.shade600;
      case 'PUT':
        return Colors.orange.shade600;
      case 'DELETE':
        return Colors.red.shade600;
      case 'PATCH':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}