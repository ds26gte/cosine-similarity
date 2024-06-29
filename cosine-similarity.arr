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
  dot-product(sd1, sd2) / num-max(dot-product(sd1, sd1), dot-product(sd2, sd2))
end

#  1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ

# headerless spreadsheet with just one cell containing a string

fun get-spreadsheet-cell(file :: String) -> List<String>:
  ss = GDS.load-spreadsheet(file)
  ws = GDS.open-sheet-by-index(ss, 0, false)
  tbl = load-table: text :: String
    source: ws
    sanitize text using DS.string-sanitizer
  end
  entire-col = extract text from tbl end
  string-split-all(string-to-lower(entire-col.get(0)), ' ')
end

fun cosine-similarity-files(file1 :: String, file2 :: String) -> Number:
  words1 = get-spreadsheet-cell(file1)
  words2 = get-spreadsheet-cell(file2)
  cosine-similarity-lists(words1, words2)
end

fun testt():
  cosine-similarity-files("1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ", "1CnAGrIMW7W1Qrxtm8ZmJXYcQvkoMbSmzL7Ixw6d4FYQ")
end
