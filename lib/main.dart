import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://oxkspuxkwezitzfjusqq.supabase.co',
    publishableKey: 'sb_publishable_khL7temTjLgB3KI64wQSWQ_Cv7atks0',
  );
  runApp(const UpwiseApp());
}