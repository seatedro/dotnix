{ ... }:

{
  services.redshift = {
    enable = true;

    # San Francisco
    latitude = "37.7792808";
    longitude = "-122.4192362";

    brightness = {
      day = "0.95";
      night = "0.75";
    };

    temperature = {
      day = 6000;
      night = 3200;
    };
  };
}

