import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/annotation_generator.dart';

Builder secureDotEnvAnnotation(BuilderOptions options) => SharedPartBuilder(
      [SecureDotEnvAnnotationGenerator(options)],
      'secure_dot_env_annotation',
    );
