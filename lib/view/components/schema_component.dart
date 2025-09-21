import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SchemaComponent extends StatelessWidget {
  final Map<String, dynamic> schemaData;

  const SchemaComponent({
    super.key,
    required this.schemaData,
  });

  @override
  Widget build(BuildContext context) {
    if (schemaData.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.code_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Schema verisi bulunamadı',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu sayfada yapılandırılmış veri bulunamadı',
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
          itemCount: schemaData.length,
          itemBuilder: (context, index) {
            final key = schemaData.keys.elementAt(index);
            final value = schemaData[key];

            return Container(
              margin: EdgeInsets.only(bottom: isWide ? 20 : 16),
              child: _buildSchemaCard(key, value, isWide),
            );
          },
        );
      },
    );
  }

  Widget _buildSchemaCard(String key, dynamic value, bool isWide) {
    final isJsonLd = key.startsWith('schema_');
    final isMicrodata = key.startsWith('microdata_');
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isJsonLd ? Colors.blue.shade50 : 
            isMicrodata ? Colors.green.shade50 : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(isWide ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isJsonLd ? Colors.blue.shade200 : 
                 isMicrodata ? Colors.green.shade200 : Colors.grey.shade200,
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
                      colors: isJsonLd ? [Colors.blue.shade600, Colors.blue.shade700] : 
                              isMicrodata ? [Colors.green.shade600, Colors.green.shade700] : 
                              [Colors.grey.shade600, Colors.grey.shade700],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (isJsonLd ? Colors.blue : 
                               isMicrodata ? Colors.green : Colors.grey).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isJsonLd ? Icons.data_object_rounded : 
                    isMicrodata ? Icons.schema_rounded : Icons.info_outline_rounded,
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
                        _getSchemaTitle(key),
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
                          color: isJsonLd ? Colors.blue.shade100 : 
                                 isMicrodata ? Colors.green.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isJsonLd ? 'JSON-LD' : isMicrodata ? 'Microdata' : 'Diğer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isJsonLd ? Colors.blue.shade700 : 
                                   isMicrodata ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isJsonLd || (value is String && value.length > 50))
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.copy_rounded, size: 20),
                      onPressed: () => _copyToClipboard(value.toString()),
                      tooltip: 'Kopyala',
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSchemaContent(value, isJsonLd, isMicrodata, isWide),
          ],
        ),
      ),
    );
  }

  String _getSchemaTitle(String key) {
    if (key.startsWith('schema_')) {
      return 'JSON-LD Schema ${key.replaceFirst('schema_', '#')}';
    } else if (key.startsWith('microdata_')) {
      return 'Microdata ${key.replaceFirst('microdata_', '#')}';
    } else if (key == 'info') {
      return 'Bilgi';
    } else if (key == 'error') {
      return 'Hata';
    }
    return key;
  }

  Widget _buildSchemaContent(dynamic value, bool isJsonLd, bool isMicrodata, bool isWide) {
    if (isMicrodata && value is Map) {
      return _buildMicrodataContent(Map<String, dynamic>.from(value), isWide);
    } else if (isJsonLd && value is String) {
      return _buildJsonLdContent(value, isWide);
    } else {
      return _buildSimpleContent(value.toString(), isWide);
    }
  }

  Widget _buildMicrodataContent(Map<String, dynamic> microdata, bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (microdata.containsKey('itemtype') && microdata['itemtype'].toString().isNotEmpty)
            _buildInfoRow('Type', microdata['itemtype'].toString(), Colors.green, isWide),
          if (microdata.containsKey('itemprop') && microdata['itemprop'].toString().isNotEmpty)
            _buildInfoRow('Property', microdata['itemprop'].toString(), Colors.green, isWide),
          if (microdata.containsKey('content') && microdata['content'].toString().isNotEmpty)
            _buildInfoRow('Content', microdata['content'].toString(), Colors.green, isWide),
        ],
      ),
    );
  }

  Widget _buildJsonLdContent(String jsonContent, bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade50, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            minWidth: double.infinity,
          ),
          child: SelectableText(
            jsonContent,
            style: TextStyle(
              fontFamily: 'JetBrains Mono, Consolas, Monaco, monospace',
              fontSize: isWide ? 13 : 12,
              color: Colors.grey.shade800,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleContent(String content, bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.blue.shade600,
            size: isWide ? 24 : 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: isWide ? 15 : 14,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, MaterialColor color, bool isWide) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isWide ? 100 : 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.shade700,
                fontSize: isWide ? 14 : 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.shade200),
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
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}