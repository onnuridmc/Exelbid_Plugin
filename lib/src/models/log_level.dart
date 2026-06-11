enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3),
  off(4);

  const LogLevel(this.rawValue);

  final int rawValue;
}
