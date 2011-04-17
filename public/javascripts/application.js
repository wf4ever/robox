$(document).ready(function(){ $('.tab-container').easytabs({
  animate: false,
  tabActiveClass: "selected-tab",
  panelActiveClass: "displayed"
}); });


$(document).ready(function() {
  $(".collapsibleContainer").collapsiblePanel();
  $(".collapsibleContainerContent").slideToggle();
});