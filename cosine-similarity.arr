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

fun massage-string(w :: String) -> String:
  fold(lam(string-a, string-b): string-a + string-b end, '',
    filter(is-non-punct, string-explode(string-to-lower(w))))
end

fun string-to-list-of-natlang-words(s :: String) -> List<String>:
  string-split-all(massage-string(string-to-lower(s)), ' ')
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
    else:
      n := n
    end
  end
  n
end

#  1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ

# headerless spreadsheet with just one cell containing a string

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

fun bow-equality-lists(words1 :: List<String>, words2 :: List<String>) -> Boolean:
  sd1 = list-of-words-to-sd(words1)
  sd2 = list-of-words-to-sd(words2)
  sd1 == sd2
end

fun cosine-similarity-lists(words1 :: List<String>, words2 :: List<String>) -> Number:
  sd1 = list-of-words-to-sd(words1)
  sd2 = list-of-words-to-sd(words2)
  # cosine similarity as defined in standard Pyret assignment docdiff
  # dot-product(sd1, sd2) / num-max(dot-product(sd1, sd1), dot-product(sd2, sd2))

  # the usual (wikipedia) cosine similarity
  if sd1 == sd2: 1
  else:
    dot-product(sd1, sd2) / (sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2)))
  end
end

fun angle-distance-lists(words1 :: List<String>, words2 :: List<String>) -> Number:
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

fun bow-equality(string1 :: String, string2 :: String) -> Boolean:
  bow-equality-lists(string-to-list-of-natlang-words(string1), string-to-list-of-natlang-words(string2))
end

fun cosine-similarity(string1 :: String, string2 :: String) -> Number:
  cosine-similarity-lists(string-to-list-of-natlang-words(string1), string-to-list-of-natlang-words(string2))
end

fun angle-distance(string1 :: String, string2 :: String) -> Number:
  cos-sim = cosine-similarity(string1, string2)
  (num-acos(cos-sim) * 180) / PI
end

# *-similarity-files: These compares files (Google Ids) containing the respective contents

fun simple-equality-files(file1 :: String, file2 :: String) -> Boolean:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  string1 = get-spreadsheet-string(ss1)
  string2 = get-spreadsheet-string(ss2)
  simple-equality(string1, string2)
end

fun bow-equality-files(file1 :: String, file2 :: String) -> Boolean:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  words1 = get-spreadsheet-words(ss1)
  words2 = get-spreadsheet-words(ss2)
  bow-equality-lists(words1, words2)
end

fun cosine-similarity-files(file1 :: String, file2 :: String) -> Number:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  words1 = get-spreadsheet-words(ss1)
  words2 = get-spreadsheet-words(ss2)
  cosine-similarity-lists(words1, words2)
end

fun angle-distance-files(file1 :: String, file2 :: String) -> Number:
  cos-sim = cosine-similarity-files(file1, file2)
  (num-acos(cos-sim) * 180) / PI
end

var sheet_id = "1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ"

check:

  # comparing file to itself shd always yield 1
  simple-equality-files(sheet_id, sheet_id) is true
  simple-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is true
  simple-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is false
  simple-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is false
  simple-equality-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is false

  # comparing file to itself shd always yield 1
  bow-equality-files(sheet_id, sheet_id) is true
  bow-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is true
  bow-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is true
  bow-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is false
  bow-equality-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is false

  # comparing file to itself shd always yield 1
  cosine-similarity-files(sheet_id, sheet_id) is-roughly 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is-roughly 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is-roughly 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is-roughly (1 / sqrt(2))
  cosine-similarity-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is%(within-rel(0.01)) ~0.49
  cosine-similarity("doo doo be doo be", "doo be doo be doo") is-roughly 1

  angle-distance-files(sheet_id, sheet_id) is-roughly 0
  angle-distance-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is-roughly 0
  angle-distance-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is-roughly 0
  angle-distance-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is-roughly ~45
  angle-distance-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is%(within-rel(0.01)) ~60.878
  angle-distance("doo doo be doo be", "doo be doo be doo") is-roughly 0

  S.list-to-list-set(string-to-bag("doo be doo be doo").get-column("word")) is [S.list-set: "be", "doo"]
  S.list-to-list-set(string-to-bag("doo be doo be doo").get-column("frequency")) is [S.list-set: 2, 3]

end
