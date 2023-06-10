part of secure_dotenv;

/// Values for the automatic field renaming behavior for [DotEnvGen].
enum FieldRename {
  /// Use the field name without changes.
  none,

  /// Encodes a field named `kebabCase` with a key `kebab-case`.
  kebab,

  /// Encodes a field named `snakeCase` with a key `snake_case`.
  snake,

  /// Encodes a field named `pascalCase` with a key `PascalCase`.
  pascal,

  /// Encodes a field named `screamingSnakeCase` with a key
  /// `SCREAMING_SNAKE_CASE`
  screamingSnake,
}
