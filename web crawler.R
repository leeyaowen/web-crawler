library(rvest)
library(magrittr)
library(RSelenium)

library(dplyr)

library(XML)
library(RCurl)
library(httr)
library(jsonlite)
library(stringi)

#rvest cwb
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
}


#RSelenium NA LCS
remdr<-rsDriver()
rd<-remdr$client
rd$navigate("https://www.lolesports.com/en_US/na-lcs/na_2018_summer/stats/playoffs")
elem<-rd$findElement(using = "id",value = "stats-page")
lcs<-elem$getElementAttribute("outerHTML")[[1]]
lcsdt<-read_html(lcs)
lcstitle<-lcsdt %>% html_nodes("table th span.column-name") %>% html_text()
lcstb<-lcsdt %>% html_nodes("table td") %>% html_text(trim = T)
lcsmatrix<-matrix(data = lcstb,ncol = 12,byrow = T)
colnames(lcsmatrix)<-lcstitle
remdr$server$stop()



################################
###RSelenium CWB monthly data###
################################

#獲取單一測站資料
remdr<-rsDriver() #啟動受控制的瀏覽器
rd<-remdr$client
#指向目標網頁
rd$navigate("https://e-service.cwb.gov.tw/HistoryDataQuery/MonthDataController.do?command=viewMain&station=C0R280&stname=%25E6%25AA%25B3%25E6%25A6%2594&datepicker=2010-01")
elem<-rd$findElement(using = "xpath", value = "//*[@id='downloadCSV']") #找到下載CSV按鍵
elem$clickElement() #按下按鍵

#單一測站年月迴圈
year<-as.character(2017:2018) #設定年分
month<-c("01","02","03","04","05","06","07","08","09","10","11","12") #設定月份
for (i in 1:length(year)) {
  for (j in 1:length(month)) {
    rd$navigate(paste("https://e-service.cwb.gov.tw/HistoryDataQuery/MonthDataController.do?command=viewMain&station=C0R280&stname=%25E6%25AA%25B3%25E6%25A6%2594&datepicker=",year[i],"-",month[j],sep = ""))
    Sys.sleep(2)
    elem<-rd$findElement(using = "xpath", value = "//*[@id='downloadCSV']")
    elem$clickElement()
    print(paste(year[i],"-",month[j],sep = ""))
    Sys.sleep(10)
  }
}

#單一縣市所有測站迴圈
remdr<-rsDriver()
rd<-remdr$client
#先指向該縣市其一測站某年某月資料
rd$navigate("https://e-service.cwb.gov.tw/HistoryDataQuery/MonthDataController.do?command=viewMain&station=C0R280&stname=%25E6%25AA%25B3%25E6%25A6%2594&datepicker=2018-12")
elem<-rd$findElement(using = "xpath", value = "//*[@id='selectStno']")
opt<-elem$selectTag() #獲取縣市內的測站清單
year<-as.character(2016:2018)
month<-c("01","02","03","04","05","06","07","08","09","10","11","12")
for (i in 1:length(opt$value)) {
  for (j in 1:length(year)) {
    for (k in 1:length(month)) {
      elem<-rd$findElement(using = "xpath", value = "//*[@id='selectStno']")
      opts<-elem$selectTag()
      opts$elements[[i]]$clickElement()
      urldt<-rd$getCurrentUrl()
      if(j==1 & k>=2){
        useurl<-substr(urldt[[1]],1,nchar(urldt[[1]])-8)
      }else if(j>1){
        useurl<-substr(urldt[[1]],1,nchar(urldt[[1]])-8)
      }else{
        useurl<-substr(urldt[[1]],1,nchar(urldt[[1]])-7)
      }
      rd$navigate(paste(useurl,year[j],"-",month[k],sep = ""))
      Sys.sleep(2)
      dldt<-rd$findElement(using = "xpath", value = "//*[@id='downloadCSV']")
      dldt$clickElement()
      print(paste(opts$value[i],"-",year[j],"-",month[k],sep = ""))
      Sys.sleep(10)
    }
  }
}

remdr$server$stop() #終止受控制的瀏覽器(如果瀏覽器關掉要重新啟動一定要執行這行)


#將測站編號加入資料表中(將欲合併的csv檔與R檔案放置於同一資料夾中)
filenames <- list.files(pattern = ".csv")
station<-list()
for (i in 1:length(filenames)) {
  station<-append(station,substr(filenames[i],1,nchar(filenames[i])-12))
}
All<-lapply(filenames,function(i){
  read.csv(i)
})
dt1<-as.data.frame(All[1])
dt1 %<>% mutate(.,station=station[1])
dt1[]<-lapply(dt1,as.character)
for (i in seq(2,length(filenames),by=1)) {
  dt2<-as.data.frame(All[i])
  dt2 %<>% mutate(.,station=station[i])
  dt2[]<-lapply(dt2,as.character)
  dt1<-rbind(dt1,dt2)
}
