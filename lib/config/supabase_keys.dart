// Supabase Keys Configuration
// WICHTIG: Ersetze den Platzhalter-Key mit deinem echten anon key aus dem Supabase Dashboard

class SupabaseKeys {
  // Echter Supabase anon key - BITTE ERSETZEN!
  // Gehe zu: https://nqxgsuxyvhjveigbjyxb.supabase.co/project/default/settings/api
  // Kopiere den "anon public" key und ersetze den Wert unten
  
  static const String realAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xeGdzdXh5dmhqdmVpZ2JqeXhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM4NjQzNTEsImV4cCI6MjA2OTQ0MDM1MX0.-OR8ogKF9CwQ2oX2er8Y3chn1-i04LmRg85Ya2fjYkA';
  
  // Beispiel eines echten Keys (ersetze mit deinem):
  // static const String realAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xeGdzdXh5dmhqdmVpZ2JqeXhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5NzQ4MDAsImV4cCI6MjA1MDU1MDgwMH0.DEIN_ECHTER_SIGNATURE_TEIL';
  
  // Prüfung ob der Key konfiguriert wurde
  static bool get isConfigured => realAnonKey != 'HIER_DEIN_ECHTER_ANON_KEY_EINFÜGEN';
}
