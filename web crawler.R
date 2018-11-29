library(rvest)
library(magrittr)
library(RSelenium)

library(dplyr)

library(XML)
library(RCurl)
library(httr)
library(jsonlite)
library(stringi)

#®rvest cwb
cwb<-read_html("https://www.cwb.gov.tw/V7/observe/rainfall/ha_100.htm")
cwbdt<-cwb %>% html_nodes("table.BoxTable td") %>% html_text()
cwbtitle<-cwb %>% html_nodes("table.BoxTable th") %>% html_text()
cwbdt<-cwbdt[-1]
cwbtitle<-cwbtitle[-1]
cwbdt<-matrix(data = cwbdt,ncol = 5,byrow = T)
colnames(cwbdt)<-cwbtitle


#RSelenium LMS
remdr<-rsDriver()
rd<-remdr$client
rd$navigate("https://2018.lms.garena.tw/stats")
elem<-rd$findElement(using = "xpath",value = "//*[@id='stats_table']")
lms<-elem$getElementAttribute("outerHTML")[[1]]
lmsdt<-read_html(lms)
lmstb<-lmsdt %>% html_nodes("table") %>% html_table()
lmsmatrix<-as.matrix(lmstb[[1]])
remdr$server$stop()


#RSelenium CPBL
remdr<-rsDriver()
rd<-remdr$client
rd$navigate("http://www.cpbl.com.tw/stats/all.html?year=0000&stat=pbat&online=0&sort=G&order=desc&per_page=1")
elem<-rd$findElement(using = "xpath",value = "/html/body/div[4]/div/div/div[4]/table")
cpbl<-elem$getElementAttribute("outerHTML")[[1]]
cpbldt<-read_html(cpbl)
cpbltb<-cpbldt %>% html_nodes("table") %>% html_table(header = T)
cpblmatrix<-as.matrix(cpbltb[[1]])
remdr$server$stop()


#rvest CPBL
cpbl<-read_html("http://www.cpbl.com.tw/stats/all.html?year=0000&stat=pbat&online=0&sort=G&order=desc&per_page=10")
cpbldt<-cpbl %>% html_nodes("table td") %>% html_text()
cpbltitle<-cpbl %>% html_nodes("table th") %>% html_text()
cpbltb<-as.data.frame(matrix(data = cpbldt,ncol = 31,byrow = T))
colnames(cpbltb)<-cpbltitle

x<-data.frame(stringsAsFactors = F)
for (i in 1:10) {
  Sys.sleep(10)
  cpbl<-read_html(paste("http://www.cpbl.com.tw/stats/all.html?year=0000&stat=pbat&online=0&sort=G&order=desc&per_page=",i,sep = ""))
  cpbldt<-cpbl %>% html_nodes("table td") %>% html_text()
  cpbltitle<-cpbl %>% html_nodes("table th") %>% html_text()
  cpbltb<-as.data.frame(matrix(data = cpbldt,ncol = 31,byrow = T))
  colnames(cpbltb)<-cpbltitle
  for (j in 1:31) {
      cpbltb[,j]<-as.character(cpbltb[,j])
  }
  x<-bind_rows(x,cpbltb)
  print(i)
  closeAllConnections()
  gc()
}
