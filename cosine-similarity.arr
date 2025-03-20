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

fun string-to-bag(str :: String) -> Table block:
  sd = list-of-words-to-sd(string-to-list-of-natlang-words(str))
  var tbl = table: word :: String, frequency :: Number end
  words = sd.keys().to-list()
  for each(word from words):
    new-row = tbl.row(word, sd.get-value(word))
    tbl := tbl.add-row(new-row)
  end
  tbl
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
  else:
    dot-product(sd1, sd2) / (sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2)))
  end
end

fun angle-difference-lists(words1 :: List<String>, words2 :: List<String>) -> Number:
  cos-sim = cosine-similarity-lists(words1, words2)
  (num-acos(cos-sim) * 180) / PI
end

# *-similarity functions: These compare string inputs directly

fun simple-equality(string1 :: String, string2 :: String) -> Boolean:
  # either use straight string comparison, or
  # massage the argument strings (converting to lower case, removing punctuation) before comparing
  #
  # string1 == string2
  simple-equality-lists(string-to-list-of-natlang-words(string1), string-to-list-of-natlang-words(string2))
end

fun bag-equality(string1 :: String, string2 :: String) -> Boolean:
  bag-equality-lists(string-to-list-of-natlang-words(string1), string-to-list-of-natlang-words(string2))
end

fun cosine-similarity(string1 :: String, string2 :: String) -> Number:
  cosine-similarity-lists(string-to-list-of-natlang-words(string1), string-to-list-of-natlang-words(string2))
end

fun angle-difference(string1 :: String, string2 :: String) -> Number:
  cos-sim = cosine-similarity(string1, string2)
  (num-acos(cos-sim) * 180) / PI
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
  (num-acos(cos-sim) * 180) / PI
end

var sheet_id1 = "1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ"

var sheet_id2 = "10ngDjr6ahZICKrSVb6zFnOKRDmqMNeqqJCVEDvxONWs"

