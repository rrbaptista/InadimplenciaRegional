library(shiny)
library(shinydashboard)
library(shinyWidgets)

cabecalho <- dashboardHeader(title = "Dashboard", 
                             titleWidth = "250")

#Lateral
lateral <- dashboardSidebar(sidebarMenu(menuItem("Introdução", tabName = "INTRODUCAO"),
                                        selectInput("uf_selecionada", label = "Selecione a UF", choices = lista_uf),
                                        menuItem("Série Histórica", tabName = "SERIE_HISTORICA"),
                                        menuItem("Sazonalidade", 
                                                 selectInput("tipo_pessoa_sazonalidade", label = "Selecione o tipo de pessoa", choices = c("PF" = "P", "PJ" = "C")),
                                                 menuSubItem("Visualizar Sazonalidade", tabName = "SAZONALIDADE")),
                                        menuItem("Projeção", 
                                                 noUiSliderInput("meses_projecao", 
                                                              label = "Selecione a quantidade de meses futuros", 
                                                              value = 2, min = 2, max = 60, step = 1, format = wNumbFormat(decimals = 0)),
                                                 selectInput("tipo_pessoa_projecao", label = "Selecione o tipo de pessoa", choices = c("PF" = 'P', "PJ" = 'C')),
                                                 menuSubItem("Visualizar projeção", tabName = "PROJECAO"))), 
                            width = 250)

#Corpo
corpo <- dashboardBody(
  tabItems(
    tabItem(tabName = "INTRODUCAO",
            titlePanel("Dashboard de Análise Exploratória de Inadimplência de Crédito por UF"),
            tagList(
              tags$h3("Esse dashboard elenca alguns estudos feitos com dados de inadimplência de produtos de crédito agrupados por UF e tipo de pessoa, usando como fonte um dataset obtido no Sistema Gerenciador de Séries Temporais do Banco Central do Brasil"),
              tags$h3("A taxa de inadimplência exibida nos estudos segue o conceito dado pelo Banco Central do Brasil:"),
              tags$blockquote("Taxa de inadimplência das operações de empréstimo, financiamento, adiantamento e arrendamento mercantil, concedidas pelas instituições integrantes do Sistema Financeiro Nacional (SFN), segregada em pessoas físicas e jurídicas, e por unidade da federação; medida pela razão entre o saldo dos contratos em que há pelo menos uma prestação, integral ou parcial, com atraso superior a noventa dias, e o saldo total das operações."),
              tags$h3("Você pode acessar o dataset completo no meu perfil no Kaggle, onde hospedo datasets livres para uso em estudos, ", tags$a(href = "https://www.kaggle.com/datasets/ex0ticone/credit-default-rates-of-brazilian-entities", target = "_blank", "clicando aqui")),
              tags$h3("Navegue pelo menu lateral para acessar os estudos e mudar os parâmetros desejados. O dashboard atualizará automaticamente o painel."),
              tags$h2("Obrigado!"))
            ),
    tabItem(tabName = "SERIE_HISTORICA",
            titlePanel("Aqui você observa a série histórica das taxas de inadimplência para a UF selecionada e ambos os tipos de pessoa"),
            box(plotlyOutput("plot_distribuicao", height = 700), width = "100%")
            ), 
    tabItem(tabName = "SAZONALIDADE",
            titlePanel(paste0("Aqui temos a sazonalidade da taxa de inadimplência para os parâmetros selecionados, exibidos em uma periodicidade mensal e trimestral")),
            box(plotlyOutput("plot_sazonalidade", height = 700), width = "100%")
            ),
    tabItem(tabName = "PROJECAO",
            box(dygraphOutput("projecao", height = 700), width = "100%")
            ))
)

dashboardPage(cabecalho, lateral, corpo, skin = "black", 
              title = "Dashboard de Inadimplência em Produtos de Crédito")