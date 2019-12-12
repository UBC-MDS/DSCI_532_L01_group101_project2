library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashTable)
library(plotly)
library(stringi)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)


###########################################
# DATA
###########################################
df <- read_csv("data/WHO_life_expectancy_data_clean.csv")

###########################################
# PLOTTING FUNCTIONS
###########################################

#' Make line plots
#'
#' @param df The data frame to create plot with
#' @param selected_y_axis The column name to plot on the y-axis
#' @param selected_countries A vector containing all countries to include
#'
#' @return Plotly plot
#'
#' @examples
#' make_line_plot(df, "life_expectancy", c("Canada", "Mexico"))
#' make_line_plot(df, "change_in_life_expectancy_percent", c("Canada", "Mexico"))
#' make_line_plot(df, "gdp", c("Canada", "Mexico"))
#' make_line_plot(df, "change_in_gdp_percent", c("Canada", "Mexico"))
make_line_plot <- function(df, selected_y_axis, selected_countries) {

  # tidy df
  df <- df %>%
    filter(country %in% selected_countries) %>%
    group_by(country, year) %>%
    summarise(
      gdp = mean(gdp),
      life_expectancy = mean(life_expectancy)
    ) %>%
    ungroup() %>%
    group_by(country) %>%
    mutate(
      change_in_gdp = gdp - lag(gdp),
      change_in_gdp_percent = (gdp - lag(gdp)) / lag(gdp),
      change_in_life_expectancy = life_expectancy - lag(life_expectancy),
      change_in_life_expectancy_percent = (life_expectancy - lag(life_expectancy)) / lag(life_expectancy)
    ) %>%
    ungroup() %>%
    arrange(country, year)

  # plot labels
  if (selected_y_axis == "gdp") {
    y_format <- scales::dollar
    y_axis_label <- "GDP (USD)"
    plot_title <- "GDP by Country"
  } else if (selected_y_axis == "change_in_gdp_percent") {
    y_format <- scales::percent
    y_axis_label <- "Change in GDP (USD)"
    plot_title <- "Change in GDP by Country"
  } else if (selected_y_axis == "life_expectancy") {
    y_format <- scales::comma
    y_axis_label <- "Life Expectancy (Years)"
    plot_title <- "Life Expectancy by Country"
  } else if (selected_y_axis == "change_in_life_expectancy_percent") {
    y_format <- scales::percent
    y_axis_label <- "Change in Life Expectancy (Years)"
    plot_title <- "Change in Life Expectancy by Country"
  } else {
    y_format <- scales::comma
    y_axis_label <- selected_y_axis %>%
      str_replace_all("_", " ") %>%
      str_to_title()
    plot_title <- selected_y_axis %>%
      str_replace_all("_", " ") %>%
      str_to_title()
  }

  # create plot
  fig <- df %>%
    ggplot(aes(x = year, y = !!sym(selected_y_axis), colour = country)) +
    # suppressed warnings b/c of bug “Ignoring unknown aesthetics: text”
    suppressWarnings(geom_line(aes(text = map(paste0(
      "<b>Country:</b> ", country, "<br>",
      "<b>Year:</b> ", year, "<br>",
      "<b>", y_axis_label, ":</b> ", y_format(!!sym(selected_y_axis))
    ), htmltools::HTML)))) +
    scale_y_continuous(labels = y_format) +
    labs(
      title = plot_title,
      x = "",
      y = y_axis_label,
      colour = "Country"
    ) +
    guides(colour = guide_legend(ncol = 1))

  ggplotly(fig, tooltip = c("text")) %>%
    config(displayModeBar = FALSE)
}

#############scatter plot####################
#' Make scatter plots
#'
#' @param df The data frame to create plot with
#' @param year_sel The numeric year for scatter plot
#' @param status_sel list of countries status included in the plot
#' @param x_axis "original" or "log" for x-axis
#'
#' @return Plotly plot
#'
#' @examples
#' make_line_plot(df, year_sel=2014, status_sel=list("Developed"), x_axis="GDP Log")
make_scatter_plot <- function(df, year_sel=2014, status_sel=list("Developed", "Developing"), x_axis="GDP Log") {
  
  p <- df %>% 
    filter(year == year_sel & status %in% status_sel) %>%
    ggplot(aes(x=gdp, y=life_expectancy, color=status,
               text=paste("GDP: ", round(gdp, 2),
                          "</br></br> Life Expectancy: ", life_expectancy,
                          "</br> Status: ", status,
                          "</br> Country: ", country))) +
    geom_point(alpha=0.5) +
    ylab("Life Expectancy") +
    ggtitle(paste("Life Expectancy vs. Mean GDP (USD) in Year", year_sel))
  
  if (x_axis=="GDP") {
    p <- p + xlab("GDP in USD")
  } else if (x_axis=="GDP Log") {
    
    p <- p + scale_x_continuous(trans="log10") +
      xlab("GDP in USD (log base 10)")
  }
  
  ggplotly(p, tooltip="text") %>%
    config(displayModeBar=FALSE)
  
}

############# World Heat Map plot####################
#' Make world heatmap plots
#'
#' @param df The data frame to create plot with
#' @param color_value The type of value (Life expectancy, GDP, GDP Log)
#'
#' @return Plotly plot
#'
#' @examples
#' make_world_heat(df, color_value="GDP Log")

make_world_heat <- function(df, color_value="Life Expectancy") {
  
  df <- select(df, c("life_expectancy","year","country","gdp"))
  raw_country_names <- levels(as.factor(df$country))
  
  # World Map Data                   
  world_outline <- ne_countries(scale = "medium", returnclass = "sf")
  labels <- levels(as.factor(world_outline$sovereignt))
  
  labels
  
  # Detect Difference
  setdiff(raw_country_names, labels)
  
  # Clean country names 
  clean_data <- df %>%
  mutate(country = case_when(country == "Bahamas" ~ "The Bahamas" ,
                               country == "Bolivia (Plurinational State of)" ~ "Bolivia",
                               country == "Brunei Darussalam" ~ "Brunei",
                               country == "Cabo Verde" ~ "Cape Verde",
                               country == "Congo" ~ "Republic of Congo",
                               country == "Côte d'Ivoire" ~ "Ivory Coast" ,
                               country == "Czechia" ~ "Czech Republic",                                             
                               country == "Democratic People's Republic of Korea" ~ "North Korea",
                               country == "Guinea-Bissau" ~ "Guinea Bissau",
                               country == "Iran (Islamic Republic of)" ~ "Iran" ,
                               country == "Lao People's Democratic Republic" ~ "Laos" ,
                               country == "Micronesia (Federated States of)" ~ "Federated States of Micronesia" ,
                               country == "Republic of Korea"  ~ "South Korea" ,                    
                               country == "Republic of Moldova" ~ "Moldova" ,                           
                               country == "Russian Federation" ~ "Russia" ,                            
                               country == "Serbia" ~ "Republic of Serbia"  ,                              
                               country == "Syrian Arab Republic"  ~ "Syria",                               
                               country == "The former Yugoslav republic of Macedonia" ~ "Macedonia",          
                               country == "Timor-Leste"  ~ "East Timor"  ,                          
                               country == "Tuvalu"~ "Samoa",                                           
                               country == "United Kingdom of Great Britain and Northern Ireland" ~ "United Kingdom" ,
                               country == "United Republic of Tanzania" ~ "United Republic of Tanzania",                   
                               country == "Venezuela (Bolivarian Republic of)" ~ "Venezuela" ,            
                               country == "Viet Nam" ~ "Vietnam" ,
                               TRUE ~ country)) %>%
    group_by(country) %>%
    summarise(mean_life_exp = mean(life_expectancy),
              mean_gdp = mean(gdp),
              mean_log_gdp = log(mean(gdp)))
  
  data_for_mapping <- left_join(world_outline, clean_data, by=c("sovereignt"="country"))
  
  if (color_value=="Life Expectancy"){
    button_value <- "mean_life_exp"
    mid_point <- 65
  } else if (color_value == "GDP"){
    button_value <- "mean_gdp"
    mid_point <- 25000
  } else {
    button_value <- "mean_log_gdp"
    mid_point <- 7.5
  }
  
  
  world_plot <- ggplot(data_for_mapping) +
    geom_sf(size=0.05, aes(fill=!!sym(button_value))) +
    scale_fill_gradient2(low= "#f2ff00", mid= "#00ff2a", high="#1500ff" , midpoint = mid_point, na.value="white")
  
  ggplotly(world_plot, tooltip="text") %>%
    config(displayModeBar=FALSE)
}





###########################################
# APP BOILERPLATE
###########################################
app <- Dash$new()

colours <- list(
    "white" = "#ffffff",
    "off_white" = "#F9F9F9",
    "light_grey" = "#d2d7df",
    "ubc_blue" = "#082145",
    "yellow" = "#FFFF00"
)


###########################################
# APP LAYOUT
###########################################
app$layout(
    htmlDiv(children = list(
        # ROW 1 - HEADER
        htmlDiv(className = "row", style = list("backgroundColor" = colours$ubc_blue, "padding" = "10px"), children = list(
            htmlH1("Global Life Expectancy Trends", style = list("color" = colours$white))
        )),
        # ROW 2 - DESCRIPTION AND BIG NUMBERS
        htmlDiv(className = "row", style = list("backgroundColor" = colours$white), children = list(
            # ROW 2 - COLUMN 1
            htmlDiv(className = "pretty_container four columns", children = list(
                htmlH6("Description:"),
                htmlP("This dashboard app is created to help decision-makers decide where and what to invest in to improve the life expectancy for all. Our app will visualize several factors across 193 countries to better understand the global macro trends.")
            )),
            # ROW 2 - COLUMN 2
            htmlDiv(className = "pretty_container two columns", children = list(
                htmlH6("Mean Life Expectancy of the World", style = list("text-align" = "center")),
                htmlH6(as.character(round(mean(df$life_expectancy, na.rm = TRUE), 1)), style = list("text-align" = "center"))
            )),
            # ROW 2 - COLUMN 3
            htmlDiv(className = "pretty_container two columns", children = list(
                htmlH6("World Mean GDP in US Dollars", style = list("text-align" = "center")),
                htmlH6(scales::dollar(mean(df$gdp, na.rm = TRUE)), style = list("text-align" = "center"))
            )),
            # ROW 2 - COLUMN 4
            htmlDiv(className = "pretty_container two columns", children = list(
                htmlH6("World Standard Dev. GDP in US Dollars", style = list("text-align" = "center")),
                htmlH6(scales::dollar(sd(df$gdp, na.rm = TRUE)), style = list("text-align" = "center"))
            )),
            # ROW 2 - COLUMN 5
            htmlDiv(className = "pretty_container two columns", children = list(
                htmlH6("Number of Countries in the World", style = list("text-align" = "center")),
                htmlH6(as.character(length(unique(df$country))), style = list("text-align" = "center"))
            ))
        )),
        # ROW 3 - PLOTS
        htmlDiv(className = "row", style = list("backgroundColor" = colours$white), children = list(
            # ROW 3 - COLUMN 1
            htmlDiv(className = "pretty_container six columns", children = list(
                htmlH6("Filters - Line Plots"),
                htmlLabel("Select line plot countries:"),
                dccDropdown(id = "dropdown_country", value = c("Italy", "France"), multi = TRUE, map(unique(df$country), ~ list(label = .x, value = .x))),
                htmlLabel("Select line plot y-axis values:"),
                dccRadioItems(id = "radio_line_y_axis", value = "Original Number", options = list(list(label = "Original Number", value = "Original Number"), list(label = "Change in Percent", value = "Change in Percent"))),
                htmlBr(),
                dccGraph(id = "line_life_expectancy"),
                htmlBr(),
                dccGraph(id = "line_gdp")

            )),
            # ROW 3 - COLUMN 2
            htmlDiv(className = "pretty_container six columns", children = list(
              # heat map
              htmlH6("Filters - Heat Map"),
              htmlLabel("Select heat map colour values:"),
              dccRadioItems(id = "radio_heat_map_colour", value = "Life Expectancy", options = list(list(label = "Life Expectancy", value = "Life Expectancy"), list(label = "GDP", value = "GDP"), list(label = "GDP Log", value = "GDP Log"))),
              htmlBr(),
              dccGraph(id = "heat_map"),
              htmlHr(),
              # scatter plot
              htmlH6("Filters - Scatter Plot"),
              htmlDiv(className = "row", children = list(
                htmlDiv(className = "six columns", children = list(
                  htmlLabel("Select scatter plot country status"),
                  dccChecklist(id = "checklist_scatter_status", value = list("Developed", "Developing"), options = list(list(label = "Developed", value = "Developed"), list(label = "Developing", value = "Developing")))
                )),
                htmlDiv(className = "six columns", children = list(
                  htmlLabel("Select scatter plot x-axis:"),
                  dccRadioItems(id = "radio_scatter_x_axis", value = "GDP Log", options = list(list(label = "GDP", value = "GDP"), list(label = "GDP Log", value = "GDP Log")))
                ))
              )),
              htmlDiv(className = "row", children = list(
                htmlDiv(className = "eleven columns", children = list(
                  htmlLabel("Select scatter plot year:"),
                  dccSlider(id="slider_scatter_year", min=min(df$year), max=max(df$year), step=1, value=2015, marks=map(unique(df$year), as.character) %>% setNames(unique(df$year)))	
                ))
              )),
              htmlBr(),
              dccGraph(id = "scatter_plot")
            ))
        )),
        # ROW 4 - LINKS
        htmlDiv(className = "row", style = list("backgroundColor" = colours$white), children = list(
          htmlDiv(className = "pretty_container two columns", children = list(
            htmlP("GitHub Repo:"),
            htmlA(href = "https://github.com/UBC-MDS/DSCI_532_L01_group101_project2", children = "GitHub.com")
          )),
          htmlDiv(className = "pretty_container two columns", children = list(
            htmlP("Data Source:"),
            htmlA(href = "https://www.kaggle.com/kumarajarshi/life-expectancy-who/data", children = "Kaggle.com")
          ))
        )),
        htmlH6("END OF DASHBOARD")
    )
  )
)

###########################################
# CALL BACKS
###########################################

# Line plot - Life expectancy
app$callback(
    output = list(id = "line_life_expectancy", property = "figure"),
    params = list(input(id = "dropdown_country", property = "value"),
                  input(id = "radio_line_y_axis", property = "value")),
    function(selected_countries, selected_y_axis){
      if (selected_y_axis == "Original Number"){
        selected_y <- "life_expectancy"
      } else if (selected_y_axis == "Change in Percent"){
        selected_y <- "change_in_life_expectancy_percent"
      }
      make_line_plot(df, selected_y, selected_countries)
    }
)

# Line plot - GDP
app$callback(
    output = list(id = "line_gdp", property = "figure"),
    params = list(input(id = "dropdown_country", property = "value"),
                  input(id = "radio_line_y_axis", property = "value")),
    function(selected_countries, selected_y_axis){
      if (selected_y_axis == "Original Number"){
        selected_y <- "gdp"
      } else if (selected_y_axis == "Change in Percent"){
        selected_y <- "change_in_gdp_percent"
      }
        make_line_plot(df, selected_y, selected_countries)
    }
)

#Scatter plot
app$callback(
  output = list(id = "scatter_plot", property = "figure"),
  params = list(input(id = "slider_scatter_year", property = "value"),
                input(id = "checklist_scatter_status", property = "value"),
                input(id = "radio_scatter_x_axis", property = "value")),
  function(year_sel, status_sel, x_axis){
    make_scatter_plot(df, year_sel, status_sel, x_axis)
  }
)


# Heat Map
app$callback(
  output = list(id = "heat_map", property = "figure"),
  params = list(input(id = "radio_heat_map_colour", property = "value")),
  function(color_value){
    make_world_heat(df, color_value)
  }
)

###########################################
# RUN APP
###########################################
app$run_server(host = "0.0.0.0", port = Sys.getenv('PORT', 8050))

