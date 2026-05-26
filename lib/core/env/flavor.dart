enum Flavor {
  dev('10k Hours Dev'),
  prod('10k Hours');

  const Flavor(this.appName);
  final String appName;
}
