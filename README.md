# EVE Online Research

## Goal

To describe the factors as a model which account for the success of EVE Online as a sociotechnical platform.

## Motivation 
* MMORPGs are valuable commercial product in themselves and therefore are financially important.
* EVE Online is not just a "game". It is a virtual world and community which causes the interaction of thousands of players inside and outside of the physical game. The success of EVE can provide insight into the functioning of similar sociotechnical systems.

## Methods
The sucess of the platform is represented by change in subscription numbers, found [here](http://eve-offline.net/?server=tranquility). These numbers can be used help analyze increasingly broad data sources to achieve a better understanding of the factors which effect them. 

The data will need to be scraped from the sources below, loaded into a database, and analyzed. Analysis, at first, will conducted manually but the goal is to do it computationally using techniques such as sentiment analysis, latent semantic analysis, and Latent Dirichlet allocation.

## Data Sources
* Council of Stellar Management (CSM) is a democratically elected group of players elected to be a route for the community to make requests for changes and improvements to the game mechanics, presentation, and content. Since 2008, they have meet with the developers at CCP Games roughly 4 times a year to discuss past and potential changes in the game. The minutes from these meetings can be found as 30 pdf documents [here](https://community.eveonline.com/community/csm/meeting-minutes/).
* [CSM EVE Online Official Forums](https://forums.eveonline.com/default.aspx?g=forum&c=65) These forums are open to all registered EVE players to bring ideas and problems to the attention of the CSM, discuss and debate past and potential changes, and campaign to be a member of the CSM. Contains about 3,500 forum topics.

## Packages Used
* [LDAvis]()
* [rvest](https://github.com/hadley/rvest)
* [stringr]()
* [tm](https://cran.r-project.org/web/packages/tm/index.html)
* [topicmodels]()

## Timeline
* Summer 2016: Complete data set from 2 sources listed above and create basic tools to analyze it.

## Files

