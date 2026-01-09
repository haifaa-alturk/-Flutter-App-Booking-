import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // قيم الفلترة (تخزَّن محلياً داخل الصفحة)
  double maxPrice = 500;
  int rooms = 1;
  String? governorate;
  String? city;

  final List<String> governorates = [
    "Damascus",
    "Aleppo",
    "Homs",
    "Hama",
    "Latakia",
    "Tartous",
  ];

  final List<String> cities = [
    "Mazzeh",
    "Baramkeh",
    "Jaramana",
    "Sahnaya",
    "Bab Touma",
  ];

  void resetFilters() {
    setState(() {
      maxPrice = 500;
      rooms = 1;
      governorate = null;
      city = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Apartments"),
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 السعر
            const Text("Max Price",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: maxPrice,
              min: 50,
              max: 1000,
              divisions: 20,
              label: "\$${maxPrice.toStringAsFixed(0)}",
              onChanged: (v) {
                setState(() => maxPrice = v);
              },
            ),

            const SizedBox(height: 20),

            // 🔹 عدد الغرف
            const Text("rooms",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: rooms.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: rooms.toString(),
              onChanged: (v) {
                setState(() => rooms = v.toInt());
              },
            ),

            const SizedBox(height: 20),

            // 🔹 المحافظة
            const Text("Governorate",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: governorate,
              isExpanded: true,
              hint: const Text("Choose governorate"),
              items: governorates.map(
                (g) => DropdownMenuItem(value: g, child: Text(g)),
              ).toList(),
              onChanged: (v) {
                setState(() => governorate = v);
              },
            ),

            const SizedBox(height: 20),

            // 🔹 المدينة
            const Text("City",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: city,
              isExpanded: true,
              hint: const Text("Choose city"),
              items: cities.map(
                (c) => DropdownMenuItem(value: c, child: Text(c)),
              ).toList(),
              onChanged: (v) {
                setState(() => city = v);
              },
            ),

            const SizedBox(height: 30),

            // 🔸 أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: resetFilters,
                    child: const Text("Reset"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    onPressed: () {
                      // نرجع القيم للصفحة الرئيسية
                      Navigator.pop(context, {
                        "maxPrice": maxPrice,
                        "rooms": rooms,
                        "governorate": governorate,
                        "city": city,
                      });
                    },
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
