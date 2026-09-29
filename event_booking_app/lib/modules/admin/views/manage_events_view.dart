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
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '100');
    final seatsCtrl = TextEditingController(text: '50');
    String selectedCategory = 'Tech';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
        child: SizedBox(
          width: 480,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create New Event', style: AppTextStyles.title(AppColors.textPrimaryLight)),
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: ['Music', 'Tech', 'Sports', 'Arts', 'Business', 'Food', 'General']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => selectedCategory = v!,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
                  const SizedBox(height: 12),
                  TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (\$)'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: seatsCtrl, decoration: const InputDecoration(labelText: 'Seats'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final eventData = {
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'category': selectedCategory,
                            'venue': venueCtrl.text.trim(),
                            'city': cityCtrl.text.trim(),
                            'startDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
                            'endDate': DateTime.now().add(const Duration(days: 8)).toIso8601String(),
                            'price': double.tryParse(priceCtrl.text) ?? 0.0,
                            'totalSeats': int.tryParse(seatsCtrl.text) ?? 50,
                            'status': 'published',
                          };
                          eventController.createEvent(eventData);
                        },
                        child: const Text('Create'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

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
                title: Text(event.title, style: AppTextStyles.button(textPrimary)),
                subtitle: Text('${event.city} • ${Formatters.currency(event.price)} • Seats: ${event.availableSeats}/${event.totalSeats}'),
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
