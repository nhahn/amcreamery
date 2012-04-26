// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require twitter/bootstrap
//= require jquery_ujs
//= require jquery-ui
//= require jquery_nested_form
//= require_tree .

// Flash fade
  $(function() {
     $('.alert-success').fadeIn('normal', function() {
        $(this).delay(3700).fadeOut();
     }); 
  }); 
  
  $(function() {
     $('.alert-error').fadeIn('normal', function() {
        $(this).delay(3700).fadeOut();
     }); 
  }); 


// Datepicker code
  $(function() {
    $(".datepicker").datepicker({
      format: 'mm/dd/YYYY'
    }); 
  }); 

//Autocomplete Stuff
$(function() {
  $("#new_shift, #edit_shift").autocompleteEmployeeName("/employees/autocompleteAsn");  
  $("#new_assignment, #edit_assignment").autocompleteEmployeeName("/employees/autocompleteEmp");  
  $("#search").autocompleteEmployeeName("/employees/autocompleteEmp");  
});

$.fn.autocompleteEmployeeName = function(url){
  return this.each(function(){
    var input = $("#employee_name", this);
    var dataContainer = $('.data_container',this);
    
    var loadData = function(item){
/*      if(item){
        var user_id = item.value;
        $.get("/employees/load_employee", {id:employee_id}, function(data){
          if(data){ dataContainer.html(data); }
        });
*/
        if(item){
          if ($(this).id == 'search'){
            window.location.href = "/employees/"+item.value
          }
          else{
            $("#assignment_id").val(item.value);
          }
        }
      }
    
    input.initAutocomplete(loadData, url);
    
    // remove links
    dataContainer.delegate('.remove_employee','click',function(){
      $(this).closest('.employee_details').remove();
      return false;
    });
  });
};


$.fn.initAutocomplete = function(callback, source){
  return this.each(function(){
    var input = $(this);
    input.autocomplete({
      source: source,
      minLength: 2, //user must type at least 2 characters
      select: function(event, ui) {
        if(ui.item){ 
          input.val(ui.item.label); 
          callback(ui.item);
        }
        return false;
      }
    });
  });
}
