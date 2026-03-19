import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_client.dart';
import '../models/app_user.dart';

class SupabaseService {
  SupabaseClient get _client => SupabaseConfig.client;

  User? get currentAuthUser => _client.auth.currentUser;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AppUser> fetchCurrentAppUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw StateError('Usuário não autenticado.');
    }

    final data = await _client
        .from('users')
        .select('id, email, role, organization_id, full_name, siape')
        .eq('id', authUser.id)
        .single();

    String? orgName;
    final orgId = data['organization_id']?.toString();
    if (orgId != null && orgId.isNotEmpty) {
      final org = await _client
          .from('organizations')
          .select('name')
          .eq('id', orgId)
          .maybeSingle();
      orgName = org?['name']?.toString();
    }

    return AppUser(
      id: data['id'].toString(),
      email: (data['email'] ?? authUser.email ?? '').toString(),
      role: AppUser.roleFromDb((data['role'] ?? 'inspector').toString()),
      organizationId: orgId,
      organizationName: orgName,
      fullName: data['full_name']?.toString(),
      siape: data['siape']?.toString(),
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String siape,
    required UserRole role,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'siape': siape,
        'role': role.name, // user_metadata
      },
    );
  }

  Future<String> createOrganization({
    required String name,
    required String type,
    String? cnpjOrCode,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw StateError('Usuário não autenticado.');

    final inserted = await _client
        .from('organizations')
        .insert({
          'name': name,
          'type': type,
          'plan': 'gratuito',
          'cnpj_or_code': cnpjOrCode,
          'owner_id': authUser.id,
        })
        .select('id')
        .single();

    return inserted['id'].toString();
  }

  Future<void> attachUserToOrganization({
    required String organizationId,
    required String email,
    required String fullName,
    required String siape,
    required UserRole role,
  }) async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) throw StateError('Usuário não autenticado.');

    await _client.from('users').upsert({
      'id': authUser.id,
      'email': email,
      'role': role.name,
      'organization_id': organizationId,
      'full_name': fullName,
      'siape': siape,
    });
  }
}

