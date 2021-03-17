
# Pakker
#library(data.table)
library(rgdal)
library(sp)
library(ggplot2)
library(raster)
library(rjson)
#library(readxl)
library(leaflet)
library(plyr)
library(maptools)
library(expss)
library(sp)
library(ggiraph)
library(maps)
library(plotly)
library(extrafont)
library(tidyverse)

# pakker <- c("raster","leaflet","expss","ggiraph" )
# walk(pakker,  ~install.packages(.x))

#du trenger trolig ikke alle disse pakkene, men jeg har lastet inn en drøss med pakker når jeg har forsøkt å lage forskjellige varianter..

#Steg 1: last inn kartfil av typen .shp. Filen NOR_adm1.shp inneholder geometriske data for fylkene (etter gammel inndeling). 
kart <- shapefile("data/Fylker_2020.shp")

#fortify konverterer et S3-object til "data frame" slik at vi kan bruke det videre i ggplot2
df <- fortify(kart) %>% as_tibble()

df %>% distinct(id)


#leser inn dataene vi ønsker å visualisere i kartet. Dette datasettet inneholder antall mottakere av kontantstøtte pr. fylke i 2011.
ks2 <- readxl::read_excel("data/ks.xlsx")

ks <- tibble( id = c(7,0,5,2,8,4,1,3,6,9,10),
                  fylke = c("Oslo", "Roganland", "Møre og Romsdal", "Nordland", "Viken", "Innland", "Vestfold og Telemark", "Agder", "Vestland", "Trøndelag", "Troms og Finnmark")
                  )

df_ledig <- readxl::read_excel("data/ledighet_korona.xlsx") 

ks <- left_join(ks,df_ledig, by = "id")

#merger de to datasettene etter felles "id". 
map <-merge(x=df,y=ks,by="id",all.x=TRUE)

head(map)

#Her plotter vi selve kartet. Du trenger minst å legge inn ggplot(df, aes(long, lat, group = group))
#og geom_polygon(aes(fill = "navnet på variabelen du ønsker å visualisere i kartet")). Alt etter dette er kun for å gjøre kartet vakkert.

a <- ggplot(map, aes(long, lat, group = group)) + 
    geom_polygon(aes(fill = Andel), color="black")+ 
    scale_fill_gradient(low="white", high="navy")+
    theme_light()+
    theme(plot.margin = unit(c(1,1,1,1), "cm"))+
    labs(title = "Kontantstøtte",
         subtitle = "Antall personer med ytelse pr. fylke i 2011",
         caption = "Kilde: NAV")
a

#theme_void gjør at du fjerner lat og long i kartet. Alternativer her er f.eks theme_light() som vil gi deg et rutenett o.l.
#theme_void gir deg et kart uten marg. Har derfor lagt til plot.margin for at det ikke skal se helt håpløst ut.
#scale_fill_gradient gjør at du graderer fargene fra lav til høy. Dette kan du endre til f.eks rødt og blått hvis du skal vise hvem som fikk flest stemmer i valget i hvert fylke. 
#group = group sikerer at hver holme, øy o.l. (deler i samme polygon er gruppert etter "group")

#Dette er starten på å gjøre kartene "dynamiske". Ved bruk av ggplotly kan du dra pekeren over kartet for å vise verdier osv.. 
fig <- ggplotly(a)
