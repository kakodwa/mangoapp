import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../models/search_result_item.dart';

class SearchProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<SearchResultItem> _results = [];
  List<SearchResultItem> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _query = '';
  String _selectedType = 'all';
  String? _selectedDistrict;
  String? _selectedCategory;
  String? _selectedListingPurpose;

  int _currentPage = 1;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  String get selectedType => _selectedType;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedCategory => _selectedCategory;
  String? get selectedListingPurpose => _selectedListingPurpose;

  void updateFilters({
    String? query,
    String? type,
    String? district,
    String? category,
    String? listingPurpose,
  }) {
    if (query != null) _query = query;
    if (type != null) {
      _selectedType = type;
      _selectedCategory = null; // Reset category selection when changing the core section tab
      _selectedListingPurpose = null;
    }
    
    // Explicit value replacement allowing null variables
    if (district != isUnchanged) _selectedDistrict = district;
    if (category != isUnchanged) _selectedCategory = category;
    if (listingPurpose != isUnchanged) _selectedListingPurpose = listingPurpose;
    
    resetSearch();
  }
  
  // Dummy constant helper to allow optional passing of properties
  static const String isUnchanged = "__UNCHANGED__";

  void resetSearch() {
    _results = [];
    _currentPage = 1;
    _hasMoreData = true;
    _errorMessage = '';
    notifyListeners();
    fetchItems(isRefresh: true);
  }

  Future<void> fetchItems({bool isRefresh = false}) async {
    if (_isLoading || _isLoadingMore || !_hasMoreData) return;

    if (isRefresh || _currentPage == 1) {
      _isLoading = true;
      _errorMessage = '';
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await _apiClient.searchUnified(
        query: _query,
        type: _selectedType,
        district: _selectedDistrict,
        category: _selectedCategory,
        listingPurpose: _selectedListingPurpose,
        page: _currentPage,
      );

      final List<dynamic> resultsRaw = response['results'] ?? [];
      final List<SearchResultItem> fetchedItems = resultsRaw
          .map((json) => SearchResultItem.fromJson(json as Map<String, dynamic>))
          .toList();

      if (fetchedItems.isEmpty) {
        _hasMoreData = false;
      } else {
        _results.addAll(fetchedItems);
        if (response['next'] == null) {
          _hasMoreData = false;
        } else {
          _currentPage++;
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll("ApiException: ", "");
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}