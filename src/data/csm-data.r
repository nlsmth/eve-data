library(tm)

input.dir <- "data/csm/raw"

Rpdf <- readPDF(control = list(text = "-layout"))

# Create Corpus
minutes.c <- Corpus(DirSource(input.dir, pattern = "^.*.pdf$"),
                  readerControl = list(reader = Rpdf))
# Preprocessing
minutes.c <- tm_map(minutes.c, content_transformer(tolower))
minutes.c <- tm_map(minutes.c, removePunctuation)
minutes.c <- tm_map(minutes.c, removeNumbers)
minutes.c <- tm_map(minutes.c, removeWords, stopwords(kind = "SMART"))
usernames <- as.character(read.csv("data/csm/interim/usernames.csv", header = FALSE, as.is = TRUE))
minutes.c <- tm_map(minutes.c, removeWords, usernames)
minutes.c <- tm_map(minutes.c, stripWhitespace)

# Create Document Term Matrix
minutes.dtm <- DocumentTermMatrix(minutes.c)

# Save Document Term Matrix
save(minutes.dtm, file = "data/csm/interim/dtm.rdata")
