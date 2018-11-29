#cd c:/users/pass2/downloads
#java -Dwebdriver.chrome.driver=chromedriver.exe -jar selenium-server-standalone-3.9.1.jar

library(rvest)
library(magrittr)
library(dplyr)
library(XML)
library(RCurl)
library(httr)
library(jsonlite)
library(RSelenium)

#氣象局雨量前百
cwb<-read_html("https://www.cwb.gov.tw/V7/observe/rainfall/ha_100.htm")
cwbdt<-cwb %>% html_nodes("table.BoxTable td") %>% html_text()
cwbtitle<-cwb %>% html_nodes("table.BoxTable th") %>% html_text()
cwbdt<-cwbdt[-1]
cwbtitle<-cwbtitle[-1]
cwbdt<-matrix(data = cwbdt,ncol = 5,byrow = T)
colnames(cwbdt)<-cwbtitle

#RSelenium LMS
remDr = remoteDriver(remoteServerAddr="localhost",port = 4444,browserName = "chrome")
remDr$open(silent=T)
remDr$navigate("https://2018.lms.garena.tw/stats")
elem<-remDr$findElement(using = "xpath",value = "//*[@id='stats_table']")
lms<-elem$getElementAttribute("outerHTML")[[1]]
lmsdt<-read_html(lms)
lmstb<-lmsdt %>% html_nodes("table") %>% html_table()
lmsmatrix<-as.matrix(lmstb[[1]])
remDr$closeWindow()

