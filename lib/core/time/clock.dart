// Polymorphism is intentional: SystemClock for prod, FakeClock for tests.
// ignore_for_file: one_member_abstracts, use_setters_to_change_properties

abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration delta) {
    _now = _now.add(delta);
  }

  void setTo(DateTime instant) {
    _now = instant;
  }
}
