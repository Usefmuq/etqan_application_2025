import 'package:etqan_application_2025/src/core/common/entities/departments.dart';
import 'package:etqan_application_2025/src/core/common/entities/positions.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/data/models/role_permission_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/roles_model.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
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
  if (departmentId.isNullOrEmpty) {
    return [];
  }

  final response = await Supabase.instance.client
      .from('positions')
      .select()
      .eq('department_id', departmentId)
      .order('position_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => Positions.fromJson(json)).toList();
}

Future<List<Positions>> fetchAllPositions() async {
  final response = await Supabase.instance.client
      .from('positions')
      .select()
      .order('position_name_en', ascending: true);

  final data = response as List;
  return data.map((json) => Positions.fromJson(json)).toList();
}

Future<List<RolesModel>> fetchAllRoles() async {
  final response = await Supabase.instance.client
      .from('roles')
      .select()
      .order('parent_role_id', ascending: true);

  final data = response as List;
  return data.map((json) => RolesModel.fromJson(json)).toList();
}

Future<List<RolePermissionViewModel>> fetchRolePermissionView(
  List<String> roleId,
) async {
  if (roleId.isEmpty) {
    return [];
  }

  final response = await Supabase.instance.client
      .from('role_permission_view')
      .select()
      .inFilter('role_id', roleId)
      .order('parent_role_id', ascending: true);

  final data = response as List;
  return data.map((json) => RolePermissionViewModel.fromJson(json)).toList();
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
      .eq('is_active', true)
      .order('order_index', ascending: true);

  final data = response as List;
  return data.map((json) => ServiceField.fromJson(json)).toList();
}

Future<List<AttendanceSessionModel>> fetchLatestAttendances(
  String userId,
) async {
  final response = await Supabase.instance.client
      .from('attendance_sessions')
      .select()
      .eq('user_id', userId)
      .eq('is_active', true)
      .lte('start_at', DateTime.now())
      .order('start_at', ascending: false);

  final data = response as List;
  return data.map((json) => AttendanceSessionModel.fromJson(json)).toList();
}
