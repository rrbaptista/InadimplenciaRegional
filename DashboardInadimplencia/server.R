library(shiny)

function(input, output, session) {
  
  output$introducao <- renderUI(htmlTemplate(filename = 'www/introducao.html'))
  
  output$plot_distribuicao <- renderPlotly({
    plot <- read_rds(paste0('www/plots/serie/', input$uf_selecionada, ".rds"))
    ggplotly(plot)
  })
  
  output$plot_sazonalidade <- renderPlotly({
    plot <- read_rds(paste0('www/modelos/sazonalidade/', input$uf_selecionada, "-", input$tipo_pessoa_sazonalidade, ".rds"))
    ggplotly(plot)
  })
  
  modelo <- reactive({
    read_rds(paste0('www/modelos/projecao/', input$uf_selecionada, "-", input$tipo_pessoa_projecao, ".rds"))
  })
  
  output$projecao <- renderDygraph({
    
    projecao <- predict(modelo(), n.ahead = input$meses_projecao, prediction.interval = FALSE)
    
    resultado <- cbind(historico = modelo()[["x"]], projecao)
    
    dygraph(resultado, 
            main = paste0("Série Histórica e Projeção para ", input$meses_projecao, " meses - " , input$uf_selecionada, " - ", ifelse(input$tipo_pessoa_projecao == 'P', 'PF', 'PJ')), 
            xlab = "Linha Temporal", ylab = "Taxa de inadimplência em %") %>%
      dySeries("historico", label = "Série Histórica") %>%
      dySeries(c("projecao"), label = "Projeção") %>%
      dyOptions(strokeWidth = 5) %>% 
      dyRangeSelector()
    
  })
  
}