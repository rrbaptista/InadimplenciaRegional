library(xts)
library(forecast)
library(tidyverse)
library(dygraphs)
library(htmltools)
library(prophet)
library(plotly)
library(timetk)

tbl_inadimplencia_uf <- read_csv("default_rates.csv")

lista_uf <- tbl_inadimplencia_uf %>%
  distinct(state_brazil) %>%
  unlist() %>% unname()

pessoas <- c('P', 'C')

#Modelo Projeção
for (uf_selecionada in lista_uf) {
  
  for (pessoa in pessoas) {
  
  #Modelo HoltWinters
  dataset <- tbl_inadimplencia_uf %>%
    filter(state_brazil == uf_selecionada & person_or_corporation == pessoa) %>%
    select('ds' = year_month, 'y' = default_rate)
  
  serie_temporal <- ts(dataset$y, start = c(2004, 1), frequency = 12)
  
  modelo <- HoltWinters(serie_temporal, seasonal = "multiplicative", alpha = 0.2, beta = 0.1, gamma = 0.1)
  
  saveRDS(modelo, paste0('DashboardInadimplencia/www/modelos/projecao/', uf_selecionada, '-', pessoa, '.rds'))
  
  #Sazonalidade
  sazonalidade <- dataset %>%
    plot_seasonal_diagnostics(ds, y, .feature_set = c('month.lbl', 'quarter'), .title = paste0("Sazonalidade - ", uf_selecionada, " - ", ifelse(pessoa == "P", "PF", "PJ")),
                              .geom = "boxplot", .x_lab = "Unidade Temporal", 
                              .geom_color = "blue", .geom_outlier_color = "maroon")
  
  sazonalidade$x$layout$annotations[[2]]$text <- "Mensal"
  sazonalidade$x$layout$annotations[[3]]$text <- "Trimestral"
  
  saveRDS(sazonalidade, paste0('DashboardInadimplencia/www/modelos/sazonalidade/', uf_selecionada, '-', pessoa, '.rds'))
  
  }
  
}

#Série Histórica
for (uf_selecionada in lista_uf) {
  
  dataset <- tbl_inadimplencia_uf %>%
    filter(state_brazil == uf_selecionada) %>%
    select(year_month, default_rate, person_or_corporation) %>%
    mutate(person_or_corporation = ifelse(person_or_corporation == "P", "PF", "PJ"))
  
  plot_ds <- dataset %>%
    ggplot(aes(x = year_month, y = default_rate, fill = person_or_corporation)) +
    geom_point() + 
    geom_smooth(method = "loess") + 
    theme_classic(base_size = 20) +
    labs(title = paste0("Série Histórica de Inadimplência - ", uf_selecionada),
         x = "Linha Temporal",
         y = "% de inadimplência", fill = "Tipo de Pessoa")
  
  plot_interativo <- ggplotly(plot_ds, height = 600)
  
  saveRDS(plot_ds, paste0('DashboardInadimplencia/www/plots/serie/', uf_selecionada, ".rds"))
  
}
