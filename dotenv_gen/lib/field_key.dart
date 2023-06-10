part of dotenv_gen;

class FieldKey {
  const FieldKey({
    this.name,
    this.defaultValue,
  });

  final String? name;
  final dynamic defaultValue;
}
