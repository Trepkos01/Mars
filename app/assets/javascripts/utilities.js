$(function() {
	$("#search_results").hide();

	//Preview the restaurant image on file selection for restaurants and meals.
	$('#restaurant_image').on('change', function(event) {
		previewImage(event);
	});
	
	$('#meal_image').on('change', function(event) {
		previewImage(event);
	});
	
	$('#search').on('click', function(event) {
		$("#logo").hide();
		$("#alert_div").hide();
		window.scrollTo(0, 0);
	});
	
	$('#search_button').on('click', function(event) {
		$("#logo").hide();
		$("#alert_div").hide();
		window.scrollTo(0, 0);
	});
	
	//If the <tr> table row has a data-link attribute, make the row clickable.
	$("tr[data-link]").click(function() {
		window.location =  $(this).data("link")
	})
	
	//If we're on the main index page aka the lat and long fields exist.
	if($('#lat').length && $('#lon').length){
		if("geolocation" in navigator) {
			navigator.geolocation.getCurrentPosition(setGeoLocationValues, couldNotGetLocation);
		} 
		else{
			couldNotGetLocation();
		}
	}
});

//Set the browser's lat/lng values to the action's form.
function setGeoLocationValues(position){
	$('#lat').val(position.coords.latitude);
	$('#lon').val(position.coords.longitude);
}

//For some reason we couldn't get the location.
function couldNotGetLocation(){
	$("#inform_user").html("We could not find your current location.");
}

//Take the chosen file and attempt to render it as an image in the preview <div>
function previewImage(event){
	var files = event.target.files;
    var image = files[0]
    var reader = new FileReader();
    reader.onload = function(file) {
      var img = new Image();
	  img.width = 150;
	  img.height = 100;
      img.src = file.target.result;
      $('#preview').html(img);
    }
    reader.readAsDataURL(image);
}

