enum ScreenSize { compact, medium, expanded }

class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double expanded = 840;
}

ScreenSize screenSizeOf(double width) {
  if (width >= Breakpoints.expanded) return ScreenSize.expanded;
  if (width >= Breakpoints.medium) return ScreenSize.medium;
  return ScreenSize.compact;
}