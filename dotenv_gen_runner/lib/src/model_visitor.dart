// import 'package:analyzer/dart/element/element.dart';
// import 'package:analyzer/dart/element/nullability_suffix.dart';
// import 'package:analyzer/dart/element/type.dart';
// import 'package:analyzer/dart/element/visitor.dart';

// class ModelVisitor extends SimpleElementVisitor<void> {
//   String className = '';
//   List<Field> fields = <Field>[];

//   @override
//   void visitConstructorElement(ConstructorElement element) {
//     final returnType = element.returnType.toString();
//     className = returnType.replaceFirst('*', '');
//   }

//   @override
//   void visitFieldElement(FieldElement element) {
//     final field = Field(
//       element.name,
//       element.type.getDisplayString(withNullability: true),
//       import: element.librarySource?.uri.toString(),
//     );
//     fields.add(field);
//   }
// }

