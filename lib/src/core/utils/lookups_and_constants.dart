import 'package:etqan_application_2025/src/core/common/entities/departments.dart';
import 'package:etqan_application_2025/src/core/common/entities/positions.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Departments>> fetchDepartments() async {
  final response = await Supabase.instance.client
      .from('departments')
      .select()
      .order('department_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => Departments.fromJson(json)).toList();
}

Future<Departments?> fetchDepartmentById(String departmentId) async {
  if (departmentId.isNullOrEmpty) {
    return null;
  }
  final response = await Supabase.instance.client
      .from('departments')
      .select()
      .eq('department_id', departmentId)
      .order('department_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => Departments.fromJson(json)).firstOrNull;
}

Future<List<Positions>> fetchPositions(String departmentId) async {
  final response = await Supabase.instance.client
      .from('positions')
      .select()
      .eq('department_id', departmentId)
      .order('position_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => Positions.fromJson(json)).toList();
}

Future<List<UserModel>> fetchUsersByDepartment(String departmentId) async {
  if (departmentId.isNullOrEmpty) {
    return [];
  }

  final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('department_id', departmentId)
      .order('first_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => UserModel.fromJson(json)).toList();
}

Future<List<UserModel>> fetchAllUsers() async {
  final response = await Supabase.instance.client
      .from('users')
      .select()
      .order('first_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => UserModel.fromJson(json)).toList();
}

Future<List<ServiceField>> fetchFieldsByServiceId(int serviceId) async {
  final response = await Supabase.instance.client
      .from('service_fields')
      .select()
      .eq('service_id', serviceId)
      .order('order_index', ascending: true);

  final data = response as List;
  return data.map((json) => ServiceField.fromJson(json)).toList();
}
