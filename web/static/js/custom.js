import $ from "jquery";
import "jquery";

$(".toggle").click(function() {
    // Switches the Icon
    $(this)
      .children("i")
      .toggleClass("glyphicon-certificate");
    // Switches the forms
    $(".form").animate(
        {
          height: "toggle",
          "padding-top": "toggle",
          "padding-bottom": "toggle",
          opacity: "toggle"
        },
        "slow"
      );
  });
  
  // $( ".selector" ).slider({
  //   max: 5000,
  //   min: 0,
  //   range: true,
  //   step: 100,
  //   value: 300
  // });
  