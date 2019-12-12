# Project 2 - Life Expectancy Dashboard in R

## Background

This repo was created as a submission for class DSCI 532 as part of the Masters of Data Science program at the University of British Columbia.

Team members (group 101):

- Jake Lee
- Sam Edwardes
- Zoe Pan

## Milestone 3:

- [Project Proposal](docs/proposal.md)
- [Code of Conduct](docs/team-code-of-conduct.md)
- [App Description and Sketch](#app-description-and-sketch)  
- [Milestone1,2 and DashR app description comparison](https://github.com/UBC-MDS/DSCI_532_L01_group101_project2/compare/5a374c6ce7dc94bac847042b56afc7d8559ad6fd...13d3991ae907e43f8ff6a063787ea0efd5b68e9d)
- Current progress screenshot:  

![](assets/current_progress.png)



## Milestone 4:

[Heroku app]()  
[Reflection](https://github.com/UBC-MDS/DSCI_532_L01_group101_project2/blob/master/docs/reflection.md)   
[App functionality](#app-functionality)   



## App Description and Sketch

The app contains one page that includes four summary statistics and four main plots. The summary statistics are about the average life expectancy, average GDP around the world, standard deviation of GDP of all countries and the count of the countries in total in our dataset. The left column are line plots that visualize `life expectancy`, `GDP` (gross domestic product) over time by country or `life expectancy` and `GDP` change in percentage year over year. The right column of plots includes a geographic heat map that can compare `life expectancy`, `GDP`, or `GDP log` and a scatter plot of `life expectancy` by `GDP` or `GDP log` for selected year range for all countries.

We include `GDP log` variable for the heat map and scatter plot, because of the right skewness of the GDP distribution of all countries. With `GDP log`, some patterns may become more obvious.

One of the most interesting features of this dashboard is the ability to change the variable each plot explores. By allowing the user to choose the variable of the y-axis, select countries through filtered country status for time series plots, the colour variable for the heat map, and year range, x-axis for the scatter plot, users are able to answer many potential questions with a limited number of plots and screen real estate.

The dashboard will also include interactive elements. Tooltips will be used on all data points to allow the user to see precise values. The summary numbers at the top of the dashboard will serve as a “grounding point” so the user can easily compare individual observations to in view averages. 

![app-sketch](assets/app_screenshot_2019-12-05.png)


## App functionality  

The top level of the plot contains a dashboard title. 

The next row of the dashboard provides a description of the data and high level summary statistics. These help the user understand how far each country is from the mean values. These values intentionally do not change with the filters so the user can always refer back to this baseline.

The final row contains two columns:

- The filters on top of the line plots enable the user to choose which countries they specifically wish to review and the user can change the y-axis from absolve values to year over year percent change.
- The life expectancy line plots allows the user to compare the life expectancy and GDP over time by country.
- The right top graph is a heat map for these 193 countries. The user can dynamically change what the fill colour represents choosing between: life expectancy, GDP, or logged GDP. Below the heat map is the GDP by life expectancy scatter plot for all 193 countries. By using the checklist box, radio buttons and slider under the plot the user can look for interesting patterns or relationships between GDP and life expectancy.

At the bottom row, we include the link to our github repo, if the users want to see the source code. The data is retrieved from [Kaggle](https://www.kaggle.com/kumarajarshi/life-expectancy-who). For the convenience of the user we have provided a button the user can click on to view the original data source.

![app-screenshot](assets/app_screenshot_2019-11-28.png)