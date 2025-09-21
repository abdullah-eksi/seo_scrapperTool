// components.dart dosyasına ekleyin
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MetaTagsComponent extends StatelessWidget {
  final Map<String, dynamic> metaTags;

  const MetaTagsComponent({super.key, required this.metaTags});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: metaTags.length,
      itemBuilder: (context, index) {
        final key = metaTags.keys.elementAt(index);
        final value = metaTags[key]?.toString() ?? '';
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(value),
            trailing: IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$key kopyalandı')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}