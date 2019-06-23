import $ from 'jquery'
// See https://www.highcharts.com/docs/getting-started/install-from-npm
var Highcharts = require("highcharts")
require("highcharts/modules/exporting")(Highcharts)

$(document).ready(function() {

  if ($("#history-page-chart-container").length > 0) {
    var allData = $("#history-page-chart-container")
      .data("chart-data")
      .map(function(i) {
        return {
          id: i.id,
          which_eye: i.which_eye,
          x: Date.parse(i.completed_at),
          y: i.score
        }
      })

    // See https://www.highcharts.com/demo/ for examples
    var chart = Highcharts.chart('history-page-chart-container', {
      chart: {
        type: "line"
      },
      title: {
        text: "Your results across all time"
      },
      xAxis: {
        type: "datetime"
      },
      yAxis: {
        title: {text: "Smallest font size seen (%)"},
        reversed: true
      },
      series: [
        {
          name: "Left eye",
          data: allData.filter((i) => i.which_eye == "left")
        },
        {
          name: "Right eye",
          data: allData.filter((i) => i.which_eye == "right")
        },
        {
          name: "Both eyes",
          data: allData.filter((i) => i.which_eye == "both")
        }
      ],
      plotOptions: {
        series: {
          cursor: "pointer",
          point: {
            events: {
              click: function(e) {
                window.location = "/assessments/"+e.point.id
              }
            }
          }
        }
      }
    })

  }

})
