library dotenv_gen;

class DotEnvGen {
  const DotEnvGen({
    this.filenames = const ['.env'],
  });

  final List<String> filenames;
}
