# load cosine-similarity.arr and animals.arr before this file

check "dot-product":
  x-sd = list-of-words-to-sd(string-to-list-of-natlang-words("apple banana citrus"))
  y-sd = list-of-words-to-sd(string-to-list-of-natlang-words("apple banana banana citrus citrus citrus"))
  dot-product(x-sd, x-sd) is 3
  dot-product(y-sd, y-sd) is 14
  dot-product(x-sd, y-sd) is 6
  dot-product(y-sd, x-sd) is 6
end

check "simple equality":

  # comparing file to itself shd always yield true
  simple-equality-files(sheet_id1, sheet_id1) is true
  simple-equality-files(sheet_id2, sheet_id2) is true

  # comparing file to a different file shd always yield false
  simple-equality-files(sheet_id1, sheet_id2) is false
  simple-equality-files(sheet_id2, sheet_id1) is false
  
  # comparing a text to itself yields true
  simple-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is true

  # comparing a text to a permuted version of itself yields false
  simple-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is false

  # comparing obviously dissimilar texts yields false
  simple-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is false
  simple-equality-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is false

  # comparing exactly similar texts yields true
  simple-equality-lists([list: "a", "b", "c", "d"], [list: "a", "b", "c", "d"]) is true

  # same as above, but using single strings instead of lists of words
  simple-equality("apple apple orange", "apple apple orange") is true
  simple-equality("apple apple orange", "apple orange apple") is false
  simple-equality("apple apple orange", "apple orange orange orange")is false
  simple-equality("a a a b b d d d d d", "a") is false
  simple-equality("a b c d", "a b c d") is true
end

check "bag equality":

  # comparing file to itself shd always yield true
  bag-equality-files(sheet_id1, sheet_id1) is true
  bag-equality-files(sheet_id2, sheet_id2) is true

  # comparing file to a different file shd always yield false
  bag-equality-files(sheet_id1, sheet_id2) is false
  bag-equality-files(sheet_id2, sheet_id1) is false

  # comparing a text to itself yields true
  bag-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is true
  
  # comparing a text to a permuted version of itself yields true
  bag-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is true

  # comparing obviously dissimilar texts yields false
  bag-equality-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is false
  bag-equality-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is false

  # comparing exactly similar texts yields true
  bag-equality-lists([list: "a", "b", "c", "d"], [list: "a", "b", "c", "d"]) is true

  # same as above, but using single strings instead of lists of words
  bag-equality("apple apple orange", "apple apple orange") is true
  bag-equality("apple apple orange", "apple orange apple") is true
  bag-equality("apple apple orange", "apple orange orange orange")is false
  bag-equality("a a a b b d d d d d", "a") is false
  bag-equality("a b c d", "a b c d") is true
end

check "cosine equality":

  # comparing file to itself shd always yield 1
  cosine-similarity-files(sheet_id1, sheet_id1) is-roughly 1
  cosine-similarity-files(sheet_id2, sheet_id2) is-roughly 1

  # comparing file to a different file shd always yield < 1
  cosine-similarity-files(sheet_id1, sheet_id2) satisfies lam(x): x < 1 end
  cosine-similarity-files(sheet_id2, sheet_id1) satisfies lam(x): x < 1 end

  # comparing a text to itself yields 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is-roughly 1

  # comparing a text to a permuted version of itself also yields 1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is-roughly 1

  # comparing obviously dissimilar texts yields <1
  cosine-similarity-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is-roughly (1 / sqrt(2))

  cosine-similarity-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is%(within-rel(0.01)) ~0.49

  # comparing exactly similar texts yields 1
  cosine-similarity-lists([list: "doo", "doo", "be", "doo", "be"], [list: "doo", "be", "doo", "be", "doo"]) is-roughly 1

  # same as above, but with single strings rather than lists of words
  cosine-similarity("apple apple orange", "apple apple orange") is-roughly 1
  cosine-similarity("apple apple orange", "apple orange apple") is-roughly 1
  cosine-similarity("apple apple orange", "apple orange orange orange") is-roughly (1 / sqrt(2))
  cosine-similarity("a a a b b d d d d d", "a") is%(within-rel(0.01)) ~0.49
  cosine-similarity("doo doo be doo be", "doo be doo be doo") is-roughly 1
end

check "angle difference":

  # comparing file to itself shd always yield 0
  angle-difference-files(sheet_id1, sheet_id1) is-roughly 0
  angle-difference-files(sheet_id2, sheet_id2) is-roughly 0

  # comparing file to a different file shd always yield >0
  angle-difference-files(sheet_id1, sheet_id2) satisfies lam(x): x > 0 end
  angle-difference-files(sheet_id2, sheet_id1) satisfies lam(x): x > 0 end

  # comparing a text to itself yields 0
  angle-difference-lists([list: "apple", "apple", "orange"], [list: "apple", "apple", "orange"]) is-roughly 0

  # comparing a text to a permuted version of itself also yields 0
  angle-difference-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "apple"]) is-roughly 0

  # comparing obviously dissimilar texts yields >0
  angle-difference-lists([list: "apple", "apple", "orange"], [list: "apple", "orange", "orange", "orange"]) is-roughly ~45
  angle-difference-lists([list: "a", "a", "a", "b", "b", "d", "d", "d", "d", "d"], [list: "a"]) is%(within-rel(0.01)) ~60.878

  # comparing exactly similar texts yields 0
  angle-difference-lists([list: "doo", "doo", "be", "doo", "be"], [list: "doo", "be", "doo", "be", "doo"]) is%(within-rel(0.01)) 0
  
  # same as above, but using single strings instead of lists of words
  angle-difference("apple apple orange", "apple apple orange") is-roughly 0
  angle-difference("apple apple orange", "apple orange apple") is-roughly 0
  angle-difference("apple apple orange", "apple orange orange orange") is-roughly ~45
  angle-difference("a a a b b d d d d d", "a") is%(within-rel(0.01)) ~60.878
  angle-difference("doo doo be doo be", "doo be doo be doo") is-roughly 0
end


check "string-to-bag":
  # the returned bag has columns "word" and "frequency"
  S.list-to-list-set(string-to-bag("doo be doo be doo").get-column("word")) is [S.list-set: "be", "doo"]
  S.list-to-list-set(string-to-bag("doo be doo be doo").get-column("frequency")) is [S.list-set: 2, 3]

end

fun distance-table-get-article-similarity(tbl :: Table, art :: String) block:
  # this is used only for testing.
  # takes the table resulting from a distance-to call, and an article name `art`,
  # and returns the similarity associated with `art`
  table-rows = tbl.all-rows()
  var answer-found = false
  var simty = 0
  for each(table-row from table-rows) block:
    if not(answer-found):
      if table-row.get-value('article') == art block:
        simty := table-row.get-value('similarity')
        answer-found := true
      else: false
      end
    else: false
    end
  end
  simty
end

check "distance-to":
  tbl1 = distance-to(elephant-article) # stopwords present
  tbl2 = distance-to-stop(elephant-article) # stopwords ignored
  #
  # following checks that the distance between an article and itself is 0
  # whether or not stopwords are removed
  distance-table-get-article-similarity(tbl1, 'elephant') is 0
  distance-table-get-article-similarity(tbl2, 'elephant') is 0
end


