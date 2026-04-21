/// Calculates IFR minutes from block minutes and factoring rules.
///
/// Rule order:
/// 1. Subtract [subtractMinutes] from [totalMinutes].
/// 2. Apply [percent] to the remaining minutes.
/// 3. Enforce [minimumMinutes].
/// 4. Clamp final value to `[0, totalMinutes]`.
int calculateIfrMinutes({
  required int totalMinutes,
  required int percent,
  required int subtractMinutes,
  required int minimumMinutes,
}) {
  final normalizedTotal = totalMinutes < 0 ? 0 : totalMinutes;
  final clampedPercent = percent.clamp(0, 100);

  var result = normalizedTotal - subtractMinutes;
  if (result < 0) result = 0;
  result = ((result * clampedPercent) / 100).round();

  if (result < minimumMinutes) result = minimumMinutes;
  if (result > normalizedTotal) result = normalizedTotal;
  if (result < 0) result = 0;

  return result;
}
