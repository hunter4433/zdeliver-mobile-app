import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_search/mapbox_search.dart';

class AddressSelectionScreen extends StatefulWidget {
  final void Function(String address, double lat, double long)?
  onAddressSelected;
  const AddressSelectionScreen({Key? key, this.onAddressSelected})
    : super(key: key);

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  late SearchBoxAPI _placesSearch;
  final TextEditingController _searchController = TextEditingController();
  String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  List<Suggestion> _suggestions = [];
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  @override
  void initState() {
    super.initState();

    _placesSearch = SearchBoxAPI(apiKey: ACCESS_TOKEN, limit: 10);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with back button and title
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Address',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Search field
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.deepOrange,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search manually',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) async {
                        if (value.length > 2) {
                          print(value);
                          // Start searching for places
                          setState(() => _isSearching = true);
                          ApiResponse<SuggestionResponse> searchPlace =
                              await _placesSearch.getSuggestions(value);
                          if (searchPlace.success == null &&
                              searchPlace.success!.suggestions.isEmpty)
                            return;

                          //  String mapboxId = searchPlace.success!.suggestions[0].mapboxId;

                          // Update suggestions with results
                          setState(() {
                            _suggestions = searchPlace.success!.suggestions;
                            _isSearching = false;
                          });
                        } else {
                          setState(() => _suggestions = []);
                        }
                      },
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.deepOrange,
                      size: 30,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Use current location button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.my_location, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'use current location',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Suggestions list
            if (_suggestions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final place = _suggestions[index];
                    return ListTile(
                      title: Text(place.name),
                      subtitle: Text(place.fullAddress ?? ''),
                      onTap: () async {
                        // Handle address selection
                        final mapboxId = place.mapboxId;
                        final placeDetails = await _placesSearch.getPlace(
                          mapboxId,
                        );
                        final lat =
                            placeDetails
                                .success
                                ?.features[0]
                                .geometry
                                .coordinates
                                .lat;
                        final lng =
                            placeDetails
                                .success
                                ?.features[0]
                                .geometry
                                .coordinates
                                .lat;
                        print('lat: $lat, lng: $lng');
                        
                        if (lat != null &&
                            lng != null &&
                            widget.onAddressSelected != null) {
                          widget.onAddressSelected!(
                            place.fullAddress ?? '',
                            lat,
                            lng,
                          );
                          // you can navigate back or close the screen
                          Navigator.pop(context, {
                            'lat': lat,
                            'lng': lng,
                            'address': place.fullAddress ?? '',
                          });
                        } else {
                          // Handle error case where lat or lng is null
                          // Show a snackbar or dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Unable to get location details.'),
                            ),
                          );
                        }
                      },
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
