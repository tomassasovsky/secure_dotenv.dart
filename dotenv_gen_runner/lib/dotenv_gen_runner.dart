import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/dotenv_gen_runner.dart';

Builder dotEnvGenAnnotation(BuilderOptions options) =>
    SharedPartBuilder([DotEnvGenAnnotationGenerator()], 'dotenv_gen_annotation');