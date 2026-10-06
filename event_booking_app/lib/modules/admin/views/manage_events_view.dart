import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../events/controllers/event_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class ManageEventsView extends StatelessWidget {
  const ManageEventsView({super.key});

  void _showCreateEventDialog(BuildContext context) {
    final eventController = Get.find<EventController>();
    final customColors = context.customColors;

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final venueCtrl = TextEditingController(text: 'BMICH, Colombo');
    final cityCtrl = TextEditingController(text: 'Colombo');
    final addressCtrl = TextEditingController(text: 'Bauddhaloka Mawatha, Colombo 00700');
    final latCtrl = TextEditingController(text: '6.9011');
    final lngCtrl = TextEditingController(text: '79.8735');
    final priceCtrl = TextEditingController(text: '2500');
    final seatsCtrl = TextEditingController(text: '200');
    final imageCtrl = TextEditingController(
        text: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80');

    String selectedCategory = 'Tech';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 520,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create Sri Lanka Event',
                      style: AppTextStyles.title(customColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Event Title *')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: 'Description *'),
                      maxLines: 2),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: ['Music', 'Tech', 'Sports', 'Arts', 'Business', 'Food', 'General']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => selectedCategory = v!,
                    decoration: const InputDecoration(labelText: 'Category *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(labelText: 'Image URL')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: venueCtrl,
                              decoration: const InputDecoration(labelText: 'Venue Name *'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TextField(
                              controller: cityCtrl,
                              decoration: const InputDecoration(labelText: 'City *'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(labelText: 'Address')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: latCtrl,
                              decoration: const InputDecoration(labelText: 'Latitude'),
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TextField(
                              controller: lngCtrl,
                              decoration: const InputDecoration(labelText: 'Longitude'),
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: priceCtrl,
                              decoration: const InputDecoration(labelText: 'Price (LKR) *'),
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: TextField(
                              controller: seatsCtrl,
                              decoration: const InputDecoration(labelText: 'Total Seats *'),
                              keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                            Get.snackbar('Error', 'Please fill required fields');
                            return;
                          }
                          final eventData = {
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'category': selectedCategory,
                            'imageUrl': imageCtrl.text.trim(),
                            'venueName': venueCtrl.text.trim(),
                            'venue': venueCtrl.text.trim(),
                            'city': cityCtrl.text.trim(),
                            'address': addressCtrl.text.trim(),
                            'latitude': double.tryParse(latCtrl.text) ?? 6.9271,
                            'longitude': double.tryParse(lngCtrl.text) ?? 79.8612,
                            'startDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                            'endDate': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
                            'price': double.tryParse(priceCtrl.text) ?? 0.0,
                            'currency': 'LKR',
                            'totalSeats': int.tryParse(seatsCtrl.text) ?? 100,
                            'status': 'published',
                            'isSample': false,
                          };
                          eventController.createEvent(eventData);
                        },
                        child: const Text('Create Event'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final customColors = context.customColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateEventDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (eventController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: eventController.events.length,
          itemBuilder: (context, index) {
            final event = eventController.events[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(event.title,
                    style: AppTextStyles.button(customColors.textPrimary)),
                subtitle: Text(
                    '${event.city} • ${Formatters.currency(event.price)} • Seats: ${event.availableSeats}/${event.totalSeats}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => eventController.deleteEvent(event.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
