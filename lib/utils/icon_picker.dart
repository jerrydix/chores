import 'package:flutter/material.dart';

Future<IconData?> showMaterialIconPicker(
  BuildContext context, {
  String title = 'Pick an icon',
}) {
  return showDialog<IconData>(
    context: context,
    builder: (ctx) => _IconPickerDialog(title: title),
  );
}

class _IconPickerDialog extends StatefulWidget {
  final String title;
  const _IconPickerDialog({required this.title});

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog> {
  String _query = '';

  static const Map<String, IconData> _icons = {
    // Home & Rooms
    'home': Icons.home,
    'house': Icons.house,
    'apartment': Icons.apartment,
    'bedroom': Icons.bedroom_parent,
    'living room': Icons.weekend,
    'kitchen': Icons.kitchen,
    'bathroom': Icons.bathroom,
    'shower': Icons.shower,
    'bathtub': Icons.bathtub,
    'toilet': Icons.wc,
    'garage': Icons.garage,
    'balcony': Icons.balcony,
    'door': Icons.door_front_door,
    'window': Icons.window,
    'stairs': Icons.stairs,
    'hallway': Icons.meeting_room,

    // Cleaning
    'cleaning': Icons.cleaning_services,
    'soap': Icons.soap,
    'wash hands': Icons.wash,
    'dry': Icons.dry,
    'sanitizer': Icons.sanitizer,
    'water drop': Icons.water_drop,

    // Kitchen & Food
    'cooking': Icons.restaurant,
    'food bank': Icons.food_bank,
    'coffee': Icons.coffee,
    'breakfast': Icons.free_breakfast,
    'lunch': Icons.lunch_dining,
    'dinner': Icons.dinner_dining,
    'microwave': Icons.microwave,
    'blender': Icons.blender,
    'countertop': Icons.countertops,
    'rice bowl': Icons.rice_bowl,
    'grocery': Icons.local_grocery_store,

    // Laundry
    'laundry': Icons.local_laundry_service,
    'iron': Icons.iron,
    'dry cleaning': Icons.dry_cleaning,
    'wardrobe': Icons.checkroom,

    // Trash & Recycling
    'trash': Icons.delete,
    'delete outline': Icons.delete_outline,
    'recycling': Icons.recycling,
    'compost': Icons.compost,
    'garbage': Icons.delete_forever,

    // Garden & Outdoor
    'yard': Icons.yard,
    'grass': Icons.grass,
    'park': Icons.park,
    'nature': Icons.nature,
    'eco': Icons.eco,
    'leaf': Icons.energy_savings_leaf,

    // Shopping & Errands
    'shopping cart': Icons.shopping_cart,
    'shopping bag': Icons.shopping_bag,
    'store': Icons.store,
    'pharmacy': Icons.local_pharmacy,
    'mail': Icons.mail,
    'package': Icons.inventory_2,
    'delivery': Icons.local_shipping,

    // People
    'person': Icons.person,
    'group': Icons.group,
    'family': Icons.family_restroom,
    'child care': Icons.child_care,
    'pets': Icons.pets,

    // Tools & Repair
    'build': Icons.build,
    'handyman': Icons.handyman,
    'plumbing': Icons.plumbing,
    'electrical': Icons.electrical_services,
    'construction': Icons.construction,

    // Home systems
    'ac': Icons.ac_unit,
    'fireplace': Icons.fireplace,
    'water': Icons.water,
    'lightbulb': Icons.lightbulb,
    'power': Icons.power,
    'wifi': Icons.wifi,
    'lock': Icons.lock,
    'security': Icons.security,

    // Furniture
    'chair': Icons.chair,
    'bed': Icons.bed,
    'table': Icons.table_bar,
    'desk': Icons.desk,

    // General / Task
    'star': Icons.star,
    'favorite': Icons.favorite,
    'check circle': Icons.check_circle,
    'task': Icons.task_alt,
    'schedule': Icons.schedule,
    'calendar': Icons.calendar_today,
    'alarm': Icons.alarm,
    'notification': Icons.notifications,
    'flag': Icons.flag,
    'bookmark': Icons.bookmark,
    'label': Icons.label,
    'work': Icons.work,
    'money': Icons.attach_money,
    'payment': Icons.payment,
    'car': Icons.directions_car,
    'bike': Icons.directions_bike,
    'phone': Icons.phone,
    'computer': Icons.computer,
    'tv': Icons.tv,
    'book': Icons.menu_book,
    'sports': Icons.sports,
    'celebration': Icons.celebration,
    'cake': Icons.cake,
    'volunteer': Icons.volunteer_activism,
    'info': Icons.info,
    'help': Icons.help,
    'spa': Icons.spa,
    'fitness': Icons.fitness_center,
    'local activity': Icons.local_activity,
    'inventory': Icons.inventory,
    'hospital': Icons.local_hospital,
    'medication': Icons.medication,
    'car wash': Icons.local_car_wash,
    'heat': Icons.heat_pump,
  };

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final filtered = q.isEmpty
        ? _icons.entries.toList()
        : _icons.entries.where((e) => e.key.contains(q)).toList();

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: 360,
        height: 380,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No results for "$_query"',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final entry = filtered[i];
                        return Tooltip(
                          message: entry.key,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(ctx).pop(entry.value),
                            child: Center(child: Icon(entry.value, size: 28)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
