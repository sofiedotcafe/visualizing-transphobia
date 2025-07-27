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
library(colourpicker)

# `file.copy` is overridden to prevent copying file permissions, which causes "Permission denied" errors on NixOS and similar immutable systems.
# The patch provided in the pull request does not work because it does not patch the SASS precompiler package.
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

inputs <- substitute(wellPanel(
  h4("Controls"),
  selectInput("selectedNode", "Select Node to Highlight:", choices = NULL),
  actionButton("reset_btn", label = "Reset controls", icon = icon("refresh"), class = "btn btn-outline-primary"),
  tags$hr(),
  p("Use the dropdown to highlight a node in the network."),
  p("Hover over nodes for details. Zoom and pan with mouse."),
  tags$hr(),
  h4("Physics Settings"),
  selectInput("solver", "Physics Solver:",
    choices = c("barnesHut", "forceAtlas2Based", "repulsion", "hierarchicalRepulsion"),
    selected = "barnesHut"
  ),
  div(
    style = "display: flex; align-items: center; gap: 6px; width: 100%;",
    tags$div(
      style = "flex-grow: 1;",
      numericInput("seed", "Seed:", value = NULL, width = "100%")
    ),
    actionButton("seed_btn", label = icon("dice"), style = "
      display: flex; justify-content: center; align-items: center;
      padding: 0 10px;
      height: 35.9px;
      margin-top: 1rem;
    ", class = "btn btn-primary")
  ),
  numericInput("gravitationalConstant", "Gravitational Constant:", value = -1500, step = 100),
  numericInput("centralGravity", "Central Gravity:", value = 0.05, min = 0, max = 1, step = 0.01),
  numericInput("springLength", "Spring Length:", value = 150, min = 10, max = 500),
  numericInput("springConstant", "Spring Constant:", value = 0.05, min = 0, max = 1, step = 0.01),
  numericInput("damping", "Damping:", value = 0.5, min = 0, max = 1, step = 0.01),
  numericInput("avoidOverlap", "Avoid Overlap:", value = 0.4, min = 0, max = 1, step = 0.01),
  numericInput("maxVelocity", "Max Velocity:", value = 50, min = 1, max = 500),
  numericInput("stabilizationIterations", "Stabilization Iterations:", value = 500, min = 0, max = 2000),
  tags$hr(),
  h4("Node Styling"),
  colourInput("color_person", "Person Node Color", value = "skyblue"),
  colourInput("color_group", "Group Node Color", value = "lightgreen"),
  colourInput("color_defunct", "Defunct Node Color", value = "gray"),
  colourInput("color_pseudoscientific", "Pseudoscientific Theory Color", value = "pink"),
  numericInput("node_min_size", "Node Min Size", value = 10, min = 1, max = 50),
  numericInput("node_max_size", "Node Max Size", value = 30, min = 1, max = 100),
  tags$hr(),
  h4("Edge Styling"),
  checkboxInput("smooth_edges", "Smooth Edges", value = FALSE),
  checkboxInput("arrows_to", "Show Arrows", value = TRUE),
  tags$hr(),
  h4("Highlight Options"),
  checkboxInput("highlight_nearest", "Highlight Nearest Nodes", value = TRUE),
  numericInput("highlight_degree", "Highlight Degree", value = 1, min = 1, max = 10)
))

resetInputs <- function(session, inputs) {
  inputs <- gsub("(\\w+\\([^\\)]*)\\s*,\\s*(.*?\\))", "\\1, \\2", inputs) # Flatten inner arguments
  inputs <- gsub("\\s+", " ", inputs) # Remove extra spaces (just in case)

  # Define a general regex for any input type that ends with "Input" (like numericInput, selectInput, etc.)
  # This regex captures the value without the surrounding quotes or parentheses
  regex <- "(\\w+Input)\\(\"([^\"]+)\",.*(value|selected)\\s*=\\s*(\"[^\"]+\"|[-+]?\\d*\\.?\\d+|TRUE|FALSE)"

  # Find all matching input inputs for the general pattern
  matches <- grep("Input", inputs, value = TRUE)

  # Loop through all matching input inputs
  lapply(matches, function(match) {
    # Extract the raw content using the regex
    capture <- regmatches(match, regexec(regex, match))

    # If a match is found, extract the relevant components
    if (length(capture[[1]]) > 0) {
      input_type <- capture[[1]][2] # Input type (e.g., numericInput, selectInput)
      inputId <- capture[[1]][3] # ID of the input
      content_type <- capture[[1]][4] # Type of value (value or selected)
      content <- capture[[1]][5] # Cleaned content of the value or selected

      if (startsWith(content, "\"") && endsWith(content, "\"")) {
        content <- substring(content, 2, nchar(content) - 1)
      }

      args <- list(session = session, inputId = inputId)
      args[[content_type]] <- content

      type <- paste0("update", toupper(substring(input_type, 1, 1)), substring(input_type, 2))
      do.call(type, args)
    }
  })
}


ui <- navbarPage(
  title = "Visualizing Transphobia",
  theme = bs_theme(precompiled = TRUE, precompile = FALSE),
  header = tagList(
    # JavaScript to activate Bootstrap tooltips
    tags$script(HTML('
      $(function () {
        $(\'[data-bs-toggle="tooltip"]\').tooltip();
      });
    ')),

    # Style for absolute positioning in navbar
    tags$style(HTML("
      .github-icon {
        position: absolute;
        right: 20px;
        top: 12px;
        font-size: 20px;
        color: #333;
      }
      .github-icon:hover {
        color: #000;
      }
    ")),

    # The GitHub icon with tooltip
    tags$a(
      href = "https://github.com/sofiedotcafe/visualizing-transphobia",
      target = "_blank",
      class = "github-icon",
      `data-bs-toggle` = "tooltip",
      `data-bs-placement` = "bottom",
      title = "View on GitHub",
      icon("github")
    )
  ),
  tabPanel(
    title = "Network Visualization",
    fluidRow(
      column(
        width = 3,
        eval(inputs),
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
      h3("Visualizing Transphobia"),
      p("This visualization explores structural influence networks within transphobic discourse, pseudoscientific medical affiliations, and ideologically motivated bias dissemination."),
      p("Data is sourced from various academic and investigative research, aggregated into a SQLite database."),
      p("Use the 'Network Visualization' tab to explore nodes and connections interactively."),
      p("This work is released under the Creative Commons CC0 1.0 Public Domain Dedication."),
      p("© 2025 Sofie Halenius and contributing authors of the academic and investigative research")
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

  observe({
    updateSelectInput(session, "selectedNode", choices = setNames(nodes$id, nodes$label))
  })

  output$network <- renderVisNetwork({
    edges <- data.frame(
      from = connections$from_id,
      to = connections$to_id,
      arrows = ifelse(input$arrows_to, "to", NA)
    )

    visNetwork(nodes, edges) %>%
      visNodes(
        font = list(size = 14),
        scaling = list(min = input$node_min_size, max = input$node_max_size)
      ) %>%
      visGroups(groupname = "person", color = input$color_person) %>%
      visGroups(groupname = "group", color = input$color_group) %>%
      visGroups(groupname = "defunct", color = input$color_defunct) %>%
      visGroups(groupname = "pseudoscientific theory", color = input$color_pseudoscientific) %>%
      visEdges(smooth = input$smooth_edges, arrows = ifelse(input$arrows_to, "to", NULL)) %>%
      visPhysics(
        enabled = TRUE,
        solver = input$solver,
        barnesHut = list(
          gravitationalConstant = input$gravitationalConstant,
          centralGravity = input$centralGravity,
          springLength = input$springLength,
          springConstant = input$springConstant,
          damping = input$damping,
          avoidOverlap = input$avoidOverlap
        ),
        maxVelocity = input$maxVelocity,
        stabilization = list(enabled = TRUE, iterations = input$stabilizationIterations)
      ) %>%
      visOptions(
        highlightNearest = list(enabled = input$highlight_nearest, hover = TRUE, degree = input$highlight_degree),
        nodesIdSelection = FALSE
      ) %>%
      visLayout(randomSeed = input$seed)
  })

  observe({
    req(input$selectedNode)
    visNetworkProxy("network") %>%
      visSelectNodes(id = input$selectedNode)
  })

  observeEvent(input$reset_btn, {
    resetInputs(session, inputs)

    showNotification(
      ui = "Controls have been reset to the default values.",
      type = "message",
      duration = 5,
      closeButton = TRUE
    )
  })

  observeEvent(input$seed_btn, {
    # Generate a random 32-bit signed integer
    random_value <- as.integer(runif(1, min = -2^31, max = 2^31 - 1))
    updateNumericInput(session, "seed", value = as.character(random_value))
  })
}

shinyApp(ui, server)
