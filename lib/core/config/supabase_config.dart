class SupabaseConfig {
  // 1. Supabase 대시보드 -> Project Settings -> API 에서 'Project URL' 복사해서 아래에 붙여넣기
  static const String supabaseUrl = 'https://lxhfosowckqzaryqgptu.supabase.co';

  // 2. Supabase 대시보드 -> Project Settings -> API 에서 'anon public' 키 복사해서 아래에 붙여넣기
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4aGZvc293Y2txemFyeXFncHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNTI5MzksImV4cCI6MjA4NjkyODkzOX0.cb_OalSlbd2zvE1hK_622ActVhVcABssYGXcmm-KeIQ';

  // 3. Google Cloud Console -> Credentials -> Web Client ID 복사해서 아래에 붙여넣기
  // (Google 로그인에 필요합니다!)
  static const String webClientId = '215935807987-vk9foiu0gq844m8kp7vgg41o87rsn2e7.apps.googleusercontent.com';
}
