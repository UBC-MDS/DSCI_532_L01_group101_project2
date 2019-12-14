# Milestone 2 Reflection

### Background

Our team sought out to create a dashboard that could help explore the following research questions:

> 1. How has the life expectancy by country changed over time?
> 2. How are monetary factors associated with life expectancy?
> 3. Does the life expectancy between developing and developed countries differ?

We believe that in one week we were able to produce a useful dashboard in R that can help researchers answer the question above. Through the use of four interactive plots users are able to answer the research questions from a variety of angles.

Based on the feedback from peers and teaching assistants for our python Dash app, we build the R dashboard. Below we have summarized what the app has been improved from python dashboard, what the app does well, what the current limitations are, and ideas for future improvements.

### Improvement of the app in R

- One advantage of the R dashboard is that the graphs are not wrapped in the Iframe, so that graphs adjust dynamically with different sizes of the web-page. That solves our one of the major issues for python dashboard that graphs were cut-off in smaller screens. 
- We adjusted text size and background color for the title header so the title stands out.
- We re-organized the graphs into two columns and control filters on top of the each graph, so that's more intuitive to navigate the page.

### What the app does well

- The design is clean and visually appealing. By organizing the plots into columns and the use of *pretty containers* (the 3d box effect) each section clearly stands out and attracts the users eyes to the important sections.
- The interactivity of the dashboard allows for the dashboard to remain minimal, while providing detailed numbers when required. For example:
  - The heat map is not crowded with labels making it nice to look at. If you need to know the name of a country or exact value you can hover the mouse over a country to get the details.

### Current limitations

- Problem deploy the app on Heroku: While attempting to deploy our R app to Heroku server, we ran into a critical issue: the sf package, which we adopted as a library for creating world heatmap, failed to install. The problem was in the version of GDAL, a translator software library for geospatial data formats. To fix this, we need an additional build pack for an updated version of machine core libraries. Also, the installation process in R had to recognize the new version of GDAL and terminal access to the machine is required. However, because R is not one of the primary languages that Heroku explicitly supports, we could not resolve this problem.
- Couldn't disable the modebar to display on the app. This is a known issue for the current version of plotly.
- There are over 193 countries. There is the possability for a user to select all 193 countries if they wish. This results in overplotting and reduces the usefullness of the plot.
  - ![overplotting_example](../assets/overplotting_example.png)
- Upon reviewing the data in detail there appear to be issues with data quality. Some of these issues were also noted on the [Kaggle page](https://www.kaggle.com/kumarajarshi/life-expectancy-who/data) where the data was obtained:
  - Canada and Greece are listed as a developing countries.
  - There is no GDP data for the USA.
  - `percentage expenditure` has some values which are greater than 100 (it is mean to represent the percent of GDP spent on health).
  - Users can un-check both statuses of countries for the scatter plot.  

### Ideas for future improvement

 Add in additional geographic details:

- Have interactive heatmap and map each country to a region or continent.
- This could enable for comparisons by region/continent as opposed to just country by country.
- It would also allow users to compare a countries performance relative to the continental/regional mean.

Other items:

- Add in a control to limit the number of countries that can be drawn on line plot.
- Obtain correct or more accurate GDP and life expectancy data.
- Add in a restriction to un-check both statuses for the scatter plot.
- Add in the ability to quickly create interesting views. For example, develop a button that can quick filter to top 10 worst or best performing countries.