library(tm)
library(topicmodels)
library(LDAvis)

# Load Document Term Matrix
load("data/csm/interim/dtm.rdata")

# Sum of words in each document
rowTotals <- apply(minutes.dtm, 1, sum)

# Remove documents without words
minutes.dtm <- minutes.dtm[rowTotals > 0,]

if(interactive()) {
  k <- as.integer(readline(prompt = "Please enter the desired integer number of topics: "))
} else
  k <- 6

# Perform LDA and create LDA object 
lda <- LDA(minutes.dtm, k, method = "Gibbs")
save(lda, file = "data/csm/processed/lda.rdata")

# topicmodels logarithmizes the word distribution
phi <- exp(lda@beta)

doc.length <- unname(apply(minutes.dtm, 1, sum))

term.frequency <- as.data.frame(inspect(minutes.dtm))
term.frequency <- unname(colSums(term.frequency))

# Create JSON object that feeds the visualization template
vis <- createJSON(phi = phi,
                  theta = lda@gamma,
                  doc.length = doc.length,
                  vocab = lda@terms,
                  term.frequency = term.frequency)

# View visualization in browser
serVis(vis, out.dir = "out/csm-LDAvis")

