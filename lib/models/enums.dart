enum Region {
  europe,
  canada,
  usa;

  String get value {
    switch (this) {
      case Region.europe:
        return 'EUR';
      case Region.canada:
        return 'CA';
      case Region.usa:
        return 'USA';
    }
  }

  @override
  String toString() {
    switch (this) {
      case Region.europe:
        return 'Europe';
      case Region.canada:
        return 'Canada';
      case Region.usa:
        return 'USA';
    }
  }
}

enum Brand {
  kia,
  hyundai;

  String get value {
    switch (this) {
      case Brand.kia:
        return 'kia';
      case Brand.hyundai:
        return 'hyundai';
    }
  }

  @override
  String toString() {
    switch (this) {
      case Brand.kia:
        return 'Kia';
      case Brand.hyundai:
        return 'Hyundai';
    }
  }
}
