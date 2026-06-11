enum Gender {
  unspecified(0),
  male(1),
  female(2);

  const Gender(this.rawValue);

  final int rawValue;
}
