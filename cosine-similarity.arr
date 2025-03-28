provide *

import string-dict as SD

import gdrive-sheets as GDS

import data-source as DS

import tables as T

import sets as S

fun list-of-words-to-sd(xx :: List<String>) -> SD.StringDict<Number> block:
  msd = [SD.mutable-string-dict:]
  for each(x from xx):
    old-value = cases(Option) (msd.get-now(x)):
        | none => 0
        | some(v) => v
        end
    msd.set-now(x, old-value + 1)
  end
  msd.freeze()
end

lower-case-a-cp = string-to-code-point('a')
lower-case-z-cp = string-to-code-point('z')

fun is-non-punct(c :: String) -> Boolean:
  if (c == ' ') or (c == '\n'): true
  else:
    c-cp = string-to-code-point(c)
    (c-cp >= lower-case-a-cp) and (c-cp <= lower-case-z-cp)
  end
end

fun is-non-empty-string(s :: String) -> Boolean:
  s <> ''
end

fun massage-string(w :: String) -> String:
  fold(lam(string-a, string-b): string-a + string-b end, '', string-explode(string-to-lower(w)).filter(is-non-punct))
end

fun string-to-list-of-natlang-words(s :: String) -> List<String>:
  string-split-all(massage-string(string-to-lower(s)), ' ').filter(is-non-empty-string)
end

# stop words from https://dl.acm.org/doi/pdf/10.1145/378881.378888, Appendix A, Christopher Fox

standard-stop-words = [list: "the", "and", "a", "that", "was", "for", "with", "not", "on", "at", "i", "had", "are", "or", "an", "they", "one", "would", "all", "there", "their", "him", "has", "when", "if", "out", "what", "up", "about", "into", "can", "other", "some", "time", "two", "then", "do", "now", "such", "man", "our", "even", "made", "after", "many", "must", "years", "much", "your", "down", "should", "of", "to", "in", "is", "he", "it", "as", "his", "be", "by", "this", "but", "from", "have", "you", "which", "were", "her", "she", "will", "we", "been", "who", "more", "no", "so", "said", "its", "than", "them", "only", "new", "could", "these", "may", "first", "any", "my", "like", "over", "me", "most", "also", "did", "before", "through", "where", "back", "way", "well", "because", "each", "people", "state", "mr", "how", "make", "still", "own", "work", "long", "both", "under", "never", "same", "while", "last", "might", "day", "since", "come", "great", "three", "go", "few", "use", "without", "place", "old", "small", "home", "went", "once", "school", "every", "united", "number", "does", "away", "water", "fact", "though", "enough", "almost", "took", "night", "system", "general", "better", "why", "end", "find", "asked", "going", "knew", "toward", "just", "those", "too", "world", "very", "good", "see", "men", "here", "get", "between", "year", "another", "being", "life", "know", "us", "off", "against", "came", "right", "states", "take", "himself", "during", "again", "around", "however", "mrs", "thought", "part", "high", "upon", "say", "used", "war", "until", "always", "something", "public", "put", "think", "head", "far", "hand", "set", "nothing", "point", "house", "later", "eyes", "next", "program", "give", "white", "room", "social", "young", "present", "order", "second", "possible", "light", "face", "important", "among", "early", "need", "within", "business", "felt", "best", "ever", "least", "got", "mind", "want", "others", "although", "open", "area", "done", "certain", "door", "different", "sense", "help", "perhaps", "group", "side", "several", "let", "national", "given", "rather", "per", "often", "god", "things", "large", "big", "become", "case", "along", "four", "power", "saw", "less", "thing", "today", "interest", "turned", "members", "family", "problem", "kind", "began", "thus", "seemed", "whole", "itself"]


fun remove-stop-words(list-of-words :: List<String>):
  list-of-words.filter(lam(w): not(standard-stop-words.member(w)) end)
end

fun string-to-bag-helper(str :: String, ignore-stop-words :: Boolean) -> Table block:
  var candidate-words = string-to-list-of-natlang-words(str)
  if ignore-stop-words:
    candidate-words := remove-stop-words(candidate-words)
  else: false
  end
  sd = list-of-words-to-sd(candidate-words)
  var tbl = table: word :: String, frequency :: Number end
  words = sd.keys().to-list()
  for each(word from words):
    new-row = tbl.row(word, sd.get-value(word))
    tbl := tbl.add-row(new-row)
  end
  tbl
end

fun string-to-bag(str :: String) -> Table:
  string-to-bag-helper(str, false)
end

fun string-to-bag-cleaned(str :: String) -> Table:
  string-to-bag-helper(str, true)
end

fun dot-product(sd1 :: SD.StringDict<Number>, sd2 :: SD.StringDict<Number>) -> Number block:
  var n = 0
  sd1-key-list = sd1.keys-list()
  for each(key from sd1-key-list) block:
    if sd2.has-key(key):
      n := n + (sd1.get-value(key) * sd2.get-value(key))
    else: false
    end
  end
  n
end

fun get-spreadsheet-string(ss :: Any) -> String:
  ws = GDS.open-sheet-by-index(ss, 0, false)
  tbl = load-table: text :: String
    source: ws
    sanitize text using DS.string-sanitizer
  end
  entire-col = extract text from tbl end
  entire-col.get(0)
end

fun get-spreadsheet-words(ss :: Any) -> List<String>:
  cell-string = get-spreadsheet-string(ss)
  string-to-list-of-natlang-words(cell-string)
end

#  *-similarity-lists functions: These compare lists of strings

fun simple-equality-lists(words1 :: List<String>, words2 :: List<String>) -> Boolean:
  words1 == words2
end

fun bag-equality-lists(words1 :: List<String>, words2 :: List<String>) -> Boolean:
  sd1 = list-of-words-to-sd(words1)
  sd2 = list-of-words-to-sd(words2)
  sd1 == sd2
end

fun cosine-similarity-lists(words1 :: List<String>, words2 :: List<String>) -> Number:
  sd1 = list-of-words-to-sd(words1)
  sd2 = list-of-words-to-sd(words2)
  # we are NOT using
  # cosine similarity as defined in standard Pyret assignment docdiff, which is
  # dot-product(sd1, sd2) / num-max(dot-product(sd1, sd1), dot-product(sd2, sd2))

  # the usual cosine similarity, as described in
  # https://en.wikipedia.org/wiki/Cosine_similarity
  if sd1 == sd2: 1
  else if (sd1.count() == 0) or (sd2.count() == 0): 0
  else:
    dot-product(sd1, sd2) / (sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2)))
  end
end

fun angle-difference-lists(words1 :: List<String>, words2 :: List<String>) -> Number:
  cos-sim = cosine-similarity-lists(words1, words2)
  (num-acos(cos-sim) * 180) / 3.14159265
end

# *-similarity functions: These compare string inputs directly

fun simple-equality(string1 :: String, string2 :: String) -> Boolean:
  # either use straight string comparison, or
  # massage the argument strings (converting to lower case, removing punctuation) before comparing
  #
  # string1 == string2
  words1 = string-to-list-of-natlang-words(string1)
  words2 = string-to-list-of-natlang-words(string2)
  simple-equality-lists(words1, words2)
end

fun bag-equality(string1 :: String, string2 :: String) -> Boolean:
  words1 = string-to-list-of-natlang-words(string1)
  words2 = string-to-list-of-natlang-words(string2)
  bag-equality-lists(words1, words2)
end

fun cosine-similarity(string1 :: String, string2 :: String) -> Number:
  words1 = string-to-list-of-natlang-words(string1)
  words2 = string-to-list-of-natlang-words(string2)
  cosine-similarity-lists(words1, words2)
end

fun angle-difference(string1 :: String, string2 :: String) -> Number:
  cos-sim = cosine-similarity(string1, string2)
  (num-acos(cos-sim) * 180) / 3.14159265
end

fun simple-equality-cleaned(string1 :: String, string2 :: String) -> Boolean:
  words1 = remove-stop-words(string-to-list-of-natlang-words(string1))
  words2 = remove-stop-words(string-to-list-of-natlang-words(string2))
  simple-equality-lists(words1, words2)
end

fun bag-equality-cleaned(string1 :: String, string2 :: String) -> Boolean:
  words1 = remove-stop-words(string-to-list-of-natlang-words(string1))
  words2 = remove-stop-words(string-to-list-of-natlang-words(string2))
  bag-equality-lists(words1, words2)
end

fun cosine-similarity-cleaned(string1 :: String, string2 :: String) -> Number:
  words1 = remove-stop-words(string-to-list-of-natlang-words(string1))
  words2 = remove-stop-words(string-to-list-of-natlang-words(string2))
  cosine-similarity-lists(words1, words2)
end

fun angle-difference-cleaned(string1 :: String, string2 :: String) -> Number:
  words1 = remove-stop-words(string-to-list-of-natlang-words(string1))
  words2 = remove-stop-words(string-to-list-of-natlang-words(string2))
  angle-difference-lists(words1, words2)
end

# *-similarity-files: These compares files (Google Ids) containing the respective contents.
# format: headerless spreadsheet with just one cell containing a string

fun simple-equality-files(file1 :: String, file2 :: String) -> Boolean:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  string1 = get-spreadsheet-string(ss1)
  string2 = get-spreadsheet-string(ss2)
  simple-equality(string1, string2)
end

fun bag-equality-files(file1 :: String, file2 :: String) -> Boolean:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  words1 = get-spreadsheet-words(ss1)
  words2 = get-spreadsheet-words(ss2)
  bag-equality-lists(words1, words2)
end

fun cosine-similarity-files(file1 :: String, file2 :: String) -> Number:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  words1 = get-spreadsheet-words(ss1)
  words2 = get-spreadsheet-words(ss2)
  cosine-similarity-lists(words1, words2)
end

fun angle-difference-files(file1 :: String, file2 :: String) -> Number:
  cos-sim = cosine-similarity-files(file1, file2)
  (num-acos(cos-sim) * 180) / 3.14159265
end
