$(document).ready(function(){ $('.tab-container').easytabs({
  animate: false,
  tabActiveClass: "selected-tab",
  panelActiveClass: "displayed"
}); });


$(document).ready(function() {
  $(".collapsibleContainer").collapsiblePanel();
  $(".collapsibleContainerContent").slideToggle();
});


$(document).ready(function(){
	$("ul.ro_contents").treeview({
		persist: "location",
		collapsed: true,
		unique: true
	});
});
