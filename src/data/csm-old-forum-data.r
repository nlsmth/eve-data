install.packages("rvest")
library(rvest)

general_forum_url <- "https://oldforums.eveonline.com"
assembly_hall_url <- "https://oldforums.eveonline.com/?a=channel&channelID=752166"
speakers_corner_url <- "https://oldforums.eveonline.com/?a=channel&channelID=759778"
subforums <- c(assembly_hall_url, speakers_corner_url)

all_subforums <- vector(mode = "character")
all_thread_ids <- vector(mode = "character")
titles <- vector(mode = "character")
usernames <- vector(mode = "character")
dates <- vector(mode = "character")
posts <- vector(mode = "character")

scrape <- function(html, thread_id) {
  # Usernames
  username <- html_nodes(html, css = "b span") %>% 
    html_text(trim = TRUE) 
  
  # Dates
  date <- html_nodes(html, css = "#content div:nth-child(1)") %>%
    html_text() %>%
    substr(10, 28)
  
  # Content
  post <- html_nodes(html, css = "#forumSignature") %>%
    html_text(trim = TRUE) %>%
    tolower()
  # Thread Title
  title <- html_nodes(html, css = ".mbSurf a") %>%
    html_text(trim = TRUE)
  title <- title[3] %>% tolower()
  
  if (subforum == subforums[1])
    this_subforum <- "assembly hall"
  else 
    this_subforum <- "speakers corner"
  all_subforums <<- this_subforum %>% rep(length(post)) %>% c(all_subforums)
  
  thread_id <- thread_id %>%
    substr(19, nchar(thread_id)) %>%
    strsplit("&") %>% unlist()
  thread_id <- thread_id[1]
  
  all_thread_ids <<- thread_id %>%
    rep(length(post)) %>% 
    c(all_thread_ids)
  
  titles <<- title %>% rep(length(post)) %>% c(titles)
  usernames <<- c(usernames, username)
  dates <<- c(dates, date)
  posts <<- c(posts, post)
}

for (subforum in subforums) {
  print(paste("Navigating to ", subforum, "...", sep = ""))
  s <- html_session(subforum)
  html <- read_html(s$url)
  
  # Number of pages for subforum
  nforum_pages <- html_nodes(html, css = ".mbSurf:nth-child(1) a:nth-child(10)") %>%
    html_attr("href") %>%
    strsplit("=") %>%
    unlist()
  nforum_pages <- nforum_pages[4] %>%
    as.numeric()
  
  for (i in 1:nforum_pages) {
    print(paste("Navigating to subform page ", i, "...", sep = ""))
    
    s <- paste(subforum, "&page=", i, sep = "") %>%
      html_session()
    html <- read_html(s$url)
    
    # Thread ids for subforum page
    thread_ids <- html_nodes(html, css = ".mbForum:nth-child(2) a") %>% 
      xml_attrs("mbForum") %>%
      pluck("href") %>%
      unique() %>% unlist()
    
    # For each thread on subform page
    for (j in 1:length(thread_ids)) {
      print(paste("Navigating to thread page ", j, "...", sep = ""))
      
      # Jump to first page of thread
      s <- paste(general_forum_url, thread_ids[j], sep = "/") %>%
        html_session()
      html <- read_html(s$url)
      # Scrape thread page
      if (is.null(grep("page", thread_ids[j]))) {
        idx <- gregexpr("&", thread_ids[j]) %>% unlist()
        this_thread_id <- thread_ids[j] %>% substr(0, idx[-1] - 1)
      } else
        this_thread_id <- thread_ids[j]
      scrape(html, thread_ids[j])
    }
  }
}

dates <- dates[!grepl("[a-z]", dates)]
dates <- dates[nchar(dates) == 19]

csm_forums.df <- data.frame(all_subforums, all_thread_ids, titles, dates, usernames, posts)
write.csv(csm_forums.df, file = "data/csm-forums/old-csm-forums.csv")