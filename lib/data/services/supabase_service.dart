import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

/// Supabase 초기화 + 인증(Auth) 서비스
/// 
/// Google 로그인, 로그아웃, 유저 상태 관리
class SupabaseService {
  // ─── 초기화 ──────────────────────────────────────────
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  /// Supabase Client 인스턴스
  static SupabaseClient get client => Supabase.instance.client;

  // ─── 인증 상태 ──────────────────────────────────────
  
  /// 현재 로그인된 유저 (null이면 비로그인)
  static User? get currentUser => client.auth.currentUser;

  /// 로그인 여부
  static bool get isLoggedIn => currentUser != null;

  /// 인증 상태 변화 스트림 (로그인/로그아웃 감지)
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ─── Google 로그인 ──────────────────────────────────
  
  /// Google 계정으로 로그인
  /// 
  /// 성공 시 [AuthResponse] 반환, 실패 시 Exception throw
  static Future<AuthResponse> signInWithGoogle() async {
    // 1. Google Sign-In 시작
    final googleSignIn = GoogleSignIn(
      serverClientId: SupabaseConfig.webClientId,
    );
    
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google 로그인이 취소되었습니다.');
    }

    // 2. Google 인증 토큰 가져오기
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('Google ID 토큰을 가져올 수 없습니다.');
    }

    // 3. Supabase에 Google 토큰으로 로그인
    final response = await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return response;
  }

  // ─── 로그아웃 ──────────────────────────────────────
  
  /// 로그아웃 (Google + Supabase 세션 모두 해제)
  static Future<void> signOut() async {
    // Google 로그아웃
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    
    // Supabase 로그아웃
    await client.auth.signOut();
  }

  // ─── 유저 정보 ──────────────────────────────────────
  
  /// 현재 유저의 display name (Google 프로필 이름)
  static String? get displayName {
    return currentUser?.userMetadata?['full_name'] as String?;
  }

  /// 현재 유저의 아바타 URL (Google 프로필 사진)
  static String? get avatarUrl {
    return currentUser?.userMetadata?['avatar_url'] as String?;
  }

  /// 현재 유저의 이메일
  static String? get email {
    return currentUser?.email;
  }
}
