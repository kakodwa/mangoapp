String capitalizeText(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    // Capitalize the first character and force the rest to lowercase
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}