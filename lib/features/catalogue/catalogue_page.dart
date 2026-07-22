import 'package:flutter/material.dart';

import 'bucket_list_page.dart';
import 'my_collection_page.dart';
import 'widgets/hub_card.dart';

// The Catalogue Main Screen showing buttons leading into the users collection & bucketlist
class CataloguePage extends StatelessWidget {
  const CataloguePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Catalogue',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Expanded(
              child: HubCard(
                label: 'Collection',
                leading: Image.asset(
                  'assets/images/collection_Button.webp',
                  fit: BoxFit.cover,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyCollectionPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: HubCard(
                label: 'Bucket List',
                leading: Image.asset(
                  'assets/images/bucketlist_Button.webp',
                  fit: BoxFit.cover,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BucketListPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
