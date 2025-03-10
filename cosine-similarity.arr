import string-dict as SD

import gdrive-sheets as GDS

import data-source as DS

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

fun cosine-similarity-lists(words1 :: List<String>, words2 :: List<String>) -> Number:
  sd1 = list-of-words-to-sd(words1)
  sd2 = list-of-words-to-sd(words2)
  # cosine similarity as defined in standard Pyret assignment docdiff
  # dot-product(sd1, sd2) / num-max(dot-product(sd1, sd1), dot-product(sd2, sd2))

  # the usual (wikipedia) cosine similarity
  dot-product(sd1, sd2) / (sqrt(dot-product(sd1, sd1)) * sqrt(dot-product(sd2, sd2)))
end

#  1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ

# headerless spreadsheet with just one cell containing a string

fun get-spreadsheet-cell(ss :: Any) -> List<String>:
  ws = GDS.open-sheet-by-index(ss, 0, false)
  tbl = load-table: text :: String
    source: ws
    sanitize text using DS.string-sanitizer
  end
  entire-col = extract text from tbl end
  string-split-all(string-to-lower(entire-col.get(0)), ' ')
end

fun get-spreadsheet-file-cell(file :: String) -> List<String>:
  ss = GDS.load-spreadsheet(file)
  get-spreadsheet-cell(ss)
end


fun cosine-similarity-files(file1 :: String, file2 :: String) -> Number:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  words1 = get-spreadsheet-cell(ss1)
  words2 = get-spreadsheet-cell(ss2)
  cosine-similarity-lists(words1, words2)
end

fun simple-similarity-files(file1 :: String, file2 :: String) -> Number:
  ss1 = GDS.load-spreadsheet(file1)
  ss2 = GDS.load-spreadsheet(file2)
  words1 = get-spreadsheet-cell(ss1)
  words2 = get-spreadsheet-cell(ss2)
  if words1 == words2: 1
  else: 0
  end
end

var sheet_id = "1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ"

check:
  # comparing file to itself shd always yield 1
  cosine-similarity-files(sheet_id, sheet_id) is-roughly 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is-roughly 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is-roughly (1 / sqrt(2))
  cosine-similarity-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is%(within-rel(0.01)) ~0.49
end
