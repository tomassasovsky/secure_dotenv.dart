part of secure_dotenv;

class FieldKey {
  const FieldKey({
    this.name,
    this.defaultValue,
  });

  final String? name;
  final Object? defaultValue;
}
