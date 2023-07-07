import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:virtual_assistant/util/chat_util.dart';

class Activity {
  final String name;
  final String location;
  final String priceEstimate;
  final String remarks;

  Activity({
    required this.name,
    required this.location,
    required this.priceEstimate,
    required this.remarks,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      name: json['name'],
      location: json['location'],
      priceEstimate: json['price_estimate'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'price_estimate': priceEstimate,
      'remarks': remarks,
    };
  }
}

class Day {
  final String day;
  final List<Activity> activities;

  Day({
    required this.day,
    required this.activities,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      day: json['day'],
      activities: (json['activities'] as List<dynamic>)
          .map((activityJson) => Activity.fromJson(activityJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'activities': activities.map((activity) => activity.toJson()).toList(),
    };
  }
}

class TravelItineraryScreen extends StatefulWidget {
  final String apiKey;

  TravelItineraryScreen({required this.apiKey});

  @override
  _TravelItineraryScreenState createState() => _TravelItineraryScreenState();
}

class _TravelItineraryScreenState extends State<TravelItineraryScreen> {
  final TextEditingController _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCurrency;
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _numTravelersController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
  final List<Day> _itinerary = [];
  bool _isGeneratingItinerary = false;

  void _generateItinerary() async {
    setState(() {
      _isGeneratingItinerary = true;
    });
    _itinerary.clear();
    final location = _destinationController.text;
    final String startDate =
        _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : '';
    final String endDate =
        _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : '';
    final String budget =
        '${_budgetController.text} ${_selectedCurrency ?? ''}';
    final numTravelers = _numTravelersController.text;
    final keywords = _keywordsController.text;

    String rawMessage = (await readRawMessageFormat())
        .replaceAll('{{location}}', location)
        .replaceAll('{{startDate}}', startDate)
        .replaceAll('{{endDate}}', endDate)
        .replaceAll('{{budget}}', budget)
        .replaceAll('{{numTravelers}}', numTravelers)
        .replaceAll('{{keywords}}', keywords);

    final responses = await ChatUtility.sendMessage(rawMessage, widget.apiKey);
    var jsonResponse = responses.join();
    // var jsonResponse = await rootBundle
    //     .loadString('assets/sample_travel_itenary_reposnse.response');
    Map<String, dynamic> jsonData = jsonDecode(jsonResponse);
    List<dynamic> itineraryJson = jsonData['itinerary'];
    List<Day> itinerary =
        itineraryJson.map((dayJson) => Day.fromJson(dayJson)).toList();
    itinerary.sort((day1, day2) {
      // Extract the day number from the string (e.g., "Day 1" => 1)js
      int dayNumberA = int.parse(day1.day.split(' ')[1]);
      int dayNumberB = int.parse(day2.day.split(' ')[1]);
      return dayNumberA.compareTo(dayNumberB);
    });
    // Clear the existing itinerary

    _itinerary.addAll(itinerary);
    setState(() {
      _isGeneratingItinerary = false;
    });
  }

  Future<String> readRawMessageFormat() async {
    return await rootBundle.loadString('assets/travel_itinerary_message.chat');
  }

  Future<void> _shareItinerary() async {
    // Generate the itinerary as an image
    final image = await _generateItineraryImage();
    if (image != null) {
      // Save the image temporarily
      final tempPath = (await path_provider.getTemporaryDirectory()).path;
      final imagePath = '$tempPath/itinerary.png';
      final imageFile =
          await File(imagePath).writeAsBytes(image.buffer.asUint8List());
      // Share the image
      Share.shareFiles([imagePath],
          subject:
              'Hey, I planned my travel itinerary using my Virtual Assistant');
    }
  }

  Future<Uint8List?> _generateItineraryImage() async {
    return _screenshotController.captureFromLongWidget(
      InheritedTheme.captureAll(
          context, Material(child: _buildItineraryTable())),
      delay: const Duration(milliseconds: 3000),
      context: context,
    );
  }

  Widget _buildItineraryTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 16,
          headingRowHeight: 50, // Adjust the height of the heading row
          dataRowMaxHeight: 55, // Adjust the height of the data rows
          horizontalMargin: 16, // Add horizontal margin around the table
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey), // Add border around the table
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Location',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Activity Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Estimated Price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Remark',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: _itinerary.expand((day) {
            final activities = day.activities;
            return activities.map((activity) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 100, // Adjust the width as needed
                      child: Text(day.day),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150, // Adjust the width as needed
                      child: Text(activity.location),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150, // Adjust the width as needed
                      child: Text(activity.name),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100, // Adjust the width as needed
                      child: Text(activity.priceEstimate),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150, // Adjust the width as needed
                      child: Text(activity.remarks),
                    ),
                  ),
                ],
                color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  // Customize the background color of the rows based on states (e.g., hover, selected)
                  if (states.contains(MaterialState.selected)) {
                    return Colors.blue.withOpacity(0.2);
                  }
                  return null; // Return null for the default background color
                }),
              );
            }).toList();
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Itinerary'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destination',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _numTravelersController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Travelers',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _startDate = selectedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startDate != null
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : ''),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _endDate = selectedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_endDate != null
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : ''),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetController,
                    decoration: InputDecoration(
                      labelText: 'Budget',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: ['USD', 'EUR', 'GBP', 'INR'].map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _keywordsController,
              decoration: const InputDecoration(labelText: 'Keywords'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _isGeneratingItinerary ? null : _generateItinerary,
              icon: _isGeneratingItinerary
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.create),
              label: const Text('Generate Itinerary'),
            ),
            const SizedBox(height: 16.0),
            if (_itinerary.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _shareItinerary,
                icon: const Icon(Icons.share),
                label: const Text('Share Itinerary'),
              ),
            const SizedBox(height: 16),
            _itinerary.isNotEmpty
                ? Screenshot(
                    controller: _screenshotController,
                    child: _buildItineraryTable())
                : Container(),
          ],
        ),
      ),
    );
  }
}
