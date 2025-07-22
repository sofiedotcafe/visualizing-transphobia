#
# This visualization uses visnetwork in R to examine and structurally represent influence networks within spheres of transphobic discourse,
# pseudoscientific medical affiliations, and ideologically motivated bias dissemination. Source data is stored in a sqlite3 database.
#
# This analytical work is released into the public domain by the author(s) under the Creative Commons CC0 1.0 Universal Public Domain Dedication.
# To the fullest extent permitted by applicable law, the author(s) waive all copyright and neighboring rights.
# Users are authorized to reproduce, adapt, transmit, and utilize this work, in whole or in part, including for commercial purposes,
# without obtaining prior permission. See: https://creativecommons.org/publicdomain/zero/1.0/legalcode

library(shiny)
library(DBI)
library(RSQLite)
library(visNetwork)
library(bslib)

# `file.copy` is overridden to prevent copying file permissions, which causes "Permission denied" errors on NixOS and similar immutable systems.
# The patch provided in the pull requests does not work because it does not patch the SASS precompiler package.
# I didn't want to deal with patching the SASS precompiler package, so I just override the `file.copy` function. >:3
# https://github.com/rstudio/bslib/issues/1154
x <- base::file.copy
base::unlockBinding("file.copy", asNamespace("base"))
assign("file.copy", function(...) {
  args <- list(...)
  args$copy.mode <- FALSE
  do.call(x, args)
}, envir = asNamespace("base"))
base::lockBinding("file.copy", asNamespace("base"))

ui <- navbarPage(
  title = "Influence Network Analysis",
  theme = bs_theme(precompiled = TRUE, precompile = FALSE),
  tabPanel(
    title = "Network Visualization",
    fluidRow(
      column(
        width = 3,
        wellPanel(
          h4("Controls"),
          selectInput("selectedNode", "Select Node to Highlight:", choices = NULL),
          tags$hr(),
          p("Use the dropdown to highlight a node in the network."),
          p("Hover over nodes for details. Zoom and pan with mouse.")
        )
      ),
      column(
        width = 9,
        visNetworkOutput("network", height = "90vh")
      )
    )
  ),
  tabPanel(
    title = "About",
    fluidPage(
      h3("Network Influence Visualization"),
      p("This visualization explores structural influence networks within transphobic discourse, pseudoscientific medical affiliations, and ideologically motivated bias dissemination."),
      p("Data is sourced from various academic and investigative research, aggregated into a SQLite database."),
      p("Use the 'Network Visualization' tab to explore nodes and connections interactively."),
      p("This work is released under the Creative Commons CC0 1.0 Public Domain Dedication."),
      p("© 2025 Sofie Halenius and contributing authors of the academic and investigative research"),
    )
  )
)

server <- function(input, output, session) {
  con <- dbConnect(RSQLite::SQLite(), "network.sqlite3")
  entities <- dbReadTable(con, "entities")
  connections <- dbReadTable(con, "connections")
  dbDisconnect(con)

  node_degrees <- table(c(connections$from_id, connections$to_id))

  nodes <- data.frame(
    id = entities$id,
    label = entities$name,
    group = entities$type,
    value = as.numeric(node_degrees[as.character(entities$id)]),
    title = paste0("<b>", entities$name, "</b><br>Type: ", entities$type),
    stringsAsFactors = FALSE
  )
  nodes$value[is.na(nodes$value)] <- 1

  edges <- data.frame(
    from = connections$from_id,
    to = connections$to_id,
    arrows = "to"
  )

  updateSelectInput(session, "selectedNode", choices = setNames(nodes$id, nodes$label))

  output$network <- renderVisNetwork({
    visNetwork(nodes, edges) %>%
      visNodes(
        font = list(size = 14),
        scaling = list(min = 10, max = 30)
      ) %>%
      visGroups(groupname = "person", color = "skyblue") %>%
      visGroups(groupname = "group", color = "lightgreen") %>%
      visGroups(groupname = "defunct", color = "gray") %>%
      visGroups(groupname = "pseudoscientific theory", color = "pink") %>%
      visEdges(smooth = FALSE, arrows = "to") %>%
      visPhysics(
        enabled = TRUE,
        solver = "barnesHut", # Switch to barnesHut for better distribution
        barnesHut = list(
          gravitationalConstant = -1500,
          centralGravity = 0.05,
          springLength = 150,
          springConstant = 0.05,
          damping = 0.5,
          avoidOverlap = 0.4
        ),
        maxVelocity = 50,
        stabilization = list(enabled = TRUE, iterations = 500)
      ) %>%
      visOptions(
        highlightNearest = list(enabled = TRUE, hover = TRUE, degree = 1),
        nodesIdSelection = FALSE
      ) %>%
      visLayout(randomSeed = 42)
  })

  observe({
    req(input$selectedNode)
    visNetworkProxy("network") %>%
      visSelectNodes(id = input$selectedNode)
  })
}

shinyApp(ui, server)
