import $ from "jquery"

$(function(){

  $(".js-fade-on-click").click(function(e) {
    e.preventDefault()
    $(this).fadeToggle(500)
  })

})
