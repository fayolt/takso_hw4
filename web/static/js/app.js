/*jshint esversion: 6*/
// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Vue from "vue";
import axios from 'axios';

new Vue({
  el: '#takso-app',
  data: {
    message: 'Hello there!',
    pickup_address: "J. Liivi 2",
    dropoff_address: "",
    map: null,
    geocoder: null
  },
  methods: {
      submitBookingRequest () {
        axios.post("/api/bookings", {pickup_address: this.pickup_address, 
          dropoff_address: this.dropoff_address})
        .then(response => {
          this.geocoder.geocode({address: response.data.taxi_location}, 
            (results, status) => {
              if (status === "OK" && results[0]) {
                var taxi_location = results[0].geometry.location;
                new google.maps.Marker({position: taxi_location, map: this.map, title: "Taxi"});
            }
          });
        })
        .catch(error => console.log(error));
      }
  },
  mounted () {
    navigator.geolocation.getCurrentPosition(
      position => {
        let loc = {lat: position.coords.latitude, lng: position.coords.longitude};
        this.geocoder = new google.maps.Geocoder();
        this.geocoder.geocode({location: loc}, 
          (results, status) => {
            if (status === "OK" && results[0])
            this.pickup_address = results[0].formatted_address;
          });
        this.map = new google.maps.Map(document.getElementById('map'), {zoom: 14, center: loc});
        new google.maps.Marker({position: loc, map: this.map, title: "Pickup address"});
      });
  }
});
