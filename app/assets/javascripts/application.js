function show_slow_warning() {
    $("#slow_warning").show();
}

$(document).ready(function() {
    $('#my-link').click(function(){
      show_slow_warning();
    });
});