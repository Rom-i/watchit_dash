import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
 static const String url ="https://hbsxpkpxzcirwiqialuw.supabase.co";
 static const String apiKey ="sb_publishable_uZaQO5cN9lE6zVsd1PhFMA_vlU3m0BU";
 static init()async{
  await Supabase.initialize(url: url, anonKey: apiKey);
 
 }
}