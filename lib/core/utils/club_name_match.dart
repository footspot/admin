/// Advisory comparison of a Footspot club name vs an Intersport shop name,
/// used to warn the PDG about a mismatched pairing before they accept a
/// Flow-1 integration. Never authoritative — only a hint.
class ClubNameMatch {
  // * Common org tokens that carry no identifying value when comparing names.
  static const _stopWords = <String>{
    'as', 'fc', 'club', 'us', 'sc', 'ac', 'rc', 'ca', 'asso', 'association',
    'sport', 'sports', 'sportive', 'sportif', 'football', 'foot', 'la', 'le',
    'les', 'de', 'du', 'des', 'et', 'd', 'l',
  };

  static const _accents = <String, String>{
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'æ': 'ae',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'œ': 'oe',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
  };

  /// Normalize: lowercase, strip accents, drop punctuation, collapse spaces.
  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      buf.write(_accents[ch] ?? ch);
    }
    return buf
        .toString()
        // * Anything that is not a letter or digit becomes a space.
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  /// Significant tokens after normalization, minus common org words.
  static Set<String> _tokens(String input) {
    return normalize(input)
        .split(' ')
        .where((t) => t.isNotEmpty && !_stopWords.contains(t))
        .toSet();
  }

  /// Returns true when the two names plausibly refer to the same entity.
  /// Conservative: only flags a mismatch when there is no meaningful overlap.
  static bool isMatch(String? a, String? b) {
    if (a == null || b == null) return true; // * can't judge — don't alarm
    final ta = _tokens(a);
    final tb = _tokens(b);
    // * If stop-word stripping emptied a set, fall back to raw normalized text.
    if (ta.isEmpty || tb.isEmpty) {
      return normalize(a) == normalize(b);
    }
    if (ta.length <= tb.length ? tb.containsAll(ta) : ta.containsAll(tb)) {
      return true;
    }
    final intersection = ta.intersection(tb).length;
    final union = ta.union(tb).length;
    // * Jaccard ≥ 0.5 → enough shared tokens to consider it a match.
    return union > 0 && intersection / union >= 0.5;
  }
}
