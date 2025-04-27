import 'dart:convert';

import 'package:assessment/constants/api_constants.dart';
import 'package:assessment/models/document.dart';
import 'package:assessment/models/login_request.dart';
import 'package:assessment/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _authService = AuthService();

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final token = responseData['data']['Token'] as String;
          await _authService.saveToken(token);

          // Get user info and company ID
          await _getUserInfo(token);

          return responseData;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> _getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final companyId = responseData['data']['belongCompanyId'] as String;
          await _authService.saveCompanyId(companyId);
        } else {
          throw Exception('Invalid user info response format');
        }
      } else {
        throw Exception('Failed to get user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<List<Document>> searchDocuments({
    String? query,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final companyId = await _authService.getCompanyId();
      if (companyId == null) {
        throw Exception('Company ID not found');
      }

      final headers = await _getHeaders();
      final queryParams = {
        if (query != null) 'query': query,
        'from': 'report',
        'component': 'reports-table',
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/$companyId/library/documents/',
        ).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List documentsJson = responseData['data'];
          return documentsJson.map((json) => Document.fromJson(json)).toList();
        } else {
          throw Exception('Invalid documents response format');
        }
      } else {
        throw Exception('Failed to search documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }

  Future<void> updateDocument(Document document) async {
    try {
      final companyId = await _authService.getCompanyId();
      if (companyId == null) {
        throw Exception('Company ID not found');
      }

      final headers = await _getHeaders();
      final queryParams = {
        'formId': ApiConstants.formId,
        'actionId': ApiConstants.actionId,
      };

      final body = {
        'document': {
          'id': document.id,
          'fields': {
            ApiConstants.firstNameFieldId: document.firstName,
            ApiConstants.lastNameFieldId: document.lastName,
            ApiConstants.notesFieldId: document.notes,
          },
        },
      };

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/$companyId/documents/actions',
        ).replace(queryParameters: queryParams),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to update document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> createDocument(
    String firstName,
    String lastName,
    String? notes,
  ) async {
    try {
      final companyId = await _authService.getCompanyId();
      if (companyId == null) {
        throw Exception('Company ID not found');
      }

      final headers = await _getHeaders();
      final queryParams = {
        'formId': ApiConstants.formId,
        'actionId': ApiConstants.actionId,
      };

      final body = {
        'document': {
          'fields': {
            ApiConstants.firstNameFieldId: firstName,
            ApiConstants.lastNameFieldId: lastName,
            ApiConstants.notesFieldId: notes,
          },
        },
      };

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.baseUrl}/api/$companyId/documents/actions',
        ).replace(queryParameters: queryParams),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final companyId = await _authService.getCompanyId();
      if (companyId == null) {
        throw Exception('Company ID not found');
      }

      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/$companyId/documents/$documentId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Future<void> logout() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (![200, 201, 204].contains(response.statusCode)) {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> getCompanyId() async {
    return _authService.getCompanyId();
  }
}
