String getTimeString(int seconds) {
  int _seconds = seconds;
  int _hours = _seconds ~/ (3600);

  _seconds -= (_hours * 3600);
  int _minutes = _seconds ~/ 60;

  _seconds -= (_minutes * 60);

  return "${_hours < 10 ? "0" + _hours.toString() : _hours} : ${_minutes < 10 ? "0" + _minutes.toString() : _minutes} :${_seconds < 10 ? "0" + _seconds.toString() : _seconds}";
}
