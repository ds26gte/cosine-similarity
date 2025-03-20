# from https://en.wikipedia.org/wiki/Elephants_in_Thailand
elephant-article = "The elephant has been a contributor to Thai society and its icon for many centuries. The elephant has had a considerable impact on Thai culture. The Thai elephant is the official national animal of Thailand. The elephant found in Thailand is the Indian elephant, a subspecies of the Asian elephant."

# from https://en.wikipedia.org/wiki/Polar_bear
polarbear-article = "The polar bear is a large bear native to the Arctic and nearby areas. It is closely related to the brown bear, and the two species can interbreed. The polar bear is the largest extant species of bear and land carnivore, with adult males weighing 300–800 kg. The polar bear is white- or yellowish-furred with black skin and a thick layer of fat."

# from https://en.wikipedia.org/wiki/Rhinoceros
rhino-article = "Rhinoceroses are some of the largest remaining megafauna: all weigh over half a tonne in adulthood. They have a herbivorous diet, small brains 400–600 g for mammals of their size, one or two horns, and a thick 1.5–5 cm, protective skin formed from layers of collagen positioned in a lattice structure. They generally eat leafy material."

# from https://en.wikipedia.org/wiki/Blue_whale
bluewhale-article = "The blue whale is a marine mammal and a baleen whale. Reaching a maximum confirmed length of 29.9 m and weighing up to 199 tons, it is the largest animal known ever to have existed. The blue whale's long and slender body can be of various shades of greyish-blue on its upper surface and somewhat lighter underneath."

# from https://en.wikipedia.org/wiki/Snow_leopard
snowleopard-article = "The snow leopard is a species of large cat in the genus Panthera of the family Felidae. The species is native to the mountain ranges of Central and South Asia. It is listed as Vulnerable on the IUCN Red List because the global population is estimated to number fewer than 10,000 mature individuals and is expected to decline about 10% by 2040."

# from https://en.wikipedia.org/wiki/Manatee
manatee-article = "Manatees are herbivores and eat over 60 different freshwater and saltwater plants. Manatees inhabit the shallow, marshy coastal areas and rivers of the Caribbean Sea, the Gulf of Mexico, the Amazon basin, and West Africa. The main causes of death for manatees are human-related issues, such as habitat destruction and human objects."

# from https://en.wikipedia.org/wiki/Chimpanzee
chimpanzee-article = "The chimpanzee lives in groups that range in size from 15 to 150 members, although individuals travel and forage in much smaller groups during the day. The species lives in a strict male-dominated hierarchy, where disputes are generally settled without the need for violence. Nearly all chimpanzee populations have been recorded using tools, modifying sticks, rocks, grass and leaves and using them for hunting and acquiring honey, termites, ants, nuts and water."

# from https://en.wikipedia.org/wiki/American_badger
badger-article = "The American badger is a North American badger similar in appearance to the European badger, although not closely related. It is found in the western, central, and northeastern United States, northern Mexico, and south-central Canada to certain areas of southwestern British Columbia. The American badger's habitat is typified by open grasslands with available prey (such as mice, squirrels, and groundhogs)."

# from https://en.wikipedia.org/wiki/Snail
snail-article = "Snails can be found in a very wide range of environments, including ditches, deserts, and the abyssal depths of the sea. Although land snails may be more familiar to laymen, marine snails constitute the majority of snail species, and have much greater diversity and a greater biomass. Numerous kinds of snail can also be found in fresh water."

# from https://en.wikipedia.org/wiki/Hamster
hamster-article = "Hamsters feed primarily on seeds, fruits, vegetation, and occasionally burrowing insects. In the wild, they are crepuscular: they forage during the twilight hours. In captivity, however, they are known to live a conventionally nocturnal lifestyle, waking around sundown to feed and exercise. Physically, they are stout-bodied with distinguishing features that include elongated cheek pouches extending to their shoulders, which they use to carry food back to their burrows, as well as a short tail and fur-covered feet."

# from https://en.wikipedia.org/wiki/Giraffe
giraffe-article = "The giraffe's distinguishing characteristics are its extremely long neck and legs, horn-like ossicones, and spotted coat patterns. It is classified under the family Giraffidae, along with its closest extant relative, the okapi. Its scattered range extends from Chad in the north to South Africa in the south and from Niger in the west to Somalia in the east."

# from https://en.wikipedia.org/wiki/Hippopotamus
hippo-article = "Hippos inhabit rivers, lakes, and mangrove swamps. Territorial bulls each preside over a stretch of water and a group of five to thirty cows and calves. Mating and birth both occur in the water. During the day, hippos remain cool by staying in water or mud, emerging at dusk to graze on grasses. While hippos rest near each other in the water, grazing is a solitary activity and hippos typically do not display territorial behaviour on land. Hippos are among the most dangerous animals in the world due to their aggressive and unpredictable nature. "

standard-named-articles = [list:
  [list: "elephant", elephant-article],
  [list: "polarbear", polarbear-article],
  [list: "rhino", rhino-article],
  [list: "bluewhale", bluewhale-article],
  [list: "snowleopard", snowleopard-article],
  [list: "manatee", manatee-article],
  [list: "chimpanzee", chimpanzee-article],
  [list: "badger", badger-article],
  [list: "snail", snail-article],
  [list: "hamster", hamster-article],
  [list: "giraffe", giraffe-article],
  [list: "hippo", hippo-article],
]

student-article = elephant-article

standard-stop-words = [list: "a", "an", "the"]

fun distance-table-get-article-similarity(tbl :: Table, art :: String) block:
  table-rows = tbl.all-rows()
  var answer-found = false
  var simty = 0
  var keep-else-happy = false
  for each(table-row from table-rows) block:
    if not(answer-found):
      if table-row.get-value('article') == art block:
        simty := table-row.get-value('similarity')
        answer-found := true
      else:
        keep-else-happy := false
      end
    else:
      keep-else-happy := false
    end
  end
  simty
end

fun distance-to(candidate-article :: String, ignore-stop-words :: Boolean) -> Table block:
  orig-candidate-words = string-to-list-of-natlang-words(candidate-article)
  var candidate-words = empty
  if ignore-stop-words:
    candidate-words := orig-candidate-words.filter(lam(w): not(standard-stop-words.member(w)) end)
  else:
    candidate-words := orig-candidate-words
  end
  var tbl = table: article :: String, similarity :: Number end
  for each(named-article from standard-named-articles) block:
    article-name = named-article.get(0)
    orig-article-words = string-to-list-of-natlang-words(named-article.get(1))
    var article-words = empty
    if ignore-stop-words:
      article-words := orig-article-words.filter(lam(w): not(standard-stop-words.member(w)) end)
    else:
      article-words := orig-article-words
    end
    new-row = tbl.row(article-name, angle-difference-lists(candidate-words, article-words))
    tbl := tbl.add-row(new-row)
  end
  tbl
end

check:
  tbl1 = distance-to(elephant-article, true)
  tbl2 = distance-to(elephant-article, false)
  distance-table-get-article-similarity(tbl1, 'elephant') is 0
  distance-table-get-article-similarity(tbl2, 'elephant') is 0
end


# try
#
# distance-to(student-article, false)
# -- this doesn't ignore stop words

# distance-to(student-article, true)
# -- this does ignore stop words

