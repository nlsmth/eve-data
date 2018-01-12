library(rvest)

general_forum_url <- "https://forums.eveonline.com"
assembly_hall_url <- "https://forums.eveonline.com/default.aspx?g=topics&f=267"
speakers_corner_url <- "https://forums.eveonline.com/default.aspx?g=topics&f=268"
campaigns_url <- "https://forums.eveonline.com/default.aspx?g=topics&f=5971"
subforums <- c(assembly_hall_url, speakers_corner_url, campaigns_url)

all_subforums <- vector(mode = "character")
all_thread_ids <- vector(mode = "character")
titles <- vector(mode = "character")
usernames <- vector(mode = "character")
dates <- vector(mode = "character")
posts <- vector(mode = "character")

scrape <- function(html, thread_id) {
  # Usernames
  username <- html_nodes(html, css = ".section") %>% 
    html_text(trim = TRUE) 
  username <- username[c(TRUE, FALSE, FALSE, FALSE)] %>%
    tolower()
  
  # Dates
  date <- html_nodes(html, css = ".posted") %>%
    html_text() %>%
    substr(21, 43)
  
  # Content
  post <- html_nodes(html, xpath="//div[contains(@id,'DisplayPost1_MessagePost1') or
                    contains(@id, 'DisplayPostAlt_MessagePost1')]") %>%
    html_text(trim = TRUE) %>%
    tolower()
  # Thread Title
  title <- html_nodes(html, css = ".title") %>%
    html_text(trim = TRUE) %>%
    tolower()
  
  if (subforum == subforums[1])
    this_subforum <- "assembly hall"
  else if (subforum == subforums[2])
    this_subforum <- "speakers corner"
  else
    this_subforum <- "campaigns"
  all_subforums <<- this_subforum %>%rep(length(post)) %>% c(all_subforums)
  
  thread_id <- thread_id %>%
    substr(25, nchar(thread_id)) %>%
    strsplit('&') %>%
    unlist()
  
  all_thread_ids <<- thread_id[1] %>%
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
  nforum_pages <- html_nodes(html, css = "#forum_ctl00_Pager_PageLabel") %>%
    html_text() %>%
    substr(1, 2) %>%
    as.numeric()
  
  for (i in 1:nforum_pages) {
    print(paste("Navigating to subform page ", i, "...", sep = ""))
    
    s <- paste(subforum, "&p=", i, sep = "") %>%
      html_session()
    html <- read_html(s$url)
    
    # Thread ids for subforum page
    thread_ids <- html_nodes(html, css = ".nonew") %>%
      xml_attrs("main nonew") %>%
      pluck("href") %>%
      unlist()
    
    thread_ids <- html_nodes(html, css = ".locked") %>%
      xml_attrs("main locked") %>%
      pluck("href") %>%
      unlist() %>%
      c(thread_ids)
    
    # For each thread on subform page
    for (j in 1:length(thread_ids)) {
      print(paste("Navigating to thread ", j, "...", sep = ""))
      
      # Jump to first page of thread
      s <- paste(general_forum_url, thread_ids[j], sep = "") %>%
        html_session()
      html <- read_html(s$url)
      
      # Number of pages for thread
      npages <- html_nodes(html, css = "#forum_ctl00_Pager_PageLabel") %>%
        html_text() %>%
        substr(1, 2) %>%
        as.numeric()
      
      # Scrape first page of thread
      scrape(html, thread_ids[j])
      
      # Navigate multipage threads and scrape each page
      if (length(npages) > 0) {
        for (k in 2:npages) {
          print(paste("Navigating to thread ", j, " page ", k, "...", sep = ""))
          
          s <- paste(general_forum_url, thread_ids[j], "&p=", k, sep = "") %>%
            html_session()
          html <- read_html(s$url)
          scrape(html, thread_ids[j])
        }
      }
    }
  }
}

csm_forums.df <- data.frame(all_subforums, all_thread_ids, titles, dates, usernames, posts)
write.csv(csm_forums.df, file = "data/csm-forums/csm-forums.csv")
